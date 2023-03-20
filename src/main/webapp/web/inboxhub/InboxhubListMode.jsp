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
<%@page import="org.oscarehr.util.MiscUtils,org.apache.commons.lang.StringEscapeUtils" %>
<%@page import="org.apache.logging.log4j.Logger,org.oscarehr.common.dao.OscarLogDao,org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.inboxhub.query.InboxhubQuery" %>
<%@ page import="oscar.oscarMDS.data.CategoryData" %>
<!DOCTYPE html
<html>
    <%
        List labDocs = (List) request.getAttribute("labDocs");
        List labLinks = (List) request.getAttribute("labLinks");
    %>
<script>
    var contextPath = '<%=request.getContextPath()%>'
</script>
<table table id="inbox_table" class='table table-striped'>
    <thead>
    <tr>
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
    <%
        for (int i = 0; i < labDocs.size(); i++) {
            LabResultData labResult = (LabResultData) labDocs.get(i);
    %>
    <tr class="<%=(Objects.equals(labResult.resultStatus, "A") ? "table-danger" : "")%>">
        <td><%=labResult.getHealthNumber()%>
        </td>
        <td><a href="javascript:void(0);"
               onclick="reportWindow('<%=labLinks.get(i).toString()%>',screen.availHeight, screen.availWidth); return false;"><%=labResult.getPatientName()%>
        </a></td>
        <td><%=labResult.getSex()%>
        </td>
        <td><%=(Objects.equals(labResult.resultStatus, "A") ? "Abnormal" : "")%>
        </td>
        <td><%=labResult.getDateTime()%>
        </td>
        <td><%=labResult.getPriority()%>
        </td>
        <td><%=labResult.getRequestingClient()%>
        </td>
        <td><%=(Objects.equals(labResult.getDisciplineDisplayString(), "D") ? "" : labResult.getDisciplineDisplayString())%>
        </td>
        <td><%=(Objects.equals(labResult.getReportStatus(), "F") ? "Final" : "Partial")%>
        </td>
        <td><%=(Objects.equals(labResult.getAcknowledgedStatus(), "Y") ? 1 : 0)%>
        </td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>