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
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div id="inboxItems"></div>
<script>
    function displayInboxItems(amount) {
        for (let i = 0; i < amount; i++) {
            jQuery('<div>').appendTo('#inboxItems').load('Inboxhub.do?method=displayInboxItem');
        }
    }

    $(window).ready(function(){
        displayInboxItems(3);
    });
    $(window).scroll(function() {
        if($(window).scrollTop() > $(document).height() - $(window).height() - 50) {
            displayInboxItems(1);
        }
    });
</script>
