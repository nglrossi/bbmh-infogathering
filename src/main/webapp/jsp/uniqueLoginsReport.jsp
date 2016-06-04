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
String thisPage = "Unique Logins";
String pageTitle = "Learn Migration Information Gathering - "+thisPage;
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

//  list logins
List<Integer> howManyDays = new ArrayList<Integer>();
howManyDays.add(30);
howManyDays.add(60);
howManyDays.add(90);
howManyDays.add(120);
howManyDays.add(180);
Map<Integer, Integer> totalLogins = new TreeMap<Integer, Integer>();

// Pull info from the DB and then close connections
try {
    totalLogins = UserInfo.getUniqueLoginsSince(howManyDays);      
} catch(Exception e) {
        // TODO: write in logs
}
// check how to move the code into servlet and remove this
pageContext.setAttribute("totalLogins", totalLogins);

%>
<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
    <bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main">
        <bbNG:breadcrumb title="Learn Migration Information Gathering" href="<%= cancelUrl %>" />
        <bbNG:breadcrumb><%=thisPage%></bbNG:breadcrumb>
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


        <bbNG:step title="Users information">
            <c:forEach items="${totalLogins}" var="hmLogins">
                <bbNG:dataElement label="${hmLogins.key} days unique logins" isRequired="false">
                    ${hmLogins.value}
                </bbNG:dataElement>
            </c:forEach>
        </bbNG:step>


        <bbNG:stepSubmit instructions="<%=pageInstructionsBottom%>" showCancelButton="false">
            <bbNG:stepSubmitButton label="OK" url="index.jsp"/>
        </bbNG:stepSubmit>


    </bbNG:dataCollection>
</bbNG:genericPage>
