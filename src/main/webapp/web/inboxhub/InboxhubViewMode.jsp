<%@ page import="java.util.*" %>
<%@ page import="oscar.oscarLab.ca.on.*" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="org.oscarehr.util.MiscUtils" %>
<%
    List labDocs = (List) request.getAttribute("labDocs");
%>
<%
    for (int i = 0; i < labDocs.size(); i++) {
        LabResultData result = (LabResultData) labDocs.get(i);
        String segmentID = result.getSegmentID();
        String demoName = result.getPatientName();
        String providerNo = "-1";
        String searchProviderNo = "-1";
        String status = result.resultStatus;
%>
<%
    try {
        if (result.isDocument()) {
%>
<div id="document_<%=segmentID%>">
    <jsp:include page="/dms/showDocument.jsp" flush="true">
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
<% } else {

%>

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
    }%>