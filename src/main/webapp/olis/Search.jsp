	<%@page contentType="text/html"%>
	<%@page import="java.util.*,oscar.oscarDB.DBHandler,java.sql.ResultSet, org.oscarehr.common.dao.DemographicDao, 
		org.oscarehr.common.model.Demographic, org.oscarehr.PMmodule.dao.ProviderDao, org.oscarehr.common.model.Provider,
		org.oscarehr.olis.dao.OLISRequestNomenclatureDao, org.oscarehr.olis.dao.OLISResultNomenclatureDao,
		org.oscarehr.olis.model.OLISRequestNomenclature, org.oscarehr.olis.model.OLISResultNomenclature, org.oscarehr.util.SpringUtils" %>
	
	<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
	<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>

	<% 
	if(session.getValue("user") == null) response.sendRedirect("../../logout.jsp");
	%>


	<%
	String outcome = (String) request.getAttribute("outcome");
	if(outcome != null){
	    if(outcome.equalsIgnoreCase("success")){
	%><script type="text/javascript">alert("Lab uploaded successfully");opener.refreshView();</script>
	<%
	    }else if(outcome.equalsIgnoreCase("uploaded previously")){
	%><script type="text/javascript">alert("Lab has already been uploaded");</script>
	<%    
	    }else if(outcome.equalsIgnoreCase("exception")){
	%><script type="text/javascript">alert("Exception uploading the lab");</script>
	<%
	    }else{
	%><script type="text/javascript">alert("Failed to upload lab");</script>
	<%
	    }
	}

	%>
	


	<html>
	<head>
	<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery.js"></script>

	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title><bean:message key="olis.olisSearch" /></title>
	<link rel="stylesheet" type="text/css"
		href="../../../share/css/OscarStandardLayout.css">
	<link rel="stylesheet" type="text/css"
		href="../share/css/OscarStandardLayout.css">
	<script type="text/javascript" src="../../../share/javascript/Oscar.js"></script>
	<script type="text/javascript" src="../share/javascript/Oscar.js"></script>
	<script type="text/javascript">
		    function selectOther(){                
		        if (document.UPLOAD.type.value == "OTHER")
		            document.getElementById('OTHER').style.visibility = "visible";
		        else
		            document.getElementById('OTHER').style.visibility = "hidden";                
		    }
		    function checkInput(){
		        if (document.UPLOAD.lab.value ==""){
		            alert("Please select a lab for upload");
		            return false;
		        }else if (document.UPLOAD.type.value == "OTHER" && document.UPLOAD.otherType.value == ""){
		            alert("Please specify the other message type");
		            return false;
		        }else{
		            var lab = document.UPLOAD.lab.value;
		            var ext = lab.substring((lab.length - 3), lab.length);
		            if (ext != 'hl7' && ext != 'xml'){
		                alert("Error: The lab must be either a .xml or .hl7 file");
		                return false;
		            }
		        }
		        return true;
		    }
		    
		    function checkBlockedConsent(form) {
		    	value = document.forms[form + "_form"].blockedInformationConsent;
		    	if (value != null && value == "Z") {
		    		return confirm("You have chosen to view blocked information.  This action is recorded in the audit log.  Are you sure?")
		    	}
		    	return true;
		    }
		</script>
		
		<style type="text/css">
		table {
			font-size: 12px;
			width: 1000px;
		}
	
		table.innerTable {
			width: 600px;
		}
	
		table.smallTable {
			width: 300px;
		}
	
		th {
			text-align: right;
			font-size: 14px;
		}
	
		td span {
			font-size: 14px;
			font-weight: bold;
		}
	
		input {
			width: 120px;
		}
	
		input.checkbox {
			width: auto;
		}
	</style>
	</head>

	<body>
	
	<table style="width:600px;" class="MainTable" align="left">
		<tbody><tr class="MainTableTopRow">
			<td class="MainTableTopRowLeftColumn" width="175">OLIS</td>
			<td class="MainTableTopRowRightColumn">
			<table class="TopStatusBar">
				<tbody><tr>
					<td>Search</td>
					<td>&nbsp;</td>
					<td style="text-align: right"><a href="javascript:popupStart(300,400,'Help.jsp')"><u>H</u>elp</a> | <a href="javascript:popupStart(300,400,'About.jsp')">About</a> | <a href="javascript:popupStart(300,400,'License.jsp')">License</a></td>
				</tr>
				</tbody>
			</table>
			</td>
		</tr>
		<tr>
			<td colspan="2">

		
	<script type="text/javascript">
	var currentQuery = "Z01";

	function displaySearch(selectBox) {
		queryType = document.getElementById("queryType").value;
		if (document.getElementById(queryType + "_query") != null) {
			document.getElementById(currentQuery + "_query").style.display = "none";
			document.getElementById(queryType + "_query").style.display = "block";
			currentQuery = queryType;
		}
	
	}

	</script>



<%
ProviderDao providerDao = (ProviderDao) SpringUtils.getBean("providerDao");
List<Provider> allProvidersList = providerDao.getActiveProviders(); 

DemographicDao demographicDao = (DemographicDao) SpringUtils.getBean("demographicDao");
List allDemographics = demographicDao.getDemographics();

OLISResultNomenclatureDao resultDao = (OLISResultNomenclatureDao) SpringUtils.getBean("OLISResultNomenclatureDao");
List<OLISResultNomenclature> resultNomenclatureList = resultDao.findAll();

OLISRequestNomenclatureDao requestDao = (OLISRequestNomenclatureDao) SpringUtils.getBean("OLISRequestNomenclatureDao");
List<OLISRequestNomenclature> requestNomenclatureList = requestDao.findAll();

%>
			


	<select id="queryType" onchange="displaySearch(this)" style="margin-left:30px;">
		<option value="Z01">Z01 - Retrieve Laboratory Information for Patient</option>
		<option value="Z02">Z02 - Retrieve Laboratory Information for Order ID</option>
		<option value="Z04">Z04 - Retrieve Laboratory Information Updates for Practitioner</option>
		<option value="Z05">Z05 - Retrieve Laboratory Information Updates for Destination Laboratory</option>
		<option value="Z06">Z06 - Retrieve Laboratory Information Updates for Ordering Facility</option>
		<option value="Z07">Z07 - Retrieve Test Results Reportable to Public Health</option>
		<option value="Z08">Z08 - Retrieve Test Results Reportable to Cancer Care Ontario</option>
		<option value="Z50">Z50 - Identify Patient by Name, Sex, and Date of Birth</option>
	</select>

	<form action="<%=request.getContextPath() %>/olis/Search.do" method="POST" onSubmit="checkBlockedConsent('Z01')" name="Z01_form">
	<input type="hidden" name="queryType" value="Z01" />
	<table id="Z01_query">
		<tbody><tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
		</tr><tr>
			<th width="20%">Observation Date &amp; Time Period<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px;" type="text" name="observationStartTimePeriod" id="observationStartTimePeriod" > to <input style="width:150px" name="obsevationEndTimePeriod" type="text" id="observationEndTimePeriod" ></td>
		</tr>
		<tr>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr><tr>
			<th width="20%">Consent to View Blocked Information?</th>
			<td width="30%"><select id="blockedInformationConsent" name="blockedInformationConsent"><option value="">(none)</option>
			<option value="Z">Temporary </option>
			</select>
			&nbsp;&nbsp;Authorized by: <select name="blockedInformationIndividual" id="blockedInformationIndividual">
			<option value="patient">Patient</option><option value="substitute">Substitute Decision Maker</option><option value="">Neither</option>
			</select> 
			</td>
		</tr>
		<tr>
			<td width="20%" colspan=4><span><input class="checkbox" type="checkbox" name="consentBlockAllIndicator" id="consentBlockAllIndicator"> Enable Patient Consent Block-All Indicator?</span></td>
		</tr>
		<tr>
			<th width="20%">Specimen Collector</th>
			<td width="30%"><select id="specimenCollector" name="specimenCollector">
<option value=""></option>
<option value="4001">BSD Lab1</option>
<option value="4002">BSD Lab2</option>
<option value="4003">BSD Lab3</option>
<option value="4004">BSD Lab4</option>
<option value="4005">BSD Lab5</option>
<option value="4006">BSD Lab6</option>
<option value="4007">BSD Lab7</option>
<option value="4008">BSD Lab8</option>
<option value="4009">BSD Lab9</option>
<option value="4010">BSD Lab10</option>
</select>
</td>
</tr><tr>
			<th width="20%">Performing Laboratory</th>
			<td width="30%"><select id="performingLaboratory" name="performingLaboratory">
<option value=""></option>
<option value="4001">BSD Lab1</option>
<option value="4002">BSD Lab2</option>
<option value="4003">BSD Lab3</option>
<option value="4004">BSD Lab4</option>
<option value="4005">BSD Lab5</option>
<option value="4006">BSD Lab6</option>
<option value="4007">BSD Lab7</option>
<option value="4008">BSD Lab8</option>
<option value="4009">BSD Lab9</option>
<option value="4010">BSD Lab10</option>
</select>
</td>
		</tr>
		<tr>
			<th width="20%">Exclude Performing Laboratory</th>
			<td width="30%"><select id="excludePerformingLaboratory" name="excludePerformingLaboratory">
<option value=""></option>
<option value="4001">BSD Lab1</option>
<option value="4002">BSD Lab2</option>
<option value="4003">BSD Lab3</option>
<option value="4004">BSD Lab4</option>
<option value="4005">BSD Lab5</option>
<option value="4006">BSD Lab6</option>
<option value="4007">BSD Lab7</option>
<option value="4008">BSD Lab8</option>
<option value="4009">BSD Lab9</option>
<option value="4010">BSD Lab10</option>
</select>
</td>
</tr>
<tr>
			<th width="20%">Reporting Laboratory</th>
			<td colspan="3"><select id="reportingLaboratory" name="reportingLaboratory">
<option value=""></option>
<option value="4001">BSD Lab1</option>
<option value="4002">BSD Lab2</option>
<option value="4003">BSD Lab3</option>
<option value="4004">BSD Lab4</option>
<option value="4005">BSD Lab5</option>
<option value="4006">BSD Lab6</option>
<option value="4007">BSD Lab7</option>
<option value="4008">BSD Lab8</option>
<option value="4009">BSD Lab9</option>
<option value="4010">BSD Lab10</option>
</select>
</td>
		</tr>
<tr>
			<th width="20%">Exclude Reporting Laboratory</th>
			<td width="30%"><select id="excludeReportingLaboratory" name="excludeReportingLaboratory">
<option value=""></option>
<option value="4001">BSD Lab1</option>
<option value="4002">BSD Lab2</option>
<option value="4003">BSD Lab3</option>
<option value="4004">BSD Lab4</option>
<option value="4005">BSD Lab5</option>
<option value="4006">BSD Lab6</option>
<option value="4007">BSD Lab7</option>
<option value="4008">BSD Lab8</option>
<option value="4009">BSD Lab9</option>
<option value="4010">BSD Lab10</option>
</select>
</td>
		</tr>
		<tr>
			<td colspan=4><hr /></td>
		</tr>
		<tr>
			<td><span>Patient</span></td><td> 
			<select name="demographic" id="demographic">
<option value=""></option>
<%
for (Object d : allDemographics) {
	Demographic demo = (Demographic) d;
	%>
	<option value="<%=demo.getDemographicNo() %>">[<%=demo.getHin() %> <%=demo.getVer() %> (<%=demo.getHcType() %>)] <%=demo.getLastName() %>, <%=demo.getFirstName() %> (Sex: <%=demo.getSex() %>, DOB: <%=demo.getDateOfBirth() %>)</option>
	<%
}
%>
</select></td>
		</tr>	
		<tr>
			<td colspan=4><hr /></td>
		</tr>	
		<tr>
			<td><span>Requesting HIC</span></td><td>
			<select name="requestingHic" id="requestingHic">
			
			<option value=""></option>
			<%
			for (Provider provider : allProvidersList) {
				%>
				<option value="<%=provider.getProviderNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%	
			}
			%>
</select></td>
		</tr>
		
		<tr>
			<td><hr></td>
		</tr>
		<tr>
			<th width="20%">Ordering Practitioner</th><td>
			<select name="orderingPractitioner" id="orderingPractitioner">
			<option value=""></option>
			<%
			for (Provider provider : allProvidersList) {
				%>
				<option value="<%=provider.getProviderNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%	
			}
			%>
</select></td>		
		</tr>
		<tr>
			<th width="20%">Copied-to Practitioner</th><td>
			<select name="copiedToPractitioner" id="copiedToPractitioner">
			<option value=""></option>
			<%
			for (Provider provider : allProvidersList) {
				%>
				<option value="<%=provider.getProviderNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%	
			}
			%>
</select></td>		
		</tr>
		<tr>
			<th width="20%">Attending Practitioner</th><td>
			<select name="attendingPractitioner" id="attendingPractitioner">
			<option value=""></option>
			<%
			for (Provider provider : allProvidersList) {
				%>
				<option value="<%=provider.getProviderNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%	
			}
			%>
</select></td>		
		</tr>
		<tr>
			<th width="20%">Admitting Practitioner</th><td>
			<select name="admittingPractitioner" id="admittingPractitioner">
			<option value=""></option>
			<%
			for (Provider provider : allProvidersList) {
				%>
				<option value="<%=provider.getProviderNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%	
			}
			%>
</select></td>		
		</tr>
		<tr>
			<th width="20%">Test Request Placer</th><td><select>
<option></option>
<option>BSD Lab1</option>
<option>BSD Lab2</option>
<option>BSD Lab3</option>
<option>BSD Lab4</option>
<option>BSD Lab5</option>
<option>BSD Lab6</option>
<option>BSD Lab7</option>
<option>BSD Lab8</option>
<option>BSD Lab9</option>
<option>BSD Lab10</option>
</select></td>
		</tr>
		<tr>
			<td colspan="4">
				<table>
					<tbody><tr>
						<th width="20%">Test Request Status (max. 15)</th>
						<td><select multiple="multiple" id="testRequestStatus" name="testRequestStatus">
						<option value=""></option>
						<option value="O"> Order Received </option>
						<option value="I"> No results </option>
						<option value="P"> Preliminary </option>
						<option value="A"> Partial </option>
						<option value="F"> Final </option>
						<option value="C"> Correction </option>
						<option value="X"> Cancelled </option>
						<option value="E"> Expired  </option>
						</select></td>
						<th width="20%">Test Result Code (max. 200)</th>
						<td><input type="text"><br><select multiple="multiple" style="width:300px;" name="testResultCode" id="testResultCode">
						<%
						
						for (OLISResultNomenclature nomenclature : resultNomenclatureList) {
						%>
							<option value="<%=nomenclature.getId() %>"><%=oscar.Misc.getStr(nomenclature.getName(), "").trim()%></option>
					    <%
						}
						%>
						</select></td>
						<th width="20%">Test Request Code (max. 100)</th>
						<td><input type="text"><br><select multiple="multiple" style="width:300px;" name="testRequestCode" id="testRequestCode">
						<%
						
						for (OLISRequestNomenclature nomenclature : requestNomenclatureList) {
						%>
							<option value="<%=nomenclature.getId() %>"><%=oscar.Misc.getStr(nomenclature.getName(),"").trim() %></option>
					    <%
						}
						%>
						</select></td>
					</tr>
				</tbody></table>
			</td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>	
	</tbody></table>
	</form>



	<form action="<%=request.getContextPath() %>/olis/Search.do" method="POST" onSubmit="checkBlockedConsent('Z02')" name="Z02_form">
	<input type="hidden" name="queryType" value="Z02" />
	<table id="Z02_query" style="display: none;">
		<tbody><tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<td width="50%" colspan=2><span><input class="checkbox" type="checkbox" name="retrieveAllResults" id="retrieveAllResults"> Retrieve All Test Results?</span></td>
			<th width="20%">Consent to View Blocked Information?</th>
			<td width="30%"><select id="blockedInformationConsent" name="blockedInformationConsent"><option value="">(none)</option>
			<option value="Z">Temporary </option>
			</select>
			<br />Authorized by: <select name="blockedInformationIndividual" id="blockedInformationIndividual">
			<option value="patient">Patient</option><option value="substitute">Substitute Decision Maker</option><option value="">Neither</option>
			</select>
			</td>
		</tr>
		<tr>
			<td width="20%" colspan=4><span><input class="checkbox" type="checkbox" name="consentBlockAllIndicator" id="consentBlockAllIndicator"> Enable Patient Consent Block-All Indicator?</span></td>
		</tr>
		<tr>
			<td colspan=4><hr /></td>
		</tr>
		<tr>
			<td width="20%"><span>Patient</span></td>
			<td> 
			<select name="demographic" id="demographic">
<option value=""></option>
<%
for (Object d : allDemographics) {
	Demographic demo = (Demographic) d;
	%>
	<option value="<%=demo.getDemographicNo() %>">[<%=demo.getHin() %> <%=demo.getVer() %> (<%=demo.getHcType() %>)] <%=demo.getLastName() %>, <%=demo.getFirstName() %> (Sex: <%=demo.getSex() %>, DOB: <%=demo.getDateOfBirth() %>)</option>
	<%
}
%>
</select></td>
		</tr>
		<tr>
			<td colspan=4><hr /></td>
		</tr>
		<tr>
			<td width="20%"><span>Requesting HIC</span></td>
			<td><select name="requestingHic" id="requestingHic">
			
			<option value=""></option>
			<%
			for (Provider provider : allProvidersList) {
				%>
				<option value="<%=provider.getProviderNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%	
			}
			%>
</select></td>		
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>



	<form action="<%=request.getContextPath() %>/olis/Search.do" method="POST">
	<input type="hidden" name="queryType" value="Z04" />
	<table id="Z04_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<td colspan=4><hr /></td>
		</tr>
		<tr>
			<td width="20%"><span>Requesting HIC</span></td><td><select name="requestingHic" id="requestingHic">
			
			<option value=""></option>
			<%
			for (Provider provider : allProvidersList) {
				%>
				<option value="<%=provider.getProviderNo() %>">[<%=provider.getProviderNo()%>] <%=provider.getLastName() %>, <%=provider.getFirstName() %></option>
			<%	
			}
			%>
</select></td>		
		</tr>
		
		<tr>
			<td colspan="4"><hr></td>
		</tr>
		<tr>
			<td colspan="4">
				<table>
					<tbody><tr>
						<th width="20%">Test Result Code (max. 200)</th>
						<td><input type="text"><br><select multiple="multiple" style="width:300px;" name="testResultCode" id="testResultCode">
						<%
						
						for (OLISResultNomenclature nomenclature : resultNomenclatureList) {
						%>
							<option value="<%=nomenclature.getId() %>"><%=nomenclature.getName().trim() %></option>
					    <%
						}
						%>
						</select></td>
						<th width="20%">Test Request Code (max. 100)</th>
						<td><input type="text"><br><select multiple="multiple" style="width:300px;" name="testRequestCode" id="testRequestCode">
						<%
						
						for (OLISRequestNomenclature nomenclature : requestNomenclatureList) {
						%>
							<option value="<%=nomenclature.getId() %>"><%=nomenclature.getName().trim() %></option>
					    <%
						}
						%>
						</select></td>
					</tr>
				</tbody></table>
			</td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
	</tbody></table>
	</form>
	
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do" method="POST">
	<input type="hidden" name="queryType" value="Z05" />
	<table id="Z05_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<th width="20%">Destination Laboratory</th>
			<td width="30%"><select id="destinationLaboratory" name="destinationLaboratory">
<option value=""></option>
<option value="4001">BSD Lab1</option>
<option value="4002">BSD Lab2</option>
<option value="4003">BSD Lab3</option>
<option value="4004">BSD Lab4</option>
<option value="4005">BSD Lab5</option>
<option value="4006">BSD Lab6</option>
<option value="4007">BSD Lab7</option>
<option value="4008">BSD Lab8</option>
<option value="4009">BSD Lab9</option>
<option value="4010">BSD Lab10</option>
</select>
</td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do" method="POST">
	<input type="hidden" name="queryType" value="Z06" />
	<table id="Z06_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<th width="20%">Ordering Facility</th>
			<td width="30%"><select id="orderingFacility" name="orderingFacility">
<option value=""></option>
<option value="4001">BSD Lab1</option>
<option value="4002">BSD Lab2</option>
<option value="4003">BSD Lab3</option>
<option value="4004">BSD Lab4</option>
<option value="4005">BSD Lab5</option>
<option value="4006">BSD Lab6</option>
<option value="4007">BSD Lab7</option>
<option value="4008">BSD Lab8</option>
<option value="4009">BSD Lab9</option>
<option value="4010">BSD Lab10</option>
</select>
</td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do" method="POST">
	<input type="hidden" name="queryType" value="Z07" />
	<table id="Z07_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do" method="POST">
	<input type="hidden" name="queryType" value="Z08" />
	<table id="Z08_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">Date &amp; Time Period to Search<br />(yyyy-mm-dd)</th>
			<td width="30%"><input style="width:150px" type="text" name="startTimePeriod" id="startTimePeriod" value="" > to <input style="width:150px" name="endTimePeriod" type="text" id="endTimePeriod" ></td>
			<th width="20%"><input class="checkbox" type="checkbox" name="quantityLimitedQuery" id="quantityLimitedQuery"> Quantity Limit?</th>
			<td width="30%">Quantity<br><input type="text" id="quantityLimit" name="quantityLimit"></td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
	
	<form action="<%=request.getContextPath() %>/olis/Search.do" method="POST">
	<input type="hidden" name="queryType" value="Z50" />
	<table id="Z50_query" style="display: none;">
		<tbody>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		<tr>
			<th width="20%">First Name</th>
			<td width="30%"><input type="text" id="z50firstName" name="z50firstName"></td>
			<th width="20%">Last Name</th>
			<td width="30%"><input type="text" id="z50lastName" name="z50lastName"></td>
		</tr>
		<tr>
			<th width="20%">Sex</th>
			<td width="30%"><select name="z50sex"><option value="M">M</option><option value="F">F</option></select></td>
			<th width="20%">Date of Birth</th>
			<td width="30%"><input type="text" id="z50dateOfBirth" name="z50dateOfBirth"></td>
		</tr>
		<tr>
			<td colspan=2><input type="submit" name="submit" value="Search" /></td>
		</tr>
		</tbody>
	</table>
	</form>
	
	
			</td>
		</tr>
	</tbody></table>
	</body>
	</html>