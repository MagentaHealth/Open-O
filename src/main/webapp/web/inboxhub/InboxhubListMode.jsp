<%@ page import="java.util.*" %>
<%@ page import="oscar.oscarLab.ca.on.*" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="https://www.owasp.org/index.php/OWASP_Java_Encoder_Project" prefix="e" %>
<%@page import="org.oscarehr.util.MiscUtils,org.apache.commons.lang.StringEscapeUtils" %>
<%@page import="org.apache.logging.log4j.Logger,org.oscarehr.common.dao.OscarLogDao,org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.inboxhub.query.InboxhubQuery" %>
<%@ page import="oscar.oscarMDS.data.CategoryData" %>
<c:if test="${page eq 1}">
<div class="bg-light text-light">
    <row>
        <input id="topFBtn" type="button" class="btn btn-primary btn-sm ms-1" value="<bean:message key="oscarMDS.index.btnForward"/>" onclick="submitForward('${sessionScope.user}')">
        <input id="topFileBtn" type="button" class="btn btn-primary btn-sm" value="File" onclick="submitFile('${sessionScope.user}')"/>
        <div class="d-flex align-items-center position-relative w-25 float-end">
            <div class="progress me-3" id="loadInboxListProgress" style="height: 25px; display: none; flex-grow: 1;">
                <div id="loadInboxListProgressBar" class="progress-bar" role="progressbar" style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                    <span id="inboxListProgressCount" class="count">0%</span>
                </div>
            </div>
            <button id="stopLoadingInboxList" onclick="stopInboxhubListProgress(0)" class="btn btn-sm btn-danger" style="display: none;">Stop</button>
        </div>
    </row>
    <row>
        <div class="inbox-table-responsive">
        <table table id="inbox_table" class="table table-striped inbox-table">
            <thead class="inbox-table-sticky-header">
            <tr>
                <th>
                    <input type="checkbox" onclick="checkAllLabs(0);" name="checkA"/>
                </th>
                <th><bean:message key="oscarMDS.index.msgHealthNumber"/></th>
                <th><bean:message key="oscarMDS.index.msgPatientName"/></th>
                <th><bean:message key="oscarMDS.index.msgSex"/></th>
                <th><bean:message key="oscarMDS.index.msgResultStatus"/></th>
                <th><bean:message key="oscarMDS.index.msgDateTest"/></th>
                <th><bean:message key="oscarMDS.index.msgOrderPriority"/></th>
                <th><bean:message key="oscarMDS.index.msgRequestingClient"/></th>
                <th><bean:message key="oscarMDS.index.msgDiscipline"/></th>
                <th><bean:message key="oscarMDS.index.msgReportStatus"/></th>
                <th>Ack #</th>
            </tr>
            </thead>
            <tbody id="inoxhubListModeTableBody">
</c:if>
            <c:if test="${page ge 1}">
            <c:forEach var="labResult" items="${labDocs}" varStatus="loopStatus">
                <tr id="labdoc_${labResult.segmentID}" class="${!labResult.isMatchedToPatient() ? 'table-warning' : (labResult.resultStatus == 'A' ? 'table-danger' : '')}">
                    <td>
                        <c:set var="disabled" value="${!labResult.matchedToPatient && labResult.labType != 'DOC' ? 'disabled' : ''}"/>
                        <input type="checkbox" name="flaggedLabs" value="${labResult.segmentID}:${labResult.labType}" ${disabled}>
                    </td>
                    <td><e:forHtmlContent value='${labResult.healthNumber}' /></td>
                    <td>
                        <c:set var="labRead" value="${labResult.hasRead(sessionScope.user) ? '' : '*'}"/>
                        <a href="javascript:void(0);" 
                        onclick="reportWindow('${e:forJavaScript(labLinks[loopStatus.index])}', window.innerHeight, window.innerWidth); return false;">
                            <e:forHtmlContent value='${labRead}${labResult.patientName}' />
                        </a>
                    </td>
                    <td>${labResult.sex}</td>
                    <td>${labResult.resultStatus == 'A' ? 'Abnormal' : ''}</td>
                    <td>${labResult.dateTime}</td>
                    <td>${labResult.priority}</td>
                    <td>${labResult.requestingClient}</td>
                    <td>${labResult.disciplineDisplayString == 'D' ? '' : labResult.disciplineDisplayString}</td>
                    <td>${labResult.reportStatus}</td>
                    <td>${labResult.acknowledgedStatus == 'Y' ? 1 : 0}</td>
                </tr>
            </c:forEach>
            </c:if>
<c:if test="${page eq 1}">
            </tbody>
        </table>
        </div>
    </row>
</div>
<script>
    ctx = "<e:forJavaScript value='${pageContext.request.contextPath}' />";

    jQuery('#inbox_table').DataTable({
        autoWidth: false,
        searching: false,
        scrollCollapse: true,
        paging: false,
        columnDefs: [
            {type: 'non-empty-string', targets: "_all"},
            {orderable: false, targets: 0}
        ],
        order: [[1, 'asc']],
    });

    //Opens a popup window to a given inbox item.
    function reportWindow(page, height, width) {
        if (height && width) {
            windowprops = "height=" + height + ", width=" + width + ", location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
        } else {
            windowprops = "height=660, width=960, location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
        }
        var popup = window.open(encodeURI(page), "labreport", windowprops);
        popup.focus();
    }
    
    //Data table custom sorting to move empty or null slots on any selected sort to the bottom.
    jQuery.extend(jQuery.fn.dataTableExt.oSort, {
        "non-empty-string-asc": function (str1, str2) {
            if (str1 == "")
                return 1;
            if (str2 == "")
                return -1;
            return ((str1 < str2) ? -1 : ((str1 > str2) ? 1 : 0));
        },
        "non-empty-string-desc": function (str1, str2) {
            if (str1 == "")
                return 1;
            if (str2 == "")
                return -1;
            return ((str1 < str2) ? 1 : ((str1 > str2) ? -1 : 0));
        }
    });
</script>
</c:if>
<c:if test="${!hasMoreData}">
<script>
    hasMoreData = false;
</script>
</c:if>