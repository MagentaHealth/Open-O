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
<%@ page import="oscar.OscarProperties" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<a href="javascript:popupStart(800,1000,'${pageContext.servletContext.contextPath}/lab/CA/ALL/testUploader.jsp')" class="btn btn-primary"><bean:message key="admin.admin.hl7LabUpload"/></a>
<% if (OscarProperties.getInstance().getBooleanProperty("legacy_document_upload_enabled", "true")) { %>
<a href="javascript:popupStart(600,500,'${pageContext.servletContext.contextPath}/dms/html5AddDocuments.jsp')" class="btn btn-primary"><bean:message key="inboxmanager.document.uploadDoc"/></a>
<% }
else { %>
<a href="javascript:popupStart(800,1000,'${pageContext.servletContext.contextPath}/dms/documentUploader.jsp')" class="btn btn-primary"><bean:message key="inboxmanager.document.uploadDoc"/></a>
<% } %>

<a href="javascript:popupStart(700,1100,'../dms/inboxManage.do?method=getDocumentsInQueues')" class="btn btn-primary"><bean:message key="inboxmanager.document.pendingDocs"/></a>

<a href="javascript:popupStart(800,1200,'${pageContext.servletContext.contextPath}/dms/incomingDocs.jsp')" class="btn btn-primary" ><bean:message key="inboxmanager.document.incomingDocs"/></a>

<% if (! OscarProperties.getInstance().isBritishColumbiaBillingRegion()) { %>
<a href="javascript:popupStart(800,1000, '${pageContext.servletContext.contextPath}/oscarMDS/CreateLab.jsp')" class="btn btn-primary"><bean:message key="global.createLab" /></a>
<a href="javascript:popupStart(800,1000, '${pageContext.servletContext.contextPath}/olis/Search.jsp')" class="btn btn-primary"><bean:message key="olis.olisSearch" /></a>
<a href="javascript:popupPage(400, 400,'<html:rewrite page="/hospitalReportManager/hospitalReportManager.jsp"/>')" class="btn btn-primary">HRM Status/Upload</a>
<% } %>

