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

String pageTitle = "Blackboard Cloud Services Information Gathering";
String pageInstructions = "This tool will gather statistical data about your Blackboard Learn environment for use by you and Blackboard as a baseline for scoping and planning a potential move to Blackboard Managed Hosting or SaaS.\n"
                        + "<br /><br />You will have an opportunity to review the results after running the report, no data is automatically sent to Blackboard.  In this initial version, you can manually save the output to send to your Blackboard representative.";
String mainTitle="<a href=\"mainReport.jsp\">Main report - Information Gathering</a>";
String mainInstructions="This report can be run at any time as it checks basic system settings and is not resource-intensive.\n"
        +"</br>Customers that are considering moving to Managed Hosting or SaaS can use it to collect basic information for Sales, to go along with the Requirements Gathering document";

String b2Title="<a href=\"b2UsageReport.jsp\">Building Block Usage Report</a>";
String b2Instruction="This report lists all installed Building Blocks, with an extra column to indicate usage - based on the number of hits recorded in activity accumulator in the last year.\n"
        +"</br>Note: As it can be resource intensive and can run for several hours on a system with a lot of data it is recommended to start the execution out of busy hours.";

String uniqueLoginsTitle="<a href=\"uniqueLoginsReport.jsp\">Unique Logins Report</a>";
String uniqueLoginsInstruction="This report lists unique logins on the system during the past few months - based on the number of hits recorded in activity accumulator in the last year.\n"
        +"</br>Note: As it can be resource intensive and can run for several hours on a system with a lot of data it is recommended to start the execution out of busy hours.";

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

            <bbNG:landingPageSection title="<%=mainTitle%>" instructions="<%=mainInstructions%>" />
            <bbNG:landingPageSection title="<%=b2Title%>" instructions="<%=b2Instruction%>" />
            <bbNG:landingPageSection title="<%=uniqueLoginsTitle%>" instructions="<%=uniqueLoginsInstruction%>" />

        </bbNG:landingPageColumn>

    </bbNG:landingPage>
</bbNG:genericPage>
