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
<!DOCTYPE html>

<html>
<link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/library/jquery/jquery-ui.theme-1.12.1.min.css" />
<link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/library/jquery/jquery-ui-1.12.1.min.css" />
<link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/library/jquery/jquery-ui.structure-1.12.1.min.css" />
    <%
        List labDocs = (List) request.getAttribute("labDocs");
        List labLinks = (List) request.getAttribute("labLinks");
        String searchProviderNumber = (String) session.getAttribute("user");
    %>
<script>
    ctx = '<%=request.getContextPath()%>';
    const searchProviderNo = '<%=(String) session.getAttribute("user")%>';
</script>
<div class="bg-light text-light">
    <row>
        <input id="topFBtn" type="button" class="btn btn-primary btn-sm ms-1" value="<bean:message key="oscarMDS.index.btnForward"/>" onclick="submitForward('<%=searchProviderNumber%>')">
        <input id="topFileBtn" type="button" class="btn btn-primary btn-sm" value="File" onclick="submitFile('<%=searchProviderNumber%>')"/>
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
            <%
                for (int i = 0; i < labDocs.size(); i++) {
                    LabResultData labResult = (LabResultData) labDocs.get(i);
            %>
            <tr id="labdoc_<%=labResult.getSegmentID()%>" class="<%=(Objects.equals(labResult.resultStatus, "A") ? "table-danger" : "")%>">
                <td>
                    <%
                        String disabled = "";
                        if (!labResult.isMatchedToPatient() && !Objects.equals(labResult.labType, "DOC"))
                        {
                            disabled = "disabled";
                        };
                    %>
                    <input type="checkbox" name="flaggedLabs" value="<%=labResult.getSegmentID() + ":" + labResult.labType%>" <%= disabled %>>
                </td>
                <td><%=labResult.getHealthNumber()%></td>
                <td><a href="javascript:void(0);"
                       onclick="reportWindow('<%=labLinks.get(i).toString()%>',window.innerHeight, window.innerWidth); return false;"><%=labResult.getPatientName()%>
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
        </div>
    </row>
</div>
<script src="<%=request.getContextPath()%>/share/javascript/oscarMDSIndex.js"></script>