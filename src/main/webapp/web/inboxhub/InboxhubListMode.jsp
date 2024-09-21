<!--
Copyright (c) 2023. Magenta Health Inc. All Rights Reserved.

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
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
-->

<%@ page import="java.util.*" %>
<%@ page import="oscar.oscarLab.ca.on.*" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="https://www.owasp.org/index.php/OWASP_Java_Encoder_Project" prefix="e" %>
<%@page import="org.oscarehr.util.MiscUtils,org.apache.commons.lang.StringEscapeUtils" %>
<%@page import="org.apache.logging.log4j.Logger,org.oscarehr.common.dao.OscarLogDao,org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.inboxhub.query.InboxhubQuery" %>
<%@ page import="oscar.oscarMDS.data.CategoryData" %>
<script>
    ctx = "<e:forJavaScriptBlock value='${pageContext.request.contextPath}' />";
    const searchProviderNo = "<e:forJavaScriptBlock value='${sessionScope.user}' />";
</script>
<div class="bg-light text-light">
    <row>
        <input id="topFBtn" type="button" class="btn btn-primary btn-sm ms-1" value="<bean:message key="oscarMDS.index.btnForward"/>" onclick="submitForward('${sessionScope.user}')">
        <input id="topFileBtn" type="button" class="btn btn-primary btn-sm" value="File" onclick="submitFile('${sessionScope.user}')"/>
    </row>
    <row>
        <div class="inbox-table-responsive">
        <table table id="inbox_table" class="table table-striped inbox-table">
            <thead class="inbox-table-sticky-header">
            <tr>
                <th>
                    <input type="checkbox" onclick="checkAllLabs(0);" name="checkA"/>
                </th>
                <th><bean:message key="oscarMDS.index.msgHealthNumber"/></th>
                <th><bean:message key="oscarMDS.index.msgPatientName"/></th>
                <th><bean:message key="oscarMDS.index.msgSex"/></th>
                <th><bean:message key="oscarMDS.index.msgResultStatus"/></th>
                <th><bean:message key="oscarMDS.index.msgDateTest"/></th>
                <th><bean:message key="oscarMDS.index.msgOrderPriority"/></th>
                <th><bean:message key="oscarMDS.index.msgRequestingClient"/></th>
                <th><bean:message key="oscarMDS.index.msgDiscipline"/></th>
                <th><bean:message key="oscarMDS.index.msgReportStatus"/></th>
                <th>Ack #</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="labResult" items="${labDocs}" varStatus="loopStatus">
                <tr id="labdoc_${labResult.segmentID}" class="${labResult.resultStatus == 'A' ? 'table-danger' : ''}">
                    <td>
                        <c:set var="disabled" value="${!labResult.matchedToPatient && labResult.labType != 'DOC' ? 'disabled' : ''}"/>
                        <input type="checkbox" name="flaggedLabs" value="${labResult.segmentID}:${labResult.labType}" ${disabled}>
                    </td>
                    <td><e:forHtmlContent value='${labResult.healthNumber}' /></td>
                    <td>
                        <a href="javascript:void(0);" 
                        onclick="reportWindow('${labLinks[loopStatus.index]}', window.innerHeight, window.innerWidth); return false;">
                            <e:forHtmlContent value='${labResult.patientName}' />
                        </a>
                    </td>
                    <td>${labResult.sex}</td>
                    <td>${labResult.resultStatus == 'A' ? 'Abnormal' : ''}</td>
                    <td>${labResult.dateTime}</td>
                    <td>${labResult.priority}</td>
                    <td>${labResult.requestingClient}</td>
                    <td>${labResult.disciplineDisplayString == 'D' ? '' : labResult.disciplineDisplayString}</td>
                    <td>${labResult.reportStatus == 'F' ? 'Final' : 'Partial'}</td>
                    <td>${labResult.acknowledgedStatus == 'Y' ? 1 : 0}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
        </div>
    </row>
</div>
<script src="<%=request.getContextPath()%>/share/javascript/oscarMDSIndex.js"></script>