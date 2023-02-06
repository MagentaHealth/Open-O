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
<!DOCTYPE html>
<html>
<head>
    <title><bean:message key="inbox.inboxmanager.title"/></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="<%=request.getContextPath() %>/library/bootstrap/5.0.2/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <script src="<%=request.getContextPath() %>/library/bootstrap/5.0.2/js/bootstrap.min.js"></script>
    <%
        List labDocs = (List) request.getAttribute("labDocs");
        InboxhubQuery query = (InboxhubQuery) request.getAttribute("query");
    %>
</head>
<body>
<div class="container">
    <div class="row">
        <div class="col-2 position-fixed justify-content-center">
                <form action="${pageContext.request.contextPath}/web/inboxhub/InboxhubManager.do?method=displayInboxForm" method="post">
                    <div class="form-check">
                        <div class="d-grid col-4">
                            <input type="checkbox" class="btn-check" name="clearFilters" id="btnClear" autocomplete="off" onchange="this.form.submit()">
                            <label class="btn btn-outline-primary" for="btnClear"><bean:message key="inbox.inboxmanager.msgClearFilters"/></label><br>
                            <input type="checkbox" class="btn-check" name="doc" <% if (query.getDoc()) { %> checked <% } %> id="btnDoc" autocomplete="off" onchange="this.form.submit()">
                            <label class="btn btn-outline-primary" for="btnDoc">DOC</label><br>
                            <input type="checkbox" class="btn-check" name="lab" <% if (query.getLab()) { %> checked <% } %> id="btnLab" autocomplete="off" onchange="this.form.submit()">
                            <label class="btn btn-outline-primary" for="btnLab">LAB</label><br>
                            <input type="checkbox" class="btn-check" name="hrm" <% if (query.getHrm()) { %> checked <% } %> id="btnHRM" autocomplete="off" onchange="this.form.submit()">
                            <label class="btn btn-outline-primary" for="btnHRM">HRM</label><br>
                            <label class="fw-bold text-uppercase mb-2">
                                <bean:message key="inbox.inboxmanager.msgAbnormalStatus"/>
                            </label>
                            <div class="btn-group" role="group">
                                <input type="radio" class="btn-check" name="abnormal" id="All" value="All" onchange="this.form.submit()" <% if (Objects.equals(query.getAbnormal(), "All")) { %> checked <% } %>>
                                <label class="btn btn-outline-primary" for="All">All</label>
                                <input type="radio" class="btn-check" name="abnormal" id="Abnormal" value="Abnormal" onchange="this.form.submit()"  <% if (Objects.equals(query.getAbnormal(), "Abnormal")) { %> checked <% } %>>
                                <label class="btn btn-outline-primary" for="Abnormal">Abnormal</label>
                                <input type="radio" class="btn-check" name="abnormal" id="Normal" value="Normal" onchange="this.form.submit()"<% if (Objects.equals(query.getAbnormal(), "Normal")) { %> checked <% } %>>
                                <label class="btn btn-outline-primary" for="Normal">Normal</label>
                            </div>
                        </div>
                    </div>
                </form>
        </div>
        <div class="col-auto offset-4">
            <table class='table table-bordered table-hover'>
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
                    <td><%=labResult.getHealthNumber()%></td>
                    <td><%=labResult.getPatientName()%></td>
                    <td><%=labResult.getSex()%></td>
                    <td><%=(Objects.equals(labResult.resultStatus, "A") ? "Abnormal" : "")%></td>
                    <td><%=labResult.getDateTime()%></td>
                    <td><%=labResult.getPriority()%></td>
                    <td><%=labResult.getRequestingClient()%></td>
                    <td><%=(Objects.equals(labResult.getDisciplineDisplayString(), "D") ? "" : labResult.getDisciplineDisplayString())%></td>
                    <td><%=(Objects.equals(labResult.getReportStatus(), "F") ? "Final" : "Partial")%></td>
                    <td><%=(Objects.equals(labResult.getAcknowledgedStatus(), "Y") ? 1 : 0)%></td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>

