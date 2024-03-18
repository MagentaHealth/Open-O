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

<!-- calendar -->
<link rel="stylesheet" type="text/css" media="all" href="../../share/calendar/calendar.css" title="win2k-cold-1" />
<script type="text/javascript" src="../../share/calendar/calendar.js"></script>
<script type="text/javascript" src="../../share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>
<script type="text/javascript" src="../../share/calendar/calendar-setup.js"></script>

<form action="${pageContext.request.contextPath}/web/inboxhub/Inboxhub.do?method=displayInboxForm" method="post"
      id="myForm">
    <div>
        <div class="d-grid">
            <input type="checkbox" class="btn-check btn-sm" name="viewMode" <% if (query.getViewMode()) { %> checked <% } %>
                   id="btnViewMode" autocomplete="off" onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnViewMode">Preview Mode</label><br>
            <label class="fw-bold text-uppercase mb-2 btn-sm">
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
            <label class="fw-bold text-uppercase mb-2 btn-sm">
                <bean:message key="inbox.inboxmanager.msgAbnormalStatus"/>
            </label>
            <div class="btn-group btn-sm" role="group">
                <input type="radio" class="btn-check btn-sm" name="abnormal" id="All" value="All"
                       onchange="this.form.submit()" <% if (Objects.equals(query.getAbnormal(), "All")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="All"><bean:message key="inbox.inboxmanager.msgAll"/></label>
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
                <label class="btn btn-outline-primary btn-sm" for="statusAll"><bean:message key="inbox.inboxmanager.msgAll"/></label>
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
            <label class="fw-bold text-uppercase mb-2 btn-sm"><bean:message key="inbox.inboxmanager.msgPhysicianSearchType"/></label>
            <div class="btn-group btn-sm" role="group">
                <input type="radio" class="btn-check btn-sm" name="searchAll" id="physicianAll" value="true"
                       onchange="this.form.submit()" <% if (Objects.equals(query.getSearchAll(), "true")) { %>
                       checked <% } %>>
                <label class="btn btn-outline-primary btn-sm" for="physicianAll"><bean:message key="inbox.inboxmanager.msgAllPhysicians"/></label>
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
                        <button class="accordion-button " type="button" data-bs-toggle="collapse"
                                data-bs-target="#collapseOne" aria-controls="collapseOne">
                            <bean:message key="inbox.inboxmanager.msgSearchFilter"/>
                        </button>
                    </h2>
                    <div id="collapseOne" class="accordion-collapse collapse" aria-labelledby="headingOne"
                         data-bs-parent="#dropdown">
                        <div class="accordion-body d-grid btn-sm">
                            <div class="accordion-body d-grid btn-sm">
                                 <!-- Any Provider -->
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="providerRadios" value="option1" id="anyProvider" />
                                    <label class="form-check-label" for="anyProvider"><bean:message key="oscarMDS.search.formAnyProvider"/></label>
                                </div>
                                <!-- No Provier -->
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="providerRadios" value="option2" id="noProvider" />
                                    <label class="form-check-label" for="noProvider"><bean:message key="oscarMDS.search.formAllProvider"/></label>
                                 </div>
                                <!-- Specific Provider -->
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="providerRadios" value="option3" id="specificProvider" checked/>
                                    <label class="form-check-label" for="specificProvider"><bean:message key="oscarMDS.search.formSpecificProvider"/></label>
                                    <label class="mb-2 btn-sm">Provider:</label>
                                    <input type="hidden" name="searchProviderNo" id="findProvider"value="<%=query.getSearchProviderNo()%>"/>
                                    <input type="text" id="autocompleteProvider" name="searchProviderName"
                                    onchange="this.form.submit()" value="<%=query.getSearchProviderName()%>"/><br>
                                </div>
                                <hr>
                                <!-- All Patients (including unmatched) -->
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="PatientsRadios" value="option1" id="allPatients" checked/>
                                    <label class="form-check-label" for="allPatients"><bean:message key="oscarMDS.search.formAllPatients"/></label>
                                </div>
                                <!-- Unmatched to Existing Patient -->
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="PatientsRadios" value="option2" id="unmatchedPatients" />
                                    <label class="form-check-label" for="unmatchedPatients"><bean:message key="oscarMDS.search.formExistingPatient"/></label>
                                </div>
                                <!-- Specific Patient(s) -->
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="PatientsRadios" value="option3" id="specificPatients"/>
                                    <label class="form-check-label" for="specificPatients"><bean:message key="oscarMDS.search.formSpecificPatients"/></label>
                                    <label class="mb-2 btn-sm" for="inputFirstName"><bean:message key="admin.provider.formFirstName"/></label>
                                    <input type="text" name="patientFirstName" id="inputFirstName" autocomplete="off"
                                           value="<%=query.getPatientFirstName()%>" onchange="this.form.submit()"><br>
                                    <label class="mb-2 btn-sm" for="inputLastName"><bean:message key="admin.provider.formLastName"/></label>
                                    <input type="text" name="patientLastName" id="inputLastName" autocomplete="off"
                                           value="<%=query.getPatientLastName()%>" onchange="this.form.submit()"><br>
                                    <label class="mb-2 btn-sm" for="inputHIN"><bean:message key="oscarMDS.index.msgHealthNumber"/></label>
                                    <input type="text" name="patientHealthNumber" id="inputHIN" autocomplete="off"
                                           value="<%=query.getPatientHealthNumber()%>" onchange="this.form.submit()">
                                </div>
                                <hr>
                                <label class="form-check-label">Date Range:</label>
                                <div>
                                    <label class="mb-2 btn-sm">Start:</label>
                                    <input readonly type="text" id="startDate" name="startDate" size="10" value="<%=query.getStartDate()%>" />
                                    <img src="../../images/cal.gif" id="startDate_cal" style="vertical-align: middle;">
                                    <img src="../../images/close.png" id="startDate_delete" style="vertical-align: middle; cursor: pointer;" onClick="resetDateUsingID('startDate')">
                                </div>
                                <div>
                                    <label class="mb-2 btn-sm">End:</label>
                                    <input readonly type="text" id="endDate" name="endDate" size="10" value="<%=query.getEndDate()%>" />
                                    <img src="../../images/cal.gif" id="endDate_cal" style="vertical-align: middle;">
                                    <img src="../../images/close.png" id="endDate_delete" style="vertical-align: middle; cursor: pointer;" onClick="resetDateUsingID('endDate')">
                                </div>
                                <center><input type="submit" class="btn btn-primary" value=" <bean:message key="oscarMDS.search.btnSearch"/> "></center>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>
<script>
    Calendar.setup({ inputField : "startDate", ifFormat : "%d/%m/%Y", showsTime :false, button : "startDate_cal", singleClick : true, step : 1 });
    Calendar.setup({ inputField : "endDate", ifFormat : "%d/%m/%Y", showsTime :false, button : "endDate_cal", singleClick : true, step : 1 });

    function resetDateUsingID(id) {
        const inputField = document.getElementById(id);
        if( inputField.value.length > 0 ) {
            inputField.value = "";
        }
}
</script>
