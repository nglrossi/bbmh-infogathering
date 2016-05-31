<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@ page	language="java"
         import="java.util.*,
         java.sql.*,
         java.util.*,
         blackboard.bbmh.*"
         pageEncoding="UTF-8"
         %>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="/bbNG" prefix="bbNG"%>

<%
// Test logging
String debug = Logging.getLogFile() + "<br>";
debug += Logging.getSeverity();
 
%>

<%
String pageTitle = "Bb Managed Hosting Info Gathering - Building Block Usage";
String cancelUrl = "index.jsp";
//String submitUrl = "../index.jsp";
String pageInstructionsBottom = "Please use your browser's print/save to PDF feature to save a copy of this page then send the PDF, along with the corresponding Word document, to your Blackboard representative.";
String pageInstructionsTop = "Results of the report are shown below. Please review the results carefully, adding any comments or clarifications at the end. <br />"
                             +pageInstructionsBottom;
%>
<%

// Identifying info
String appServerTime = AppServerInfo.getServerTime("yyyy-MM-dd HH:mm:ss");
String fullHostname = AppServerInfo.getUrl();


// Db Info - left this in incase we need it
String dbVersion = "";
String dbServerTime = "";
String dbType = DbServerInfo.getDatabaseType();
String dbMainSchema = DbServerInfo.getMainSchema();
double dbSize = -1;
List<String> dbListSchemas = DbServerInfo.getAllSchemas();

List<B2HelperAdvanced> b2s = new ArrayList<B2HelperAdvanced>();


// Pull info from the DB and then close connections
try {
        // Db server information - left this in in case we need it
        dbVersion = DbServerInfo.getDatabaseVersion();
        
        // Building Blocks
        b2s = B2HelperFactoryAdvanced.getB2s();

} catch(Exception e) {
        // TODO: write in logs
}

%>
<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
    <bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main">
        <bbNG:breadcrumb title="Bb Managed Hosting Info Gathering" href="<%= cancelUrl %>" />
        <bbNG:breadcrumb><%=pageTitle%></bbNG:breadcrumb>
    </bbNG:breadcrumbBar>
    <bbNG:pageHeader instructions="<%=pageInstructionsTop%>">
        <bbNG:pageTitleBar ><%=pageTitle%></bbNG:pageTitleBar>
    </bbNG:pageHeader>
    <bbNG:dataCollection>
  
        <bbNG:step title="System Information">
            <bbNG:dataElement label="Full Hostname" isRequired="yes" labelFor="fullhostname">
                <%=fullHostname%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Server time and timezone" isRequired="yes" labelFor="appServerTime">
                <%=appServerTime%>
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Building Block Usage"> 
            <bbNG:inventoryList collection="<%=b2s%>" objectVar="ux" className="B2HelperAdvanced" description="Building Blocks" emptyMsg="No plugins found" showAll="true" displayPagingControls="false">
                <bbNG:listElement isRowHeader="true" label="Name" name="b2Name">
                    <%=ux.localizedName%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Version" name="version">
                    <%=ux.version%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Vendor" name="b2Vendor">
                    <%=ux.vendorName%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Handle" name="b2handle">
                    <%=ux.handle%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Status" name="b2Status">
                    <%=ux.availableFlag%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Last Modified" name="lastmodified">
                    <%=ux.dateModified%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Hits Last Year" name="hitslastyear">
                    <%=ux.hits%>
                </bbNG:listElement>
            </bbNG:inventoryList>
        </bbNG:step>

       
        <bbNG:stepSubmit instructions="<%=pageInstructionsBottom%>" showCancelButton="false">
            <bbNG:stepSubmitButton label="OK" url="index.jsp"/>
        </bbNG:stepSubmit>
            

    </bbNG:dataCollection>
</bbNG:genericPage>
