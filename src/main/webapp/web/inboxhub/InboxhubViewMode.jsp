<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div id="inboxItems">
</div>
<script>
    //Displays inbox items based on the amount given on this page.
    function displayInboxItems(amount) {
        for (let i = 0; i < amount; i++) {
            jQuery('<div>').appendTo('#inboxItems').load('Inboxhub.do?method=displayInboxItem');
        }
    }
    //Load some initial inbox data.
    $(window).ready(function(){
        displayInboxItems(3);
    });
    //When scrolling to bottom or near bottom of screen, load more inbox items.
    $(window).scroll(function() {
        if($(window).scrollTop() > $(document).height() - $(window).height() - 50) {
            displayInboxItems(1);
        }
    });
</script>
