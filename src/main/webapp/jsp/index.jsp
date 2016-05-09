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
String pageTitle = "Bb Managed Hosting Info Gathering";
String pageInstructions = "Bbmh tool for gathering information as part of the onboarding to managed hosting.\n"
        + "<br/>This tool will produce a report about this system.\n";

String simpleTitle="<a href=\"basicReportConfirm.jsp\">Basic report</a>";
String simpleInstructions="This report can be ran at any time as it checks basic system settings and is not resource-intensive.\n"
        +"</br>Customers that are considering moving to Managed Hosting or SaaS can use it to collect basic informationf for Sales."
        +"<br/>A confirmation will be requested before running any report.";

String advancedTitle="<a href=\"advancedReportConfirm.jsp\">Advanced report</a>";
String advancedInstruction="This is an advanced report collects information about the system configuraiton and usage that should be provided to Blackboard.\n"
        +"</br>As it can be resource intensive and can run for several hours it is recommended to start the execution out of busy hours."
        +"<br/>A confirmation will be requested before running any report.";

%>



<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
    <bbNG:pageHeader instructions="<%=pageInstructions%>">
        <bbNG:breadcrumbBar environment="SYS_ADMIN" isContent="true">
            <bbNG:breadcrumb><%=pageTitle%></bbNG:breadcrumb>
        </bbNG:breadcrumbBar>
        <bbNG:pageTitleBar  showTitleBar="true" title="<%=pageTitle%>"/>
    </bbNG:pageHeader>
    
    <bbNG:landingPage>
        <bbNG:landingPageColumn>

            <bbNG:landingPageSection title="<%=simpleTitle%>" instructions="<%=simpleInstructions%>" />
            <bbNG:landingPageSection title="<%=advancedTitle%>" instructions="<%=advancedInstruction%>" />

        </bbNG:landingPageColumn>

    </bbNG:landingPage>
</bbNG:genericPage>

<%!
//code methods in here e.g. private static boolean pingUrl (String address) {....}
%>
