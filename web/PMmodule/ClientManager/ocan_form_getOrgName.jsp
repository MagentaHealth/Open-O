<%@page import="org.oscarehr.common.model.OcanStaffForm"%>
<%@page import="org.oscarehr.PMmodule.model.Admission"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="org.oscarehr.PMmodule.web.OcanForm"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>

<%
	int currentDemographicId=Integer.parseInt(request.getParameter("demographicId"));	
	int prepopulationLevel = OcanForm.PRE_POPULATION_LEVEL_ALL;
	
	int centerNumber = Integer.parseInt(request.getParameter("center_num"));
	String LHIN_code = request.getParameter("LHIN_code");
	
	OcanStaffForm ocanStaffForm=OcanForm.getOcanStaffForm(currentDemographicId, prepopulationLevel);		
	
%>


<script type="text/javascript">
$('document').ready(function() {
	//load mental health centres orgnaization name
	var demographicId='<%=currentDemographicId%>';
	var LHIN_code= $("#serviceUseRecord_orgLHIN<%=centerNumber%>").val(); 
	var orgName = $("#serviceUseRecord_orgName<%=centerNumber%>").val();
	var item = $("#center_block_orgName<%=centerNumber%>");
	if(orgName!=null && orgName!="") {
		$.get('ocan_form_getProgramName.jsp?demographicId='+demographicId+'&center_num=<%=centerNumber%>'+'&LHIN_code='+LHIN_code+'&orgName='+orgName, function(data) {
			  item.append(data);					 
			});				
	}
});
</script>

<div id="center_orgName<%=centerNumber%>">
	<table>
	
		<tr>
			<td class="genericTableHeader">Organization Name</td>
			<td class="genericTableData">
			
			<select name="serviceUseRecord_orgName<%=centerNumber %>" id="serviceUseRecord_orgName<%=centerNumber %>" onchange="changeOrgName(this);" class="{validate: {required:true}}">					
				<%=OcanForm.renderAsConnexOrgNameSelectOptions(ocanStaffForm.getId(), "serviceUseRecord_orgName"+centerNumber, OcanForm.getOcanConnexOrgOptions(LHIN_code), prepopulationLevel)%>
			</select>	
			</td>
		</tr>
		
	</table>
</div>