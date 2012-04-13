<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" type="text/css" href="css/ui.jqgrid.css" />
	<link rel="stylesheet" type="text/css" href="css/redmond/jquery-ui-redmond.css" />
	<script type="text/javascript" src="js/jquery-ui.js"></script>
	<script type="text/javascript" src="js/jquery.min.js"></script>
	<script type="text/javascript" src="js/jquery.validate.min.js"></script>
	<script src="js/grid.locale-en.js" type="text/javascript"></script>
	<script src="js/jquery.jqGrid.min.js" type="text/javascript"></script>
	<script src="js/jquery.xml2json.js" type="text/javascript"></script>
	
	<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
	<title>Join a Meeting</title>
</head>
<body>
	<%@ include file="auth_header.jsp"%>
	<%@ include file="meeting_api.jsp"%>
	<br/>
	<br/>
	<%
		out.println("<p align='center' style='font-size:23px'>Welcome <b><span style='color:green;'>" + ldap.getCN() + "</b> as " + ldap.getOU() + "</p>");
	%>
	<br/>
	<br/>
	<%  
		if(!ldap.getAuthenticated().equals("true")) {
	    	response.sendRedirect("login.jsp");	
		}
		meetingApplication.loadAllMeetings();
		ArrayList <String[]> lectureList = meetingApplication.getLectures();
   		ArrayList <String[]> meetingList = meetingApplication.getMeetings();
   	%>
	<table align="center" border="1" cellpadding="10" cellspacing="10">
		<tr valign="top">
			<td>
				<b>Join Lecture:</b><br/>
   				<form action="joinAction.jsp?type=1" method="post" name="lectureForm">
   					<%
   						out.println("<select name='lectureName'>");
   						
   						lectureList = runningList(lectureList);
						
   						if (lectureList.size() == 0){
   							out.println("No active lectures. <br/>");
   						}
   						
   						for (int i = 0; i < lectureList.size(); i++){
   							String rawName = lectureList.get(i)[0];
   							String displayName = StringUtils.removeStart(rawName, String.valueOf(PROF_SYMBOL));
   							displayName = StringUtils.replace(displayName, String.valueOf(NAME_DELIMITER), " (");
   							displayName = displayName + ")";
   							out.println("<option value='" + rawName + "'>" + displayName + "</option>");
   						}
						out.println("</select>");
						out.println("<br/>Password: <input type='password' name='lPassword' value=''/><br/><br/>");
						out.println("<input type='submit' id='lectureBtn' value='Join Lecture'/>");
   						   						   						
   						if(session.getAttribute("fail")!= null){
   							if (session.getAttribute("fail").toString().equals("1")){
  								session.removeAttribute("fail");
   								out.print("<div style='color:red' align='center'> Please input a password.</div>");
   							}
   							else if (session.getAttribute("fail").toString().equals("PW1")){
   								session.removeAttribute("fail");
   								out.print("<div style='color:red' align='center'> Invalid password.</div>");
   							}
   						}
   					%>   					
   				</form>
   			</td>
   			<td>
				<b>Join Meeting:</b><br/>
				<form action="joinAction.jsp?type=2" method="post" name="meetingForm">
   					<%
   						out.println("<select name='meetingName'>");
   						int validMeetings = 0;
   						for (int i = 0; i < meetingList.size(); i++){
   							String rawName = meetingList.get(i)[0];
   							if (isMeetingRunning(rawName).equals("true")){
   								String displayName = StringUtils.replace(rawName, String.valueOf(NAME_DELIMITER), " (");
   								displayName = displayName + ")";
   								out.println("<option value='" + rawName + "'>" + displayName + "</option>");
   								validMeetings++;
   							}
   						}
   						
   						if (validMeetings == 0){
								out.println("<option value='NULL'> No active meetings. </option>");
								out.println("</select>");
						}
   						else{
   							out.println("</select>");
   							out.println("<br/>Password: <input type='password' name='mPassword' value=''/><br/><br/>");
   							out.println("<input type='submit' id='meetingBtn' value='Join Meeting'/>");
   						}   	
   						
   						if(session.getAttribute("fail")!= null){
   							if (session.getAttribute("fail").toString().equals("2")){
  								session.removeAttribute("fail");
   								out.print("<div style='color:red' align='center'> Please input a password.</div>");
   							}
   							else if (session.getAttribute("fail").toString().equals("PW2")){
   								session.removeAttribute("fail");
   								out.print("<div style='color:red' align='center'> Invalid password.</div>");
   							}
   						}
   					%>
   				</form> 
   			</td>
   		</tr>
   	</table>
</body>
</html>