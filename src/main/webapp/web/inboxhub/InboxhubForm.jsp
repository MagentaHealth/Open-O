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
<%@ page import="oscar.OscarProperties" %>
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

<form action="${pageContext.request.contextPath}/web/inboxhub/Inboxhub.do?method=displayInboxForm" method="post" id="myForm">
    <div class="m-2">
        <div class="d-grid mb-2">
            <input type="checkbox" class="btn-check btn-sm" name="viewMode" <% if (query.getViewMode()) { %> checked <% } %>
                   id="btnViewMode" autocomplete="off" onchange="this.form.submit()">
            <label class="btn btn-outline-primary btn-sm" for="btnViewMode"><bean:message key="inbox.inboxmanager.msgPreviewModes"/></label>
        </div>

        <div class="mb-1">
        <!--Provider-->
            <label class="fw-bold text-uppercase">
                <bean:message key="inbox.inboxmanager.msgProviders"/>
            </label>
            <input type="hidden" name="searchAll" id="searchProviderAll" value="<%=query.getSearchAll()%>"/>
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
                    onClick="changeValueElementByName('searchAll', ''); changeValueElementByName('searchProviderNo', document.getElementsByName('searchProviderNo')[0].value);" />
                <label class="form-check-label" for="specificProvider"><bean:message key="oscarMDS.search.formSpecificProvider"/></label>
                <div id="specificProviderId" class="ms-3">
                    <input type="hidden" name="searchProviderNo" id="findProvider" value="<%=query.getSearchProviderNo()%>"/>
                    <div class="input-group input-group-sm">
                        <input class="form-control pe-0 m-1" type="text" id="autocompleteProvider" name="searchProviderName" value="<%=query.getSearchProviderName()%>" placeholder="Provider"/>
                    </div>
                </div>
            </div>
        </div>

        <div class="mb-1">
        <!--Patient(s)-->
            <label class="fw-bold text-uppercase">
                <bean:message key="inbox.inboxmanager.msgPatinets"/>
            </label>
            <!-- All Patients (including unmatched) -->
            <input type="hidden" name="unmatched" id="unmatchedId" value="<%=query.getUnmatched()%>"/>
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption1" id="allPatients" onClick="changeValueElementByName('unmatched', 'false'); changeValueElementByName('patientFirstName', '')" checked/>
                <label class="form-check-label" for="allPatients"><bean:message key="oscarMDS.search.formAllPatients"/></label>
            </div>
            <!-- Unmatched to Existing Patient -->
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption2" id="unmatchedPatients" onClick="changeValueElementByName('unmatched', 'true')" />
                <label class="form-check-label" for="unmatchedPatients"><bean:message key="oscarMDS.search.formExistingPatient"/></label>
            </div>
            <!-- Specific Patient(s) -->
            <div class="form-check">
                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption3" id="specificPatients" onClick="changeValueElementByName('unmatched', 'false')"/>
                <label class="form-check-label" for="specificPatients"><bean:message key="oscarMDS.search.formSpecificPatients"/></label> <br>
                <div id="specificPatientsId" class="d-grid ms-3">
                    <div class="input-group input-group-sm">
                        <input class="form-control pe-0 m-1" type="text" name="patientFirstName" id="inputFirstName" value="<%=query.getPatientFirstName()%>" placeholder="<bean:message key='admin.provider.formFirstName'/>"/>
                    </div>
                    <div class="input-group input-group-sm">
                        <input class="form-control pe-0 mb-1 mx-1" type="text" name="patientLastName" id="inputLastName" value="<%=query.getPatientLastName()%>" placeholder="<bean:message key='admin.provider.formLastName'/>"/>
                    </div>
                    <div class="input-group input-group-sm">
                        <input class="form-control pe-0 mb-1 mx-1" type="text" name="patientHealthNumber" id="inputHIN" value="<%=query.getPatientHealthNumber()%>" placeholder="<bean:message key='oscarMDS.index.msgHealthNumber'/>"/>
                    </div>
                </div>
            </div>
        </div>

        <div class="mb-1">
        <!-- Date Range-->
            <label class="fw-bold text-uppercase">
                <bean:message key="inbox.inboxmanager.msgDateRange"/>
            </label>
            <div id="dateId" class="inbox-form-date-range">
                <div class="inbox-form-datepicker-wrapper mb-1 d-flex">
                    <label class="my-auto pe" for="startDate">Start</label>
                    <div class="input-group input-group-sm d-inline-flex">
                        <input class="form-control pe-0 inbox-form-datepicker-input" type="text" placeholder="yyyy-mm-dd" id="startDate" name="startDate" value="<%=query.getStartDate()%>"/>
                        <span class="input-group-text" for="startDate" id="startDateIcon"><i class="icon-calendar"></i></span>
                    </div>
                    <i class="icon-remove-sign clear-btn" aria-hidden="true" id="clearStartDate"></i>
                </div>
                <div class="inbox-form-datepicker-wrapper d-flex">
                    <label class="my-auto" for="endDate">End</label>
                    <div class="input-group input-group-sm d-inline-flex">
                        <input class="form-control pe-0 inbox-form-datepicker-input" type="text" placeholder="yyyy-mm-dd" id="endDate" name="endDate" value="<%=query.getEndDate()%>"/>
                        <span class="input-group-text" for="endDate" id="endDateIcon"><i class="icon-calendar"></i></span>
                    </div>
                    <i class="icon-remove-sign clear-btn" aria-hidden="true" id="clearEndDate"></i>
                </div>
            </div>
        </div>

        <div class="mb-1">
        <!--Type-->
            <label class="fw-bold text-uppercase">
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

            <% if (!OscarProperties.getInstance().isBritishColumbiaBillingRegion()) { %>
            <div class="form-check">
                <input type="checkbox" class="btn-check-input" name="hrm" <% if (query.getHrm() || (!query.getDoc() && !query.getLab() && !query.getHrm())) { %> checked <% } %> id="btnHRM"
                   autocomplete="off">
                <label class="form-checkbox-label" for="btnHRM"><bean:message key="inbox.inboxmanager.msgTypeHRM"/></label><br>
            </div>
            <% } %>
        </div>

        <div class="mb-1">
        <!--Review Status-->
            <label class="fw-bold text-uppercase">
                <bean:message key="inbox.inboxmanager.msgReviewStatus"/>
            </label>
            <div class="form-check">
                <input type="radio" class="btn-check-input" name="status" id="statusAll" id="All" value="All"
                    <% if (Objects.equals(query.getStatus(), "")) { %> checked <% } %> onclick="changeValueElementByName('status', '')">
                <label class="form-check-label" for="statusAll"><bean:message key="inbox.inboxmanager.msgAll"/>
            </div>
            <div class="form-check">
                <input type="radio" class="btn-check-input" name="status" id="statusNew" value="N"
                    <% if (Objects.equals(query.getStatus(), "N")) { %> checked <% } %> onclick="changeValueElementByName('status', 'N')">
                <label class="form-check-label" for="statusNew"><bean:message key="inbox.inboxmanager.msgNew"/></label>
            </div>
            <div class="form-check">
                <input type="radio" class="btn-check-input" name="status" id="statusAcknowledged" value="A"
                       onclick="changeValueElementByName('status', 'A')">
                <label class="form-check-label" for="statusAcknowledged"><bean:message key="inbox.inboxmanager.msgAcknowledged"/></label>
            </div>
            <div class="form-check">
                <input type="radio" class="btn-check-input" name="status" id="statusFiled" value="F"
                       onclick="changeValueElementByName('status', 'F')">
                <label class="form-check-label" for="statusFiled"><bean:message key="inbox.inboxmanager.msgFiled"/></label>
            </div>
        </div>

        <div class="mb-2">
        <!--Abnormal-->
            <label class="fw-bold text-uppercase">
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
        <div class="d-grid">
            <input class="btn btn-primary btn-sm"type="submit"value='<bean:message key="oscarMDS.search.btnSearch"/>'>
        </div>
    </div>
</form>
<script>
    function changeValueElementByName(name, value) {
        let inPatient = document.getElementsByName(name);
        inPatient[0].value = value;
    }

    document.addEventListener('DOMContentLoaded', function() {
        const form = document.getElementById('myForm');

        // Provider
        const providerRadios = form.elements['providerRadios'];
        for (var i = 0; i < providerRadios.length; i++) {
            providerRadios[i].addEventListener('change', function() {
                sessionStorage.setItem('selectedProviderRadio', this.value);
                //updateInputDisabled('selectedProviderRadio', 'specificProviderId', 'option3');
                toggleInputVisibility('specificProvider', 'specificProviderId');
            });
        }
        const selectedProviderRadio = sessionStorage.getItem('selectedProviderRadio');
        if (selectedProviderRadio) {
            document.querySelector('input[value="' + selectedProviderRadio + '"]').checked = true;
            //updateInputDisabled('selectedProviderRadio', 'specificProviderId', 'option3');
        }

        // Patients
        const patientsRadios = form.elements['patientsRadios'];
        for (var i = 0; i < patientsRadios.length; i++) {
            patientsRadios[i].addEventListener('change', function() {
                sessionStorage.setItem('selectedPatientsRadio', this.value);
                //updateInputDisabled('selectedPatientsRadio', 'specificPatientsId', 'patientsOption3');
                toggleInputVisibility('specificPatients', 'specificPatientsId');
            });
        }
        const selectedPatientsRadio = sessionStorage.getItem('selectedPatientsRadio');
        if (selectedPatientsRadio) {
            document.querySelector('input[value="' + selectedPatientsRadio + '"]').checked = true;
            //updateInputDisabled('selectedPatientsRadio', 'specificPatientsId', 'patientsOption3');
        }

        toggleInputVisibility('specificProvider', 'specificProviderId');
        toggleInputVisibility('specificPatients', 'specificPatientsId');

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

        document.getElementById('startDateIcon').addEventListener('click', function() {
            document.getElementById('startDate').focus();
        });
        document.getElementById('endDateIcon').addEventListener('click', function() {
            document.getElementById('endDate').focus();
        });

        // Initialize datepickers and clear buttons
        setupDatepicker('#startDate', '#clearStartDate');
        setupDatepicker('#endDate', '#clearEndDate');
    });

    function toggleInputVisibility(selectedRadioId, inputDivId) {
        const selectedRadio = document.getElementById(selectedRadioId);
        const inputDiv = $('#' + inputDivId);
        if (selectedRadio.checked) {
            inputDiv.hide().removeClass('d-none').slideDown(200);  // Show with animation and remove 'd-none'
        } else {
            inputDiv.slideUp(200, function() {
                inputDiv.addClass('d-none');  // Hide with animation and add 'd-none'
            });
        }
    }

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

    function setupDatepicker(dateInputId, clearBtnId) {
        let dateInput = $(dateInputId);
        let clearBtn = $(clearBtnId);
        
        dateInput.datetimepicker({
            format: 'YYYY-MM-DD',
            useCurrent: false,
        }).on('dp.change', function(e) {
            clearBtn.toggle(!!dateInput.val());
        }).on('dp.hide', function(e) {
        });

        // Disable manual typing
        dateInput.on('keydown paste', function(e) {
            e.preventDefault();
        });

        // Attach event listeners for input change and clear button
        dateInput.on('input', clearBtn.toggle(!!dateInput.val()));
        clearBtn.on('click', function() {
            dateInput.val('');
            clearBtn.toggle(!!dateInput.val());
        });

        // Initialize clear button visibility
        clearBtn.toggle(!!dateInput.val());
    }
</script>
