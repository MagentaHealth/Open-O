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
<style>
    #specificProviderId label {
        display: inline-block;
        width: 90px;
        text-align: right;
        margin-bottom: 5px;
    }

    #specificProviderId input[type="text"] {
        width: calc(100% - 120px);
    }

    #specificPatientsId label {
        display: inline-block;
        width: 100px;
        text-align: right;
        margin-bottom: 5px;
    }

    #specificPatientsId input[type="text"] {
        width: calc(100% - 120px);
    }

    #dateId label {
        display: inline-block;
        width: 70px;
        text-align: right;
        margin-bottom: 5px;
    }

    #dateId input[type="text"] {
        width: calc(100% - 140px);
    }
</style>

<form action="${pageContext.request.contextPath}/web/inboxhub/Inboxhub.do?method=displayInboxForm" method="post"
      id="myForm">
    <div>
        <div class="d-grid" style="font-size:smaller" >
            <input type="checkbox" class="btn-check btn-sm" name="viewMode" <% if (query.getViewMode()) { %> checked <% } %>
                   id="btnViewMode" autocomplete="off" onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnViewMode"><bean:message key="inbox.inboxmanager.msgPreviewModes"/></label><br>
        <div style="text-align: left;">
        <!--Provider-->
            <label class="fw-bold text-uppercase mu-2 btn-sm">
                <bean:message key="inbox.inboxmanager.msgProviders"/>
            </label>
            <!-- Any Provider -->
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="providerRadios" value="option1" id="anyProvider" onClick="changeValueElementByName('searchAll', 'true');"/>
                <label class="form-check-label" for="anyProvider"><bean:message key="oscarMDS.search.formAnyProvider"/></label>
            </div>
            <!-- No Provier -->
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="providerRadios" value="option2" id="noProvider" onClick="changeValueElementByName('searchAll', 'false');"/>
                <label class="form-check-label" for="noProvider"><bean:message key="oscarMDS.search.formNoProvider"/></label>
            </div>
            <!-- Specific Provider -->
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="providerRadios" value="option3" id="specificProvider" checked
                    onClick="changeValueElementByName('searchAll', ''); changeValueElementByName('searchProviderNo', '<%=query.getSearchProviderNo()%>');"/>
                <label class="form-check-label" for="specificProvider"><bean:message key="oscarMDS.search.formSpecificProvider"/></label>
                <div id="specificProviderId">
                    <label class="mb-0">Provider</label>
                    <input type="hidden" name="searchAll" id="searchProviderAll"value="<%=query.getSearchAll()%>"/>
                    <input type="hidden" name="searchProviderNo" id="findProvider"value="<%=query.getSearchProviderNo()%>"/>
                    <input type="text" id="autocompleteProvider" name="searchProviderName" value="<%=query.getSearchProviderName()%>"/><br>
                </div>
            </div>
        <!--Patient(s)-->
            <label class="fw-bold text-uppercase mu-2 btn-sm">
                <bean:message key="inbox.inboxmanager.msgPatinets"/>
            </label>
            <!-- All Patients (including unmatched) -->
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption1" id="allPatients" onClick="changeValueElementByName('patientFirstName', '')" checked/>
                <label class="form-check-label" for="allPatients"><bean:message key="oscarMDS.search.formAllPatients"/></label>
            </div>
            <!-- Unmatched to Existing Patient -->
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption2" id="unmatchedPatients" onClick="changeValueElementByName('unmatched', 'true')" />
                <label class="form-check-label" for="unmatchedPatients"><bean:message key="oscarMDS.search.formExistingPatient"/></label>
            </div>
            <!-- Specific Patient(s) -->
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption3" id="specificPatients"/>
                <label class="form-check-label" for="specificPatients"><bean:message key="oscarMDS.search.formSpecificPatients"/></label> <br>
                <div id="specificPatientsId">
                    <label class="mb-0" for="inputFirstName"><bean:message key="admin.provider.formFirstName"/></label>
                    <input type="text" name="patientFirstName" id="inputFirstName" autocomplete="off" disabled="true"
                        value="<%=query.getPatientFirstName()%>"><br>
                    <label class="mb-0" for="inputLastName"><bean:message key="admin.provider.formLastName"/></label>
                    <input type="text" name="patientLastName" id="inputLastName" autocomplete="off" disabled="true"
                        value="<%=query.getPatientLastName()%>"><br>
                    <div>
                        <label class="mb-0" for="inputHIN"><bean:message key="oscarMDS.index.msgHealthNumber"/></label>
                        <input type="text" name="patientHealthNumber" id="inputHIN" autocomplete="off" disabled="true"
                            value="<%=query.getPatientHealthNumber()%>">
                    </div>
                </div>
            </div>
        <!-- Date Range-->
            <label class="fw-bold text-uppercase mu-2 btn-sm">
                <bean:message key="inbox.inboxmanager.msgDateRange"/>
            </label>
            <div id="dateId">
                <div>
                    <label class="mb-1">Start:</label>
                    <input readonly type="text" id="startDate" name="startDate" size="10" value="<%=query.getStartDate()%>" />
                    <img src="../../images/cal.gif" id="startDate_cal" style="vertical-align: middle;">
                    <img src="../../images/clear.png" id="startDate_delete" style="vertical-align: middle; cursor: pointer;" onClick="resetDateUsingID('startDate')">
                </div>
                <div>
                    <label class="mb-1">End:</label>
                    <input readonly type="text" id="endDate" name="endDate" size="10" value="<%=query.getEndDate()%>" />
                    <img src="../../images/cal.gif" id="endDate_cal" style="vertical-align: middle;">
                    <img src="../../images/clear.png" id="endDate_delete" style="vertical-align: middle; cursor: pointer;" onClick="resetDateUsingID('endDate')">
                </div>
            </div>
        <!--Type-->
            <label class="fw-bold text-uppercase mu-2 btn-sm">
                <bean:message key="inbox.inboxmanager.msgType"/>
            </label>
            <div class="form-check">
                <input type="checkbox" class="btn-check-input" name="doc" <% if (query.getDoc() || (!query.getDoc() && !query.getLab() && !query.getHrm())) { %> checked <% } %> id="btnDoc"
                    autocomplete="off">
                <label class="form-check-label" for="btnDoc"><bean:message key="inbox.inboxmanager.msgTypeDocs"/></label><br>
            </div>
            <div class="form-check">
                <input type="checkbox" class="btn-check-input" name="lab" <% if (query.getLab() || (!query.getDoc() && !query.getLab() && !query.getHrm())) { %> checked <% } %> id="btnLab"
                   autocomplete="off">
            <label class="form-check-label" for="btnLab"><bean:message key="inbox.inboxmanager.msgTypeLabs"/></label><br>
            </div>
            <div class="form-check">
                <input type="checkbox" class="btn-check-input" name="hrm" <% if (query.getHrm() || (!query.getDoc() && !query.getLab() && !query.getHrm())) { %> checked <% } %> id="btnHRM"
                   autocomplete="off">
                <label class="form-checkbox-label" for="btnHRM"><bean:message key="inbox.inboxmanager.msgTypeHRM"/></label><br>
            </div>
        <!--Review Status-->
            <label class="fw-bold text-uppercase mu-2 btn-sm">
                <bean:message key="inbox.inboxmanager.msgReviewStatus"/>
            </label>
            <div class="form-check">
                <input type="radio" class="btn-check-input btn-sm" name="status" id="statusAll" id="All" value="All"
                    <% if (Objects.equals(query.getStatus(), "")) { %> checked <% } %> onclick="changeValueElementByName('status', '')">
                <label class="form-check-label" for="statusAll"><bean:message key="inbox.inboxmanager.msgAll"/>
            </div>
            <div class="form-check">
                <input type="radio" class="btn-check-input btn-sm" name="status" id="statusNew" value="N"
                    <% if (Objects.equals(query.getStatus(), "N")) { %> checked <% } %> onclick="changeValueElementByName('status', 'N')">
                <label class="form-check-label" for="statusNew"><bean:message key="inbox.inboxmanager.msgNew"/></label>
            </div>
            <div class="form-check">
                <input type="radio" class="btn-check-input btn-sm" name="status" id="statusAcknowledged" value="A"
                       onclick="changeValueElementByName('status', 'A')">
                <label class="form-check-label" for="statusAcknowledged"><bean:message key="inbox.inboxmanager.msgAcknowledged"/></label>
            </div>
            <div class="form-check">
                <input type="radio" class="btn-check-input btn-sm" name="status" id="statusFiled" value="F"
                       onclick="changeValueElementByName('status', 'F')">
                <label class="form-check-label" for="statusFiled"><bean:message key="inbox.inboxmanager.msgFiled"/></label>
            </div>
        <!--Abnormal-->
            <label class="fw-bold text-uppercase mu-2 btn-sm">
                <bean:message key="inbox.inboxmanager.msgResultStatus"/>
            </label>
            <div class="form-check">
                <input type="radio" class="btn-check-input" name="abnormal" id="All" value="All" checked
                    <% if (Objects.equals(query.getAbnormal(), "All")) { %> checked <% } %> onclick="changeValueElementByName('abnormal', 'All')">
                <label class="form-check-label" for="All"><bean:message key="inbox.inboxmanager.msgAll"/></label>
            </div>
            <div class="form-check">
                <input type="radio" class="btn-check-input" name="abnormal" id="Abnormal" value="Abnormal"
                    onclick="changeValueElementByName('abnormal', 'Abnormal')">
                <label class="form-check-label" for="Abnormal"><bean:message key="global.abnormal"/></label>
            </div>
            <div class="form-check">
                <input type="radio" class="btn-check-input" name="abnormal" id="Normal" value="Normal"
                    onclick="changeValueElementByName('abnormal', 'Normal')">
                <label class="form-check-label" for="Normal"><bean:message key="inbox.inboxmanager.msgNormal"/></label>
             </div>
        </div>
        <!--Search Button-->
            <input class="btn btn-primary btn-sm"type="submit"value='<bean:message key="oscarMDS.search.btnSearch"/>'>
        </div>
    </div>
</form>
<script>
    function changeValueElementByName(name, value) {
        let inPatient = document.getElementsByName(name);
        inPatient[0].value = value;
    }

    Calendar.setup({ inputField : "startDate", ifFormat : "%Y-%m-%d", showsTime :false, button : "startDate_cal", singleClick : true, step : 1 });
    Calendar.setup({ inputField : "endDate", ifFormat : "%Y-%m-%d", showsTime :false, button : "endDate_cal", singleClick : true, step : 1 });

    function resetDateUsingID(id) {
        const inputField = document.getElementById(id);
        if( inputField.value.length > 0 ) {
            inputField.value = "";
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const form = document.getElementById('myForm');

        // Provider
        const providerRadios = form.elements['providerRadios'];
        for (var i = 0; i < providerRadios.length; i++) {
            providerRadios[i].addEventListener('change', function() {
                sessionStorage.setItem('selectedProviderRadio', this.value);
                updateInputDisabled('selectedProviderRadio', 'specificProviderId', 'option3');
            });
        }
        const selectedProviderRadio = sessionStorage.getItem('selectedProviderRadio');
        if (selectedProviderRadio) {
            document.querySelector('input[value="' + selectedProviderRadio + '"]').checked = true;
            updateInputDisabled('selectedProviderRadio', 'specificProviderId', 'option3');
        }

        // Patients
        const patientsRadios = form.elements['patientsRadios'];
        for (var i = 0; i < patientsRadios.length; i++) {
            patientsRadios[i].addEventListener('change', function() {
                sessionStorage.setItem('selectedPatientsRadio', this.value);
                updateInputDisabled('selectedPatientsRadio', 'specificPatientsId', 'patientsOption3');
            });
        }
        const selectedPatientsRadio = sessionStorage.getItem('selectedPatientsRadio');
        if (selectedPatientsRadio) {
            document.querySelector('input[value="' + selectedPatientsRadio + '"]').checked = true;
            updateInputDisabled('selectedPatientsRadio', 'specificPatientsId', 'patientsOption3');
        }

        // Result status
        const resultStatusRadios = form.elements['status'];
        for (var i = 0; i < resultStatusRadios.length; i++) {
            resultStatusRadios[i].addEventListener('change', function() {
                sessionStorage.setItem('selectedResultStatusRadio', this.value);
            });
        }
        const selectedResultStatusRadio = sessionStorage.getItem('selectedResultStatusRadio');
        if (selectedResultStatusRadio) {
            document.querySelector('input[value="' + selectedResultStatusRadio + '"]').checked = true;
        }

        // Abnormal
        const resultAbnormalRadios = form.elements['abnormal'];
        for (var i = 0; i < resultAbnormalRadios.length; i++) {
            resultAbnormalRadios[i].addEventListener('change', function() {
                sessionStorage.setItem('selectedAbnormalRadio', this.value);
            });
        }
        const selectedAbnormalRadio = sessionStorage.getItem('selectedAbnormalRadio');
        if (selectedAbnormalRadio) {
            document.querySelector('input[value="' + selectedAbnormalRadio + '"]').checked = true;
        }
    });

    function updateInputDisabled(itemName, inputDivId, radioValue) {
        const selectedRadio = sessionStorage.getItem(itemName);
        const inputDiv = document.getElementById(inputDivId);
        const inputs = inputDiv.getElementsByTagName('input');
        let disableVal = true;
        if (selectedRadio === radioValue) {
            disableVal = false;
        }
        for (var i = 0; i < inputs.length; i++) {
            inputs[i].disabled = disableVal;
        }
    }

</script>
