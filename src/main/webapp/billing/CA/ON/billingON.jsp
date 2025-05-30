
<%--

    Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

--%>
<!DOCTYPE html>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ page errorPage="errorpage.jsp"%>

<%@page import="java.util.*,java.net.*,java.sql.*,oscar.*,oscar.util.*,oscar.appt.*"%>
<%@page import="oscar.oscarBilling.ca.on.data.*"%>
<%@page import="oscar.oscarBilling.ca.on.pageUtil.*"%>
<%@page import="oscar.oscarBilling.ca.bc.decisionSupport.BillingGuidelines"%>
<%@page import="org.oscarehr.common.dao.CSSStylesDAO, org.oscarehr.common.model.ProviderPreference, org.oscarehr.common.model.CssStyle"%>
<%@page import="org.oscarehr.common.dao.BillingServiceDao, org.oscarehr.common.model.BillingService"%>
<%@page import="org.oscarehr.common.dao.ClinicNbrDao, org.oscarehr.common.model.ClinicNbr"%>
<%@page import="org.oscarehr.common.dao.CtlBillingTypeDao, org.oscarehr.common.model.CtlBillingType"%>
<%@page import="org.oscarehr.common.dao.CtlBillingServiceDao, org.oscarehr.common.model.CtlBillingService"%>
<%@page import="org.oscarehr.common.dao.CtlBillingServicePremiumDao, org.oscarehr.common.model.CtlBillingServicePremium"%>
<%@page import="org.oscarehr.common.dao.DiagnosticCodeDao, org.oscarehr.common.model.CtlDiagCode, org.oscarehr.common.model.DiagnosticCode"%>
<%@page import="org.oscarehr.common.dao.DxresearchDAO, org.oscarehr.common.model.Dxresearch"%>
<%@page import="org.oscarehr.common.dao.MyGroupDao, org.oscarehr.common.model.MyGroup"%>
<%@page import="org.oscarehr.common.dao.OscarAppointmentDao, org.oscarehr.common.model.Appointment"%>
<%@page import="org.oscarehr.common.dao.ProfessionalSpecialistDao, org.oscarehr.common.model.ProfessionalSpecialist"%>
<%@page import="org.oscarehr.common.dao.UserPropertyDAO, org.oscarehr.common.model.UserProperty"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao, org.oscarehr.common.model.ProviderPreference"%>
<%@page import="org.oscarehr.decisionSupport.model.DSConsequence"%>
<%@page import="org.oscarehr.web.admin.ProviderPreferencesUIBean"%>
<%@page import="org.oscarehr.util.SpringUtils"%>

<%@page import="org.oscarehr.managers.DemographicManager,org.oscarehr.billing.CA.filters.CodeFilterManager"%>

<%
	ProfessionalSpecialistDao professionalSpecialistDao = SpringUtils.getBean(ProfessionalSpecialistDao.class);
	DxresearchDAO dxresearchDao = SpringUtils.getBean(DxresearchDAO.class);
	UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);
    LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
%>
<jsp:useBean id="providerBean" class="java.util.Properties"
	scope="session" />
<%
			if (session.getAttribute("user") == null) {
				response.sendRedirect("${ pageContext.request.contextPath }/logout.jsp");
			}
                        oscar.OscarProperties oscarVariables = oscar.OscarProperties.getInstance();

			String user_no = (String) session.getAttribute("user");
			String providerview = request.getParameter("providerview") == null ? "" : request.getParameter("providerview");
			String asstProvider_no = "", color = "", premiumFlag = "", service_form = "";
			String sql = null;
			ResultSet rs = null;
			String sql0 = null;
			ResultSet rs0 = null;
			String strToday = UtilDateUtilities.getToday("yyyy-MM-dd");
			boolean bSingleClick = oscarVariables.getProperty("onBillingSingleClick", "").equals("yes") ? true : false;
			boolean bHospitalBilling = false;
			String clinicview = bHospitalBilling ? oscarVariables.getProperty("clinic_hospital", "") : oscarVariables.getProperty("clinic_view", "");
			String clinicNo = oscarVariables.getProperty("clinic_no", "").trim();
			String visitType = bHospitalBilling ? "02" : oscarVariables.getProperty("visit_type", "");

			if (visitType.startsWith("00") || visitType.equals(""))	clinicview = "0000";
			String appt_no = request.getParameter("appointment_no");
                        String billReferenceDate;
                        if( appt_no != null && appt_no.compareTo("0") == 0 ) {
                            billReferenceDate = request.getParameter("service_date")!=null? request.getParameter("service_date"):strToday;
                        }
                        else {
                           billReferenceDate = request.getParameter("appointment_date");
                        }
			String demoname = request.getParameter("demographic_name");
			String demo_no = request.getParameter("demographic_no");
			String apptProvider_no = request.getParameter("apptProvider_no");
			String assgProvider_no = request.getParameter("assgProvider_no");
			String demoSex = request.getParameter("DemoSex");
			String m_review = request.getParameter("m_review")!=null ? request.getParameter("m_review") : "";
			String ctlBillForm = request.getParameter("billForm");
			String curBillForm = request.getParameter("curBillForm");

			String provider_no;
            if( apptProvider_no.equalsIgnoreCase("none") ) {
                     provider_no = user_no;
 			}
			else {
     			provider_no = apptProvider_no;
 			}
            CodeFilterManager codeFilterManager = SpringUtils.getBean(CodeFilterManager.class);
            DemographicManager demographicManager = SpringUtils.getBean(DemographicManager.class);
			Demographic demo = demographicManager.getDemographic(loggedInInfo, demo_no);
			java.util.Date filterDate = ConversionUtils.fromDateString(billReferenceDate);
			if(request.getParameter("start_time") != null){
	   			filterDate =  ConversionUtils.fromTimestampString(billReferenceDate+" "+request.getParameter("start_time"));
 			}

			//load patientDx
			List<Dxresearch> dxList = dxresearchDao.getByDemographicNo(Integer.parseInt(demo_no));
			List<String> patientDx = new ArrayList<String>();
			for (Dxresearch dx : dxList) {
				if ("icd9".equals(dx.getCodingSystem())) patientDx.add(dx.getDxresearchCode());
			}

			//load codelist to add to patientDx
			UserProperty codeList = userPropertyDao.getProp(UserProperty.CODE_TO_ADD_PATIENTDX);
			String codeToAddPatientDx = codeList!=null ? codeList.getValue() : "";
			codeToAddPatientDx = codeToAddPatientDx!=null ? codeToAddPatientDx.trim() : "";

			codeList = userPropertyDao.getProp(UserProperty.CODE_TO_MATCH_PATIENTDX);
			String codeToMatchPatientDx = codeList!=null ? codeList.getValue() : "";
			codeToMatchPatientDx = codeToMatchPatientDx!=null ? codeToMatchPatientDx.trim() : "";

            //check for management fee code eligibility
            StringBuilder billingRecomendations = new StringBuilder();
            try{
            	List<DSConsequence> list = BillingGuidelines.getInstance().evaluateAndGetConsequences(loggedInInfo, request.getParameter("demographic_no"), (String) request.getSession().getAttribute("user"));

            	for (DSConsequence dscon : list){
                     if (dscon.getConsequenceStrength().equals(DSConsequence.ConsequenceStrength.warning)) {
                        billingRecomendations.append(dscon.getText()).append("<br/>");
                     }
                }
            }catch(Exception e){
                    MiscUtils.getLogger().error("Error", e);
            }

            ProviderPreferenceDao preferenceDao = SpringUtils.getBean(ProviderPreferenceDao.class);
            ProviderPreference preference = null;
            preference=ProviderPreferencesUIBean.getProviderPreferenceByProviderNo(provider_no);






			GregorianCalendar now = new GregorianCalendar();
			int curYear = now.get(Calendar.YEAR);
			int curMonth = (now.get(Calendar.MONTH) + 1);
			int curDay = now.get(Calendar.DAY_OF_MONTH);
			int dob_year = 0, dob_month = 0, dob_date = 0, age = 0;

			String msg = "The default unit and @ value is 1.";
			String action = "edit";
			Properties propHist = null;
			Vector vecHist = new Vector();

			if (request.getParameter("xml_provider") != null) {
				providerview = request.getParameter("xml_provider");
				if(providerview.indexOf("|")!=-1)
					providerview = providerview.substring(0,providerview.indexOf("|"));
			}

			// get patient's detail
			String errorFlag = "";
			String warningMsg = "", errorMsg = "";
			String r_doctor = "", r_doctor_ohip = "";
			String demoFirst = "", demoLast = "", demoHIN = "", demoVer = "", demoDOB = "", demoDOBYY = "", demoDOBMM = "", demoDOBDD = "", demoHCTYPE = "";
			String family_doctor = "";
			String roster_status = "";
			String referSpet = "";
			// last_name,first_name,dob,hin,ver,hc_type,sex,family_doctor
			JdbcBillingPageUtil tdbObj = new JdbcBillingPageUtil();
			List demoL = tdbObj.getPatientCurBillingDemographic(loggedInInfo, demo_no);

			//String sql = "select * from demographic where demographic_no=" + demo_no;
			//ResultSet rs = dbObj.searchDBRecord(sql);
			//while (rs.next()) {
				demoLast = (String)demoL.get(0); //rs.getString("last_name");
				demoFirst = (String)demoL.get(1); //rs.getString("first_name");
				demoDOB = (String)demoL.get(2);
				demoHIN = (String)demoL.get(3); //rs.getString("hin");
				demoVer = (String)demoL.get(4); //rs.getString("ver");
				demoHCTYPE = (String)demoL.get(5); //rs.getString("hc_type") == null ? "" : rs.getString("hc_type");
				demoSex = (String)demoL.get(6); //rs.getString("sex");
				family_doctor = (String)demoL.get(7);
				assgProvider_no = (String)demoL.get(8);
				roster_status = (String)demoL.get(9);

				if (demoHCTYPE.compareTo("") == 0 || demoHCTYPE == null || demoHCTYPE.length() < 2) {
					demoHCTYPE = "ON";
				} else {
					demoHCTYPE = demoHCTYPE.substring(0, 2).toUpperCase();
				}

				if ("".equals(family_doctor)) {
					r_doctor = "N/A";
					r_doctor_ohip = "000000";
				} else {
					r_doctor = SxmlMisc.getXmlContent(family_doctor, "rd") == null ? "" : SxmlMisc
							.getXmlContent(family_doctor, "rd");
					r_doctor_ohip = SxmlMisc.getXmlContent(family_doctor, "rdohip") == null ? ""
							: SxmlMisc.getXmlContent(family_doctor, "rdohip");
					referSpet = tdbObj.getReferDocSpet(r_doctor_ohip);
				}

				if (demoHIN.equals("")) {
					warningMsg += "<b><div class='alert alert-error'>Warning: The patient does not have a valid HIN. </div></b>";
				}
				if (r_doctor_ohip != null && r_doctor_ohip.length() > 0 && r_doctor_ohip.length() != 6) {
					warningMsg += "<div class='alert alert error'>Warning: the referral doctor's no is wrong. </div>";
				}
				if (StringUtils.isBlank(demoDOB) || demoDOB.length() != 8) {
					errorFlag = "1";
					errorMsg = errorMsg
							+ "<b><div class='alert alert error'>Error: The patient does not have a valid DOB. </div></b>";
				}
			//}





			// get patient's billing history
			boolean bFirst = true;
			JdbcBillingReviewImpl hdbObj = new JdbcBillingReviewImpl();
			List aL = hdbObj.getBillingHist(demo_no, 5,0, null);

			Vector vecHistD = new Vector();
			if (aL.size()>0) {
				BillingClaimHeader1Data obj = (BillingClaimHeader1Data) aL.get(0);
				BillingItemData iobj = (BillingItemData) aL.get(1);

				propHist = new Properties();

				//propHist.setProperty("billing_no", "" + rs.getInt("id"));
				propHist.setProperty("visitdate", obj.getAdmission_date() == null ? "" : obj.getAdmission_date()); // admission date
				//propHist.setProperty("billing_date", rs.getString("billing_date")); // service date
				//propHist.setProperty("update_date", rs.getString("timestamp")); // create date
				propHist.setProperty("visitType", obj.getVisittype());
				propHist.setProperty("clinic_ref_code", obj.getFacilty_num());
				vecHist.add(propHist);
				//propHist.setProperty("service_code", serCode);
				propHist.setProperty("diagnostic_code", iobj.getDx());
				vecHistD.add(propHist);
			}

			// display the fixed billing part
			// Retrieving Provider
			Vector vecProvider = new Vector();
			Properties propT = null;
			ProviderDao dao = SpringUtils.getBean(ProviderDao.class);
			for(Provider p : dao.getProvidersWithNonEmptyCredentials()) {
				propT = new Properties();
				propT.setProperty("last_name", p.getLastName());
				propT.setProperty("first_name", p.getFirstName());
				propT.setProperty("proOHIP", p.getProviderNo() + "|" + p.getOhipNo());
				vecProvider.add(propT);
			}

			// set default value
			// use parameter -> history record
			ProfessionalSpecialist specialist = professionalSpecialistDao.getByReferralNo(r_doctor_ohip);
            if(specialist != null) {
            	r_doctor = specialist.getLastName() + "," + specialist.getFirstName();
            }

			String paraName = request.getParameter("dxCode");
            if(paraName==null || paraName.equals("")) {
            	// get the default diagnostic code
                if(preference!=null) {
                    paraName = preference.getDefaultDxCode();
            	}
            }
            String dxCode = getDefaultValue(paraName, vecHistD, "diagnostic_code");


			//visitType
			paraName = request.getParameter("xml_visittype");

			String xml_visittype = getDefaultValue(paraName, vecHist, "visitType");
			//xml_visittype = paraName != null && !"".equals(paraName)? paraName : "00" ;

			if (!"".equals(xml_visittype)) {
				visitType = xml_visittype;
			} else {
				visitType = visitType == null ? "" : visitType;
			}

            String defaultServiceType = "";

			if (curBillForm!=null) {
			    // user picks a bill form from browser
			    ctlBillForm = curBillForm;
			} else {
                            //check if patient's roster status determines which billing form to display (this superceeds provider preference)
                            String rosterStatus = demo.getRosterStatus();

                            CtlBillingServiceDao ctlBillingServiceDao = SpringUtils.getBean(CtlBillingServiceDao.class);
                            List<CtlBillingService> ctlBillSrvList = ctlBillingServiceDao.findByServiceTypeId(rosterStatus);

                            if (!ctlBillSrvList.isEmpty() && !rosterStatus.isEmpty()) {
                                ctlBillForm = ctlBillSrvList.get(0).getServiceType();
                            }
                            else {
                                // check user preference to show a bill form
                                ProviderPreferenceDao providerPreferenceDao=SpringUtils.getBean(ProviderPreferenceDao.class);
                                ProviderPreference providerPreference=null;

                                //use the appointment provider's preferences first if we can
                                //otherwise, use the preferences of the logged in user
                                if( apptProvider_no.equalsIgnoreCase("none") ) {
                                    providerPreference = providerPreferenceDao.find(user_no);
                                } else {
                                    providerPreference = providerPreferenceDao.find(apptProvider_no);
                                }


                                if (providerPreference!=null) {
                                    defaultServiceType = providerPreference.getDefaultServiceType();
                                }

                                if ((roster_status.equals("QU - Quebec")||roster_status.equals("FS")) && !defaultServiceType.equals("RN")) { defaultServiceType = "PRI"; }
                                if (defaultServiceType != null && !defaultServiceType.isEmpty() && !defaultServiceType.equals("no")) {
									ctlBillForm = providerPreference.getDefaultServiceType();
                                } else {
                                        //check if there is a group preference for default billing
                                        MyGroupDao myGroupDao = SpringUtils.getBean(MyGroupDao.class);
                                        List<MyGroup> myGroups = myGroupDao.getProviderGroups(provider_no);
                                        String groupBillForm = "";
                                        for (MyGroup group : myGroups) {
                                            groupBillForm = group.getDefaultBillingForm();
                                            if (groupBillForm != null && !groupBillForm.isEmpty()) {
                                                ctlBillForm = groupBillForm;
                                                break;
                                            }
                                        }

                                        if (ctlBillForm == null || ctlBillForm.isEmpty()) {
                                            // check oscar.properties to show a default bill form
                                            String dv = OscarProperties.getInstance().getProperty("default_view");
                                            if (dv!=null) ctlBillForm = dv;
                                        }
                                }
                            }
			}

			if( ctlBillForm == null ) {
				ctlBillForm = "";
			}

			if((visitType.startsWith("02") || visitType.startsWith("04")) && !defaultServiceType.equals("RN")){
				ctlBillForm = "MIP"; // This is a reference to the "MIP" ctl_billingservice.servicetype, blank service type if not exist
            }
            if ((roster_status.equals("QU - Quebec")||roster_status.equals("FS")) && !defaultServiceType.equals("RN")) {
                ctlBillForm = "PRI";
            } // "PRI" ctl_billingservice.servicetype, blank if not exist

			paraName = request.getParameter("xml_location");
			String xml_location = getDefaultValue(paraName, vecHist, "clinic_ref_code");
			xml_location = paraName != null && !"".equals(paraName)? paraName : "0000";
			if (!"".equals(xml_location)) {
				clinicview = xml_location;
			} else {
				clinicview = clinicview == null ? "" : clinicview;
			}

			//Read default clinic_view from oscar.properties file
			String cv = OscarProperties.getInstance().getProperty("clinic_view");
			if (cv!=null) clinicview = cv;

			String visitdate = null;
			paraName = request.getParameter("xml_vdate");
			String xml_vdate = getDefaultValue(paraName, vecHist, "visitdate");
			xml_vdate = request.getParameter("xml_vdate")!=null? paraName : "" ;
			if (!"".equals(xml_vdate)) {
				visitdate = xml_vdate;
			} else {
				visitdate = visitdate == null ? "" : visitdate;
			}

			// get billing dx/form info
			HashMap<String, ArrayList<Properties>> billingServiceCodesMap = new HashMap<String, ArrayList<Properties>>();
            ArrayList<String> listServiceType = new ArrayList<String>();
            HashMap<String, String> titleMap = new HashMap<String, String>();
            Properties propPremium = new Properties();
            String serviceCode, serviceDesc, serviceValue, servicePercentage, serviceType, displayStyle, serviceDisp = "";
            String headerTitle1 = "", headerTitle2 = "", headerTitle3 = "";

            CSSStylesDAO cssStylesDao = SpringUtils.getBean(CSSStylesDAO.class);
			CssStyle cssStyle;
			String styleId;

            boolean sliFlag = false;

            CtlBillingServiceDao cbsDao = SpringUtils.getBean(CtlBillingServiceDao.class);
            BillingServiceDao bDao = SpringUtils.getBean(BillingServiceDao.class);
            CtlBillingServicePremiumDao pDao = SpringUtils.getBean(CtlBillingServicePremiumDao.class);

            for(Object[] i : cbsDao.findServiceTypesByStatus("A")) {
                    ArrayList<Properties> listGroup1 = new ArrayList<Properties>();
                    ArrayList<Properties> listGroup2 = new ArrayList<Properties>();
                    ArrayList<Properties> listGroup3 = new ArrayList<Properties>();

                    String ctlcode = String.valueOf(i[1]);
                    String ctlcodename = String.valueOf(i[0]);

                    listServiceType.add(ctlcode);

			for(Object[] o : bDao.findBillingServiceAndCtlBillingServiceByMagic(ctlcode, "Group1", ConversionUtils.fromDateString(billReferenceDate))) {
				BillingService b = (BillingService) o[0];
				CtlBillingService c = (CtlBillingService) o[1];

				if(!codeFilterManager.isCodeValid(b.getServiceCode(), null, false, filterDate, demo)){
					continue;
				}

				propT = new Properties();
				propT.setProperty("serviceCode", b.getServiceCode() );
				propT.setProperty("serviceDesc", b.getDescription() == null ? "N/A" : b.getDescription());
				propT.setProperty("serviceDisp", noNull(b.getValue()));
				propT.setProperty("servicePercentage", noNull(b.getPercentage()));
				propT.setProperty("serviceType", c.getServiceType());
                propT.setProperty("serviceTypeName", c.getServiceGroupName());
                styleId = null;
                if(b != null && b.getDisplayStyle() != null) {
                	styleId = "" + b.getDisplayStyle();
                	cssStyle = cssStylesDao.find(b.getDisplayStyle());
                	propT.setProperty("displaystyle", cssStyle.getStyle());
                }
                else {
                	propT.setProperty("displaystyle", "");
                }

                propT.setProperty("serviceSLI",  "" + b.getSliFlag());
               	titleMap.put("group1_".concat(ctlcode), c.getServiceGroupName());

                listGroup1.add(propT);
			}

			if (listGroup1.size() > 0) {
				List<String> serviceCodes = new ArrayList<String>();
				for (int ii = 0; ii < listGroup1.size(); ii++) {
					serviceCodes.add(listGroup1.get(ii).getProperty("serviceCode"));
				}

				for(CtlBillingServicePremium p : pDao.findByServceCodes(serviceCodes)) {
					propPremium.setProperty(p.getServiceCode(), "A");
				}
			}
			billingServiceCodesMap.put("group1_".concat(ctlcode),listGroup1);

			for(Object[] o : bDao.findBillingServiceAndCtlBillingServiceByMagic(ctlcode, "Group2", ConversionUtils.fromDateString(billReferenceDate))) {
				BillingService b = (BillingService) o[0];
				CtlBillingService c = (CtlBillingService) o[1];

				if(!codeFilterManager.isCodeValid(b.getServiceCode(), null, false, filterDate, demo)){
					continue;
				}

				propT = new Properties();

				propT.setProperty("serviceCode", b.getServiceCode() );
				propT.setProperty("serviceDesc", b.getDescription());
				propT.setProperty("serviceDisp", b.getValue());
				propT.setProperty("servicePercentage", noNull(b.getPercentage()));
				propT.setProperty("serviceType", c.getServiceType());
                propT.setProperty("serviceTypeName", c.getServiceGroupName());
                styleId = null;
                if(b != null && b.getDisplayStyle() != null) {
                	styleId = "" + b.getDisplayStyle();
                	cssStyle = cssStylesDao.find(b.getDisplayStyle());
                	propT.setProperty("displaystyle", cssStyle.getStyle());
                }
                else {
                	propT.setProperty("displaystyle", "");
                }

                propT.setProperty("serviceSLI", "" + b.getSliFlag());
                titleMap.put("group2_".concat(ctlcode), c.getServiceGroupName());

                listGroup2.add(propT);

			}

			if (listGroup2.size() > 0) {
				List<String> serviceCodes = new ArrayList<String>();
				for (int ii = 0; ii < listGroup2.size(); ii++) {
					serviceCodes.add(listGroup2.get(ii).getProperty("serviceCode"));
				}

				for(CtlBillingServicePremium p : pDao.findByServceCodes(serviceCodes)) {
					propPremium.setProperty(p.getServiceCode(), "A");
				}
			}

            billingServiceCodesMap.put("group2_".concat(ctlcode),listGroup2);


            for(Object[] o : bDao.findBillingServiceAndCtlBillingServiceByMagic(ctlcode, "Group3", ConversionUtils.fromDateString(billReferenceDate))) {
				BillingService b = (BillingService) o[0];
				CtlBillingService c = (CtlBillingService) o[1];

				if(!codeFilterManager.isCodeValid(b.getServiceCode(), null, false, filterDate, demo)){
					continue;
				}

				propT = new Properties();

				propT.setProperty("serviceCode", b.getServiceCode() );
				propT.setProperty("serviceDesc", b.getDescription());
				propT.setProperty("serviceDisp", b.getValue());
				propT.setProperty("servicePercentage", noNull(b.getPercentage()));
				propT.setProperty("serviceType", c.getServiceType());
                propT.setProperty("serviceTypeName", c.getServiceGroupName());
                styleId = null;
                if(b != null && b.getDisplayStyle() != null) {
                	styleId = "" + b.getDisplayStyle();
                	cssStyle = cssStylesDao.find(b.getDisplayStyle());
                	propT.setProperty("displaystyle", cssStyle.getStyle());
                }
                else {
                	propT.setProperty("displaystyle", "");
                }

                propT.setProperty("serviceSLI", "" + b.getSliFlag());
                titleMap.put("group3_".concat(ctlcode), c.getServiceGroupName());

                listGroup3.add(propT);

			}

            if (listGroup3.size() > 0) {
				List<String> serviceCodes = new ArrayList<String>();
				for (int ii = 0; ii < listGroup3.size(); ii++) {
					serviceCodes.add(listGroup3.get(ii).getProperty("serviceCode"));
				}

				for(CtlBillingServicePremium p : pDao.findByServceCodes(serviceCodes)) {
					propPremium.setProperty(p.getServiceCode(), "A");
				}
			}

            billingServiceCodesMap.put("group3_".concat(ctlcode),listGroup3);

            }

           CtlBillingTypeDao tDao = SpringUtils.getBean(CtlBillingTypeDao.class);
           String defaultBillType = "";
           for(CtlBillingType t : tDao.findByServiceType(ctlBillForm)){
            	defaultBillType = t.getBillType();
           }


			// create msg
			msg += errorMsg + warningMsg;
%>


<%@page import="org.oscarehr.common.dao.SiteDao"%>
<%@page import="org.oscarehr.common.model.Site"%>
<%@page import="org.oscarehr.common.model.Provider"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="org.oscarehr.common.dao.ProviderPreferenceDao"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.common.model.ProviderPreference"%>
<%@ page import="org.owasp.encoder.Encode" %>
<html>
<head>
<title>Ontario Billing</title>

<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="${ pageContext.request.contextPath }/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">


<style type="text/css">
<!--
.demo1 {
	color: #000033;
	background-color: lightgray;
	position: absolute;
	top: 50px;
	left: 170px;
	width: 190px;
	height: 80px;
	z-index: 99;
	visibility: hidden;
}
.demo1 th{
	background-color: silver;

}
.demo1 td{
	text-align:center;

}
-->
select, input[type="text"] {
	margin-bottom:0px;
}
.border1, .border1 th, .border1 td {
    border: 1px solid lightgray

}
</style>

<!-- calendar stylesheet -->
<link rel="stylesheet" type="text/css" media="all"
	href="${ pageContext.request.contextPath }/share/calendar/calendar.css" title="win2k-cold-1" />
<!-- main calendar program -->
<script type="text/javascript" src="${ pageContext.request.contextPath }/share/calendar/calendar.js"></script>
<!-- language for the calendar -->
<script src="${ pageContext.request.contextPath }/share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>
<!-- the following script defines the Calendar.setup helper function, which makes
       adding a calendar a matter of 1 or 2 lines of code. -->
<script type="text/javascript"
	src="${ pageContext.request.contextPath }/share/calendar/calendar-setup.js"></script>

<script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>

<script type="text/javascript" language="JavaScript">
    jQuery.noConflict();
</script>
<!-- to load for example /oscar/js/custom/ocean/global.js and /oscar/js/custom/ocean/billing.js although those are not present in stock -->
<oscar:customInterface section="billing"/>
<script>

function gotoBillingOB() {
    if(self.location.href.lastIndexOf("?") > 0) {
	a = self.location.href.substring(self.location.href.lastIndexOf("?"));
    }
    self.location.href = "billingOB.jsp" + a ;
}

function findObj(n, d) { //v4.0
    var p,i,x;
    if(!d) d=document;
    if((p=n.indexOf("?"))>0&&parent.frames.length) {
	d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);
    }
    if(!(x=d[n])&&d.all) x=d.all[n];
    for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
    for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=findObj(n,d.layers[i].document);
    if(!x && document.getElementById) x=document.getElementById(n);
    return x;
}

function showHideLayers() { //v3.0
    var i,p,v,obj,args=showHideLayers.arguments;
    for (i=0; i<(args.length-2); i+=3) {
	if ((obj=findObj(args[i]))!=null) {
	    v=args[i+2];
	    if (obj.style) {
		obj=obj.style;
		v=(v=='show')?'visible':(v='hide')?'hidden':v;
	    }
	    obj.visibility=v;
	}
    }
}

function onNext() {
	var codeToAddStr = "<%=codeToAddPatientDx%>";
	var codeToMatchStr = "<%=codeToMatchPatientDx%>";

	var codeToAdd = codeToAddStr.split(",");
	var codeToMatch = {};
	if (codeToMatchStr!="") {
		var codeToMatchArr = codeToMatchStr.split(",");
		for (var i=0; i<codeToMatchArr.length; i++) {
			var codeMatch = codeToMatchArr[i].split(":");
			codeToMatch[codeMatch[0]] = codeMatch[1];
		}
	}

	var dxCode = document.titlesearch.dxCode.value;
	var codeMatch = codeToMatch[dxCode];
	if (codeToAdd.indexOf(dxCode)>=0 || codeMatch!=null) {
		var dxCodeMatch = codeMatch==null ? dxCode : codeMatch;
<%for (String pcode : patientDx) {%>
		if (dxCodeMatch==<%=pcode%>) dxCode = -1;
<%}%>
		if (dxCode!=-1 && codeMatch!=null) {
			document.titlesearch.codeMatchToPatientDx.value = codeMatch;
		}
	} else {
		dxCode = -1;
	}

    var ret = true;
    if (!checkAllDates()) {
    	ret = false;
    }else if(!checkServicePercent()){
    	ret = false;
    	alert("Please enter a decimal number in the service code percent textbox!");
    } else if (!existServiceCode() && document.forms[0].services_checked.value<=0) {
	    ret = false;
	    alert("You haven't selected any billing item yet!");
	}
	else if (!checkSli()) {
		ret = false;
		alert("You have selected billing codes that require an SLI code but have not provided an SLI code.");
	}
	else if (document.forms[0].dxCode.value=="") {
	    ret = confirm("You didn't enter a diagnostic code in the Dx box. Continue?");
	    if (!ret) document.forms[0].dxCode.focus();
	}
	else if (dxCode!=-1) {
    	var codeDesc = document.getElementById("code_desc").innerHTML.trim();
    	var yes = confirm("Add \""+codeDesc+"\"("+dxCode+") to patient's disease registry?\n(OK=Yes, Cancel=No)");
    	if (yes) document.titlesearch.addToPatientDx.value = "yes";
    }
    return ret;
}

function checkServicePercent() {
	var ret = true;
	var regInt = /^-?\d+\.\d+$/;
	jQuery("input[id^='serviceAt'][value!='']").each(function() {
		var val = this.value.trim();
		if (val.length > 0 && !regInt.test(val)) {
			ret = false;
			return false;
		}
	});
	return ret;
}

function checkSli() {
	var needsSli = false;
    jQuery("input[name^=xml_]:checked").each(function() {
            needsSli = needsSli || eval(jQuery("input[name='sli_xml_" + this.name.substring(4) + "']").val());
    });
    jQuery("input[name^=serviceCode][value!='']").each(function() {
            needsSli = needsSli || eval(jQuery("input[name='sli_xml_" + this.value + "']").val());
    });
    return !needsSli || jQuery("select[name='xml_slicode']").get(0).selectedIndex != 0;
}

function checkAllDates() {
	var b = true;

    if(document.forms[0].xml_provider.value=="000000"){
		alert("Please select a provider.");
		b = false;
    }
    <% if (!OscarProperties.getInstance().getBooleanProperty("rma_enabled", "true")) { %>
    else if(document.forms[0].xml_visittype.options[2].selected && (document.forms[0].xml_vdate.value=="" || document.forms[0].xml_vdate.value=="0000-00-00")) {
		alert("Need an admission date.");
		b = false;
    }
    <% } %>
    else if(document.forms[0].xml_vdate.value.length>0) {
		b = checkServiceDate(document.forms[0].xml_vdate.value);
    } else if(document.forms[0].service_date.value.length>0) {
		b = checkServiceDate(document.forms[0].service_date.value);
    } else if(document.forms[0].referralCode.value.length>0) {
		if(document.forms[0].referralCode.value.length!=6 || !isInteger(document.forms[0].referralCode.value)) {
		    alert("Wrong referral code!");
		    b = false;
		}
    }
    return b;
}

function updateDate(){
    if (!document.forms[0].xml_visittype.options[2].selected || !document.forms[0].xml_visittype.options[4].selected) {
       document.getElementById("xml_vdate").value = "" ;  //only nursing homes and hospitals have admission dates
    }
}

function checkServiceDate(s) {
	var calDate=new Date();
	varYear = calDate.getFullYear();
	varMonth = calDate.getMonth()+1;
	varDate = calDate.getDate();
	var str_date = s; //document.forms[0].xml_appointment_date.value;
	var yyyy = str_date.substring(0, str_date.indexOf("-"));
	var mm = str_date.substring(eval(str_date.indexOf("-")+1), str_date.lastIndexOf("-"));
	var dd = str_date.substring(eval(str_date.lastIndexOf("-")+1));
	var bWrongDate = false;
	sMsg = "";
	if(yyyy > varYear) {
		sMsg = "year";
		bWrongDate = true;
	} else if(yyyy == varYear && mm > varMonth) {
		sMsg = "month";
		bWrongDate = true;
	} else if(yyyy == varYear && mm == varMonth && dd > varDate) {
		sMsg = "date";
		bWrongDate = true;
	}
	if(bWrongDate) {
		alert("You may have a wrong Service/admission Date!" + " Wrong " + sMsg);
		return false;
	} else {
		return true;
	}
}

function existServiceCode() {
    b = false;

    if (document.forms[0].serviceCode0.value!="") b=true;
<% for (int i = 1; i < BillingDataHlp.FIELD_SERVICE_NUM; i++) { %>
    else if (document.forms[0].serviceCode<%=i%>.value!="") b=true;
<% } %>

    return b;
}

function isInteger(s){
    var i;
    for (i = 0; i < s.length; i++){
	// Check that current character is number.
	var c = s.charAt(i);
	if (((c < "0") || (c > "9"))) return false;
    }
    // All characters are numbers.
    return true;
}

function isServiceCode(s){
    // temp for 0.
    if(s.length==0) return true;
    if(s.length!=5) return false;
    if((s.charAt(0) < "A") || (s.charAt(0) > "Z")) return false;
    if((s.charAt(4) < "A") || (s.charAt(4) > "Z")) return false;

    var i;
    for (i = 1; i < s.length-1; i++){
	// Check that current character is number.
	var c = s.charAt(i);
	if (((c < "0") || (c > "9"))) return false;
    }
    return true;
}

function isChecked(s) {
    for (var i =0; i <document.forms[0].elements.length; i++) {
        if (document.forms[0].elements[i].name.indexOf(s)==0 && document.forms[0].elements[i].name.length==14) {
            if (document.forms[0].elements[i].checked) {
				return true;
	    }
    	}
    }
    return false;
}

var remote=null;
function rs(n,u,w,h,x) {
    args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,top=60,left=30";
    remote=window.open(u,n,args);
    //if (remote != null) {
    //  if (remote.opener == null)
    //    remote.opener = self;
    //}
    //if (x == 1) { return remote; }
}

var awnd=null;
function referralScriptAttach(elementName) {
     var d = elementName;
     t0 = escape("document.forms[0].elements[\'"+d+"\'].value");
     //t1 = escape("");
     //alert(('searchRefDoc.jsp?param='+t0));
     awnd=rs('att',('searchRefDoc.jsp?param='+t0),1000,800,1);
     //awnd.focus();
}

function referralScriptAttach2(elementName, name2) {
     var d = elementName;
     t0 = escape("document.forms[0].elements[\'"+d+"\'].value");
     t1 = escape("document.forms[0].elements[\'"+name2+"\'].value");
     awnd=rs('att',('searchRefDoc.jsp?param='+t0+'&param2='+t1+'&submit=Search&keyword='+document.forms[0].elements[name2].value),1000,800,1);
     //awnd.focus();
}

function dxScriptAttach(name2) {
	ff = eval("document.forms[0].elements['" +name2+"']");
	f0 = ff.value;
	f1 = escape("document.forms[0].elements[\'"+name2+"\'].value");
	awnd=rs('att','billingDigSearch.jsp?name='+f0 + '&search=&name2='+f1,800,800,1);
	//awnd.focus();
}

function scScriptAttach(nameF) {
	f0 = escape(nameF.value);
	f1 = escape("document.forms[0].elements[\'"+nameF.name + "\'].value");
	awnd=rs('att','billingCodeSearch.jsp?name='+f0 + '&search=&name1=&name2=&nameF='+f1,600,600,1);
	//awnd.focus();
}

function onDblClickServiceCode(item) {
	if(document.forms[0].serviceCode0.value=="") {
		document.forms[0].serviceCode0.value = item.id.substring(3);
	}
<% for(int i=1; i<BillingDataHlp.FIELD_SERVICE_NUM; ++i) { %>
	else if(document.forms[0].serviceCode<%=i%>.value=="") {
		document.forms[0].serviceCode<%=i%>.value = item.id.substring(3);
	}
<% } %>
}

function onClickServiceCode(item) {
	if(document.forms[0].serviceCode0.value=="") {
		document.forms[0].serviceCode0.value = item.id.substring(4);
	}
<% for(int i=1; i<BillingDataHlp.FIELD_SERVICE_NUM; ++i) { %>
	else if(document.forms[0].serviceCode<%=i%>.value=="") {
		document.forms[0].serviceCode<%=i%>.value = item.id.substring(4);
	}
<% } %>
}

function upCaseCtrl(ctrl) {
	var n = document.forms[0].xml_billtype.selectedIndex;
	var val = document.forms[0].xml_billtype[n].value;
	if(val.substring(0,3) == "ODP" || val.substring(0,3) == "WCB" || val.substring(0,3) == "BON") ctrl.value = ctrl.value.toUpperCase();
}

function changeCut(dropdown) {
	var str = dropdown.options[dropdown.selectedIndex].value;
	var temp = new Array();
	temp = str.split('\|');
	//alert(temp);
	var tlen = temp.length;
	//alert(tlen);
	document.forms[0].dxCode.value="";
	document.forms[0].dxCode1.value="";
	document.forms[0].dxCode2.value="";
	var n = 0;
	for(var i=0; i<<%=BillingDataHlp.FIELD_SERVICE_NUM %>; ++i) {
		ocode = eval("document.forms[0].serviceCode" + i);
		ounit = eval("document.forms[0].serviceUnit" + i);
		operc = eval("document.forms[0].serviceAt" + i);
		//alert(i+":"+n+"|"+temp[n]);
		ocode.value	= "";
		ounit.value	= "";
		operc.value	= "";
		if(i<tlen && temp[n].length==5) {
			ocode.value	= temp[n];
			ounit.value	= temp[n+1];
			operc.value	= temp[n+2];
			n=n+3;
		} else if(i<tlen && temp[n].length==3) {
			if(document.forms[0].dxCode.value=="") {
				document.forms[0].dxCode.value=temp[n];
			} else if(document.forms[0].dxCode1.value=="") {
				document.forms[0].dxCode1.value=temp[n];
			} else if(document.forms[0].dxCode2.value=="") {
				document.forms[0].dxCode2.value=temp[n];
			}
			n=n+1;
		}
	}
	if (document.forms[0].dxCode.value=="" && document.forms[0].dxCode1.value=="" && document.forms[0].dxCode2.value=="") {
		document.forms[0].dxCode.value='<%=request.getParameter("dxCode")!=null?request.getParameter("dxCode"):dxCode%>';
		document.forms[0].dxCode1.value='<%=request.getParameter("dxCode1")!=null?request.getParameter("dxCode1"):""%>';
		document.forms[0].dxCode2.value='<%=request.getParameter("dxCode2")!=null?request.getParameter("dxCode2"):""%>';
		}
}

function popupPage(vheight,vwidth,varpage) { //open a new popup window
    var page = "" + varpage;
    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
    var popup=window.open(page, "billingfavourite", windowprops);
    if (popup != null) {
	if (popup.opener == null) popup.opener = self;
	popup.focus();
    }
}

function onClickRefDoc() {
    if (!document.forms[0].rfcheck.checked) {
	document.forms[0].referralCode.value="";
	document.forms[0].referralDocName.value="";
	document.forms[0].referralSpet.value="";
    } else {
	document.forms[0].referralCode.value="<%=r_doctor_ohip%>";
	document.forms[0].referralDocName.value="<%=r_doctor%>";
	document.forms[0].referralSpet.value="<%=referSpet%>";
    }
}

function onChangePrivate() {
	var n = document.forms[0].xml_billtype.selectedIndex;
	var val = document.forms[0].xml_billtype[n].value;
  	if(val.substring(0,3) == "PAT" || val.substring(0,3) == "OCF" || val.substring(0,3) == "ODS" || val.substring(0,3) == "CPP" || val.substring(0,3) == "STD") {
  		self.location.href = "billingON.jsp?curBillForm=<%="PRI"%>&hotclick=<%=URLEncoder.encode("","UTF-8")%>&appointment_no=<%=request.getParameter("appointment_no")%>&demographic_name=<%=URLEncoder.encode(demoname,"UTF-8")%>&demographic_no=<%=request.getParameter("demographic_no")%>&xml_billtype="+val.substring(0,3)+"&apptProvider_no=<%=request.getParameter("apptProvider_no")%>&providerview=<%=request.getParameter("apptProvider_no")%>&appointment_date=<%=request.getParameter("appointment_date")%>&status=<%=request.getParameter("status")%>&start_time=<%=request.getParameter("start_time")%>&bNewForm=1";
  	}
    else if( val.substring(0,3) == "BON") {
        self.location.href = "billingON.jsp?curBillForm=<%=oscarVariables.getProperty("primary_care_incentive", "").trim()%>&hotclick=<%=URLEncoder.encode("","UTF-8")%>&appointment_no=<%=request.getParameter("appointment_no")%>&demographic_name=<%=URLEncoder.encode(demoname,"UTF-8")%>&demographic_no=<%=request.getParameter("demographic_no")%>&xml_billtype="+val.substring(0,3)+"&apptProvider_no=<%=request.getParameter("apptProvider_no")%>&providerview=<%=request.getParameter("apptProvider_no")%>&appointment_date=<%=request.getParameter("appointment_date")%>&status=<%=request.getParameter("status")%>&start_time=<%=request.getParameter("start_time")%>&bNewForm=1";
    }
    else {
<% if(ctlBillForm.equals("PRI") ) {%>
        self.location.href = "billingON.jsp?curBillForm=<%=oscarVariables.getProperty("default_view", "").trim()%>&hotclick=<%=URLEncoder.encode("","UTF-8")%>&appointment_no=<%=request.getParameter("appointment_no")%>&demographic_name=<%=URLEncoder.encode(demoname,"UTF-8")%>&demographic_no=<%=request.getParameter("demographic_no")%>&xml_billtype="+val.substring(0,3)+"&apptProvider_no=<%=request.getParameter("apptProvider_no")%>&providerview=<%=request.getParameter("apptProvider_no")%>&appointment_date=<%=request.getParameter("appointment_date")%>&status=<%=request.getParameter("status")%>&start_time=<%=request.getParameter("start_time")%>&bNewForm=1";
<% } %>
  	}
}

function showHideBox(layerName, iState) { // 1 visible, 0 hidden
    if(document.layers)	{   //NN4+
	document.layers[layerName].visibility = iState ? "show" : "hide";
    } else if(document.getElementById) {  //gecko(NN6) + IE 5+
        var obj = document.getElementById(layerName);
        obj.style.visibility = iState ? "visible" : "hidden";
    } else if(document.all) {	// IE 4
        document.all[layerName].style.visibility = iState ? "visible" : "hidden";
    }
}

function onHistory() {
    var dd = document.forms[0].day.value;
    //alert(dd);
    popupPage("800","1000","billingONHistorySpec.jsp?demographic_no=<%=demo_no%>&demo_name=<%=URLEncoder.encode(demoname,"UTF-8")%>&orderby=appointment_date&day=" + dd);
}

function prepareBack() {
    document.forms[0].services_checked.value = "<%=request.getParameter("services_checked")%>";
    if (document.forms[0].services_checked.value=="null") document.forms[0].services_checked.value = 0;
    document.forms[0].url_back.value = location.href;

    showBillFormDiv ("group1_", "<%=ctlBillForm%>");
    showBillFormDiv ("group2_", "<%=ctlBillForm%>");
    showBillFormDiv ("group3_", "<%=ctlBillForm%>");
    showBillFormDiv ("dxCodeSearchDiv_", "<%=ctlBillForm%>");

}

function showBillFormDiv (group, selectedForm) {
    var selectedFormDivGroupId = group + selectedForm;
    var thisDiv = document.getElementById(selectedFormDivGroupId);
    if (thisDiv)
    {
    if (thisDiv.style.display == "none") {
            thisDiv.style.display = "block";
    }
    }
    else {
    //alert("Error: Could not locate div with id: " + selectedFormDivGroupId);
    	//do nothing
    }
}

function hideBillFormDiv (group, selectedForm) {
    var selectedFormDivGroupId = group + selectedForm;
    var thisDiv = document.getElementById(selectedFormDivGroupId);
    if (thisDiv)
    {
    if (thisDiv.style.display == "block") {
            thisDiv.style.display = "none";
    }
    }
    else {
    //alert("Error: Could not locate div with id: " + selectedFormDivGroupId);
        //do nothing
    }
}

function refreshServicesChecked(chkd) {
    var name_id = chkd.name;
	if (chkd.checked) {
            document.forms[0].services_checked.value++;

            //check other checkbox with same name
            for(i=0;i<document.forms[0][name_id].length; i++) {
                    document.forms[0][name_id][i].checked = true;
            }
	} else {
            document.forms[0].services_checked.value--;

            //uncheck other checkbox with same name
            for(i=0;i<document.forms[0][name_id].length; i++) {
                    document.forms[0][name_id][i].checked = false;
          	}
	}
}


function callChangeCodeDesc() {
    setTimeout("changeCodeDesc();",10);
}

function changeCodeDesc() {
    var url  = "billingON_dx_desc.jsp";
    var pars = "diagnostic_code=" + document.forms[0].dxCode.value;

    //prototype
    //var descAjax = new Ajax.Updater("code_desc",url, {method: "get", parameters: pars});

    jQuery.ajax({
       url: url,
       type: "get",
       dataType: "html",
       data: pars,
       success: function(returnData){
         jQuery("#code_desc").html(returnData);
       },
       error: function(e){
         alert(e);
       }
    });
}

//this function will show the content within the <div> tag of billing codes
function toggleDiv(selectedBillForm, selectedBillFormName,billType)
{

        document.getElementById("billForm").value=selectedBillForm;
        document.getElementById("billFormName").value=selectedBillFormName;

        if(billType != ''){
        	for (var i=0;i<document.forms[0].xml_billtype.options.length;i++) {
        	    if (document.forms[0].xml_billtype.options[i].value.substring(0,3) == billType){
        	    	document.forms[0].xml_billtype.options[i].selected = true;
        		}
        	}
        }

        //dx search
        showBillFormDiv("dxCodeSearchDiv_",selectedBillForm);

        //var selectedForm = selectedBillForm.options[selectedBillForm.selectedIndex].value;
        showBillFormDiv ("group1_", selectedBillForm);
        showBillFormDiv ("group2_", selectedBillForm);
        showBillFormDiv ("group3_", selectedBillForm);

        //hide other billing codes whose forms are not selected
<%
        for( int j=0; j< listServiceType.size(); j++) {
                String st = listServiceType.get(j);
 %>
        if(selectedBillForm!="<%=st%>") {

                hideBillFormDiv ("group1_", "<%=st%>");
                hideBillFormDiv ("group2_", "<%=st%>");
                hideBillFormDiv ("group3_", "<%=st%>");

                hideBillFormDiv ("dxCodeSearchDiv_", "<%=st%>");
        }

        <% }  %>
}





//-->
</script>
</head>

<body onload="prepareBack();changeCodeDesc();getDays();">
	<div id="Instrdiv" class="demo1">

		<table style="width: 99%;">
			<tr>
				<th style="text-align: right"><a href="javascript:void(0)"
					onclick="showHideBox('Instrdiv',0); return false;">X</a></th>
			</tr>
			<tr>
				<td><a href="javascript:void(0);" style="color:black"
					onclick="showHideBox('Instrdiv',0); return false;">Double clicking any code below will move up
						to specialist billing.<br>&nbsp;</a></td>
			</tr>

		</table>
	</div>
	<div id="Layer1"
		style="position: absolute; left: 360px; top: 165px; width: 410px; height: 210px; z-index: 1; visibility: hidden">
		<table style="width: 98%; margin:auto; ">
			<tr>
				<td style="width: 96%; background-color:silver; height:12px;">
					<b>Billing Form</b></td>
				<td style="width: 3%; background-color:silver; height:12px;"><b><a href="javascript:void(0);"
						onclick="showHideLayers('Layer1','','hide');return false;">X</a></b></td>
			</tr>
			<%
		String ctlcode = "", ctlcodename = "", currentFormName = "";
		int ctlCount = 0;
		CtlBillingServiceDao ctlBillingServiceDao = SpringUtils.getBean(CtlBillingServiceDao.class);
		CtlBillingTypeDao  ctlBillingtypeDao = SpringUtils.getBean(CtlBillingTypeDao.class);
		for(Object[] bs : ctlBillingServiceDao.findServiceTypesByStatus("A")) {
			ctlcode = String.valueOf(bs[1]);
			ctlcodename = String.valueOf(bs[0]);
			ctlCount++;
			if (ctlcode.equals(ctlBillForm)) {
			    currentFormName = ctlcodename;
			}
			String billType = "";

			for(CtlBillingType bt : ctlBillingtypeDao.findByServiceType(ctlcode)) {
				billType = bt.getBillType();
	        }
%>
			<tr>
				<td colspan="2" style="background-color:lightgray;"><b>
						<a href="javascript:void(0);"
							onclick="toggleDiv('<%=ctlcode%>', '<%=ctlcodename %>','<%=billType%>');showHideLayers('Layer1','','hide');"><%=ctlcodename%></a>
					</b></td>
			</tr>
			<%}%>
		</table>
	</div>

	<div id="Layer2"
		style="position: absolute; left: 1px; top: 26px; width: 435px; height: 680px; z-index: 2; background-color: #FFCC00; border: 1px none #000000; visibility: hidden">
		<table style="width: 98%; margin:auto;">
			<tr>
				<td style="width: 10%"><b>DxCode</b></td>
				<td style="width: 85%"><b>Description</b></td>
				<td><a href="javascript:void(0);" onclick="showHideLayers('Layer2','','hide');return false">
					</a>
				</td>
			</tr>
		</table>
		<%
    for( int j=0; j< listServiceType.size(); j++) {
        String st = listServiceType.get(j);

        String ctldiagcode = "", ctldiagcodename = "";
        ctlCount = 0;
%>

		<div id="dxCodeSearchDiv_<%=st%>" style="display: none;">

			<%
			DiagnosticCodeDao dcDao = SpringUtils.getBean(DiagnosticCodeDao.class);

		for(Object[] o : dcDao.findDiagnosictsAndCtlDiagCodesByServiceType(st)) {
			DiagnosticCode d = (DiagnosticCode) o[0];
			CtlDiagCode c = (CtlDiagCode) o[1];

				ctldiagcode = d.getDiagnosticCode();
				ctldiagcodename = d.getDescription();
				ctlCount++;
%>
			<table style="width: 98%; margin:auto;" class="table-striped table-hover" >
				<tr>
					<td style="width: 10%">
							<a href="javascript:void(0);" onclick="document.forms[0].dxCode.value='<%=ctldiagcode%>';showHideLayers('Layer2','','hide');changeCodeDesc();return false;">
								<%=ctldiagcode%>
							</a>
					</td>
					<td>
						<a href="javascript:void(0);" onclick="document.forms[0].dxCode.value='<%=ctldiagcode%>';showHideLayers('Layer2','','hide');changeCodeDesc();return false;">
							<%=ctldiagcodename.length() < 56 ? Encode.forHtml(ctldiagcodename) : Encode.forHtml(ctldiagcodename.substring(0, 55))%>
						</a>
					</td>
				</tr>
			</table>
			<%} %>
		</div>
		<%} %>

	</div>

	<form method="post" id="titlesearch" name="titlesearch"
		action="billingONReview.jsp" onsubmit="return onNext();">
		<%
String checkFlag = request.getParameter("checkFlag");
if(checkFlag == null) checkFlag = "0";
%>
		<input type="hidden" name="checkFlag" id="checkFlag"
			value="<%=checkFlag %>" />
		<input type="hidden" name="addToPatientDx" />
		<input type="hidden" name="codeMatchToPatientDx" />

		<table class="xmyDarkGreen"
			style="width: 100%; background-color: silver;">
			<tr>
				<td><H4><i class="icon-money" style="margin-left:10px;"></i>&nbsp;Ontario Billing</H4></td>
				<td style="text-align: right"><i class="icon-question-sign"></i>&nbsp;<oscar:help keywords="Billing"
						key="app.top1" />
					|  <i class="icon-edit"></i><a href="javascript:void(0);"
					onclick="popupPage(800,700,'billingONfavourite.jsp'); return false;">
						Edit
				</a> <select name="cutlist" id="cutlist" onchange="changeCut(this)" >
						<option selected="selected" value="">- SUPER CODES -</option>
						<% //
		    List sL = tdbObj.getBillingFavouriteList();
		    for (int i = 0; i < sL.size(); i = i + 2) { %>
						<option value="<%=(String) sL.get(i+1)%>"><%=(String) sL.get(i)%></option>
						<% } %>
				</select></td>
				<td style="text-align: right; width: 10%; white-space:nowrap">
                    <input type="submit"
					name="submit" value="Next" style="width: 120px;" class="btn btn-primary"/>
                    <input
					type="button" class="btn" name="button" value="Exit" style="width: 120px;" class="btn"
					onclick="self.close();" /> &nbsp;</td>
			</tr>
		</table>

		<table style="width: 100%; border-spacing:2px;">
			<tr>
				<td>
					<table  style="width: 100%;">
						<tr>
							<td style="white-space:nowrap; width: 10%; text-align: center"><b>&nbsp;<oscar:nameage
										demographicNo="<%=demo_no%>" /> <%=roster_status%></b>
                            <%if (appt_no.compareTo("0") == 0) {%>
                                <span class="input-append">
								<input type="text" id="service_date" name="service_date" readonly
								value="<%=request.getParameter("service_date")!=null? request.getParameter("service_date"):strToday%>"
								style="width: 80px; height:14px;  vertical-align: bottom;">
                                <img src="${ pageContext.request.contextPath }/images/cal.gif" id="service_date_cal" style="height:14px;  vertical-align: bottom;" class="add-on" alt="cal"></span>
                            <%} else {%>
                                <input type="text" id="service_date" name="service_date" readonly
								value="<%=request.getParameter("appointment_date")%>"
								maxlength="10" style="width: 80px;" > <%}%></td>
							<%
                                                              String warningClass = "";
                                                              if (billingRecomendations.length() > 0) {
                                                                  warningClass="alert";
                                                              }
                                                        %>
							<td style="text-align: center;"
								class="<%=warningClass%>"><%=billingRecomendations.toString()%></td>
							<td style="text-align: center;"><%=msg%></td>
						</tr>
					</table>

					<table class="border1"  style="width: 100%;">
						<tr>
							<td style="width: 46%">
								<table class="border1" style="width: 100%; border-spacing:2px;"
									>
									<tr>
										<td colspan="2" >Specialist billing
											&nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:void(0);"
											title="Double click shaded fields for drop down or calculation"
											onClick="showHideBox('Instrdiv',1);return false;">Instruction
										</a>
										</td>
										<td style="vertical-align:top" rowspan="2">
											<table
												style="width: 100%;">
												<tr>
													<td style="width: 15%">&nbsp;</td>
													<td style="white-space:nowrap">
														<div id="code_desc"></div>
													</td>
												</tr>
												<tr>
													<td><a href="javascript:void(0);"
														onclick="showHideLayers('Layer2','','show','Layer1','','hide'); return false;">Dx</a>
													</td>
													<td><input type="text" name="dxCode" class="input-mini"
														maxlength="5" ondblClick="dxScriptAttach('dxCode')"
														onchange="changeCodeDesc();"
														value="<%=request.getParameter("dxCode")!=null?request.getParameter("dxCode"):dxCode%>" />
														<a href="javascript:void(0);" onclick="dxScriptAttach('dxCode');">Search</a>
													</td>
												</tr>
												<tr>
													<td>dx1</td>
													<td><input type="text" name="dxCode1" class="input-mini"
														maxlength="5" ondblClick="dxScriptAttach('dxCode1')"
														value="<%=request.getParameter("dxCode1")!=null?request.getParameter("dxCode1"):""%>" />
														<a href="javascript:void(0);" onclick="dxScriptAttach('dxCode1')">Search</a></td>
												</tr>
												<tr>
													<td>dx2</td>
													<td><input type="text" name="dxCode2" class="input-mini"
														maxlength="5" ondblClick="dxScriptAttach('dxCode2')"
														value="<%=request.getParameter("dxCode2")!=null?request.getParameter("dxCode2"):""%>" />
														<a href="javascript:void(0);" onclick="dxScriptAttach('dxCode2')">Search</a></td>
												</tr>
											</table> <a
											href="javascript:referralScriptAttach2('referralCode','referralDocName')">Refer.
												Doctor #</a> <%
			String checkRefBox = "";
			String refName = "";
			String refNo = "";
			if (request.getParameter("rfcheck") != null) {
				checkRefBox = request.getParameter("rfcheck");
				refName = request.getParameter("referralDocName");
				refNo = request.getParameter("referralCode");
				referSpet = request.getParameter("referralSpet");
			} else if (oscarVariables.getProperty("billingRefBoxDefault", "").equals("checked")) {
				checkRefBox = "checked";
				refName = r_doctor;
				refNo = r_doctor_ohip;
			}


			%> <input type="checkbox" name="rfcheck" value="checked"
											<%=checkRefBox%> onclick="onClickRefDoc()" /><br />
                                            <input
											type="text" name="referralCode" class="input-mini" maxlength="6" placeholder="<bean:message
													key="oscarEncounter.oscarConsultationRequest.config.AddSpecialist.referralNo" />"
											value="<%=refNo%>">&nbsp;
                                            <input type="text" placeholder="<bean:message
													key="dms.documentReport.msgType" />"
											name="referralSpet" class="input-small" maxlength="2"
											value="<%=referSpet==null?"":referSpet%>"><br />
                                            <input placeholder="<bean:message
													key="demographic.demographiceditdemographic.formRefDoc" />"
											type="text" name="referralDocName" class="input-medium" maxlength="30"
											value="<%=refName%>">
										</td>
									</tr>
									<tr>
										<td style="white-space:nowrap; width: 33%; text-align: center" class="xmyPink"><b>Code
												&nbsp; Time &nbsp;%</b><br /> <%	    for (int i = 0; i < BillingDataHlp.FIELD_SERVICE_NUM / 2; i++) { %>
											<input type="text" name="serviceCode<%=i%>" class="input-mini"

											value="<%=request.getParameter("serviceCode"+i)!=null?request.getParameter("serviceCode"+i):""%>"
											onDblClick="scScriptAttach(this)" onBlur="upCaseCtrl(this)" />x
											<input type="text" name="serviceUnit<%=i%>" size="2" maxlength="4" style="width: 20px;"
											value="<%=request.getParameter("serviceUnit"+i)!=null?request.getParameter("serviceUnit"+i):""%>" />@
											<input type="text" name="serviceAt<%=i%>" size="3" maxlength="4" style="width: 30px"
											value="<%=request.getParameter("serviceAt"+i)!=null?request.getParameter("serviceAt"+i):""%>" /><br />
											<%	    } %></td>
										<td style="white-space:nowrap; width: 33%; text-align: center" class="xmyPink"><b>Code
												&nbsp; Time &nbsp;%</b><br /> <%	    for (int i = BillingDataHlp.FIELD_SERVICE_NUM / 2; i < BillingDataHlp.FIELD_SERVICE_NUM; i++) { %>
											<input type="text" name="serviceCode<%=i%>" class="input-mini"

											value="<%=request.getParameter("serviceCode"+i)!=null?request.getParameter("serviceCode"+i):""%>"
											onDblClick="scScriptAttach(this)" onBlur="upCaseCtrl(this)" />x
											<input type="text" name="serviceUnit<%=i%>" size="2" maxlength="2" style="width: 20px;"
											value="<%=request.getParameter("serviceUnit"+i)!=null?request.getParameter("serviceUnit"+i):""%>" />@
											<input type="text" name="serviceAt<%=i%>" size="3" maxlength="4" style="width: 30px"
											value="<%=request.getParameter("serviceAt"+i)!=null?request.getParameter("serviceAt"+i):""%>" /><br />
											<%	    } %></td>
									</tr>
								</table>
							</td>
							<td style="vertical-align:top">
								<table class="border1 table-hover" style="width: 100%; border-spacing:2px;">
									<tr>
										<td style="white-space:nowrap; width: 30%"><b>Billing
												Physician</b></td>
										<td style="width: 20%">
											<% if (org.oscarehr.common.IsPropertiesOn.isMultisitesEnable())
{ // multisite start ==========================================
        	SiteDao siteDao = SpringUtils.getBean(SiteDao.class);
          	List<Site> sites = siteDao.getActiveSitesByProviderNo((String) session.getAttribute("user"));

      %> <script>
var _providers = [];
<%	for (int i=0; i<sites.size(); i++) {
	Set<Provider> siteProviders = sites.get(i).getProviders();
	List<Provider>  siteProvidersList = new ArrayList<Provider> (siteProviders);
     Collections.sort(siteProvidersList,(new Provider()).ComparatorName());%>
	_providers["<%= Encode.forJavaScriptBlock(sites.get(i).getName()) %>"]="<% Iterator<Provider> iter = siteProvidersList.iterator();
	while (iter.hasNext()) {
		Provider p=iter.next();
		if ("1".equals(p.getStatus()) && StringUtils.isNotBlank(p.getOhipNo())) {
	%><option value='<%= p.getProviderNo() %>|<%= p.getOhipNo() %>' ><%=Encode.forHtmlAttribute(p.getLastName())%>, <%=Encode.forHtmlAttribute(p.getFirstName())%></option><%}}%>";
<%}%>
function changeSite(sel) {
	sel.form.xml_provider.innerHTML=sel.value=="none"?"":_providers[sel.value];
	sel.style.backgroundColor=sel.options[sel.selectedIndex].style.backgroundColor;
}
      </script> <select id="site" name="site" onchange="changeSite(this)"
											>
												<option value="none" style="background-color: white">---select
													clinic---</option>
												<%
													String selectedSite = request.getParameter("site");
												      	String xmlp = null;
												      	if (selectedSite==null) {
												      		OscarAppointmentDao apptDao = SpringUtils.getBean(OscarAppointmentDao.class);
												      		for(Object[] obj : apptDao.findAppointmentAndProviderByAppointmentNo(ConversionUtils.fromIntString(appt_no))) {
												      			Appointment a = (Appointment) obj[0];
												      			Provider p = (Provider) obj[1];

												      			selectedSite = a.getLocation();
												      			xmlp = a.getProviderNo() + "|" + p.getOhipNo();
												      		}
												      	}
												      	for (int i=0; i<sites.size(); i++) {
												%>
												<option value="<%=sites.get(i).getName()%>"
													style="background-color:<%=sites.get(i).getBgColor()%>"
													<%=sites.get(i).getName().toString().equals(selectedSite)?"selected":""%>><%=Encode.forHtmlContent(sites.get(i).getName())%></option>
												<%
													}
												%>
										</select> <select id="xml_provider" name="xml_provider"
											></select> <script>
     	changeSite(document.getElementById("site"));
      	document.getElementById("xml_provider").value='<%=Encode.forJavaScriptBlock(request.getParameter("xml_provider")==null?xmlp:request.getParameter("xml_provider"))%>';
      	</script> <%
 	// multisite end ==========================================
 } else {
 %> <select name="xml_provider">
												<%
													String[] tmp;
												            if (vecProvider.size() == 1) {
														propT = (Properties) vecProvider.get(0);
												                tmp = propT.getProperty("proOHIP","").split("\\|");
												%>
												<option value="<%=propT.getProperty("proOHIP")%>"
													<%=providerview.equals(tmp[0].trim())?"selected":""%>>
													<b><%=Encode.forHtmlContent(propT.getProperty("last_name")+", "+propT.getProperty("first_name"))%></b>
												</option>
												<%
													} else {
												%>
												<option value="000000"
													<%=providerview.equals("000000")?"selected":""%>>
													<b>Select Provider</b>
												</option>
												<%
													for (int i = 0; i < vecProvider.size(); i++) {
														    propT = (Properties) vecProvider.get(i);
                                                                                                                    String info = propT.getProperty("proOHIP");
                                                                                                                    String prov = info.substring(0, info.indexOf("|"));

												%>

												<option value="<%=propT.getProperty("proOHIP")%>"
													<%=providerview.equalsIgnoreCase(prov)?"selected":""%>>
													<b><%=Encode.forHtmlContent(propT.getProperty("last_name")+", "+propT.getProperty("first_name"))%></b>
												</option>
												<%
													}
													    }
												%>
										</select> <%
 	}
 %>

										</td>
										<td style="white-space:nowrap; width: 30%"><b>Assig. Phys.</b></td>
										<td style="width: 20%"><%=providerBean.getProperty(assgProvider_no, "").length() > 15
					    ? providerBean.getProperty(assgProvider_no, "").substring(0, 14)
					    : providerBean.getProperty(assgProvider_no, "")%></td>
									</tr>
									<tr>
										<td style="width: 30%"><b> <%
 	if (OscarProperties.getInstance().getBooleanProperty("rma_enabled", "true")) {
 %>
												Clinic Nbr <%
 	} else {
 %> <bean:message
													key="billing.billingCorrection.formVisitType" /> <%
 	}
 %>
										</b></td>
										<td style="width: 20%"><select name="xml_visittype" onchange="updateDate()">
												<%
													if (OscarProperties.getInstance().getBooleanProperty("rma_enabled", "true")) {
												%>
												<%
													ClinicNbrDao cnDao = SpringUtils.getBean(ClinicNbrDao.class);
																ArrayList<ClinicNbr> nbrs = cnDao.findAll();
													            ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
													            String providerSearch = apptProvider_no.equalsIgnoreCase("none") ? user_no : apptProvider_no;
													            Provider p = providerDao.getProvider(providerSearch);
													            String providerNbr = SxmlMisc.getXmlContent(p.getComments(),"xml_p_nbr");
													                    for (ClinicNbr clinic : nbrs) {
																	String valueString = String.format("%s | %s", clinic.getNbrValue(), clinic.getNbrString());
												%>
												<option value="<%=valueString%>"
													<%=providerNbr.startsWith(clinic.getNbrValue())?"selected":""%>><%=valueString%></option>
												<%
													}
												%>
												<%
													} else {
												%>
												<option value="00| Clinic Visit"
													<%=visitType.startsWith("00")?"selected":""%>>00 |
													Clinic Visit</option>
												<option value="01| Outpatient Visit"
													<%=visitType.startsWith("01")?"selected":""%>>01 |
													Outpatient Visit</option>
												<option value="02| Hospital Visit"
													<%=visitType.startsWith("02")?"selected":""%>>02 |
													Hospital Visit</option>
												<option value="03| ER"
													<%=visitType.startsWith("03")?"selected":""%>>03 |
													ER</option>
												<option value="04| Nursing Home"
													<%=visitType.startsWith("04")?"selected":""%>>04 |
													Nursing Home</option>
												<option value="05| Home Visit"
													<%=visitType.startsWith("05")?"selected":""%>>05 |
													Home Visit</option>
												<%
													}
												%>
										</select></td>
										<td style="width: 30%"><b>Billing Type</b></td>
										<td style="width: 20%">
											<%
												if ((roster_status.equals("QU - Quebec")||roster_status.equals("FS")) && !defaultServiceType.equals("RN")) {
												    defaultBillType = "PAT";
												}
												String srtBillType = request.getParameter("xml_billtype")!=null ? request.getParameter("xml_billtype") : defaultBillType;
											%> <select name="xml_billtype" onchange="onChangePrivate();">
												<option value="ODP | Bill OHIP"
													<%=srtBillType.startsWith("ODP")?"selected" : ""%>>Bill
													OHIP</option>
												<option value="WCB | Worker's Compensation Board"
													<%=srtBillType.startsWith("WCB")?"selected" : ""%>>WSIB</option>
												<option value="NOT | Do Not Bill"
													<%=srtBillType.startsWith("NOT")?"selected" : ""%>>Do
													Not Bill</option>
												<option value="IFH | Interm Federal Health"
													<%=srtBillType.startsWith("IFH")?"selected" : ""%>>IFH</option>
												<option value="PAT | Bill Patient"
													<%=srtBillType.startsWith("PAT")?"selected" : ""%>>3rd
													Party</option>
												<option value="OCF | "
													<%=srtBillType.startsWith("OCF")?"selected" : ""%>>
													-OCF</option>
												<option value="ODS | "
													<%=srtBillType.startsWith("ODS")?"selected" : ""%>>
													-ODSP</option>
												<option value="CPP | Canada Pension Plan"
													<%=srtBillType.startsWith("CPP")?"selected" : ""%>>
													-CPP</option>
												<option
													value="STD | Short Term Disability / Long Term Disability"
													<%=srtBillType.startsWith("STD")?"selected" : ""%>>-STD/LTD</option>
												<option value="BON | Bonus Codes"
													<%=srtBillType.startsWith("BON")?"selected" : ""%>>Bonus
													Codes</option>
										</select>
										</td>
									</tr>
									<tr>
										<td><b>Visit Location</b></td>
										<td colspan="3"><select name="xml_location">
												<%
													//
													    String billLocationNo="", billLocation="";
String strLocation ="";
													    List lLocation = tdbObj.getFacilty_num();
                                                        String last_location = getDefaultValue(request.getParameter("xml_visittype"),vecHist,"clinic_ref_code");
													    for (int i = 0; i < lLocation.size(); i = i + 2) {
														billLocationNo = (String) lLocation.get(i);
														billLocation = (String) lLocation.get(i + 1);
														strLocation = request.getParameter("xml_location") != null ? request.getParameter("xml_location") : last_location != null ? last_location  : clinicview;
												%>
												<option value="<%=billLocationNo + "|" + billLocation%>"
													<%=strLocation.startsWith(billLocationNo)?"selected":""%>>
                                                    <%=billLocation%>
												</option>
												<%
													}
												%>
										</select>Manual Review Flag: <input type="checkbox" name="m_review" value="Y"
											<%=m_review.equals("Y")?"checked":""%>></td>
									</tr>
									<tr>
										<td><b><bean:message
													key="oscar.billing.CA.ON.billingON.OB.SLIcode" /></b></td>
										<td colspan="3"><select name="xml_slicode">
												<option value="<%=clinicNo%>">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.NA" />
												</option>
												<option value="HDS">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.HDS" />
												</option>
												<option value="HED">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.HED" />
												</option>
												<option value="HIP">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.HIP" />
												</option>
												<option value="HOP">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.HOP" />
												</option>
												<option value="HRP">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.HRP" />
												</option>
												<option value="IHF">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.IHF" />
												</option>
												<option value="OFF">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.OFF" />
												</option>
												<option value="OTN">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.OTN" />
												</option>
												<option value="PDF">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.PDF" />
												</option>
												<option value="RTF">
													<bean:message
														key="oscar.billing.CA.ON.billingON.OB.SLIcode.RTF" />
												</option>
										</select></td>
									</tr>
									<tr>
										<td><b>Admission Date</b></td>
										<td>
											<%
												String admDate = "";
											          String inPatient = oscarVariables.getProperty("inPatient");
											          try{
											             if(inPatient != null && inPatient.trim().equalsIgnoreCase("YES")){
													oscar.oscarDemographic.data.DemographicData demoData = new oscar.oscarDemographic.data.DemographicData();
													admDate = demoData.getDemographicDateJoined(loggedInInfo, demo_no);
												     }
											          }catch(Exception inPatientEx){
											        	  MiscUtils.getLogger().error("Error", inPatientEx);
												     admDate = "";
											          }
												  if (visitType.startsWith("02") || visitType.startsWith("04")) admDate = getDefaultValue(request.getParameter("visitdate"),vecHist,"visitdate");
											%>
											<span class="input-append">
											    <input type="text" name="xml_vdate" id="xml_vdate" onchange="getDays();"
											value="<%=request.getParameter("xml_vdate")!=null? request.getParameter("xml_vdate"):admDate%>"
											class="input-small" style="height: 14px; margin-top:4px;" readonly> <img alt="cal" class="add-on" style="height:14px;  margin-top:4px;"
											src="${ pageContext.request.contextPath }/images/cal.gif" id="xml_vdate_cal">
											</span>
                                            <span id="duration_display"></span>
										</td>
										<td colspan="2"><a href="javascript:void(0);"
											onclick="showHideLayers('Layer1','','show');return false;">
												Billing form</a>: <input type="text" name="billFormName" class="input-large"
											id="billFormName" readonly
											value="<%=currentFormName.length() < 40 ? currentFormName : currentFormName.substring(0, 40)%>" />
											<input type="hidden" name="billForm" id="billForm"
											value="<%=ctlBillForm%>" /></td>
									</tr>
									<%
										if (!org.oscarehr.common.IsPropertiesOn.isMultisitesEnable()) {
									    OscarProperties props = OscarProperties.getInstance();
									    boolean bMoreAddr = props.getProperty("scheduleSiteID", "").equals("") ? false : true;
									    if(bMoreAddr) {
										BillingSiteIdPrep sitePrep = new BillingSiteIdPrep();
										String [] siteList = sitePrep.getSiteList();
										String strServDate = request.getParameter("appointment_date")!=null? request.getParameter("appointment_date"):strToday;
										String thisSite = (new JdbcApptImpl()).getLocationFromSchedule(strServDate, apptProvider_no);
										String suggestSite = sitePrep.getSuggestSite(siteList, thisSite, strServDate, apptProvider_no );
									%>
									<tr>
										<td style="text-align: right">Site</td>
										<td colspan="3"><select name="siteId">
												<%
													for(int i=0; i<siteList.length; i++) {
												%>
												<option value="<%=siteList[i]%>"
													<%=suggestSite.equals(siteList[i])?"selected":""%>>
													<b><%=siteList[i]%></b>
												</option>
												<%
													}
												%>
										</select></td>
									</tr>
									<%
										}
									}
									%>

								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table style="width: 100%; height:137px">
						<tr>
							<td style="vertical-align:top; width: 33%">
								<%
									for( int j=0; j< listServiceType.size(); j++) {
								        ArrayList<Properties> vecCodeCol1 = new ArrayList<Properties>();
								        vecCodeCol1 = billingServiceCodesMap.get("group1_".concat(listServiceType.get(j)));
								        headerTitle1 = titleMap.get("group1_".concat(listServiceType.get(j)));
								%>
								<div id="group1_<%=listServiceType.get(j)%>" style="display: none;">
									<table style="width: 100%;" class="border1 table-striped table-hover">
										<tr>
											<th style="width: 10%; white-space:nowrap; background-color:silver"><div class="smallFont"><%=headerTitle1%></div></th>
											<th style="width: 70%; background-color:silver"><div class="smallFont">Description</div></th>
											<th style="background-color:silver"><div class="smallFont">Fee</div></th>
										</tr>


										<%
											for (int i = 0; i < vecCodeCol1.size(); i++) {
												propT = vecCodeCol1.get(i);
												serviceCode = propT.getProperty("serviceCode");
												serviceDesc = propT.getProperty("serviceDesc");
												serviceDisp = propT.getProperty("serviceDisp");
												servicePercentage = propT.getProperty("servicePercentage");
												serviceType = propT.getProperty("serviceType");
												displayStyle = propT.getProperty("displaystyle");
												sliFlag = Boolean.parseBoolean(propT.getProperty("serviceSLI"));

												if (propPremium.getProperty(serviceCode) != null) premiumFlag = "A";
												else premiumFlag = "";

												String bgcolor = "";
												if (request.getParameter("xml_" + serviceCode) != null) bgcolor = "background-color: #66FF66;";
										%>
										<tr>
											<td style="<%=displayStyle%> text-align: left; white-space:nowrap; <%=bgcolor%>" ><input
												type="checkbox" id="xml_<%=serviceCode%>"
												name="xml_<%=serviceCode%>" value="checked"
												onclick="refreshServicesChecked(this);"
												<%=request.getParameter("xml_"+serviceCode)!=null?request.getParameter("xml_"+serviceCode):""%>
												<%=bSingleClick? "onClick='onClickServiceCode(this)'" :""%> />
												<span id="sc<%=(""+i).substring(0,1)+serviceCode%>"
												onclick="getElementById('xml_<%=serviceCode%>').click();"
												ondblclick="onDblClickServiceCode(this)"><%=serviceCode%></span>
											</td>
											<td style="<%=displayStyle%> <%=bgcolor%>"
												<%=serviceDesc.length()>30?"title=\""+serviceDesc+"\"":""%>
												<%=displayStyle.equals("")? "class=\"smallFont\"": "style=\"" + displayStyle + "\""%>>
												<div onclick="getElementById('xml_<%=serviceCode%>').click();"><%=serviceDesc.length() > 30 ? serviceDesc.substring(0, 30) + "..." : serviceDesc%>
													<!--<input type="hidden" name="desc_xml_<%=serviceCode%>" value="<%=serviceDesc%>" />-->
												</div>
											</td>
											<td style="text-align: right; <%=displayStyle%> <%=bgcolor%>">
												<div class="smallFont"><%=serviceDisp%></div> <input
												type="hidden" name="sli_xml_<%=serviceCode%>"
												value="<%=sliFlag%>" /> <!--<input type="hidden" name="price_xml_<%=serviceCode%>" value="<%=serviceDisp%>" />
				    <input type="hidden" name="perc_xml_<%=serviceCode%>" value="<%=servicePercentage%>" />-->
											</td>
										</tr>
										<%
											}
										%>
									</table>
								</div> <%
 	}
 %>

							</td>
							<td style="width: 33%" valign="top">
								<%
									for( int j=0; j< listServiceType.size(); j++) {

								                ArrayList<Properties> vecCodeCol2 = new ArrayList<Properties>();
								                vecCodeCol2 = billingServiceCodesMap.get("group2_".concat(listServiceType.get(j)));
								                headerTitle2 = titleMap.get("group2_".concat(listServiceType.get(j)));
								%>
								<div id="group2_<%=listServiceType.get(j)%>"
									style="display: none;">


									<table style="width: 100%;" class="border1 table-striped table-hover">
										<tr>
											<th style="width: 10%; white-space:nowrap; background-color:silver">
												<div class="smallFont"><%=headerTitle2%></div>
											</th>
											<th style="width: 70%; background-color:silver"><div class="smallFont">Description</div></th>
											<th style="background-color:silver"><div class="smallFont">Fee</div></th>
										</tr>

										<%
											for (int i = 0; i < vecCodeCol2.size(); i++) {
												propT = vecCodeCol2.get(i);
												serviceCode = propT.getProperty("serviceCode");
												serviceDesc = propT.getProperty("serviceDesc");
												serviceDisp = propT.getProperty("serviceDisp");
												servicePercentage = propT.getProperty("servicePercentage");
												serviceType = propT.getProperty("serviceType");
												displayStyle = propT.getProperty("displaystyle");
												sliFlag = Boolean.parseBoolean(propT.getProperty("serviceSLI"));

												if (propPremium.getProperty(serviceCode) != null) premiumFlag = "A";
												else premiumFlag = "";

												String bgcolor = "";
												if (request.getParameter("xml_" + serviceCode) != null) bgcolor = "background-color: #66FF66;";
										%>
										<tr >
											<td style="text-align: left; <%=displayStyle%> white-space:nowrap; <%=bgcolor%>"><input
												type="checkbox" id="xml_<%=serviceCode%>"
												name="xml_<%=serviceCode%>" value="checked"
												onclick="refreshServicesChecked(this);"
												<%=request.getParameter("xml_"+serviceCode)!=null?request.getParameter("xml_"+serviceCode):""%>
												<%=bSingleClick? "onClick='onClickServiceCode(this)'" :""%> />
												<span id="sc<%=(""+i).substring(0,1)+serviceCode%>"
												onclick="getElementById('xml_<%=serviceCode%>').click();"
												onDblClick="onDblClickServiceCode(this)"><%=serviceCode%></span>

											</td>
											<td style="<%=displayStyle%> <%=bgcolor%>"
												<%=serviceDesc.length()>30?"title=\""+serviceDesc+"\"":""%>
												<%=displayStyle.equals("")? "class=\"smallFont\"": "style=\"" + displayStyle + "\""%>>
												<div onclick="getElementById('xml_<%=serviceCode%>').click();">
													<%=serviceDesc.length() > 30 ? serviceDesc.substring(0, 30) + "..." : serviceDesc%>
												</div> <!--<input type="hidden" name="desc_xml_<%=serviceCode%>" value="<%=serviceDesc%>" />-->
											</td>
											<td style="text-align: right;<%=displayStyle%>  <%=bgcolor%>">
												<div class="smallFont"><%=serviceDisp%></div> <input
												type="hidden" name="sli_xml_<%=serviceCode%>"
												value="<%=sliFlag%>" /> <!--<input type="hidden" name="price_xml_<%=serviceCode%>" value="<%=serviceDisp%>" />
					<input type="hidden" name="perc_xml_<%=serviceCode%>" value="<%=servicePercentage%>" />-->
											</td>
										</tr>
										<%
											}
										%>

									</table>
								</div> <%
 	}
 %>

							</td>
							<td style="width: 33%" valign="top">
								<%
									for( int j=0; j< listServiceType.size(); j++) {

								                ArrayList<Properties> vecCodeCol3 = new ArrayList<Properties>();
								                vecCodeCol3 = billingServiceCodesMap.get("group3_".concat(listServiceType.get(j)));
								                headerTitle3 = titleMap.get("group3_".concat(listServiceType.get(j)));
								%>
								<div id="group3_<%=listServiceType.get(j)%>"
									style="display: none;">



									<table style="width: 100%;" class="border1 table-striped table-hover">
										<tr>
											<th style="width: 10%; white-space:nowrap; background-color:silver"><div class="smallFont"><%=headerTitle3%></div></th>
											<th style="width: 70%; background-color:silver"><div class="smallFont">Description</div></th>
											<th style="background-color:silver"><div class="smallFont">Fee</div></th>
										</tr>

										<%
											for (int i = 0; i < vecCodeCol3.size(); i++) {
												propT = vecCodeCol3.get(i);
												serviceCode = propT.getProperty("serviceCode");
												serviceDesc = propT.getProperty("serviceDesc");
												serviceDisp = propT.getProperty("serviceDisp");
												servicePercentage = propT.getProperty("servicePercentage");
												serviceType = propT.getProperty("serviceType");
												displayStyle = propT.getProperty("displaystyle");
												sliFlag = Boolean.parseBoolean(propT.getProperty("serviceSLI"));

												if (propPremium.getProperty(serviceCode) != null) premiumFlag = "A";
												else premiumFlag = "";

												String bgcolor = "";
												if (request.getParameter("xml_" + serviceCode) != null) bgcolor = "background-color: #66FF66;";
										%>
										<tr>
											<td style="text-align: left; <%=displayStyle%> white-space:nowrap; <%=bgcolor%>"><input
												type="checkbox" id="xml_<%=serviceCode%>"
												name="xml_<%=serviceCode%>" value="checked"
												onclick="refreshServicesChecked(this);"
												<%=request.getParameter("xml_"+serviceCode)!=null?request.getParameter("xml_"+serviceCode):""%>
												<%=bSingleClick? "onClick='onClickServiceCode(this)'" :""%> />
												<span id="sc<%=(""+i).substring(0,1)+serviceCode%>"
												onclick="getElementById('xml_<%=serviceCode%>').click();"
												onDblClick="onDblClickServiceCode(this)"><%=serviceCode%></span>
											</td>
											<td style="<%=displayStyle%> <%=bgcolor%> "
												<%=serviceDesc.length()>30?"title=\""+serviceDesc+"\"":""%>
												<%=displayStyle.equals("")? "class=\"smallFont\"": "style=\"" + displayStyle + "\""%>>
												<div onclick="getElementById('xml_<%=serviceCode%>').click();">
													<%=serviceDesc.length() > 30 ? serviceDesc.substring(0, 30) + "..." : serviceDesc%>
													<!--<input type="hidden" name="desc_xml_<%=serviceCode%>" value="<%=serviceDesc%>" />-->
												</div>
											</td>
											<td style="text-align: right; <%=displayStyle%>  <%=bgcolor%>">
												<div class="smallFont"><%=serviceDisp%></div> <input
												type="hidden" name="sli_xml_<%=serviceCode%>"
												value="<%=sliFlag%>" /> <!--<input type="hidden" name="price_xml_<%=serviceCode%>" value="<%=serviceDisp%>" />
					<input type="hidden" name="perc_xml_<%=serviceCode%>" value="<%=servicePercentage%>" />-->
											</td>
										</tr>
										<%
											}
										%>
									</table>
								</div> <%
 	}
 %>

							</td>
						</tr>
					</table>
				</td>
			</tr>

			<input type="hidden" name="clinic_no" value="<%=clinicNo%>" />
			<input type="hidden" name="demographic_no" value="<%=demo_no%>" />
			<input type="hidden" name="appointment_no" value="<%=appt_no%>" />

			<input type="hidden" name="ohip_version" value="V03G" />
			<input type="hidden" name="hin" value="<%=demoHIN%>" />
			<input type="hidden" name="ver" value="<%=demoVer%>" />
			<input type="hidden" name="hc_type" value="<%=demoHCTYPE%>" />
			<input type="hidden" name="sex" value="<%=demoSex%>" />

			<input type="hidden" name="start_time"
				value="<%=request.getParameter("start_time")%>" />

			<input type="hidden" name="demographic_dob" value="<%=demoDOB%>" />

			<input type="hidden" name="apptProvider_no"
				value="<%=request.getParameter("apptProvider_no")%>" />
			<input type="hidden" name="asstProvider_no"
				value="<%=request.getParameter("asstProvider_no")%>" />

			<input type="hidden" name="demographic_name" value="<%=demoname%>" />
			<input type="hidden" name="providerview" value="<%=providerview%>" />
			<input type="hidden" name="appointment_date"
				value="<%=request.getParameter("appointment_date")%>" />
			<input type="hidden" name="assgProvider_no"
				value="<%=assgProvider_no%>" />
			<input type="hidden" name="billForm" value="<%=ctlBillForm%>" />
			<input type="hidden" name="curBillForm" value="<%=ctlBillForm%>" />
			<input type="hidden" name="services_checked">
			<input type="hidden" name="url_back">
			<input type="hidden" name="billNo_old" id="billNo_old"
				value="<%=request.getParameter("billNo_old")%>" />
			<input type="hidden" name="billStatus_old" id="billStatus_old"
				value="<%=request.getParameter("billStatus_old")%>" />

		</table>

		<table style="width: 100%; border-spacing:2px;"
			 >
			<tr style="background-color: silver;">
				<td><%=Encode.forHtml(demoname)%> - <b>Billing History</b> (last 5 records)</td>
				<td style="width: 20%; text-align: right">Last <input type="text"
					name="day" value="365" class="input-small" /> days <input type="button"
					name="buttonDay" value="Go" onClick="onHistory(); return false;" />
				</td>
			</tr>
		</table>
	</form>

	<table style="width: 100%; border-spacing:2px;"
		class="myIvory">
		<tr>
			<td>
				<table class="border1"
					class="table-striped" style="width: 100%;">
					<tr class="myYellow" style="text-align: center">
						<th style="white-space:nowrap">Serial No.</th>
						<th style="white-space:nowrap">Billing Date</th>
						<th style="white-space:nowrap">Appt/Adm Date</th>
						<th style="white-space:nowrap">Service Code</th>
						<th style="white-space:nowrap">Dx</th>
						<th>Create Date</th>
					</tr>
					<%
						// new billing records
						for (int i = 0; i < aL.size(); i = i + 2) {
							BillingClaimHeader1Data obj = (BillingClaimHeader1Data) aL.get(i);
							BillingItemData iobj = (BillingItemData) aL.get(i + 1);
					%>
					<tr style="text-align: center">
						<td class="smallFont"><%=obj.getId()%></td>
						<td class="smallFont"><%=obj.getBilling_date()%></td>
						<td class="smallFont"><%=iobj.getService_date()%></td>
						<td class="smallFont"><%=iobj.getService_code()%></td>
						<td class="smallFont"><%=iobj.getDx()%></td>
						<td class="smallFont"><%=obj.getUpdate_datetime().substring(0, 10)%></td>
					</tr>
					<%
						}
					%>
				</table>
			</td>
		</tr>
	</table>

	<script>

Calendar.setup( { inputField : "xml_vdate", ifFormat : "%Y-%m-%d", showsTime :false, button : "xml_vdate_cal", singleClick : true, step : 1 } );
<%if (appt_no.compareTo("0") == 0) {%>
    Calendar.setup( { inputField : "service_date", ifFormat : "%Y-%m-%d", showsTime :false, button : "service_date_cal", singleClick : true, step : 1 } );
<%}%>

function getDays() {
    if (!document.getElementById("xml_vdate") || !document.getElementById("service_date")) { return; }
    if (document.getElementById("xml_vdate").value == "" || document.getElementById("service_date").value == "" ) { return; }

    let date_xml_vdate = new Date(document.getElementById("xml_vdate").value);
    let date_service_date = new Date(document.getElementById("service_date").value);

    // Convert dates to UTC timestamps
    let utc1 =
        Date.UTC(date_xml_vdate.getFullYear(), date_xml_vdate.getMonth(), date_xml_vdate.getDate());
    let utc2 =
        Date.UTC(date_service_date.getFullYear(), date_service_date.getMonth(), date_service_date.getDate());

    // Calculate the time difference in milliseconds
    let timeDiff = Math.abs(utc2 - utc1);

    // Convert milliseconds to days
    let daysDiff = Math.ceil(timeDiff / (1000 * 60 * 60 * 24));

	let display = " "+daysDiff+"d";

    if (daysDiff > 34){
        let weeksDiff = Math.floor(daysDiff/7);
        let remainder = daysDiff - (weeksDiff*7);
        display = " "+weeksDiff+"w "+remainder+"d";
    }

    // Display the result
    document.getElementById("duration_display").textContent = display;
}

</script>

	<%!String getDefaultValue(String paraName, Vector vec, String propName) {
		String ret = "";
		if (paraName != null && !"".equals(paraName)) {
			ret = paraName;
		} else if (vec != null && vec.size() > 0 && vec.get(0) != null) {
			ret = ((Properties) vec.get(0)).getProperty(propName, "");
		}
		return ret;
	}

	String noNull(String str) {
		if (str != null) {
			return str;
		}
		return "";
	}%>

</body>
</html>
