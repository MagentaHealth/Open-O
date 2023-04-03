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
<%@page import="oscar.oscarMDS.data.CategoryData" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="<%=request.getContextPath()%>/library/bootstrap/5.0.2/css/bootstrap.min.css" rel="stylesheet"
          media="screen">
    <link rel="stylesheet" type="text/css"
          href="<%=request.getContextPath()%>/library/DataTables-1.13.2/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/web/css/Inboxhub.css"/>
    <link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">

    <script src="<%=request.getContextPath()%>/library/bootstrap/5.0.2/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jQuery-3.6.0/jquery-3.6.0.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-ui-1.12.1.min.js"></script>
    <script type="text/javascript" charset="utf8"
            src="<%=request.getContextPath()%>/library/DataTables-1.13.2/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript"
            src="<%=request.getContextPath()%>/library/DataTables-1.13.2/js/dataTables.bootstrap5.min.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath()%>/web/inboxhub/inboxhubController.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap-datepicker.js"></script>
    <title>Inboxhub</title>
</head>
<body>

<%
    Boolean viewMode = (Boolean) request.getAttribute("viewMode");
%>
<script>
    const contextPath = "<%=request.getContextPath()%>";
</script>
<input type="hidden" id="ctx" value="<%=request.getContextPath()%>"/>

<div class="container-fluid">
    <div class="row">
        <nav class="navbar navbar-light d-flex justify-content-center" style="background-color: #e3f2fd;">
            <jsp:include page="InboxhubTopbar.jsp"/>
        </nav>
    </div>
    <div class="row">
        <div class="col-2 offset-lg-0 offset-xl-2" style="z-index: 5">
            <div class="bg-light text-dark" style="display: inline-block;">
                <jsp:include page="InboxhubForm.jsp"/>
            </div>
        </div>
        <div class="col-md-8 col-lg-6" style="z-index:100">
            <div class="bg-light text-dark">
                <c:choose>
                    <c:when test="${viewMode}">
                        <jsp:include page="InboxhubViewMode.jsp"/>
                    </c:when>
                    <c:otherwise>
                        <jsp:include page="InboxhubListMode.jsp"/>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
</body>
</html>