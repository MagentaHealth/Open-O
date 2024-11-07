/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.hospitalReportManager;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.hospitalReportManager.dao.HRMCategoryDao;
import org.oscarehr.hospitalReportManager.dao.HRMSubClassDao;
import org.oscarehr.hospitalReportManager.model.HRMDocument;
import org.oscarehr.hospitalReportManager.model.HRMSubClass;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

public class HRMMappingAction extends DispatchAction {

	 private SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
	private static Logger log = MiscUtils.getLogger();
	 
	public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)  {

		HRMCategoryDao hrmCategoryDao = (HRMCategoryDao) SpringUtils.getBean(HRMCategoryDao.class);
		HRMSubClassDao hrmSubClassDao = (HRMSubClassDao) SpringUtils.getBean(HRMSubClassDao.class);
		
		if(!securityInfoManager.hasPrivilege(LoggedInInfo.getLoggedInInfoFromSession(request), "_admin", "r", null)) {
        	throw new SecurityException("missing required security object (_admin)");
        }
		
		try {
			if (request.getParameter("deleteMappingId") != null && request.getParameter("deleteMappingId").trim().length() > 0) {
				hrmSubClassDao.remove(Integer.parseInt(request.getParameter("deleteMappingId")));
				return mapping.findForward("success");
			}

			if (request.getParameter("fetchUnlinkedHRMs") != null && request.getParameter("fetchUnlinkedHRMs").trim().length() > 0) {
				generateUnlinkedHRMsFile(request, response);
				return null;
			}
			
			String className = request.getParameter("class"); 
			String subClass = request.getParameter("subclass");
			String mnemonic = request.getParameter("mnemonic");
			String description = request.getParameter("description");
			String sendingFacilityId = request.getParameter("sendingFacilityId");
			String categoryId = request.getParameter("category");


			HRMSubClass hrmSubClass = new HRMSubClass();
			hrmSubClass.setClassName(className);
			hrmSubClass.setSubClassName(subClass);
			hrmSubClass.setSendingFacilityId(sendingFacilityId);
			hrmSubClass.setSubClassMnemonic(mnemonic);
			hrmSubClass.setSubClassDescription(description);
			hrmSubClass.setHrmCategory(hrmCategoryDao.findById(Integer.parseInt(categoryId)).get(0));
			
			hrmSubClassDao.merge(hrmSubClass);
			request.setAttribute("success", true);
		} catch (Exception e) {
			MiscUtils.getLogger().error("Couldn't set up sub class mapping", e);
			request.setAttribute("success", false);
		}

		return mapping.findForward("success");
	}

	private void generateUnlinkedHRMsFile(HttpServletRequest request, HttpServletResponse response) {
		LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);

		// Retrieve hrmIds from the request
		String limitString = request.getParameter("limit");
		Integer limit = 0;
		if (limitString != null && !limitString.trim().isEmpty()) {
			limit = Integer.parseInt(limitString);
		} 

		// Pass the list to HRMUtil.processUnlinkedHRMs
		Map<String, List<HRMDocument>> hrmResults = HRMUtil.processUnlinkedHRMs(loggedInInfo, limit);

		response.setContentType("application/zip");
		response.setHeader("Content-Disposition", "attachment;filename=\"hrm_results.zip\"");

		// Get the base URL from the request
		String baseUrl = getBaseUrl(request);

		try (ZipOutputStream zos = new ZipOutputStream(response.getOutputStream());
			 PrintWriter writer = new PrintWriter(new OutputStreamWriter(zos, StandardCharsets.UTF_8))) {

			writeCSVToZip(zos, writer, "Successfully_Routed_to_Patient.csv", hrmResults.get("matchedToPatient"), baseUrl);
			writeCSVToZip(zos, writer, "Unmatched_Documents_Routed_to_NotPatient.csv", hrmResults.get("unmatchedToPatient"), baseUrl);
			writeCSVToZip(zos, writer, "Newborns_for_Manual_Review.csv", hrmResults.get("newbornsForManualReview"), baseUrl);
			writeCSVToZip(zos, writer, "Failed_to_Route_Invalid_Report_Path_or_Unparsable_Report.csv", hrmResults.get("failedDueToMissingOrUnparsableReport"), baseUrl);
			writeCSVToZip(zos, writer, "Failed_to_Route_Missing_DOB_or_Report_Date.csv", hrmResults.get("failedDueToMissingDOBOrReportDate"), baseUrl);

		} catch (IOException e) {
			log.error("Error generating HRM CSV files", e);
		}
	}

	private String getBaseUrl(HttpServletRequest request) {
		String scheme = request.getScheme();             // http or https
		String serverName = request.getServerName();     // e.g., emr3.magentahealth.ca
		int serverPort = request.getServerPort();        // e.g., 80, 443
		String contextPath = request.getContextPath();   // e.g., /oscar
	
		// Construct the base URL
		StringBuilder url = new StringBuilder();
		url.append(scheme).append("://").append(serverName);
	
		// Append the port if it's not the default port for the scheme
		if ((scheme.equals("http") && serverPort != 80) || (scheme.equals("https") && serverPort != 443)) {
			url.append(":").append(serverPort);
		}
	
		url.append(contextPath);
		return url.toString();
	}

	private void writeCSVToZip(ZipOutputStream zos, PrintWriter writer, String fileName, List<HRMDocument> documents, String baseUrl) throws IOException {
		ZipEntry entry = new ZipEntry(fileName);
		zos.putNextEntry(entry);
		writeHRMDocumentsToCSV(writer, documents, baseUrl);
		writer.flush();
		zos.closeEntry();
	}

	private void writeHRMDocumentsToCSV(PrintWriter writer, List<HRMDocument> hrmDocuments, String baseUrl) {
		// Write CSV header
		writer.println("HRM document ID,Link to HRM Document,Time Received,Report File,Report Date");

		// Write each HRMDocument's data
		if (hrmDocuments != null) {
			for (HRMDocument document : hrmDocuments) {
				writer.println((document.getId() != null ? document.getId() : "") + "," +
								baseUrl + "/hospitalReportManager/Display.do?id=" + document.getId() + "," +
							   (document.getTimeReceived() != null ? document.getTimeReceived() : "") + "," +
							   (document.getReportFile() != null ? document.getReportFile() : "") + "," +
							   (document.getReportDate() != null ? document.getReportDate() : ""));
			}
		}
	}

}
