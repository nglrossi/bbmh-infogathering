<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@ page	language="java"
         import="java.util.*,
         java.sql.*,
         blackboard.bbmh.*
         "
         pageEncoding="UTF-8"
         %>

<%@ taglib uri="/bbData" prefix="bbData"%>
<%@ taglib uri="/bbNG" prefix="bbNG"%>
<%
String pageTitle = "Bb Managed Hosting Info Gathering - Advanced Report";
String cancelUrl = "index.jsp";
//String submitUrl = "../index.jsp";
String pageInstructions = "Bbmh tool for gathering information as part of the onboarding to managed hosting.\n"
        + "<br/>This tool will produce a report about this system.\n";
%>
<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
    <bbNG:pageHeader instructions="<%=pageInstructions%>">
        <bbNG:breadcrumbBar environment="SYS_ADMIN" isContent="true">
            <bbNG:breadcrumb><%=pageTitle%></bbNG:breadcrumb>
        </bbNG:breadcrumbBar>
        <bbNG:pageTitleBar  showTitleBar="true" title="<%=pageTitle%>"/>
    </bbNG:pageHeader>

    <bbNG:dataCollection>

        <bbNG:step title="Advanced report confirmation">
            <bbNG:dataElement label="Full Hostname" isRequired="yes" labelFor="fullhostname">
                Click Submit to continue..
            </bbNG:dataElement>
        </bbNG:step>

            <bbNG:stepSubmit showCancelButton="false">
                <bbNG:stepSubmitButton label="OK" url="advancedReportExec.jsp"/>
            </bbNG:stepSubmit>
    </bbNG:dataCollection>
</bbNG:genericPage>
