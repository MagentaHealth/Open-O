// Instead of importing cme.js using the CME tag (as done in Oscar19/OscarPro),
// we are opting to directly import cme.js into newEncounterLayout.jsp to load the ocean toolbar without utilizing the CME tag.

// Here, the 'ocean-host' script attribute is added in the cme.js script tag as follows:
// '<script id="mainScript" src="${ pageContext.request.contextPath }/js/custom/ocean/cme.js?no-cache=<%=randomNo%>&autoRefresh=true" ocean-host=<%=Encode.forUriComponent(OscarProperties.getInstance().getProperty("ocean_host"))%>></script>'
// when it is being imported into the newEncounterLayout.jsp.
(function (script) {
  let oceanHost = script.attributes['ocean-host'];
  if (oceanHost && oceanHost.value) {
      window.oceanHost = decodeURIComponent(oceanHost.value);
  }
})(document.currentScript);

 jQuery(document).ready(function(){
     // init();
     // rather than highjacking a <div> lets put OCEAN where the OSCAR instance has allowance
     jQuery("#ocean_placeholder").append("<div id='ocean_div' style='width: 100%; display: none; font-size: 11px;'>Sorry, the Ocean toolbar is currently unavailable.</div>");

     jQuery.ajax({
         url: window.oceanHost + "/robots.txt",
         cache: true,
         dataType: "text",
         success: function() {
             jQuery.ajax({
                 url: window.oceanHost + "/oscar_resources/OscarToolbar.js",
                 cache: true,
                 dataType: "script"
             });
         },
         error: function(jqXHR, textStatus, error) {
             console.log("Ocean toolbar error: " + textStatus + ", " + error);
             jQuery("#ocean_div").show().css("padding", "5px").
             css("text-align", "center");
         }
     });
   });
