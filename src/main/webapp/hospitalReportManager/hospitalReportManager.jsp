<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>
<!DOCTYPE html>

<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
      boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%
   LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="java.util.*"%>
<%@ page import="org.oscarehr.hospitalReportManager.SFTPConnector, org.oscarehr.hospitalReportManager.dao.HRMProviderConfidentialityStatementDao" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html:html>
<head>
<html:base />
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Hospital Report Manager</title>
	<style>
		body {
			margin-left: 30px !important;
		}

		.file-item {
			border: 1px solid green;
			border-radius: 5px;
			padding: 7px;
			margin-bottom: 3px;
			font-size: 14px;
			word-wrap: break-word;
			max-width: 100%;
			position: relative;
		}

		.upload-text {
			position: absolute;
			top: 50%;
			right: 10px;
			transform: translateY(-50%);
			font-weight: bold;
		}

		.file-name {
			max-width: calc(100% - 170px);
			display: inline-block;
			vertical-align: middle;
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
		}

		.loading-screen {
			position: fixed;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			background-color: #f1f1f1;
			display: none;
			flex-direction: column;
			align-items: center;
			justify-content: center;
			z-index: 9999;
		}

		.loading-bar {
			width: 50%;
			margin-bottom: 20px;
		}

		.loading-message {
			font-size: 16px;
			font-weight: bold;
		}

		.flex {
			display: flex;
		}

		.invalid {
			color: red;
		}

		.success,
		.pending {
			color: green;
		}

		.failed {
			color: #FFD700;
		}
  	</style>

    <script src="<%= request.getContextPath() %>/js/global.js"></script>
	<script type="text/javascript" src="${pageContext.request.contextPath}/library/jquery/jquery-3.6.4.min.js" ></script>

	<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/hospitalReportManager/inbox.css" >


	<script>
	function runFetch() {
		window.location = "<%=request.getContextPath() %>/hospitalReportManager/hospitalReportManager.jsp?fetch=true";
	}

	function validateForm() {
		let fileInput = document.getElementById("fileInput");
		if (fileInput.files.length === 0) {
		  alert("Please select a file to upload.");
		  return false;
		}

		document.getElementById("file-upload-btn").disabled = true;
		document.querySelector('.loading-screen').classList.toggle('flex');
		return true;
	}

	function getFileList(event) {
		const fileList = document.getElementById('file-list');
		const files = event.target.files;
		fileList.innerHTML = '';

		for (let i = 0; i < files.length; i++) {
			addFileNameWithStatus(files[i].name, "PENDING");
		}
	}

	function addFileNameWithStatus(name, status) {
		const fileList = document.getElementById('file-list');
		const fileItem = document.createElement('div');
		fileItem.className = 'file-item';

		const fileName = document.createElement('span');
		fileName.className = 'file-name';
		fileName.textContent = name;

		const uploadText = document.createElement('span');
		uploadText.className = 'upload-text';
		uploadText.classList.remove('invalid', 'success', 'pending', 'failed');
		switch (status.trim()) {
			case "FAILED":
				uploadText.textContent = 'Failed to handle HRM report';
				uploadText.classList.add('failed');
				break;
			case "COMPLETED":
				uploadText.textContent = 'Uploaded Successfully';
				uploadText.classList.add('success');
				break;
			case "PENDING":
				uploadText.textContent = 'Pending Upload';
				uploadText.classList.add('pending');
				break;
			default:
				uploadText.textContent = 'Invalid File';
				uploadText.classList.add('invalid');
				break;
		}

		fileItem.appendChild(fileName);
		fileItem.appendChild(uploadText);
		fileList.appendChild(fileItem);
	}

	function validateHrmLimit(input) {
		// Remove any decimal points and non-numeric characters
		input.value = input.value.replace(/[^\d]/g, '');
		
		// Convert to number for validation
		const value = parseInt(input.value);
		
		// Validate range
		if (value > 1500) {
			input.value = 1500;
		}
	}

	function fetchUnlinkedHRMs() {
		ShowSpin(true);
		
		const hrmLimit = jQuery("#hrmLimit").val().trim();
		
		// Final validation before submission
		if (!hrmLimit || 
			isNaN(hrmLimit) || 
			parseInt(hrmLimit) < 1 || 
			parseInt(hrmLimit) > 1500 || 
			!Number.isInteger(parseFloat(hrmLimit))) {
			
			alert("Please enter a valid number between 1 and 1500.");
			HideSpin();
			return;
		}
		
		jQuery.ajax({
			url: "${pageContext.request.contextPath}/hospitalReportManager/Mapping.do?fetchUnlinkedHRMs=true&limit=" + hrmLimit,
			type: "POST",
			xhrFields: {
				responseType: 'blob'  // Expecting a blob response
			},
			success: function (blobData, status, xhr) {
				HideSpin();
				// Get filename from Content-Disposition header
				var disposition = xhr.getResponseHeader('Content-Disposition');
				var filename = "hrm_results.zip"; // Default filename
				if (disposition && disposition.indexOf('attachment') !== -1) {
					var matches = /filename="([^"]*)"/.exec(disposition);
					if (matches != null && matches[1]) filename = matches[1];
				}

				// Create a temporary link element to trigger file download
				var link = document.createElement('a');
				var url = window.URL.createObjectURL(blobData);
				link.href = url;
				link.download = filename;
				document.body.appendChild(link);
				link.click();
				window.URL.revokeObjectURL(url); // Clean up

				// Clear the input after successful submission
				jQuery("#hrmLimit").val('');

				alert("File download started successfully. The ZIP includes:\n" +
					"- Successfully routed HRMs to patients.\n" +
					"- Unmatched HRMs routed to 'Not Patient'.\n" +
					"- Newborn HRMs flagged for manual review.\n" +
					"- HRMs with invalid/unparsable reports.\n" +
					"- HRMs missing DOB or report date.");
			},
			error: function (jqXHR, textStatus, errorThrown) {
				HideSpin();
				console.error("Error details:", {
					textStatus: textStatus,
					errorThrown: errorThrown,
					responseText: jqXHR.responseText
				});
				alert("Failed to generate file");
			}
		});
	}

	function linkHrmDocumentIds() {
		const hrmIdsInput = document.getElementById("hrmIds").value.trim();
    
		// 1. Validate if input is empty
		if (!hrmIdsInput) {
			alert("Please enter at least one HRM Document ID.");
			return;
		}

		// 2. Split the input by commas and trim whitespace
		const hrmIds = hrmIdsInput.split(',').map(id => id.trim()).filter(id => id);

		// 3. Validate each ID to ensure they are integers
		const invalidIds = hrmIds.filter(id => !/^\d+$/.test(id)); // Check if each ID is a non-negative integer
		if (invalidIds.length > 0) {
			alert("Please enter valid integer HRM Document IDs. Invalid IDs: " + invalidIds.join(", "));
			return;
		}

		ShowSpin(true); // Show the spinner while processing

		jQuery.ajax({
			url: "${pageContext.request.contextPath}/hospitalReportManager/Mapping.do?linkHrmDocumentIds=true&hrmIds=" + hrmIdsInput,
			type: "POST",
			xhrFields: {
				responseType: 'blob'  // Expecting a blob response
			},
			success: function (blobData, status, xhr) {
				HideSpin();
				// Get filename from Content-Disposition header
				var disposition = xhr.getResponseHeader('Content-Disposition');
				var filename = "hrm_results.zip"; // Default filename
				if (disposition && disposition.indexOf('attachment') !== -1) {
					var matches = /filename="([^"]*)"/.exec(disposition);
					if (matches != null && matches[1]) filename = matches[1];
				}

				// Create a temporary link element to trigger file download
				var link = document.createElement('a');
				var url = window.URL.createObjectURL(blobData);
				link.href = url;
				link.download = filename;
				document.body.appendChild(link);
				link.click();
				window.URL.revokeObjectURL(url); // Clean up

				// Clear the input after successful submission
				jQuery("#hrmLimit").val('');

				alert("File download started successfully. The ZIP includes:\n" +
					"- Successfully routed HRMs to patients.\n" +
					"- Unmatched HRMs routed to 'Not Patient'.\n" +
					"- Newborn HRMs flagged for manual review.\n" +
					"- HRMs with invalid/unparsable reports.\n" +
					"- HRMs missing DOB or report date.");
			},
			error: function (jqXHR, textStatus, errorThrown) {
				HideSpin();
				console.error("Error details:", {
					textStatus: textStatus,
					errorThrown: errorThrown,
					responseText: jqXHR.responseText
				});
				alert("Failed to generate file");
			}
		});
	}

	function convertConsultResponseToNote() {
		const consultResponseIdsInput = document.getElementById("consultResponseIds").value.trim();
    
		// 1. Validate if input is empty
		if (!consultResponseIdsInput) {
			alert("Please enter at least one Consult Response ID.");
			return;
		}

		// 2. Split the input by commas and trim whitespace
		const consultResponseIds = consultResponseIdsInput.split(',').map(id => id.trim()).filter(id => id);

		// 3. Validate each ID to ensure they are integers
		const invalidIds = consultResponseIds.filter(id => !/^\d+$/.test(id)); // Check if each ID is a non-negative integer
		if (invalidIds.length > 0) {
			alert("Please enter valid integer Consult Response IDs. Invalid IDs: " + invalidIds.join(", "));
			return;
		}

		ShowSpin(true); // Show the spinner while processing

		jQuery.ajax({
			url: "${pageContext.request.contextPath}/CaseManagementEntry.do?method=convertConsultResponseToNote&consultResponseIds=" + consultResponseIdsInput,
			type: "POST",
			contentType: "application/json",
			success: function(response) {
				alert("Consult responses converted to notes successfully.");
				HideSpin(); // Hide the spinner after processing
			},
			error: function(xhr, status, error) {
				console.error("AJAX Request Failed");
				console.error("Status: " + status);
				console.error("Error: " + error);
				console.error("Response Text: " + xhr.responseText);
				console.error("Response Status: " + xhr.status);
				console.error("Response Headers: " + xhr.getAllResponseHeaders());
				alert("An error occurred: " + error);
				HideSpin(); // Hide the spinner even if there's an error
			}
		});
	}
	</script>


</head>
<body>
<jsp:include page="../images/spinner.jsp" flush="true"/>
<div class="container">
<h4>Hospital Report Manager</h4>
	<div class="loading-screen">
		<div class="loading-bar progress progress-striped active">
			<div class="bar" style="width: 100%;"></div>
		</div>
		<div class="loading-message">
			Please be patient. Uploading a large number of HRM documents may take some time. Do not close this window while uploading...
		</div>
	</div>

<% if (request.getParameter("fetch") != null && request.getParameter("fetch").equalsIgnoreCase("true"))
		new SFTPConnector(loggedInInfo).startAutoFetch(loggedInInfo);
%>
<p>
	HRM Status: <%=SFTPConnector.isFetchRunning() ? "Fetching data from HRM" : "Idle" %><br>
	<% if (!SFTPConnector.isFetchRunning()) { %>
		<input type="button" class="btn" onClick="runFetch()" value="Fetch New Data from HRM" >
	<% } else { %>
		Please wait until the current fetch task completes before requesting another data fetch.
	<% } %>
</p>
<form enctype="multipart/form-data" action="<%=request.getContextPath() %>/hospitalReportManager/UploadLab.do" method="post" onsubmit="return validateForm()">
    Upload HRM reports from your computer: <input type="file" id="fileInput" name="importFile" multiple onChange="getFileList(event)"/>
    <span title="<bean:message key="global.uploadWarningBody"/>" style="vertical-align:middle;font-family:arial;font-size:20px;font-weight:bold;color:#ABABAB;cursor:pointer"><img alt="alert" src="../images/icon_alertsml.gif"></span>

	<input type="submit" id="file-upload-btn" class="btn" name="submit" value="Upload" >
	<div id="file-list">
	</div>

	<c:forEach var="file" items="${filesStatusMap}">
		<script>
			addFileNameWithStatus("<c:out value="${file.key}" />", "<c:out value="${file.value}" />");
		</script>
	</c:forEach>
</form>
<%
	HRMProviderConfidentialityStatementDao hrmProviderConfidentialityStatementDao = (HRMProviderConfidentialityStatementDao) SpringUtils.getBean(HRMProviderConfidentialityStatementDao.class);
	String statement = hrmProviderConfidentialityStatementDao.getConfidentialityStatementForProvider(loggedInInfo.getLoggedInProviderNo());
%>
<form action="<%=request.getContextPath() %>/hospitalReportManager/Statement.do" method="post">
	<div class="control-group">
		<label class="control-label">Provider Confidentiality Statement</label>
		<div class="controls">
			<textarea name="statement"><%=statement %></textarea>
		</div>
	</div>
	<div>
		<input type="submit" class="btn btn-primary" name="submit" value="Save Statement" >
		<% if (request.getAttribute("statementSuccess") != null && (Boolean) request.getAttribute("statementSuccess")) { %>
			Success
		<% } else if (request.getAttribute("statementSuccess") != null && !((Boolean) request.getAttribute("statementSuccess")))  { %>
			Error
		<% } %>
	</div>
</form>
<input type="button" class="btn" value="I don't want to receive any more HRM outage messages for this outage instance" onclick="window.location='disable_msg_action.jsp'" >

<hr/>
<h3>Link Unlinked HRM Documents Not Linked to Demographics</h3> <!-- Updated title -->
<div class="form-group" style="margin-bottom: 30px;">
    <span>Enter a limit (up to 1500) for unlinked HRM documents to link them with demographics:</span> <!-- Updated description -->
    <input type="number" 
           id="hrmLimit" 
           class="form-control" 
           placeholder="Enter a number up to 1500" 
           style="width: 200px; margin: 10px 0;"
           min="1" 
           max="1500" 
           step="1" 
           onkeydown="return event.keyCode !== 190"
           oninput="validateHrmLimit(this)">
    <button type="button" class="btn" onclick="fetchUnlinkedHRMs()">Link</button>
</div>
<hr/>
<h3>Link Unlinked HRM Document IDs with Demographics</h3>
<div class="form-group" style="margin-bottom: 30px;">
    <span>Enter specific unlinked HRM document IDs separated by commas to link them with demographics:</span> 
    <div> <!-- Added div for textarea -->
        <textarea 
            id="hrmIds" 
            class="form-control" 
            placeholder="Enter unlinked HRM document IDs in CSV format" 
            style="width: 100%; margin: 10px 0;" 
            rows="10"></textarea>
    </div>
    <div> <!-- Added div for button -->
        <input type="button" class="btn smallButton" value="Link IDs" onClick="linkHrmDocumentIds()" /> 
    </div>
</div>

<hr/>
<h3>Convert Consult Response to Note</h3>
<div class="form-group" style="margin-bottom: 30px;">
    <span>Enter specific consult response IDs separated by commas to convert them into case notes:</span>
    <div> <!-- Added div for textarea -->
        <textarea 
            id="consultResponseIds" 
            class="form-control" 
            placeholder="Enter consult response IDs in CSV format" 
            style="width: 100%; margin: 10px 0;" 
            rows="10"></textarea>
    </div>
    <div> <!-- Added div for button -->
        <input type="button" class="btn smallButton" value="Convert" onClick="convertConsultResponseToNote()" />
    </div>
</div>
</div>
</body>
</html:html>