<%--


    Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for
    Centre for Research on Inner City Health, St. Michael's Hospital,
    Toronto, Ontario, Canada

--%>


<%@page import="org.oscarehr.sharingcenter.SharingCenterUtil" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="/casemgmt/taglibs.jsp" %>
<%@taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="org.oscarehr.casemgmt.model.*" %>

<%
    String demo = request.getParameter("demographicNo");
    String roleName$ = (String) session.getAttribute("userrole") + "," + (String) session.getAttribute("user");

// MARC-HI's Sharing Center
    boolean isSharingCenterEnabled = SharingCenterUtil.isEnabled();

%>
<script type="text/javascript">

    //This object stores the key -> cmd value passed to action class and the id of the created div
    // and the value -> URL of the action class
    <c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>

    // Creates a popup upload window to upload a profile picture with a set URL
    function popupUploadPage(varpage, dn) {
        var page = varpage + "?demographicNo=" + dn;
        windowprops = "height=500,width=500,location=no,"
            + "scrollbars=no,menubars=no,toolbars=no,resizable=yes,top=50,left=50";
        var popup = window.open(page, "", windowprops);
        popup.focus();

    }

    // Sets a timer before reseting the client image back to the default, this is only done if a client image is set
    function delay(time) {
        var string = "document.getElementById('ci').src='${pageContext.request.contextPath}${ClientImage.imagePresentPlaceholderUrl}'";
        setTimeout(string, time);
    }
</script>

<!-- Sets the profile picture of a loaded case encounter-->
<security:oscarSec roleName="<%=roleName$%>" objectName="_newCasemgmt.photo" rights="r">
    <c:choose>
        <c:when test="${not empty requestScope.image_exists}">
            <c:set var="clientId" value="${demographicNo}"></c:set>
            <img style="cursor: pointer;" id="ci"
                 src="${pageContext.request.contextPath}/${ClientImage.imagePresentPlaceholderUrl}" alt="id_photo" height="100"
                 title="Click to upload a new photo."
                 OnMouseOver="document.getElementById('ci').src='${pageContext.request.contextPath}/imageRenderingServlet?source=local_client&clientId=${demographicNo}'"
                 OnMouseOut="delay(5000)" window.status='Click to upload a new photo.'; return true;"
            onClick="popupUploadPage('${pageContext.request.contextPath}/uploadimage.jsp', ${demographicNo}); return false;"/>
        </c:when>
        <c:otherwise>
            <img style="cursor: pointer;" src="${pageContext.request.contextPath}/${ClientImage.imageMissingPlaceholderUrl}"
                 alt="No_Id_Photo" height="100" title="Click to upload a new photo."
                 OnMouseOver="window.status='Click to upload a new photo.'; return true"
                 onClick="popupUploadPage('${pageContext.request.contextPath}/uploadimage.jsp', ${demographicNo}); return false;"/>
        </c:otherwise>
    </c:choose>
</security:oscarSec>

<!-- MARC-HI's Sharing Center -->
<% if (isSharingCenterEnabled) { %>
<div>
    <button type="button"
            onclick="window.open('${ctx}/sharingcenter/documents/demographicExport.jsp?demographic_no=<%=demo%>');">
        Export Patient Demographic
    </button>
</div>
<% } %>

<div id="rightColLoader" style="width: 100%;">
    <h3 style="width: 100%; background-color: #CCCCFF;">
        <fmt:setBundle basename="oscarResources"/><fmt:message key="oscarEncounter.LeftNavBar.msgLoading"/></h3>
</div>
