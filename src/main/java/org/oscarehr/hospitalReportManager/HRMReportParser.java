package org.oscarehr.hospitalReportManager;

import java.io.File;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

//import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.cxf.helpers.FileUtils;
import org.apache.http.impl.cookie.DateParseException;
import org.apache.log4j.Logger;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Provider;
import org.oscarehr.hospitalReportManager.dao.HRMDocumentDao;
import org.oscarehr.hospitalReportManager.dao.HRMDocumentSubClassDao;
import org.oscarehr.hospitalReportManager.dao.HRMDocumentToDemographicDao;
import org.oscarehr.hospitalReportManager.dao.HRMDocumentToProviderDao;
import org.oscarehr.hospitalReportManager.model.HRMDocument;
import org.oscarehr.hospitalReportManager.model.HRMDocumentSubClass;
import org.oscarehr.hospitalReportManager.model.HRMDocumentToDemographic;
import org.oscarehr.hospitalReportManager.model.HRMDocumentToProvider;
import org.oscarehr.hospitalReportManager.xsd.OmdCds;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.xml.sax.SAXException;


public class HRMReportParser {

	private static Logger logger = MiscUtils.getLogger();
	private static OmdCds root = null;

	private HRMReportParser() {}


	public static HRMReport parseReport(String hrmReportFileLocation) {

		String fileData = null;
		if (hrmReportFileLocation != null) {
			try {
				//a lot of the parsers need to refer to a file and even when they provide functions like parse(String text)
				//it will not parse the same way because it will treat the text as a URL
				//so we take the lab and store them temporarily in a random filename in /tmp/oscar-sftp/
				File tmpXMLholder = new File(hrmReportFileLocation);

				fileData = FileUtils.getStringFromFile(tmpXMLholder);
				// Parse an XML document into a DOM tree.
				DocumentBuilder parser = DocumentBuilderFactory.newInstance().newDocumentBuilder();
				// Create a SchemaFactory capable of understanding WXS schemas.
				
				
				//logger.debug(XMLConstants.W3C_XML_SCHEMA_NS_URI);
				SchemaFactory factory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");//XMLConstants.W3C_XML_SCHEMA_NS_URI);

				// Load a WXS schema, represented by a Schema instance.
				Source schemaFile = new StreamSource(new File(SFTPConnector.OMD_directory + "report_manager_cds.xsd"));
				Schema schema = factory.newSchema(schemaFile); //new File(SFTPConnector.OMD_directory + "report_manager_cds.xsd"));

				JAXBContext jc = JAXBContext.newInstance("org.oscarehr.hospitalReportManager.xsd");
				Unmarshaller u = jc.createUnmarshaller();
				root = (OmdCds) u.unmarshal(tmpXMLholder);

				tmpXMLholder = null;

			} catch (SAXException e) {
				logger.error("SAX ERROR PARSING XML " + e);
			} catch (ParserConfigurationException e) {
				logger.error("PARSER ERROR PARSING XML " + e);
			} catch (JAXBException e) {
				// TODO Auto-generated catch block
				logger.error("error",e);
			}

			return new HRMReport(root, hrmReportFileLocation, fileData);
		}

		return null;
	}

	public static void addReportToInbox(HRMReport report) {
		HRMDocument document = new HRMDocument();

		document.setReportFile(report.getFileLocation());
		document.setReportStatus(report.getResultStatus());
		document.setReportType(report.getFirstReportClass());
		document.setTimeReceived(new Date());

		String reportFileData = report.getFileData();

		String noMessageIdFileData = reportFileData.replaceAll("<MessageUniqueID>.*?</MessageUniqueID>", "<MessageUniqueID></MessageUniqueID>");
		String noTransactionInfoFileData = reportFileData.replaceAll("<TransactionInformation>.*?</TransactionInformation>", "<TransactionInformation></TransactionInformation>");
		String noDemograhpicInfoFileData = reportFileData.replaceAll("<Demographics>.*?</Demographics>", "<Demographics></Demographics").replaceAll("<MessageUniqueID>.*?</MessageUniqueID>", "<MessageUniqueID></MessageUniqueID>");
		
		String noMessageIdHash = DigestUtils.md5Hex(noMessageIdFileData);
		String noTransactionInfoHash = DigestUtils.md5Hex(noTransactionInfoFileData);
		String noDemographicInfoHash = DigestUtils.md5Hex(noDemograhpicInfoFileData);

		document.setReportHash(noMessageIdHash);
		document.setReportLessTransactionInfoHash(noTransactionInfoHash);
		document.setReportLessDemographicInfoHash(noDemographicInfoHash);
		
		try {
	        document.setReportDate(HRMReportParser.getAppropriateDateFromReport(report));
        } catch (DateParseException e) {
	        MiscUtils.getLogger().error("Can't find report date on report", e);
        }
		
		// We're going to check to see if there's a match in the database already for either of these
		// report hash matches = duplicate report for same recipient
		// no transaction info hash matches = duplicate report, but different recipient
		HRMDocumentDao hrmDocumentDao = (HRMDocumentDao) SpringUtils.getBean("HRMDocumentDao");
		List<Integer> exactMatchList = hrmDocumentDao.findByHash(noMessageIdHash);
		
		if (exactMatchList == null || exactMatchList.size() == 0) {
			List<HRMDocument> sameReportDifferentRecipientReportList = hrmDocumentDao.findByNoTransactionInfoHash(noTransactionInfoHash);
			
			if (sameReportDifferentRecipientReportList != null && sameReportDifferentRecipientReportList.size() > 0) {
				HRMReportParser.routeReportToProvider(sameReportDifferentRecipientReportList.get(0), report);
			} else {
				// New report
				hrmDocumentDao.merge(document);
				
				HRMReportParser.routeReportToDemographic(report, document);
				HRMReportParser.doSimilarReportCheck(report, document);
				// Attempt a route to the provider listed in the report -- if they don't exist, note that in the record
				Boolean routeSuccess = HRMReportParser.routeReportToProvider(report, document.getId());
				if (!routeSuccess) {
					// Add the provider name to the list of unidentified providers for this report
					document.setUnmatchedProviders(document.getUnmatchedProviders() + "|" + report.getDeliverToUserIdLastName() + ", " + report.getDeliverToUserIdFirstName() + " (" + report.getDeliverToUserId() + ")");
					hrmDocumentDao.merge(document);
				}
				
				HRMReportParser.routeReportToSubClass(report, document.getId());
			}
		} else if (exactMatchList != null && exactMatchList.size() > 0) {
			// We've seen this one before.  Increment the counter on how many times we've seen it before
			HRMDocument existingDocument = hrmDocumentDao.findById(exactMatchList.get(0)).get(0);
			existingDocument.setNumDuplicatesReceived((existingDocument.getNumDuplicatesReceived() != null ? existingDocument.getNumDuplicatesReceived() : 0) + 1);
			
			hrmDocumentDao.merge(existingDocument);
		}
	}
	
	private static void routeReportToDemographic(HRMReport report, HRMDocument mergedDocument) {
	    // Search the demographics on the system for a likely match and route it to them automatically
		DemographicDao demographicDao = (DemographicDao) SpringUtils.getBean("demographicDao");
		
	    List<Demographic> matchingDemographicListByName = demographicDao.searchDemographic(report.getLegalName());
	    
	    if (matchingDemographicListByName.size() == 1) {
	    	// Found a match by name
	    	HRMReportParser.routeReportToDemographic(mergedDocument.getId().toString(), matchingDemographicListByName.get(0).getDemographicNo().toString());
	    } else {
	    	for (Demographic d : matchingDemographicListByName) {
	    		
	    		if (report.getHCN().equalsIgnoreCase(d.getHin())) { // Check health card no.
	    			HRMReportParser.routeReportToDemographic(mergedDocument.getId().toString(), d.getDemographicNo().toString());
	    			return;
	    		} else if (report.getGender().equalsIgnoreCase(d.getSex()) && report.getDateOfBirthAsString().equalsIgnoreCase(d.getBirthDayAsString())) { // Check dob & sex
	    			HRMReportParser.routeReportToDemographic(mergedDocument.getId().toString(), d.getDemographicNo().toString());
	    			return;
	    		}
	    	}
	    }
    }


	private static void doSimilarReportCheck(HRMReport report, HRMDocument mergedDocument) {
		HRMDocumentDao hrmDocumentDao = (HRMDocumentDao) SpringUtils.getBean("HRMDocumentDao");
		
		// Check #1: Identify if this is a report that we received before, but was sent to the wrong demographic
		List<Integer> parentReportList = hrmDocumentDao.findAllWithSameNoDemographicInfoHash(mergedDocument.getReportLessDemographicInfoHash());
		if (parentReportList != null && parentReportList.size() > 0) {
			for (Integer id : parentReportList) {
				if (id != null) {
					mergedDocument.setParentReport(id);
					hrmDocumentDao.merge(mergedDocument);
					return;
				}
			}
		}
		
		// Load all the reports for this demographic into memory -- check by name only
		List<HRMReport> thisDemoHrmReportList = HRMReportParser.loadAllReportsRoutedToDemographic(report.getLegalName());
		
		for (HRMReport loadedReport : thisDemoHrmReportList) {
			boolean hasSameReportContent = report.getFirstReportTextContent().equalsIgnoreCase(loadedReport.getFirstReportTextContent());
			boolean hasSameStatus = report.getResultStatus().equalsIgnoreCase(loadedReport.getResultStatus());
			boolean hasSameClass = report.getFirstReportClass().equalsIgnoreCase(loadedReport.getFirstReportClass());
			boolean hasSameDate = false;
			try {
	            hasSameDate = HRMReportParser.getAppropriateDateFromReport(report).equals(HRMReportParser.getAppropriateDateFromReport(loadedReport));
            } catch (DateParseException e) {
	            MiscUtils.getLogger().warn("Can't parse date on HRM report", e);
            }
            
            Integer threshold = 0;
            
            if (hasSameReportContent)
            	threshold += 100;
            else
            	threshold += 10;
            
            if (hasSameStatus)
            	threshold += 5;
            else
            	threshold += 10;
            
            if (hasSameClass)
            	threshold += 10;
            else
            	threshold += 10;
            
            if (hasSameDate)
            	threshold += 20;
            else
            	threshold += 5;
            
            if (threshold >= 50) {
            	// This is probably a changed report addressed to the same demographic, so set the parent id (as long as this isn't the same report) and we're done!
            	if (loadedReport.getHrmParentDocumentId() != null && loadedReport.getHrmDocumentId().intValue() != mergedDocument.getId().intValue()) {
            		mergedDocument.setParentReport(loadedReport.getHrmParentDocumentId());
            		hrmDocumentDao.merge(mergedDocument);
            	}
            }
		}
    }


	private static List<HRMReport> loadAllReportsRoutedToDemographic(String legalName) {
		DemographicDao demographicDao = (DemographicDao) SpringUtils.getBean("demographicDao");
		HRMDocumentToDemographicDao hrmDocumentToDemographicDao = (HRMDocumentToDemographicDao) SpringUtils.getBean("HRMDocumentToDemographicDao");
		HRMDocumentDao hrmDocumentDao = (HRMDocumentDao) SpringUtils.getBean("HRMDocumentDao");
		
	    List<Demographic> matchingDemographicListByName = demographicDao.searchDemographic(legalName);
	    
	    List<HRMReport> allRoutedReports = new LinkedList<HRMReport>();
	    
	    for (Demographic d : matchingDemographicListByName) {
	    	List<HRMDocumentToDemographic> matchingHrmDocumentList = hrmDocumentToDemographicDao.findByDemographicNo(d.getDemographicNo().toString());
	    	for (HRMDocumentToDemographic matchingHrmDocument : matchingHrmDocumentList) {
	    		HRMDocument hrmDocument = hrmDocumentDao.find(matchingHrmDocument.getHrmDocumentId());
	    		
	    		HRMReport hrmReport = HRMReportParser.parseReport(hrmDocument.getReportFile());
	    		hrmReport.setHrmDocumentId(hrmDocument.getId());
	    		hrmReport.setHrmParentDocumentId(hrmDocument.getParentReport());
	    		allRoutedReports.add(hrmReport);
	    	}
	    }
	    
	    return allRoutedReports;
	    
    }


	public static void routeReportToSubClass(HRMReport report, Integer reportId) {
		HRMDocumentSubClassDao hrmDocumentSubClassDao = (HRMDocumentSubClassDao) SpringUtils.getBean("HRMDocumentSubClassDao");
		
		if (report.getFirstReportClass().equalsIgnoreCase("Diagnostic Imaging Report") || report.getFirstReportClass().equalsIgnoreCase("Cardio Respiratory Report")) {
			List<List<Object>> subClassList = report.getAccompanyingSubclassList();
			
			for (List<Object> subClass : subClassList) {
				HRMDocumentSubClass newSubClass = new HRMDocumentSubClass();
				
				newSubClass.setSubClass((String) subClass.get(0));
				newSubClass.setSubClassMnemonic((String) subClass.get(1));
				newSubClass.setSubClassDescription((String) subClass.get(2));
				newSubClass.setSubClassDateTime((Date) subClass.get(3));
                
                newSubClass.setHrmDocumentId(reportId);
                
                hrmDocumentSubClassDao.merge(newSubClass);
			}
		} else {
			// There aren't subclasses on a Medical Records Report
		}
	}
	
	public static Date getAppropriateDateFromReport(HRMReport report) throws DateParseException {
		if (report.getFirstReportClass().equalsIgnoreCase("Diagnostic Imaging Report") || report.getFirstReportClass().equalsIgnoreCase("Cardio Respiratory Report")) {
			return ((Date) (report.getAccompanyingSubclassList().get(0).get(3)));
		}
		
		// Medical Records Report
		return report.getFirstReportEventTime().getTime();
	}

	public static boolean routeReportToProvider(HRMReport report, Integer reportId) {
		HRMDocumentToProviderDao hrmDocumentToProviderDao = (HRMDocumentToProviderDao) SpringUtils.getBean("HRMDocumentToProviderDao");
		ProviderDao providerDao = (ProviderDao) SpringUtils.getBean("providerDao"); 

		String providerNo = report.getDeliverToUserId().substring(1); // We have to remove the first "D"
		String providerLastName = report.getDeliverToUserIdLastName();
		String providerFirstName = report.getDeliverToUserIdFirstName();

		Provider sendToProvider = providerDao.getProvider(providerNo);
		List<Provider> sendToProviderList = new LinkedList<Provider>();
		if (sendToProvider == null) {
			// Check to see if there's a match with first and last name
			List<Provider> potentialProviderMatchList = providerDao.getProviderLikeFirstLastName(providerFirstName, providerLastName);
			if (potentialProviderMatchList != null && potentialProviderMatchList.size() >= 1) {
				for (Provider p : potentialProviderMatchList)
					sendToProviderList.add(p);
			}
		} else {
			sendToProviderList.add(sendToProvider);
		}

		for (Provider p : sendToProviderList) {
			HRMDocumentToProvider providerRouting = new HRMDocumentToProvider();
			providerRouting.setHrmDocumentId(reportId.toString());

			providerRouting.setProviderNo(p.getProviderNo());
			providerRouting.setSignedOff(0);

			hrmDocumentToProviderDao.merge(providerRouting);
		}
		
		return sendToProviderList.size() > 0;

	}
	
	public static void setDocumentParent(String reportId, String childReportId) {
		HRMDocumentDao hrmDocumentDao = (HRMDocumentDao) SpringUtils.getBean("HRMDocumentDao");
		try {
			HRMDocument childDocument = hrmDocumentDao.find(childReportId);
			childDocument.setParentReport(Integer.parseInt(reportId));
			
			hrmDocumentDao.merge(childDocument);
		} catch (Exception e) {
			MiscUtils.getLogger().error("Can't set HRM document parent", e);
		}
	}
	
	public static void routeReportToProvider(HRMDocument originalDocument, HRMReport newReport) {
		routeReportToProvider(newReport, originalDocument.getId());
	}

	public static void routeReportToProvider(String reportId, String providerNo) {
		HRMDocumentToProviderDao hrmDocumentToProviderDao = (HRMDocumentToProviderDao) SpringUtils.getBean("HRMDocumentToProviderDao");
		HRMDocumentToProvider providerRouting = new HRMDocumentToProvider();

		providerRouting.setHrmDocumentId(reportId);
		providerRouting.setProviderNo(providerNo);

		hrmDocumentToProviderDao.merge(providerRouting);

	}

	public static void signOffOnReport(String providerRoutingId, Integer signOffStatus) {
		HRMDocumentToProviderDao hrmDocumentToProviderDao = (HRMDocumentToProviderDao) SpringUtils.getBean("HRMDocumentToProviderDao");
		HRMDocumentToProvider providerRouting = hrmDocumentToProviderDao.find(providerRoutingId);

		if (providerRouting != null) {
			providerRouting.setSignedOff(signOffStatus);
			providerRouting.setSignedOffTimestamp(new Date());
			hrmDocumentToProviderDao.merge(providerRouting);
		}
	}

	public static void routeReportToDemographic(String reportId, String demographicNo) {
		HRMDocumentToDemographicDao hrmDocumentToDemographicDao = (HRMDocumentToDemographicDao) SpringUtils.getBean("HRMDocumentToDemographicDao");

		HRMDocumentToDemographic demographicRouting = new HRMDocumentToDemographic();
		demographicRouting.setDemographicNo(demographicNo);
		demographicRouting.setHrmDocumentId(reportId);
		demographicRouting.setTimeAssigned(new Date());

		hrmDocumentToDemographicDao.merge(demographicRouting);

	}
}