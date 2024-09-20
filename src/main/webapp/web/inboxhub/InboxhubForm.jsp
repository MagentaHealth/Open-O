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

<!-- Search form Accordion -->
<div class="accordion" id="inbox-hub-search">
    <div class="accordion-item">
        <h2 class="accordion-header" id="headingSearch">
            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseSearch" aria-expanded="true" aria-controls="collapseSearch">
                Search
            </button>
        </h2>
        <div id="collapseSearch" class="accordion-collapse collapse show" aria-labelledby="headingSearch" data-bs-parent="#inbox-hub-search">
            <div class="accordion-body">
                <form action="${pageContext.request.contextPath}/web/inboxhub/Inboxhub.do?method=displayInboxForm" method="post" id="inboxSearchForm" onsubmit="return validatePatientOptions();">
                    <div class="m-2">
                        <div class="d-grid mb-2">
                            <input type="checkbox" class="btn-check btn-sm" name="viewMode" ${query.viewMode ? 'checked' : ''}
                                id="btnViewMode" autocomplete="off" onchange="this.form.submit()">
                            <label class="btn btn-outline-primary btn-sm" for="btnViewMode"><bean:message key="inbox.inboxmanager.msgPreviewModes"/></label>
                        </div>

                        <div class="mb-1">
                        <!--Provider-->
                            <label class="fw-bold text-uppercase">
                                <bean:message key="inbox.inboxmanager.msgProviders"/>
                            </label>
                            <input type="hidden" name="searchAll" id="searchProviderAll" value="${query.searchAll}"/>
                            <!-- Any Provider -->
                            <div class="form-check">
                                <input class="btn-check-input" type="radio" name="providerRadios" value="option1" id="anyProvider" ${query.searchAll eq 'true' ? 'checked' : ''} onClick="changeValueElementByName('searchAll', 'true');toggleInputVisibility('specificProvider', 'specificProviderId', 200);"/>
                                <label class="form-check-label" for="anyProvider"><bean:message key="oscarMDS.search.formAnyProvider"/></label>
                            </div>
                            <!-- No Provier -->
                            <div class="form-check">
                                <input class="btn-check-input" type="radio" name="providerRadios" value="option2" id="noProvider" ${query.searchAll eq 'false' ? 'checked' : ''} onClick="changeValueElementByName('searchAll', 'false');toggleInputVisibility('specificProvider', 'specificProviderId', 200);"/>
                                <label class="form-check-label" for="noProvider"><bean:message key="oscarMDS.search.formNoProvider"/></label>
                            </div>
                            <!-- Specific Provider -->
                            <div class="form-check">
                                <input class="btn-check-input" type="radio" name="providerRadios" value="option3" id="specificProvider" ${query.searchAll eq '' ? 'checked' : ''} onclick="changeValueElementByName('searchAll', ''); changeValueElementByName('searchProviderNo', document.getElementsByName('searchProviderNo')[0].value);toggleInputVisibility('specificProvider', 'specificProviderId', 200);" />
                                <label class="form-check-label" for="specificProvider"><bean:message key="oscarMDS.search.formSpecificProvider"/></label>
                                <div id="specificProviderId" class="ms-3">
                                    <input type="hidden" name="searchProviderNo" id="findProvider" value="${query.searchProviderNo}"/>
                                    <div class="input-group input-group-sm">
                                        <input class="form-control pe-0 m-1" type="text" id="autocompleteProvider" name="searchProviderName" value="${query.searchProviderName}" placeholder="Provider"/>
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
                            <input type="hidden" name="unmatched" id="unmatchedId" value="${query.unmatched}"/>
                            <div class="form-check">
                                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption1" id="allPatients" ${query.unmatched eq 'false' and query.patientFirstName eq '' ? 'checked' : ''} onClick="changeValueElementByName('unmatched', 'false');toggleInputVisibility('specificPatients', 'specificPatientsId', 200);"/>
                                <label class="form-check-label" for="allPatients"><bean:message key="oscarMDS.search.formAllPatients"/></label>
                            </div>
                            <!-- Unmatched to Existing Patient -->
                            <div class="form-check">
                                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption2" id="unmatchedPatients" ${query.unmatched eq 'true' ? 'checked' : ''} onClick="changeValueElementByName('unmatched', 'true');toggleInputVisibility('specificPatients', 'specificPatientsId', 200);" />
                                <label class="form-check-label" for="unmatchedPatients"><bean:message key="oscarMDS.search.formExistingPatient"/></label>
                            </div>
                            <!-- Specific Patient(s) -->
                            <div class="form-check">
                                <input class="btn-check-input" type="radio" name="patientsRadios" value="patientsOption3" id="specificPatients" ${query.unmatched eq 'false' and query.patientFirstName ne '' ? 'checked' : ''} onClick="changeValueElementByName('unmatched', 'false');toggleInputVisibility('specificPatients', 'specificPatientsId', 200);"/>
                                <label class="form-check-label" for="specificPatients"><bean:message key="oscarMDS.search.formSpecificPatients"/></label> <br>
                                <div id="specificPatientsId" class="d-grid ms-3">
                                    <div class="input-group input-group-sm">
                                        <input class="form-control pe-0 m-1" type="text" name="patientFirstName" id="inputFirstName" value="${query.patientFirstName}" placeholder="<bean:message key='admin.provider.formFirstName'/>"/>
                                    </div>
                                    <div class="input-group input-group-sm">
                                        <input class="form-control pe-0 mb-1 mx-1" type="text" name="patientLastName" id="inputLastName" value="${query.patientLastName}" placeholder="<bean:message key='admin.provider.formLastName'/>"/>
                                    </div>
                                    <div class="input-group input-group-sm">
                                        <input class="form-control pe-0 mb-1 mx-1" type="text" name="patientHealthNumber" id="inputHIN" value="${query.patientHealthNumber}" placeholder="<bean:message key='oscarMDS.index.msgHealthNumber'/>"/>
                                    </div>
                                    <div class="text-danger d-none ms-1" id="specificPatientErrorMessage">Please fill at least one field for the specific patient.</div>
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
                                        <input class="form-control pe-0 inbox-form-datepicker-input" type="text" placeholder="yyyy-mm-dd" id="startDate" name="startDate" value="${query.startDate}"/>
                                        <span class="input-group-text" for="startDate" id="startDateIcon"><i class="icon-calendar"></i></span>
                                    </div>
                                    <i class="icon-remove-sign clear-btn" aria-hidden="true" id="clearStartDate"></i>
                                </div>
                                <div class="inbox-form-datepicker-wrapper d-flex">
                                    <label class="my-auto" for="endDate">End</label>
                                    <div class="input-group input-group-sm d-inline-flex">
                                        <input class="form-control pe-0 inbox-form-datepicker-input" type="text" placeholder="yyyy-mm-dd" id="endDate" name="endDate" value="${query.endDate}"/>
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
                                <input type="checkbox" class="btn-check-input" name="doc" ${query.doc || (!query.doc && !query.lab && !query.hrm) ? 'checked' : ''} id="btnDoc" autocomplete="off">
                                <label class="form-check-label" for="btnDoc"><bean:message key="inbox.inboxmanager.msgTypeDocs"/></label><br>
                            </div>
                            <div class="form-check">
                                <input type="checkbox" class="btn-check-input" name="lab" ${query.lab || (!query.doc && !query.lab && !query.hrm) ? 'checked' : ''} id="btnLab" autocomplete="off">
                                <label class="form-check-label" for="btnLab"><bean:message key="inbox.inboxmanager.msgTypeLabs"/></label><br>
                            </div>

                            <c:if test="${!OscarProperties.getInstance().isBritishColumbiaBillingRegion()}">
                                <div class="form-check">
                                    <input type="checkbox" class="btn-check-input" name="hrm" ${query.hrm || (!query.doc && !query.lab && !query.hrm) ? 'checked' : ''} id="btnHRM" autocomplete="off">
                                    <label class="form-checkbox-label" for="btnHRM"><bean:message key="inbox.inboxmanager.msgTypeHRM"/></label><br>
                                </div>
                            </c:if>
                        </div>

                        <div class="mb-1">
                        <!--Review Status-->
                            <label class="fw-bold text-uppercase">
                                <bean:message key="inbox.inboxmanager.msgReviewStatus"/>
                            </label>
                            <input type="hidden" name="status" id="statusId" value="${query.status}"/>
                            <div class="form-check">
                                <input type="radio" class="btn-check-input" name="statusReview" id="statusAll" id="All" value="All"
                                    ${empty query.status ? 'checked' : ''} onclick="changeValueElementByName('status', '')">
                                <label class="form-check-label" for="statusAll"><bean:message key="inbox.inboxmanager.msgAll"/>
                            </div>
                            <div class="form-check">
                                <input type="radio" class="btn-check-input" name="statusReview" id="statusNew" value="N"
                                    ${query.status eq 'N' ? 'checked' : ''} onclick="changeValueElementByName('status', 'N')">
                                <label class="form-check-label" for="statusNew"><bean:message key="inbox.inboxmanager.msgNew"/></label>
                            </div>
                            <div class="form-check">
                                <input type="radio" class="btn-check-input" name="statusReview" id="statusAcknowledged" value="A"
                                    ${query.status eq 'A' ? 'checked' : ''} onclick="changeValueElementByName('status', 'A')">
                                <label class="form-check-label" for="statusAcknowledged"><bean:message key="inbox.inboxmanager.msgAcknowledged"/></label>
                            </div>
                            <div class="form-check">
                                <input type="radio" class="btn-check-input" name="statusReview" id="statusFiled" value="F"
                                    ${query.status eq 'F' ? 'checked' : ''} onclick="changeValueElementByName('status', 'F')">
                                <label class="form-check-label" for="statusFiled"><bean:message key="inbox.inboxmanager.msgFiled"/></label>
                            </div>
                        </div>

                        <div class="mb-2">
                        <!--Abnormal-->
                            <label class="fw-bold text-uppercase">
                                <bean:message key="inbox.inboxmanager.msgResultStatus"/>
                            </label>
                            <input type="hidden" name="abnormal" id="abnormalId" value="${query.abnormal}"/>
                            <div class="form-check">
                                <input type="radio" class="btn-check-input" name="abnormalResult" id="All" value="All"
                                    ${query.abnormal eq 'All' ? 'checked' : ''} onclick="changeValueElementByName('abnormal', 'All')">
                                <label class="form-check-label" for="All"><bean:message key="inbox.inboxmanager.msgAll"/></label>
                            </div>
                            <div class="form-check">
                                <input type="radio" class="btn-check-input" name="abnormalResult" id="Abnormal" value="Abnormal"
                                    ${query.abnormal eq 'Abnormal' ? 'checked' : ''} onclick="changeValueElementByName('abnormal', 'Abnormal')">
                                <label class="form-check-label" for="Abnormal"><bean:message key="global.abnormal"/></label>
                            </div>
                            <div class="form-check">
                                <input type="radio" class="btn-check-input" name="abnormalResult" id="Normal" value="Normal"
                                    ${query.abnormal eq 'Normal' ? 'checked' : ''} onclick="changeValueElementByName('abnormal', 'Normal')">
                                <label class="form-check-label" for="Normal"><bean:message key="inbox.inboxmanager.msgNormal"/></label>
                            </div>
                        </div>

                        <!--Search Button-->
                        <div class="d-grid">
                            <input class="btn btn-primary btn-sm" type="submit" value='<bean:message key="oscarMDS.search.btnSearch"/>'>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<!-- End of the Search form Accordion -->

<c:if test="${ categoryData.unmatchedDocs gt 0 or categoryData.unmatchedLabs gt 0 or not empty requestScope.categoryData.patientList }">
<div class="category-list"> 
    <!-- Unmatched List Accordion -->
    <c:if test="${ categoryData.unmatchedDocs gt 0 or categoryData.unmatchedLabs gt 0 }">
    <div class="accordion mt-1" id="inbox-hub-unmatched-list">
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingUnmatchedList">
                <a class="text-decoration-none accordion-button ${ param.providerNo eq 0 ? '' : 'collapsed' }" type="button" data-bs-toggle="collapse" data-bs-target="#collapseUnmatched" aria-expanded="false" aria-controls="collapseUnmatched">
                    Unmatched
                </a>
            </h2>
            <div id="collapseUnmatched" class="accordion-collapse collapse ${ param.providerNo eq 0 ? 'show' : '' }" aria-labelledby="headingUnmatchedList" data-bs-parent="#inbox-hub-unmatched-list">
                <div class="accordion-body my-2 ms-3">
                    <div class="accordion-item border-0">
                        <div class="accordion-header category-list-header d-flex" id="headingUnmatchedAll">
                            <span class="collapse-btn" data-bs-toggle="collapse" data-bs-target="#collapseUnmatchedAll" aria-expanded="true" aria-controls="collapseUnmatchedAll"></span>
                            <a id="patient0all" class="text-decoration-none text-wrap text-start collapse-heading btn category-btn px-0 ms-3" onclick="changeView(CATEGORY_PATIENT,0)">
                                All (<span id="patientNumDocs0"><c:out value="${requestScope.categoryData.unmatchedDocs + requestScope.categoryData.unmatchedLabs}" /></span>)
                            </a>
                        </div>
                        <div id="collapseUnmatchedAll" class="accordion-collapse collapse show" aria-labelledby="headingUnmatchedAll">
                            <div class="accordion-body collapse-sub-category-list">
                                <ul class="list-unstyled" id="labdoc0showSublist">
                                    <c:if test="${ categoryData.unmatchedDocs gt 0}" >
                                    <li>
                                        <a id="patient0docs" href="javascript:void(0);" class="btn category-btn text-decoration-none" onclick="changeView(CATEGORY_PATIENT_SUB,0,CATEGORY_TYPE_DOC);" title="Documents">
                                            Documents (<span id="pDocNum_0"><c:out value="${categoryData.unmatchedDocs}" /></span>)
                                        </a>
                                    </li>
                                    </c:if>
                                    <c:if test="${ categoryData.unmatchedLabs gt 0 }" >
                                    <li>
                                        <a id="patient0hl7s" href="javascript:void(0);" class="btn category-btn text-decoration-none" onclick="changeView(CATEGORY_PATIENT_SUB,0,CATEGORY_TYPE_HL7);" title="HL7">
                                            HL7 (<span id="pLabNum_0"><c:out value="${categoryData.unmatchedLabs}" /></span>)
                                        </a>
                                    </li>
                                    </c:if>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </c:if>
    <!-- End of the Unmatched Accordion -->

    <!-- Matched List Accordion -->
    <div class="accordion mt-1" id="inbox-hub-matched-list">
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingMatchedList">
                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseMatched" aria-expanded="false" aria-controls="collapseMatched">
                    Matched
                </button>
            </h2>
            <div id="collapseMatched" class="accordion-collapse collapse show" aria-labelledby="headingMatchedList" data-bs-parent="#inbox-hub-matched-list">
                <div class="accordion-body my-2 ms-3">
                    <c:forEach items="${requestScope.categoryData.patientList}" var="patient">
                    <c:set var="patientId" value="${patient.id}" />
                    <c:set var="patientName" value="${ patient.lastName }, ${patient.firstName}" />
                    <c:set var="numDocs" value="${ patient.docCount + patient.labCount }" />
                    <c:set var="docCount" value="${ patient.docCount }" />
                    <c:set var="labCount" value="${ patient.labCount }" />
                    <div class="accordion-item border-0">
                        <div class="accordion-header category-list-header d-flex" id="headingPatient${patientId}MatchedAll">
                            <span class="collapse-btn collapsed" data-bs-toggle="collapse" data-bs-target="#collapsePatient${patientId}MatchedAll" aria-expanded="true" aria-controls="collapsePatient${patientId}MatchedAll"></span>
                            <a id="patient${patientId}all" href="javascript:void(0);" class="text-decoration-none text-wrap text-start collapse-heading btn category-btn px-0 ms-3" onclick="changeView(CATEGORY_PATIENT,${patientId});" title="<c:out value='${patientName}' />">
                                <c:out value='${patientName}' /> (<span id="patientNumDocs${patientId}">${numDocs}</span>)
                            </a>
                        </div>
                        <div id="collapsePatient${patientId}MatchedAll" class="accordion-collapse collapse" aria-labelledby="headingPatient${patientId}MatchedAll">
                            <div class="accordion-body collapse-sub-category-list">
                                <ul class="list-unstyled" id="labdoc${patientId}showSublist">
                                    <c:if test="${not empty docCount}">
                                    <li>
                                        <a id="patient${patientId}docs" href="javascript:void(0);" class="btn category-btn text-decoration-none" onclick="changeView(CATEGORY_PATIENT_SUB,${patientId},CATEGORY_TYPE_DOC);" title="Documents">
                                            Documents (<span id="pDocNum_${patientId}">${docCount}</span>)
                                        </a>
                                    </li>
                                    </c:if>
                                    <c:if test="${not empty labCount}">
                                    <li>
                                        <a id="patient${patientId}hl7s" href="javascript:void(0);" class="btn category-btn text-decoration-none" onclick="changeView(CATEGORY_PATIENT_SUB,${patientId},CATEGORY_TYPE_HL7);" title="HL7">
                                            HL7 (<span id="pLabNum_${patientId}">${labCount}</span>)
                                        </a>
                                    </li>
                                    </c:if>
                                </ul>
                            </div>
                        </div>
                    </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
    <!-- End of the Matched Accordion -->
</div>
</c:if>

<script>
    $(document).ready( function() {
        toggleInputVisibility('specificProvider', 'specificProviderId', 0);
        toggleInputVisibility('specificPatients', 'specificPatientsId', 0);

        document.getElementById('startDateIcon').addEventListener('click', function() {
            document.getElementById('startDate').focus();
        });
        document.getElementById('endDateIcon').addEventListener('click', function() {
            document.getElementById('endDate').focus();
        });

        // Initialize datepickers and clear buttons
        setupDatepicker('#startDate', '#clearStartDate');
        setupDatepicker('#endDate', '#clearEndDate');

        // Adds a click event to all links within the '.category-list' to highlight the clicked link.
        highlightClickedLink();
    });

    function changeValueElementByName(name, value) {
        let inPatient = document.getElementsByName(name);
        inPatient[0].value = value;
    }

    function toggleInputVisibility(selectedRadioId, inputDivId, animationTime) {
        const selectedRadio = document.getElementById(selectedRadioId);
        const inputDiv = $('#' + inputDivId);
        if (selectedRadio.checked) {
            inputDiv.hide().removeClass('d-none').slideDown(animationTime);  // Show with animation and remove 'd-none'
        } else {
            inputDiv.slideUp(animationTime, function() {
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

    /**
     * Adds a click event to all links within the '.category-list' to highlight the clicked link.
     */
    function highlightClickedLink() {
        document.querySelectorAll('.category-list a').forEach(link => {
            link.addEventListener('click', function() {
            // Remove 'selected' class from all links
            document.querySelectorAll('.category-list a').forEach(item => {
                item.classList.remove('selected');
            });
            // Add 'selected' class to the clicked link
            this.classList.add('selected');
            });
        });
    }

    function validatePatientOptions() {
        // Get the selected patient option value
        const selectedValue = document.querySelector('input[name="patientsRadios"]:checked').value;

        // If the "patientsOption1" radio is selected, clear the patient details fields
        if (selectedValue === "patientsOption1") {
            ['patientFirstName', 'patientLastName', 'patientHealthNumber'].forEach(fieldName => 
                changeValueElementByName(fieldName, '')
            );
        }

        // If "patientsOption3" is selected, validate the patient details fields
        if (selectedValue === "patientsOption3") {
            // Retrieve the values of the specific patient input fields (first name, last name, health number)
            const fields = ['inputFirstName', 'inputLastName', 'inputHIN'].map(id => 
                document.getElementById(id).value.trim()
            );

            const errorMessage = document.getElementById('specificPatientErrorMessage');
            
            const isAllFieldsEmpty = fields.every(field => field === '');
            
            // If all fields are empty, display the error message and prevent form submission
            if (isAllFieldsEmpty) {
                errorMessage.classList.remove('d-none'); // Show error message
                return false; // Prevent form submission
            }

            // If at least one field is filled, hide the error message
            errorMessage.classList.add('d-none'); // Hide error message
        }

        return true;
    }

    function test() {
        $.ajax({
			url: "${pageContext.request.contextPath}/web/inboxhub/Inboxhub.do?method=displayInboxForm",
			method: 'POST',
			data: $('#inboxSearchForm').serialize(),			
			success: function(data) {
			},
            error: function(xhr, status, error) {
            }
        });
    }
</script>
