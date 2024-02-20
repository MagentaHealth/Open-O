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
<%@ page import="oscar.oscarLab.ca.on.*" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="org.oscarehr.util.MiscUtils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<%
    LabResultData result = (LabResultData) request.getAttribute("labResult");
    String segmentID = result.getSegmentID();
    String demoName = result.getPatientName();
    String providerNo = (String) session.getAttribute("user");
    String searchProviderNo = (String) request.getAttribute("searchProviderNo");
    String status = result.resultStatus;
%>
<%
    try {
        if (result.isDocument()) {
%>
<div id="document_<%=segmentID%>">
    <jsp:include page="/documentManager/showDocument.jsp" flush="true">
        <jsp:param name="segmentID" value="<%=segmentID%>"/>
        <jsp:param name="demoName" value="<%=demoName%>"/>
        <jsp:param name="providerNo" value="<%=providerNo%>"/>
        <jsp:param name="searchProviderNo" value="<%=searchProviderNo%>"/>
        <jsp:param name="status" value="<%=status%>"/>
    </jsp:include>
</div>
<%
} else if (result.isHRM()) {
    StringBuilder duplicateLabIds = new StringBuilder();
    for (Integer duplicateLabId : result.getDuplicateLabIds()) {
        if (duplicateLabIds.length() > 0) duplicateLabIds.append(',');
        duplicateLabIds.append(duplicateLabId);
    }
%>
<jsp:include page="/hospitalReportManager/displayHRMReport.jsp" flush="true">
    <jsp:param name="id" value="<%=segmentID %>"/>
    <jsp:param name="segmentID" value="<%=segmentID %>"/>
    <jsp:param name="providerNo" value="<%=providerNo %>"/>
    <jsp:param name="searchProviderNo" value="<%=searchProviderNo %>"/>
    <jsp:param name="status" value="<%=status %>"/>
    <jsp:param name="demoName" value="<%=result.getPatientName() %>"/>
    <jsp:param name="duplicateLabIds" value="<%=duplicateLabIds.toString() %>"/>
</jsp:include>
<% } else { %>
<jsp:include page="/lab/CA/ALL/labDisplayAjax.jsp" flush="true">
    <jsp:param name="segmentID" value="<%=segmentID%>"/>
    <jsp:param name="demoName" value="<%=demoName%>"/>
    <jsp:param name="providerNo" value="<%=providerNo%>"/>
    <jsp:param name="searchProviderNo" value="<%=searchProviderNo%>"/>
    <jsp:param name="status" value="<%=status%>"/>
    <jsp:param name="showLatest" value="true"/>
</jsp:include>
<%
        }
    } catch (Exception e) {
        MiscUtils.getLogger().error(e.toString());
    }
%>
