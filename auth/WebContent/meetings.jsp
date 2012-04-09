<!--
XX
BigBlueButton - http://www.bigbluebutton.org

Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.

BigBlueButton is free software; you can redistribute it and/or modify it under the 
terms of the GNU Lesser General Public License as published by the Free Software 
Foundation; either version 3 of the License, or (at your option) any later 
version. 

BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along 
with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.

-->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<% 
	request.setCharacterEncoding("UTF-8"); 
	response.setCharacterEncoding("UTF-8"); 
%>
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
	<title>Manage Your Meetings</title>
	<style type="text/css">
	 #formcreate{
		margin-bottom:30px;
	 }
	 #formcreate label.labform{
	 	display:block;
	 	float:left;
	 	width:100px;
	 	text-align:right;
		margin-right:5px;
	 }
	 #formcreate div{
		margin-bottom:5px;
		clear:both;
	 }
	 #formcreate .submit{
		margin-left:100px;
		margin-top:15px;
	 }
	 #descript{
	 	vertical-align:top;
	 }
	 #meta_description , #username1{
		float:left;
	 }
	 .ui-jqgrid{
		font-size:0.7em
	}
	label.error{
		float: none; 
		color: red; 
		padding-left: .5em; 
		vertical-align: top;
		width:200px;
		text-align:left;
	}
	</style>
</head>
<body>

<%@ include file="bbb_api.jsp"%>
<%@ page import="java.util.regex.*"%>

<%@ include file="auth_header.jsp"%>

<%
	if (request.getParameterMap().isEmpty()) {
		//
		// Assume we want to see a list of meetings
		//
%>	

	<h3>Manage Meetings</h3>
	<select id="actionscmb" name="actions" onchange="recordedAction(this.value);">
		<option value="novalue" selected>Actions...</option>
		<option value="start">Start</option>
		<option value="edit">Edit</option>
		<option value="delete">Delete</option>
	</select>
	<table id="meetinggrid"></table>
	<div id="pager"></div> 
	<p>Note: New meetings will appear in the above list after processing.  Refresh your browser to update the list.</p>
	<script>
	function recordedAction(action){
		if(action=="novalue"){
			return;
		}
		
		var s = jQuery("#meetinggrid").jqGrid('getGridParam','selarrrow');
		if(s.length==0){
			alert("Select at least one row");
			$("#actionscmb").val("novalue");
			return;
		}
		var meetingid="";
		for(var i=0;i<s.length;i++){
			var d = jQuery("#meetinggrid").jqGrid('getRowData',s[i]);
			meetingid+=d.id;
			if(i!=s.length-1)
				meetingid+=",";
		}
		if(action=="delete"){ 
			var answer = confirm ("Are you sure to delete the selected meeting?");
			if (answer)
				sendRecordingAction(meetingid,action);
			else{
				$("#actionscmb").val("novalue");
				return;
			}
		}else{
			sendRecordingAction(meetingid,action);
		}
		$("#actionscmb").val("novalue");
	}
	
	function sendRecordingAction(meetingID,action){
		$.ajax({
			type: "GET",
			url: 'mettings_helper.jsp',
			data: "command="+action+"&meetingID="+meetingID,
			dataType: "xml",
			cache: false,
			success: function(xml) {
				window.location.reload(true);
				$("#meetinggrid").trigger("reloadGrid");
			},
			error: function() {
				alert("Failed to connect to API.");
			}
		});
	}
	
	$(document).ready(function(){
		$("#formcreate").validate();
		$("#meetingID option[value='English 101']").attr("selected","selected");
		jQuery("#meetinggrid").jqGrid({
			url: "meetings_helper.jsp?command=getMeetings",
			datatype: "xml",
			height: 300,
			loadonce: true,
			sortable: true,
			colNames:['Id','Type','Name','Moderator Pass', 'Viewer Pass', 'Guests', 'Recorded', 'Date Last Edited'],
			colModel:[
				{name:'id',index:'id', width:50, hidden:true, xmlmap: "meetingID"},
				{name:'type',index:'type', width:150, xmlmap: "type", sortable:true},
				{name:'name',index:'name', width:150, xmlmap: "name", sortable:true},
				{name:'modpass',index:'modpass', width:100, xmlmap: "modPass",sortable: true},
				{name:'viewpass',index:'viewpass', width:100, xmlmap: "viewPass",sortable: true},
				{name:'guests',index:'guests', width:80, xmlmap: "guests", sortable:true },
				{name:'recorded',index:'recorded', width:80, xmlmap: "recorded", sortable:true },
				{name:'date',index:'date', width:200, xmlmap: "date", sortable: true},
			],
			xmlReader: {
				root : "meetings",
				row: "meeting",
				repeatitems:false,
				id: "meetingID"
			},
			pager : '#pager',
			emptyrecords: "Nothing to display",
			multiselect: false,
			caption: "Your Meetings",
			loadComplete: function(){
				$("#meetinggrid").trigger("reloadGrid");
			}
		});
	});
	
	</script>
<%
	} else if (request.getParameter("action").equals("create")) {
		
		String meetingID = request.getParameter("meetingID");
		String username = request.getParameter("meta_email");
		
		//metadata
		Map<String,String> metadata=new HashMap<String,String>();
		
		metadata.put("description", request.getParameter("meta_description"));
		metadata.put("email", request.getParameter("meta_email"));
		// Use the meetingID (e.g English 101) as the title as slides playback
		// uses the title to display the link.
		metadata.put("title", request.getParameter("meetingID"));

		//
		// This is the URL for to join the meeting as moderator
		//
		String welcomeMsg = "<br>Welcome to %%CONFNAME%%!<br><br>For help see our <a href=\"event:http://www.bigbluebutton.org/content/videos\"><u>tutorial videos</u></a>.<br><br>To join the voice bridge for this meeting click the headset icon in the upper-left <b>(you can mute yourself in the Listeners window)</b>.<br><br>This meeting is being recorded (audio + slides + chat).";
		String joinURL = getJoinURL(username, meetingID, "true", welcomeMsg, metadata, null);
		if (joinURL.startsWith("http://")) {
%>
<script language="javascript" type="text/javascript">
  window.location.href="<%=joinURL%>";
</script>
<%
		}else{
%>
Error: getJoinURL() failed
<p /><%=joinURL%> <%
		}
	}
%> 



</body>
</html>
