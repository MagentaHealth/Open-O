<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
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

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_search" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_search");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<!DOCTYPE HTML>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@page import="org.oscarehr.caisi_integrator.ws.CachedProvider"%>
<%@page import="org.oscarehr.caisi_integrator.ws.FacilityIdStringCompositePk"%>
<%@page import="org.oscarehr.PMmodule.caisi_integrator.CaisiIntegratorManager"%>
<%@page import="org.apache.commons.lang.time.DateFormatUtils"%>
<%@page import="org.oscarehr.common.dao.OscarLogDao"%>
<%@page import="org.oscarehr.caisi_integrator.ws.DemographicTransfer"%>
<%@page import="org.oscarehr.caisi_integrator.ws.MatchingDemographicTransferScore"%>
<%@page import="org.oscarehr.casemgmt.service.CaseManagementManager"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%
//     Boolean isMobileOptimized = session.getAttribute("mobileOptimized") != null;

     LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
     
 	GregorianCalendar now=new GregorianCalendar();
 	int curYear = now.get(Calendar.YEAR);
 	int curMonth = (now.get(Calendar.MONTH)+1);
 	int curDay = now.get(Calendar.DAY_OF_MONTH);
 	String curProvider_no = (String) session.getAttribute("user");
 	

%>


<%@ page import="java.util.*, java.sql.*, java.net.URLEncoder, oscar.*, oscar.util.*" %>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="oscar.oscarDemographic.data.DemographicMerged" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="org.oscarehr.common.dao.DemographicExtDao" %>
<%@ page import="org.oscarehr.common.model.DemographicExt" %>
<jsp:useBean id="providerBean" class="java.util.Properties"	scope="session" />

<%
	String strOffset = "0";
	String strLimit = "18";
	String deepColor = "#CCCCFF", weakColor = "#EEEEFF";
	if (request.getParameter("limit1") != null) {
		strOffset = request.getParameter("limit1");
	}
	if (request.getParameter("limit2") != null) {
		strLimit = request.getParameter("limit2");
	}

	int offset = Integer.parseInt(strOffset);
	int limit = Integer.parseInt(strLimit);

	String displayMode = request.getParameter("displaymode");
	String dboperation = request.getParameter("dboperation");
	String keyword = null;
	if(request.getParameter("keyword")!=null){
		keyword = Encode.forJava(request.getParameter("keyword"));
	}
	String orderBy = request.getParameter("orderby");
	String ptStatus = request.getParameter("ptstatus") == null ? "active" : request.getParameter("ptstatus");;

	java.util.ResourceBundle oscarResources = ResourceBundle.getBundle("oscarResources", request.getLocale());
    String noteReason = oscarResources.getString("oscarEncounter.noteReason.TelProgress");

	if (OscarProperties.getInstance().getProperty("disableTelProgressNoteTitleInEncouterNotes") != null 
			&& OscarProperties.getInstance().getProperty("disableTelProgressNoteTitleInEncouterNotes").equals("yes")) {
		noteReason = "";
	}

%>
<html:html lang="en">
	<script src="${pageContext.request.contextPath}/csrfguard"></script>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<script type="text/javascript" src="<c:out value="${ctx}/share/javascript/Oscar.js"/>"></script>
<title><bean:message key="demographic.demographicsearchresults.title" /></title>

	<script src="${pageContext.request.contextPath}/library/jquery/jquery-3.6.4.min.js" type="text/javascript"></script>
	<script src="${pageContext.request.contextPath}/library/bootstrap/3.0.0/js/bootstrap.min.js" type="text/javascript"></script>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/library/jquery/jquery-ui-1.12.1.min.css"/>
	<link href="${pageContext.request.contextPath}/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet" type="text/css"/>

   <script>
     jQuery.noConflict();
   </script>

   <link rel="stylesheet" type="text/css" media="all" href="${pageContext.request.contextPath}/demographic/searchdemographicstyle.css"  />
	<link rel="stylesheet" type="text/css" media="all" href="${pageContext.request.contextPath}/share/css/searchBox.css"  />

   <style> .deep { background-color: <%= deepColor %>; } .weak { background-color: <%= weakColor %>; } </style>

<script type="text/javascript">

	function showHideItem(id) {
		if (document.getElementById(id).style.display == 'inline')
			document.getElementById(id).style.display = 'none';
		else
			document.getElementById(id).style.display = 'inline';
	}
	function setfocus() {
		document.titlesearch.keyword.focus();
		document.titlesearch.keyword.select();
	}

	function checkTypeIn() {
		var dob = document.titlesearch.keyword;
		typeInOK = true;

		if (dob.value.indexOf('%b610054') == 0 && dob.value.length > 18) {
			document.titlesearch.keyword.value = dob.value.substring(8, 18);
			document.titlesearch.search_mode[4].checked = true;
		}
		if (document.titlesearch.search_mode[0].checked) {
			var keyword = document.titlesearch.keyword.value;
			var keywordLowerCase = keyword.toLowerCase();
			document.titlesearch.keyword.value = keywordLowerCase;
		}
		if (document.titlesearch.search_mode[2].checked) {
			if (dob.value.length == 8) {
				dob.value = dob.value.substring(0, 4) + "-"
						+ dob.value.substring(4, 6) + "-"
						+ dob.value.substring(6, 8);
			}
			if (dob.value.length != 10) {
				alert("<bean:message key="demographic.search.msgWrongDOB"/>");
				typeInOK = false;
			}

			return typeInOK;
		} else {
			return true;
		}
	}

	function popup(vheight, vwidth, varpage) {
		var page = varpage;
		windowprops = "height="
				+ vheight
				+ ",width="
				+ vwidth
				+ ",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
		var popup = window.open(varpage, "<bean:message key="global.oscarRx"/>_________________$tag________________________________demosearch",	windowprops);
		if (popup != null) {
			if (popup.opener == null) {
				popup.opener = self;
			}
			popup.focus();
		}
	}

	function popupEChart(vheight,vwidth,varpage) { //open a new popup window
		  var page = "" + varpage;
		  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=50,screenY=50,top=20,left=20";
		  var popup=window.open(page, "encounter", windowprops);
		  if (popup != null) {
		    if (popup.opener == null) {
		      popup.opener = self;
		    }
		    popup.focus();
		  }
		}
</SCRIPT>
</head>
	

<body onLoad="setfocus()" >
<div class="container">
<div id="demographicSearch" style="margin-bottom: 10px;">
	<h2 style="margin:auto 15px;"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-search" viewBox="0 0 16 16">
		<path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001q.044.06.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1 1 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0"></path>
	</svg>Search Patient</h2>
    <a  href="javascript:void(0)" onclick="showHideItem('demographicSearch');" id="cancelButton" class="leftButton top"> <bean:message key="global.btnCancel" /> </a>
	<%@ include file="zdemographicfulltitlesearch.jsp"%>
</div>


<div id="searchResults">
<a  href="javascript:void(0)" onclick="showHideItem('demographicSearch');" id="searchPopUpButton" class="rightButton top">Search</a>

<i><bean:message key="demographic.demographicsearchresults.msgSearchKeys" /></i> : <c:out value="${param.keyword}" />

    <table id="patientResults" class="table table-condensed table-striped table-responsive">
        <tr class="tableHeadings deep">
        
		<% if ( fromMessenger ) {%>
		<!-- leave blank -->
		                <th class="demoIdSearch">
                    <a href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=demographic_no&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
                        key="demographic.demographicsearchresults.btnDemoNo" /></a>
                </th>
		<%} else {%>
                <th class="demoIdSearch">
                    <a href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=demographic_no&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
                        key="demographic.demographicsearchresults.btnDemoNo" /></a>
                </th>
		<th class="links"><bean:message key="demographic.demographicsearchresults.module" /></th>

		<%}%>
		<th class="name"><a
                    href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=last_name&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
                    key="demographic.demographicsearchresults.btnDemoName"/></a>
                </th>
		<th class="chartNo"><a
			href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=chart_no&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
			key="demographic.demographicsearchresults.btnChart" /></a>
                </th>
		<th class="sex"><a
			href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=sex&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
			key="demographic.demographicsearchresults.btnSex" /></a>
                </th>
		<th class="dob"><a
			href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=dob&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
			key="demographic.demographicsearchresults.btnDOB" /> <span class="dateFormat"><bean:message key="demographic.demographicsearchresults.btnDOBFormat" /></span></a>
                </th>
		<th class="doctor"><a
			href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=provider_no&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
			key="demographic.demographicsearchresults.btnDoctor" /></a>
                </th>
                <th class="rosterStatus"><a
			href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=roster_status&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
                        key="demographic.demographicsearchresults.btnRosSta" /></a>
                </th>
		<th class="patientStatus"><a
			href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=patient_status&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
                        key="demographic.demographicsearchresults.btnPatSta" /></a>
                </th>
                <th class="phone"><a
			href="demographiccontrol.jsp?fromMessenger=<%=fromMessenger%>&keyword=<%=StringEscapeUtils.escapeHtml(request.getParameter("keyword"))%>&displaymode=<%=request.getParameter("displaymode")%>&search_mode=<%=request.getParameter("search_mode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=phone&limit1=0&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>"><bean:message
			key="demographic.demographicsearchresults.btnPhone" /></a>
                </th>
	</tr>

<%!
	DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
        OscarLogDao oscarLogDao = SpringUtils.getBean(OscarLogDao.class);
	CaseManagementManager caseManagementManager = SpringUtils.getBean(CaseManagementManager.class);

%>
<%
	String providerNo = loggedInInfo.getLoggedInProviderNo();
	boolean outOfDomain = true;
	if(OscarProperties.getInstance().getProperty("ModuleNames","").indexOf("Caisi") != -1) {
		if(!"true".equals(OscarProperties.getInstance().getProperty("pmm.client.search.outside.of.domain.enabled","true"))) {
			outOfDomain=false;
		}
		if(request.getParameter("outofdomain")!=null && request.getParameter("outofdomain").equals("true")) {
			outOfDomain=true;
		}
	}
	
	

	if (searchMode == null) {
		searchMode = "search_name";
	}
	if (orderBy == null) {
		orderBy = "last_name";
	}
	
	
	List<Demographic> demoList = null;

        if(keyword!=null && keyword.length()==0) {
            int mostRecentPatientListSize=Integer.parseInt(OscarProperties.getInstance().getProperty("MOST_RECENT_PATIENT_LIST_SIZE","3"));
            List<Integer> results = oscarLogDao.getRecentDemographicsAccessedByProvider(providerNo,  0, mostRecentPatientListSize);
            demoList = new ArrayList<Demographic>();
            for(Integer r:results) {
                demoList.add(demographicDao.getDemographicById(r));
            }
            
        } else {
            demoList = doSearch(demographicDao,searchMode,ptStatus,keyword,limit,offset,orderBy,providerNo,outOfDomain);
        }	
	
	boolean toggleLine = false;
	boolean firstPageShowIntegratedResults = request.getParameter("firstPageShowIntegratedResults") != null && "true".equals(request.getParameter("firstPageShowIntegratedResults"));
	int nItems=0;

	if(demoList==null) {
		out.println("Your Search Returned No Results!!!");
	} 
	else {
		
		if(orderBy.equals("last_name")) {
			Collections.sort(demoList, Demographic.LastNameComparator);
		}
		else if (orderBy.equals("last_name, first_name")) {
		    Collections.sort(demoList, Demographic.LastAndFirstNameComparator);
		}
		else if(orderBy.equals("demographic_no")) {
			Collections.sort(demoList, Demographic.DemographicNoComparator);
		}
		else if(orderBy.equals("chart_no")) {
			Collections.sort(demoList, Demographic.ChartNoComparator);
		}
		else if(orderBy.equals("sex")) {
			Collections.sort(demoList, Demographic.SexComparator);
		}
		else if(orderBy.equals("dob")) {
			Collections.sort(demoList, Demographic.DateOfBirthComparator);
		}
		else if(orderBy.equals("provider_no")) {
			Collections.sort(demoList, Demographic.ProviderNoComparator);
		}
		else if(orderBy.equals("roster_status")) {
			Collections.sort(demoList, Demographic.RosterStatusComparator);
		}
		else if(orderBy.equals("patient_status")) {
			Collections.sort(demoList, Demographic.PatientStatusComparator);
		}
		else if(orderBy.equals("phone")) {
			Collections.sort(demoList, Demographic.PhoneComparator);
		}
		
		
		@SuppressWarnings("unchecked")
		  List<MatchingDemographicTransferScore> integratorSearchResults=(List<MatchingDemographicTransferScore>)request.getAttribute("integratorSearchResults");
		  
		  
		  if (integratorSearchResults!=null) {
		      firstPageShowIntegratedResults = true;
			  for (MatchingDemographicTransferScore matchingDemographicTransferScore : integratorSearchResults) {
			      if( isLocal(matchingDemographicTransferScore, demoList)) {
				  	continue;
			      }
				  
				  DemographicTransfer demographicTransfer=matchingDemographicTransferScore.getDemographicTransfer();
		%>
				   <tr class="<%=toggleLine?"even":"odd"%>">
				   <td class="demoIdSearch">
				   	<a title="Import"  href="javascript:void(0)"  onclick="popup(700,1027,'../appointment/copyRemoteDemographic.jsp?remoteFacilityId=<%=demographicTransfer.getIntegratorFacilityId()%>&demographic_no=<%=String.valueOf(demographicTransfer.getCaisiDemographicId())%>&originalPage=../demographic/demographiceditdemographic.jsp&provider_no=<%=curProvider_no%>')" >Import</a></td>
				   <td class="links">Remote</td>
				   <td class="name"><%=Encode.forHtml(Misc.toUpperLowerCase(demographicTransfer.getLastName()) + ", " + Misc.toUpperLowerCase(demographicTransfer.getFirstName()))%></td>
				   <td class="chartNo"></td>
				   <td class="sex"><%=demographicTransfer.getGender()%></td>
				   <td class="dob"><%=demographicTransfer.getBirthDate() != null ?  DateFormatUtils.ISO_DATE_FORMAT.format(demographicTransfer.getBirthDate()) : ""%></td>
				   <td class="doctor">
				   
		<% 
		   		FacilityIdStringCompositePk providerPk=new FacilityIdStringCompositePk();
		   		providerPk.setIntegratorFacilityId(demographicTransfer.getIntegratorFacilityId());
		   		providerPk.setCaisiItemId(demographicTransfer.getCaisiProviderId());
		   		CachedProvider cachedProvider=CaisiIntegratorManager.getProvider(loggedInInfo, loggedInInfo.getCurrentFacility(), providerPk);
		   		MiscUtils.getLogger().debug("Cached provider, pk="+providerPk.getIntegratorFacilityId()+","+providerPk.getCaisiItemId()+", cachedProvider="+cachedProvider);
		   		
		   		String providerName="";
		   		
		   		if (cachedProvider!=null)
		   		{
		   			providerName=cachedProvider.getLastName()+", "+cachedProvider.getFirstName();
		   		}
		%>
		        	<%=providerName%>
					</td>
					<td class="rosterStatus"></td>
					<td class="patientStatus"></td>
					<td class="phone"><%=demographicTransfer.getPhone1()%></td>
				</tr>
		<%	  
					toggleLine = !toggleLine;
					nItems++;
				}
		 	}
		
		

		DemographicMerged dmDAO = new DemographicMerged();

		for(Demographic demo : demoList) {


			
			String dem_no = demo.getDemographicNo().toString();
			String head = dmDAO.getHead(dem_no);

			if (head != null && !head.equals(dem_no)) {
				//skip non head records
				nItems++;
				continue;
			}

%>
	<tr class="<%=toggleLine?"even":"odd"%>">
	<td class="demoIdSearch">

	<%

		if (fromMessenger) {
	%>
		<a href="demographiccontrol.jsp?keyword=<%=Encode.forUriComponent(Encode.forHtml(Misc.toUpperLowerCase(demo.getLastName()+", "+demo.getFirstName())))%>&demographic_no=<%= dem_no %>&displaymode=linkMsg2Demo&dboperation=search_detail" ><%=demo.getDemographicNo()%></a></td>
	<%	
		} else { 
	%>
		<a title="Master Demographic File"  href="javascript:void(0)"  onclick="popup(700,1027,'demographiccontrol.jsp?demographic_no=<%=head%>&displaymode=edit&dboperation=search_detail')" ><%=dem_no%></a></td>
	
		<!-- Rights -->
		<td class="links"><security:oscarSec roleName="<%=roleName$%>"
			objectName="_eChart" rights="r">
			<a class="encounterBtn" title="Encounter"  href="javascript:void(0)"
				onclick="popupEChart(710,1024,'<c:out value="${ctx}"/>/oscarEncounter/IncomingEncounter.do?providerNo=<%=curProvider_no%>&appointmentNo=&demographicNo=<%=dem_no%>&curProviderNo=&reason=<%=URLEncoder.encode(noteReason)%>&encType=&curDate=<%=""+curYear%>-<%=""+curMonth%>-<%=""+curDay%>&appointmentDate=&startTime=&status=');return false;">E</a>
		</security:oscarSec> <!-- Rights --> <security:oscarSec roleName="<%=roleName$%>"
			objectName="_rx" rights="r">
			<a class="rxBtn" title="Prescriptions"  href="javascript:void(0)" onclick="popup(700,1027,'<c:out value="${ctx}"/>/oscarRx/choosePatient.do?providerNo=<%=demo.getProviderNo()%>&demographicNo=<%=dem_no%>')">Rx</a>
			</security:oscarSec>
			<security:oscarSec roleName="<%=roleName$%>" objectName="_tickler" rights="r">
			<a class="ticklerBtn" title="Tickler"  href="javascript:void(0)" onclick="popup(700,1027,'<c:out value="${ctx}"/>/tickler/ticklerMain.jsp?demoview=<%=dem_no%>')">T</a>
			</security:oscarSec>
			<security:oscarSec roleName="<%=roleName$%>" objectName="_con" rights="r">
			<a class="consultBtn" title="Consultation"  href="javascript:void(0)" onclick="popup(700,1027,'<c:out value="${ctx}"/>/oscarEncounter/oscarConsultationRequest/DisplayDemographicConsultationRequests.jsp?de=<%=dem_no%>')">C</a>
			</security:oscarSec>
		</td>

	<%	
		}
	%>
		<caisi:isModuleLoad moduleName="caisi">
		<td class="name"><a  href="javascript:void(0)" onclick="location.href='<%= request.getContextPath() %>/PMmodule/ClientManager.do?id=<%=dem_no%>'"><%=Encode.forHtml(Misc.toUpperLowerCase(demo.getLastName()))%>, <%=Encode.forHtml(Misc.toUpperLowerCase(demo.getFirstName()))%></a></td>
		</caisi:isModuleLoad>
		<caisi:isModuleLoad moduleName="caisi" reverse="true">
		<td class="name"><%=Encode.forHtml(Misc.toUpperLowerCase(demo.getLastName()+", "+Misc.toUpperLowerCase(demo.getFirstName()) + " " + Misc.toUpperLowerCase(demo.getMiddleNames())))%></td>
		</caisi:isModuleLoad>
		<td class="chartNo"><%=Encode.forHtml(demo.getChartNo()==null||demo.getChartNo().equals("")?" ":demo.getChartNo())%></td>
		<td class="sex"><%=demo.getSex()%></td>
		<td class="dob"><%=demo.getFormattedDob()%></td>
		<td class="doctor"><%=Misc.getShortStr(providerBean.getProperty(demo.getProviderNo() == null ? "" : demo.getProviderNo()),"_",12 )%></td>
		<td class="rosterStatus"><%=demo.getRosterStatus()==null||demo.getRosterStatus().equals("")?" ":demo.getRosterStatus()%></td>
		<td class="patientStatus"><%=demo.getPatientStatus()==null||demo.getPatientStatus().equals("")?" ":demo.getPatientStatus()%></td>
		<td class="phone"><%=Encode.forHtml(demo.getPhone()==null||demo.getPhone().equals("")?" ":(demo.getPhone().length()==10?(demo.getPhone().substring(0,3)+"-"+demo.getPhone().substring(3)):demo.getPhone()))%></td>
	</tr>
	<%
		
	toggleLine = !toggleLine;
	nItems++; //to calculate if it is the end of records
		}
	}
%>
</table>
<%

  
  int nLastPage=0,nNextPage=0;
  nNextPage=Integer.parseInt(strLimit)+Integer.parseInt(strOffset);
  nLastPage=Integer.parseInt(strOffset)-Integer.parseInt(strLimit);
  if(nLastPage>=0) {
%> 
	<a href="demographiccontrol.jsp?keyword=<%=URLEncoder.encode(keyword,"UTF-8")%>&search_mode=<%=searchMode%>&displaymode=<%=displayMode%>&dboperation=<%=dboperation%>&orderby=<%=orderBy%>&limit1=<%=nLastPage%>&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>&firstPageShowIntegratedResults=<%=firstPageShowIntegratedResults%><%=nLastPage==0 && firstPageShowIntegratedResults?"&includeIntegratedResults=true":""%>">
	<bean:message key="demographic.demographicsearchresults.btnLastPage" /></a> <%
  }
  if(nItems>=Integer.parseInt(strLimit)) {
      if (nLastPage>=0) {
	%> | <%    } %> 
	<a href="demographiccontrol.jsp?keyword=<%=URLEncoder.encode(keyword,"UTF-8")%>&search_mode=<%=searchMode%>&displaymode=<%=displayMode%>&dboperation=<%=dboperation%>&orderby=<%=orderBy%>&limit1=<%=nNextPage%>&limit2=<%=strLimit%>&ptstatus=<%=ptStatus%>&firstPageShowIntegratedResults=<%=firstPageShowIntegratedResults%>">
	<bean:message key="demographic.demographicsearchresults.btnNextPage" /></a>
<%
}
%>
<br> 
<div class="createNew">
<a href="demographicaddarecordhtm.jsp?search_mode=<%=searchMode%>&keyword=<%=StringEscapeUtils.escapeHtml(keyWord)%>" title="<bean:message key="demographic.search.btnCreateNewTitle" />">
<bean:message key="demographic.search.btnCreateNew" />
</a>
</div>

<caisi:isModuleLoad moduleName="caisi">
<div class="goBackToSchedule">
<a href="../provider/providercontrol.jsp" title="<bean:message key="demographic.search.btnReturnToSchedule" />">
<bean:message key="demographic.search.btnReturnToSchedule" />
</a>
</div>
</caisi:isModuleLoad>


</div>
</div>
</body>
</html:html>
<%!

Boolean isLocal(MatchingDemographicTransferScore matchingDemographicTransferScore, List<Demographic> demoList) {
    String hin = matchingDemographicTransferScore.getDemographicTransfer().getHin(); 
    for( Demographic demo : demoList ) {
		
		if( hin != null && hin.equals(demo.getHin()) ) {
		    return true;
		}
    }
    
    return false;
    
}

List<Demographic> doSearch(DemographicDao demographicDao,String searchMode, String ptstatus, String keyword, int limit, int offset, String orderBy, String providerNo, boolean outOfDomain) {
	List<Demographic> demoList = null;  
	OscarProperties props = OscarProperties.getInstance();
	String pstatus = props.getProperty("inactive_statuses", "IN, DE, IC, ID, MO, FI");
	pstatus = pstatus.replaceAll("'","").replaceAll("\\s", "");
	List<String> stati = Arrays.asList(pstatus.split(","));



	if( "".equals(ptstatus) ) {
		if(searchMode.equals("search_name")) {
			demoList = demographicDao.searchDemographicByName(keyword, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_phone")) {
			demoList = demographicDao.searchDemographicByPhone(keyword, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_dob")) {
			demoList = demographicDao.searchDemographicByDOB(keyword, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_address")) {
			demoList = demographicDao.searchDemographicByAddress(keyword, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_hin")) {
			demoList = demographicDao.searchDemographicByHIN(keyword, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_chart_no")) {
			demoList = demographicDao.findDemographicByChartNo(keyword, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_demographic_no")) {
			demoList = demographicDao.findDemographicByDemographicNo(keyword, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_band_number")) {
			demoList = demographicDao.findDemographicByDemographicNo(getDemographicNumberWithBandNumber(keyword), limit, offset,orderBy,providerNo,outOfDomain);
		}
	}
	else if( "active".equals(ptstatus) ) {
	    if(searchMode.equals("search_name")) {
			demoList = demographicDao.searchDemographicByNameAndNotStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
	    else if(searchMode.equals("search_phone")) {
			demoList = demographicDao.searchDemographicByPhoneAndNotStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_dob")) {
			demoList = demographicDao.searchDemographicByDOBAndNotStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_address")) {
			demoList = demographicDao.searchDemographicByAddressAndNotStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_hin")) {
			demoList = demographicDao.searchDemographicByHINAndNotStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_chart_no")) {
			demoList = demographicDao.findDemographicByChartNoAndNotStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_demographic_no")) {
			demoList = demographicDao.findDemographicByDemographicNoAndNotStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_band_number")) {
			demoList = demographicDao.findDemographicByDemographicNoAndNotStatus(getDemographicNumberWithBandNumber(keyword), stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
	}
	else if( "inactive".equals(ptstatus) ) {
	    if(searchMode.equals("search_name")) {
			demoList = demographicDao.searchDemographicByNameAndStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
	    else if(searchMode.equals("search_phone")) {
			demoList = demographicDao.searchDemographicByPhoneAndStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_dob")) {
			demoList = demographicDao.searchDemographicByDOBAndStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_address")) {
			demoList = demographicDao.searchDemographicByAddressAndStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_hin")) {
			demoList = demographicDao.searchDemographicByHINAndStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_chart_no")) {
			demoList = demographicDao.findDemographicByChartNoAndStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_demographic_no")) {
			demoList = demographicDao.findDemographicByDemographicNoAndStatus(keyword, stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
		else if(searchMode.equals("search_band_number")) {
			demoList = demographicDao.findDemographicByDemographicNoAndStatus(getDemographicNumberWithBandNumber(keyword), stati, limit, offset,orderBy,providerNo,outOfDomain);
		}
	}

	return new ArrayList<>(new HashSet<>(demoList != null ? demoList : Collections.emptyList()));

}

String getDemographicNumberWithBandNumber(String bandNumber) {
	//Gets the demographicExtDao
	DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
	//Gets the demographicExts that match the given key and value
	List<DemographicExt> demographicExts = demographicExtDao.getDemographicExtByKeyAndValue("statusNum", bandNumber);
	//Creates a demographicNumber string with the value of '-1'
	String demographicNumber = "-1";
	//If the list is not null and is not empty, gets the demographic number from the first record and converts it to a string
	if (demographicExts != null && !demographicExts.isEmpty()) {
		demographicNumber = demographicExts.get(0).getDemographicNo().toString();
	}
	//Returns the demographicNumber
	return demographicNumber;
}

%>
