<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<%@ page language="java" 
import="java.net.*,
java.util.*,
java.io.*,
blackboard.platform.config.ConfigurationServiceFactory,
blackboard.platform.config.*
" pageEncoding="UTF-8" %>
<%@ taglib prefix="bbNG" uri="/bbNG"%>
<%
String pageTitle = "Bb Managed Hosting Info gathering";
String cancelUrl = "/";
String submitUrl = "processPost.jsp";
String pageInstructions = "Bbmh tool for gathering information as part of the onboarding to managed hosting.\n"
        + "<br/>This tool will produce a report about this system";

%>
<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
	<bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main">
		<bbNG:breadcrumb title="BB Support Tools" href="<%= cancelUrl %>" />
		<bbNG:breadcrumb><%=pageTitle%></bbNG:breadcrumb>
	</bbNG:breadcrumbBar>
	<bbNG:pageHeader instructions="<%=pageInstructions%>">
		<bbNG:pageTitleBar ><%=pageTitle%></bbNG:pageTitleBar>
	</bbNG:pageHeader>
        <form action="<%=submitUrl%>" method="post">
	<bbNG:dataCollection>
            <bbNG:step title="Run report">
			<bbNG:dataElement label="Delivery method" isRequired="yes" labelFor="deliveryMethod">
				<input type="radio" name="deliveryMethod" value="email" <%if ("email".equals(request.getParameter("deliveryMethod"))) out.print("checked"); %>>email
	 			<input type="radio" name="deliveryMethod" value="screen" <%if ("screen".equals(request.getParameter("deliveryMethod"))) out.print("checked"); %>>screen
			</bbNG:dataElement>
	</bbNG:step>


<%
    
String content="";
String command;

String baseDIR="";


/*
if ( "Yes".equals(request.getParameter("mh")) ) {
	baseDIR = "/mnt/asp/utils/app/bbpatch";
	command = "./bbpatch.sh list";
}

	 try 
	{ 
		String line;
		Process p=Runtime.getRuntime().exec(command,null,( new File(baseDIR)));
        BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
        while ((line = in.readLine()) != null) {
        	content+=line + "</br>";
        }
        BufferedReader er = new BufferedReader(new InputStreamReader(p.getErrorStream()));
        while ((line = er.readLine()) != null) {
        	content+=line + "</br>";
        }    
        in.close();
        p.waitFor(); 
	} catch(IOException e1) {	
	} catch(InterruptedException e2) {
	}


content+="Done"; 
*/
%>
<%=content%>
	<bbNG:stepSubmit cancelUrl="<%=cancelUrl%>" />
</bbNG:dataCollection>
</form>
</bbNG:genericPage>
<%!
//code methods in here e.g. private static boolean pingUrl (String address) {....}
%>
