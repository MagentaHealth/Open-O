<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
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

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>

<%@page import="java.util.Set"%>
<%@page import="java.util.List"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.text.DateFormat" %>
<%@page import="java.text.SimpleDateFormat" %>

<%@page import="org.oscarehr.common.dao.TicklerTextSuggestDao"%>
<%@page import="org.oscarehr.util.LocaleUtils"%>
<%@page import="org.oscarehr.common.dao.TicklerTextSuggestDao"%>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao"  %>
<%@page import="org.oscarehr.common.model.Provider"  %>
<%@page import="org.oscarehr.common.model.Demographic"  %>
<%@page import="org.oscarehr.common.model.TicklerTextSuggest"  %>
<%@page import="org.oscarehr.common.model.Tickler" %>
<%@page import="org.oscarehr.common.model.TicklerComment" %>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@page import="org.oscarehr.managers.TicklerManager" %>
<%@page import="oscar.OscarProperties"%>




<%
	TicklerManager ticklerManager = SpringUtils.getBean(TicklerManager.class);
   	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_tickler" rights="w" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_tickler");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%
    Boolean caisiEnabled = OscarProperties.getInstance().isPropertyActive("caisi");
	String ticklerNoStr = request.getParameter("tickler_no");    
    
    Integer ticklerNo = null;
    try {
        ticklerNo = Integer.valueOf(ticklerNoStr);
    }catch (NumberFormatException e) {}
    
    
    Tickler t = null;
    Demographic d = null;
    if (ticklerNo != null) {
        t = ticklerManager.getTickler(loggedInInfo, ticklerNo);
        d = t.getDemographic();
    }
    else {
        response.sendRedirect("../errorpage.jsp");
    }
             
    java.util.Locale vLocale =(java.util.Locale)session.getAttribute(org.apache.struts.Globals.LOCALE_KEY);

    String selected="";
    String stActive =  LocaleUtils.getMessage(request.getLocale(), "tickler.ticklerMain.stActive");
    String stComplete = LocaleUtils.getMessage(request.getLocale(), "tickler.ticklerMain.stComplete");
    String stDeleted = LocaleUtils.getMessage(request.getLocale(), "tickler.ticklerMain.stDeleted");
    
    String prHigh = LocaleUtils.getMessage(request.getLocale(), "tickler.ticklerMain.priority.high");
    String prNormal = LocaleUtils.getMessage(request.getLocale(), "tickler.ticklerMain.priority.normal");
    String prLow = LocaleUtils.getMessage(request.getLocale(), "tickler.ticklerMain.priority.low");
    
    GregorianCalendar now=new GregorianCalendar();
    int curYear = now.get(Calendar.YEAR);
    int curMonth = (now.get(Calendar.MONTH)+1);
	int curDay = now.get(Calendar.DAY_OF_MONTH); 
%>
<!DOCTYPE html>
<html:html locale="true">
    <head>
        <style>
            *:not(h2) {
                line-height: 1 !important;
                font-size: 12px !important;
            }
            .grid {
				display: grid;
				grid-template-columns: repeat(10, 1fr);
				grid-gap: 2px;
				width: 270px;
			}

			.grid a {
				background-color: #E6E6FA;
				text-align: center;
				width: auto;
				height: auto;
                padding: 2px;
				margin: 1px;
				display: flex;
				justify-content: center;
				text-decoration: none;
				color: black;
				font-size: 11px !important;
				border-radius: 20%;
			}

			.grid a:hover {
				background-color: #EE82EE;
				color: white;
			}
        </style>
        <title><bean:message key="tickler.ticklerEdit.title"/></title>
        <script type="application/javascript">
            //open a new popup window
            function popupPage(vheight,vwidth,varpage) { 
                var page = "" + varpage;
                windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
                var popup=window.open(page, "attachment", windowprops);
                if (popup != null) {
                    if (popup.opener == null) {
                      popup.opener = self;
                    }
                }
            }
            
            function pasteMessageText() {
                var selectedIdx = document.serviceform.suggestedText.selectedIndex;
                document.serviceform.newMessage.value = document.serviceform.suggestedText.options[selectedIdx].text;
            }
            
            function openBrWindow(theURL,winName,features) { 
                window.open(theURL,winName,features);
            }

            // Add options 1 to 10 for days, weeks, months, and years
			function addQuickPick() {
                const quickPickDiv = document.getElementById('quickPickDateOptions');
				for (let i = 0; i < 40; i++) {
					const linkButton = document.createElement('a');
					linkButton.href = '#';                    					
					switch (Math.floor(i/10)){
                        case 0: linkButton.innerText = (i%10)+1 + "d";linkButton.onclick = function() { addTime((i%10)+1, "days"); }; break;//1 through 10 days
						case 1: linkButton.innerText = (i%10)+1 + "w";linkButton.onclick = function() { addTime(((i%10)+1) * 7, "days"); }; break;//1 through 10 weeks
						case 2: linkButton.innerText = (i%10)+1 + "m";linkButton.onclick = function() { addTime((i%10)+1, "months"); }; break;//1 through 10 months
						case 3: linkButton.innerText = (i%10)+1 + "y";linkButton.onclick = function() { addTime(((i%10)+1) * 12, "months"); }; break;//1 through 10 years
                    }
                    quickPickDiv.appendChild(linkButton);
				}
			}

			function addTime(num, type) {
				let currentDate = new Date();
				if (type === "months") {
					currentDate.setMonth(currentDate.getMonth() + num);
				} else {
					currentDate.setDate(currentDate.getDate() + num);
				}
				const year = currentDate.getFullYear();
				const month = String(currentDate.getMonth() + 1).padStart(2, '0');
				const day = String(currentDate.getDate()).padStart(2, '0');
				const newDate = year + "-" + month + "-" + day;
				document.serviceform.xml_appointment_date.value = newDate;
			}
            
            function DateAdd(startDate, numDays, numMonths, numYears){
                var returnDate = new Date(startDate.getTime());
                var yearsToAdd = numYears;

                var month = returnDate.getMonth() + numMonths;
                if (month > 11)
                {
                        yearsToAdd = Math.floor((month+1)/12);
                        month -= 12*yearsToAdd;
                        yearsToAdd += numYears;
                }
                returnDate.setMonth(month);
                returnDate.setFullYear(returnDate.getFullYear()	+ yearsToAdd);

                returnDate.setTime(returnDate.getTime()+60000*60*24*numDays);

                return returnDate;
            }
            
    Date.prototype.addMonths = function(months) {
  	  var dat = new Date(this.valueOf());
  	  dat.setMonth(dat.getMonth() + months);
  	  return dat;
  }

 
	function validate(form){
		validate(form, false);
	}
 
	function validate(form , writeToEncounter){
               
        if (validateDate(form) <%=caisiEnabled?"&& validateSelectedProgram()":""%>){
            if(writeToEncounter) {
                var windowFeatures = "height=700,width=960";
                   // Open encounter window
                    window.open('../oscarEncounter/IncomingEncounter.do?demographicNo=<%=d.getDemographicNo()%>&providerNo=<%=loggedInInfo.getLoggedInProviderNo()%>&curDate=<%=curYear%>-<%=curMonth%>-<%=curDay%>&encType=&status=', '', windowFeatures);
            }
            form.submit();                
            return true;
        }
                return false;
	}

    function IsDate(value) {
      let dateWrapper=new Date(value);
        return !isNaN(dateWrapper.getDate());
    }	

	function validateDate() {
		if (document.serviceform.xml_appointment_date.value == "" || !IsDate(document.serviceform.xml_appointment_date.value)) {
            document.getElementById("error").insertAdjacentText("beforeend","<bean:message key="tickler.ticklerAdd.msgMissingDate"/>");
            document.getElementById("error").style.display='block';
			return false;
		} else {
			return true;
		}
    }
        </script>
<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet" type="text/css">

    </head>
    
    <body onLoad="addQuickPick()">
    <div class="container" >
        <html:form action="/tickler/EditTickler">
            <input type="hidden" name="method" value="editTickler"/>
            <input type="hidden" name="ticklerNo" value="<%=ticklerNo%>"/>
    <h2><bean:message key="tickler.ticklerEdit.title"/></h2>
            <div id="error" class="alert alert-error" style="display:none;"></div>

        <table class="table table-condensed">

                <tr>
                    <th style="background-color: #EEEEFF"><bean:message key="tickler.ticklerEdit.demographicName"/></th>                           
                    <td><a href="javascript:void(0)" onClick="popupPage(600,800,'<%=request.getContextPath() %>/demographic/demographiccontrol.jsp?demographic_no=<%=d.getDemographicNo()%>&displaymode=edit&dboperation=search_detail')"><%=d.getLastName()%>,<%=d.getFirstName()%></a></td>
                    <th style="background-color: #EEEEFF"><bean:message key="tickler.ticklerEdit.primaryPhone"/></th>                           
                    <td><%=d.getPhone()%></td> 
                </tr>
                <tr>
                    <th style="background-color: #EEEEFF"><bean:message key="tickler.ticklerEdit.chartNo"/></th>                           
                    <td><%=d.getChartNo()%></td>
                    <th style="background-color: #EEEEFF"><bean:message key="tickler.ticklerEdit.secondaryPhone"/></th>
                    <td><%=d.getPhone2()%></td>
                </tr>
                <tr>
                    <th style="background-color: #EEEEFF"><bean:message key="tickler.ticklerEdit.age"/></th>                           
                    <td><%=d.getAge()%>(<%=d.getFormattedDob()%>)</td> 
                    <th style="background-color: #EEEEFF"><bean:message key="tickler.ticklerEdit.email"/></th>
                    <td><%=d.getEmail()%></td>
                </tr>                

                <tr>
                    <td colspan="4" style="padding-bottom:1em;"></td>
                </tr>
                <tr>
                    <th colspan="2" style="background-color: #336666;color:white;"><bean:message key="tickler.ticklerEdit.messages"/></th>
                    <th style="background-color: #336666;color:white;"><bean:message key="tickler.ticklerEdit.addedBy"/>
                    <th style="background-color: #336666;color:white;"><bean:message key="tickler.ticklerEdit.updateDate"/>
                </tr>
                
                <%
                                	String cellColour = "lilac";
                                %>
                
                <tr>
                    <td colspan="2" class="<%=cellColour%>" style="font-weight: bold"><%=t.getMessage()%></td>
                    <td class="<%=cellColour%>" style="font-weight: bold"><%=t.getProvider().getLastName()%>,<%=t.getProvider().getFirstName()%></td>
                    <td class="<%=cellColour%>" style="font-weight: bold"><%=t.getUpdateDate()%></td>
                </tr>
                
                    <%
                                    	Set<TicklerComment> tComments = t.getComments(); 
                                                          for (TicklerComment tc : tComments) { 
                                                               if (cellColour.equals("lilac")) {
                                                                    cellColour = "white";
                                                                }else{
                                                                    cellColour = "lilac"; 
                                                                }
                                    %>
               <tr>
                    <td colspan="2" class="<%=cellColour%>"><%=tc.getMessage()%></td>
                    <td class="<%=cellColour%>"><%=tc.getProvider().getLastName()%>,<%=tc.getProvider().getFirstName()%></td>
                    <td class="<%=cellColour%>"><%=tc.getUpdateDateTime(vLocale)%></td>
                </tr>
                    <%}%>

                <tr><td colspan="4" style="padding-top:1em;"></td></tr>
                <tr>
                    <th colspan="2" style="background-color: #666699;color:white;"><bean:message key="tickler.ticklerEdit.newMessage"/></th>
                    <th colspan="2" style="background-color: #666699;color:white;"><bean:message key="tickler.ticklerEdit.status"/></th>
                </tr>
                <tr>
                    <td><a href="javascript:void(0)" onclick="openBrWindow('./ticklerSuggestedText.jsp','tickler_suggested_text','width=680,height=400')" style="font-weight:bold">
                        <bean:message key="tickler.ticklerEdit.suggestedText"/></a>:</td>
                    <td>
                        <select class="form-control" name="suggestedText">
                            <option value="">---</option>
                            <%   
                                TicklerTextSuggestDao ticklerTextSuggestDao = (TicklerTextSuggestDao) SpringUtils.getBean("ticklerTextSuggestDao");
                                for (TicklerTextSuggest tTextSuggest : ticklerTextSuggestDao. getActiveTicklerTextSuggests()) { %>
                                <option><%=tTextSuggest.getSuggestedText()%></option>
                            <% } %>
                        </select>
                    </td>
                    
                    <td colspan="2">
                        <select class="form-control" name="status">
                            <% if (t.getStatusDesc(vLocale).equals(stActive)){selected="selected";}else{selected="";}%>
                            <option <%=selected%> value="A"><bean:message key="tickler.ticklerMain.stActive"/></option>
                            <% if (t.getStatusDesc(vLocale).equals(stComplete)){selected="selected";}else{selected="";}%>
                            <option <%=selected%> value="C"><bean:message key="tickler.ticklerMain.stComplete"/></option>
                            <% if (t.getStatusDesc(vLocale).equals(stDeleted)){selected="selected";}else{selected="";}%>
                            <option <%=selected%> value="D"><bean:message key="tickler.ticklerMain.stDeleted"/></option>                           
                        <select>
                    </td>
                </tr>                
                <tr>
                    <td colspan="2" style="border: none;"><label for="newMessage"><bean:message key="tickler.ticklerEdit.messageText"/>:</label></td>
                    <th colspan="2" style="background-color: #666699;color:white;"><bean:message key="tickler.ticklerEdit.priority"/></th>
                </tr>
                
                <tr>
                    <td colspan="2" rowspan="7" style="border: none;">
                        <textarea class="form-control" rows="22" style="width:100%;" id="newMessage" name="newMessage"></textarea>
                        <input type="button" class="btn" name="pasteMessage" onclick="pasteMessageText()" value="<bean:message key="tickler.ticklerEdit.pasteMessage"/>"/>
                    </td>

                    <td colspan="2">
                        <select class="form-control" name="priority">
                            <% if (t.getPriorityWeb().equals(prHigh)){selected="selected";}else{selected="";}%>
                            <option <%=selected%> value="<bean:message key="tickler.ticklerMain.priority.high"/>"><bean:message key="tickler.ticklerMain.priority.high"/></option>
                            <% if (t.getPriorityWeb().equals(prNormal)){selected="selected";}else{selected="";}%>
                            <option <%=selected%> value="<bean:message key="tickler.ticklerMain.priority.normal"/>"><bean:message key="tickler.ticklerMain.priority.normal"/></option>
                            <% if (t.getPriorityWeb().equals(prLow)){selected="selected";}else{selected="";}%>
                            <option <%=selected%> value="<bean:message key="tickler.ticklerMain.priority.low"/>"><bean:message key="tickler.ticklerMain.priority.low"/></option>
                        </select>
                    </td>
                </tr>
                
                <tr>
                    <th colspan="2" style="background-color: #666699;color:white;">
                        <bean:message key="tickler.ticklerEdit.assignedTo"/>
                    </th>
                </tr>
                <tr>
                    <td colspan="2">
                        <select class="form-control" name="assignedToProviders">
                            <%
                                ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
                                List<Provider> providers = providerDao.getActiveProviders(); 
                                for (Provider p: providers) {
                                    
                                    if (p.equals(t.getAssignee())){
                                        selected = "selected";
                                    }
                                    else {
                                        selected = "";
                                    }
                            %>
                            <option <%=selected%> value="<%=p.getProviderNo()%>"><%=p.getLastName()%>,<%=p.getFirstName()%></option>
                            <%  } %>
                        </select>
                    </td>
                </tr>
                
                <tr>
                    <th colspan="2" style="background-color: #666699;color:white;">
                        <bean:message key="tickler.ticklerEdit.serviceDate"/>
                    </th>
                </tr>
                <tr>
                    <%


                    DateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd");
                    String strDate = dateformat.format(t.getServiceDate());


                    %>
                    <td colspan="2" style="border: none;">
                        <label for="xml_appointment_date"><bean:message key="tickler.ticklerEdit.calendarLookup"/></label>
                        <input name="xml_appointment_date" class="form-control" id="xml_appointment_date" type="date" maxlength="10" value="<%=strDate%>"/>
                    </td>

                </tr>
                <tr>
                    <td colspan="2" style="border: none;">
                        <div id="quickPickDateOptions" class="grid" >
                            <!-- Quick pick will be added here using JavaScript -->
                        </div>
                    </td>
                </tr>                 
                <tr>
                    <td colspan="2" style="vertical-align: bottom;text-align:right; padding-top:15px; border:none;">
                         <oscar:oscarPropertiesCheck property="tickler_email_enabled" value="true">
                            <html:checkbox property="emailDemographic"><bean:message key="tickler.ticklerEdit.emailDemographic"/></html:checkbox>
                         </oscar:oscarPropertiesCheck>
                       
                         <input type="button" class="btn btn-primary" name="updateTickler" value="<bean:message key="tickler.ticklerEdit.update"/>" onClick="validate(this.form)"/>
                         <input type="button" class="btn" name="cancelChangeTickler" value="<bean:message key="tickler.ticklerEdit.cancel"/>" onClick="window.close()"/>

                    </td>         
                </tr>
        </table>
        </html:form>
</div>

    </body>
</html:html>
