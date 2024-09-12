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
    <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/library/DataTables/DataTables-1.13.4/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/css/bootstrap-datetimepicker-standalone.css" />
    <link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/css/bootstrap-datetimepicker.min.css" /> 
    <link href="<%=request.getContextPath()%>/library/bootstrap/5.0.2/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/web/css/Inboxhub.css"/>

    <script type="text/javascript" src="<%=request.getContextPath()%>/library/moment.js"></script>
    <script src="<%=request.getContextPath()%>/library/bootstrap/5.0.2/js/bootstrap.bundle.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-ui-1.12.1.min.js"></script>
    <script type="text/javascript" charset="utf8" src="<%=request.getContextPath()%>/library/DataTables/DataTables-1.13.4/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath()%>/library/DataTables/DataTables-1.13.4/js/dataTables.bootstrap5.min.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath()%>/web/inboxhub/inboxhubController.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath()%>/library/bootstrap-datetimepicker.min.js" ></script>
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
    <div class="row flex-nowrap">
        <div class="col-auto px-0 m-1">
            <div class="bg-light text-dark inbox-form" style="display: inline-block;">
                <jsp:include page="InboxhubForm.jsp"/>
            </div>
        </div>
        <div class="col px-0 m-1">
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