<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<%
	if(request.getParameter( "username" ) != null && request.getParameter( "password" ) != null){
		
		if (ldap.search(request.getParameter( "username" ),request.getParameter( "password"))) {
			if (ldap.getAccessLevel() < 0) {
				response.sendRedirect("banned.jsp");
			} else {
				response.sendRedirect("join.jsp");
			}
		} else {
			response.sendRedirect("login.jsp");	
		}
	}
%>