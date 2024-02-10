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

<%
    CategoryData categoryData = (CategoryData) request.getAttribute("categoryData");
    InboxhubQuery query = (InboxhubQuery) request.getAttribute("query");
%>

<form action="${pageContext.request.contextPath}/web/inboxhub/Inboxhub.do?method=displayInboxForm" method="post"
      id="myForm">
    <div>
        <div class="d-grid">
            <input type="checkbox" class="btn-check btn-sm" name="viewMode" <% if (query.getViewMode()) { %> checked <% } %>
                   id="btnViewMode" autocomplete="off" onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnViewMode">Preview Mode</label><br>
            <label class="fw-bold text-uppercase mb-2">
                <bean:message key="inbox.inboxmanager.msgTotalResults"/>: <%=categoryData.getTotalNumDocs()%>
            </label>
            <input type="checkbox" class="btn-check btn-sm" name="clearFilters" id="btnClear" autocomplete="off"
                   onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnClear">Clear Filters</label><br>
            <input type="checkbox" class="btn-check btn-sm" name="doc" <% if (query.getDoc()) { %> checked <% } %> id="btnDoc"
                   autocomplete="off" onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnDoc">DOC (<%=categoryData.getTotalDocs()%>)</label><br>
            <input type="checkbox" class="btn-check btn-sm" name="lab" <% if (query.getLab()) { %> checked <% } %> id="btnLab"
                   autocomplete="off" onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnLab">LAB (<%=categoryData.getTotalLabs()%>)</label><br>
            <input type="checkbox" class="btn-check btn-sm" name="hrm" <% if (query.getHrm()) { %> checked <% } %> id="btnHRM"
                   autocomplete="off" onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnHRM">HRM</label><br>
            <input type="checkbox" class="btn-check btn-sm" name="unmatched" <% if (query.getUnmatched()) { %> checked <% } %>
                   id="btnUnmatched" autocomplete="off" onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnUnmatched"><bean:message key="inbox.inboxmanager.msgUnmatched"/>
                (<%=categoryData.getUnmatchedDocs() + categoryData.getUnmatchedLabs()%>)</label><br>
            <label class="fw-bold text-uppercase mb-2">
                <bean:message key="inbox.inboxmanager.msgAbnormalStatus"/>
            </label>
            <div class="btn-group btn-sm" role="group">
                <input type="radio" class="btn-check btn-sm" name="abnormal" id="All" value="All"
                       onchange="this.form.submit()" <% if (Objects.equals(query.getAbnormal(), "All")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary" for="All"><bean:message key="inbox.inboxmanager.msgAll"/></label>
                <input type="radio" class="btn-check btn-sm" name="abnormal" id="Abnormal" value="Abnormal"
                       onchange="this.form.submit()"  <% if (Objects.equals(query.getAbnormal(), "Abnormal")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="Abnormal"><bean:message key="global.abnormal"/> (<%=categoryData.getAbnormalCount()%>
                    )</label>
                <input type="radio" class="btn-check btn-sm" name="abnormal" id="Normal" value="Normal"
                       onchange="this.form.submit()"<% if (Objects.equals(query.getAbnormal(), "Normal")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="Normal"><bean:message key="inbox.inboxmanager.msgNormal"/> (<%=categoryData.getNormalCount()%>)</label>
            </div>
            <br>
            <label class="fw-bold text-uppercase mb-2">
                <bean:message key="oscarMDS.index.msgReportStatus"/>
            </label>
            <div class="btn-group btn-sm" role="group">
                <input type="radio" class="btn-check btn-sm" name="status" id="statusAll" value=""
                       onchange="this.form.submit()" <% if (Objects.equals(query.getStatus(), "")) { %> checked <% } %>>
                <label class="btn btn-outline-primary" for="statusAll"><bean:message key="inbox.inboxmanager.msgAll"/></label>
                <input type="radio" class="btn-check btn-sm" name="status" id="statusNew" value="N"
                       onchange="this.form.submit()"  <% if (Objects.equals(query.getStatus(), "N")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="statusNew">New</label>
                <input type="radio" class="btn-check btn-sm" name="status" id="statusAcknowledged" value="A"
                       onchange="this.form.submit()"<% if (Objects.equals(query.getStatus(), "A")) { %> checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="statusAcknowledged">Acknowledged</label>
                <input type="radio" class="btn-check btn-sm" name="status" id="statusFiled" value="F"
                       onchange="this.form.submit()" <% if (Objects.equals(query.getStatus(), "F")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="statusFiled"><bean:message key="inbox.inboxmanager.msgFiled"/></label>
                <br>
            </div>
            <br>
            <label class="fw-bold text-uppercase mb-2"><bean:message key="inbox.inboxmanager.msgPhysicianSearchType"/></label>
            <div class="btn-group btn-sm" role="group">
                <input type="radio" class="btn-check btn-sm" name="searchAll" id="physicianAll" value="true"
                       onchange="this.form.submit()" <% if (Objects.equals(query.getSearchAll(), "true")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary" for="physicianAll"><bean:message key="inbox.inboxmanager.msgAllPhysicians"/></label>
                <input type="radio" class="btn-check btn-sm" name="searchAll" id="physicianUnclaimed" value="false"
                       onchange="this.form.submit()"  <% if (Objects.equals(query.getSearchAll(), "false")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="physicianUnclaimed"><bean:message key="inbox.inboxmanager.msgUnclaimedPhysicians"/></label>
                <input type="radio" class="btn-check btn-sm" name="searchAll" id="physicianClear" value=""
                       onchange="this.form.submit()"  <% if (Objects.equals(query.getSearchAll(), "")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="physicianClear">Clear</label>
            </div>
            <div class="accordion" id="dropdown">
                <div class="accordion-item">
                    <h2 class="accordion-header" id="headingOne">
                        <button class="accordion-button btn-sm" type="button" data-bs-toggle="collapse"
                                data-bs-target="#collapseOne" aria-controls="collapseOne">
                            <bean:message key="inbox.inboxmanager.msgSearchFilter"/>
                        </button>
                    </h2>
                    <div id="collapseOne" class="accordion-collapse collapse" aria-labelledby="headingOne"
                         data-bs-parent="#dropdown">
                        <div class="accordion-body d-grid">
                            <div class="accordion-body d-grid">
                                <label class="text-uppercase mb-2"><bean:message key="inbox.inboxmanager.msgSearchPhysician"/></label>
                                <input type="hidden" name="searchProviderNo" id="findProvider"
                                       value="<%=query.getSearchProviderNo()%>"/>
                                <input type="text" id="autocompleteProvider" name="searchProviderName"
                                       onchange="this.form.submit()" value="<%=query.getSearchProviderName()%>"/><br>
                                <label class="text-uppercase mb-2"><bean:message key="inbox.inboxmanager.msgStartDate"/></label>
                                <input type="text" name="startDate" autocomplete="off"
                                       value="<%=query.getStartDate()%>"><br>
                                <label class="text-uppercase mb-2"><bean:message key="inbox.inboxmanager.msgEndDate"/> (yyyy-mm-dd)</label>
                                <input type="text" name="endDate" autocomplete="off"
                                       value="<%=query.getEndDate()%>"><br>
                                <label for="inputFirstName"><bean:message key="oscarMDS.search.formPatientFirstName"/></label>
                                <input type="text" name="patientFirstName" id="inputFirstName" autocomplete="off"
                                       value="<%=query.getPatientFirstName()%>" onchange="this.form.submit()"><br>
                                <label for="inputLastName"><bean:message key="oscarMDS.search.formPatientLastName"/></label>
                                <input type="text" name="patientLastName" id="inputLastName" autocomplete="off"
                                       value="<%=query.getPatientLastName()%>" onchange="this.form.submit()"><br>
                                <label for="inputHIN"><bean:message key="oscarMDS.search.formPatientHealthNumber"/></label>
                                <input type="text" name="patientHealthNumber" id="inputHIN" autocomplete="off"
                                       value="<%=query.getPatientHealthNumber()%>" onchange="this.form.submit()">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>
