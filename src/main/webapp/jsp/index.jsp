<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<%@ page language="java" 
import="java.net.*,
java.util.*,
java.io.*,
blackboard.platform.config.ConfigurationServiceFactory,
blackboard.platform.config.*,
blackboard.bbmh.*
" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="bbNG" uri="/bbNG"%>
<c:set var="dbType" value="unknown"/>

<%

String pageTitle = "Learn Migration Information Gathering";
String pageInstructions = "This tool will gather statistical data about your Blackboard Learn environment for use by you and Blackboard as a baseline for scoping and planning a potential move to Blackboard Managed Hosting or SaaS.\n<br /><br />"
                        + "You will have an opportunity to review and print the results after running the report. No data is automatically sent to Blackboard.";
String mainTitle="1. <a href=\"mainReport.jsp\">Main Report - Information Gathering</a>";
String mainInstructions="Customers that are considering moving to Managed Hosting or SaaS can use it to collect basic information for Sales, to go along with the Requirements Gathering document.\n<br /><br />"
        +"This report can be run at any time as it checks basic system settings and is not resource-intensive.\n";

String b2csvTitle="2. <a href=\"b2csv.jsp\">Download CSV list of Building Blocks</a>";
String b2csvInstruction="This will download a CSV file listing all installed Building Blocks, including an extra column to indicate if the installation WAR file was found on the filesystem.\n<br /><br />"
        +"This report can be used as the basis for B2 comparison or for your Integrations Worksheet. ";

String uniqueLoginsTitle="3. <a href=\"uniqueLoginsReport.jsp\">Unique Logins Report</a>";
String uniqueLoginsInstruction="This report lists unique logins on the system during the past few months based on information in the Activity Accumulator.\n<br /><br />"
        +"<strong>Note:</strong> The run time for this report is dependent on the volume of historical activity on the system and system resources available.   To reduce run time on larger systems, consider running during a period of low anticipated end-user activity.";

String b2Title="4. <a href=\"b2UsageReport.jsp\">Building Block Usage Report</a>";
String b2Instruction="This report lists all installed Building Blocks. It includes an extra column to indicate usage based on the number of hits recorded in Activity Accumulator in the last year.\n<br /><br />"
        +"<strong>Note:</strong> The run time for this report is dependent on the volume of historical activity on the system and system resources available.   To reduce run time on larger systems, consider running during a period of low anticipated end-user activity.";


// getting db type so we can hide B2 Usage on SQL Server. Remmove this + inclusion of bbmh import when fixed
pageContext.setAttribute("dbType", DbServerInfo.getDatabaseType());


%>



<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
    <bbNG:pageHeader instructions="<%=pageInstructions%>">
       <bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main"  isContent="true">
            <bbNG:breadcrumb><%=pageTitle%></bbNG:breadcrumb>
        </bbNG:breadcrumbBar>
        <bbNG:pageTitleBar  showTitleBar="true" title="<%=pageTitle%>"/>
    </bbNG:pageHeader>
    <bbNG:landingPage>
        <bbNG:landingPageColumn>
            <bbNG:landingPageSection title="<%=mainTitle%>" instructions="<%=mainInstructions%>" />       
            <bbNG:landingPageSection title="<%=b2csvTitle%>" instructions="<%=b2csvInstruction%>" />
        </bbNG:landingPageColumn>
        <bbNG:landingPageColumn>
            <bbNG:landingPageSection title="<%=uniqueLoginsTitle%>" instructions="<%=uniqueLoginsInstruction%>" />
            <c:if test="${dbType == 'oracle'}">
                <bbNG:landingPageSection title="<%=b2Title%>" instructions="<%=b2Instruction%>" />
            </c:if> 
        </bbNG:landingPageColumn>
    </bbNG:landingPage>
</bbNG:genericPage>
