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
String cancelUrl = "index.jsp";
//String submitUrl = "../index.jsp";
String thisPage = "Main Report";
String pageTitle = "Learn Migration Information Gathering - "+thisPage;
String pageInstructionsBottom = "Please use your browser's print/save to PDF feature to save a copy of this page then send the PDF, along with the corresponding Word document, to your Blackboard representative.";
String pageInstructionsTop = "Results of the report are shown below. Please review the results carefully, adding any comments or clarifications at the end. <br />"
                             +pageInstructionsBottom;
%>
<c:set var="dbType2" value="unknown"/>
<%

// Detect App server info
String appOsName = AppServerInfo.getOsName();
String appOsArch = AppServerInfo.getOsArch();
String appOsversion = AppServerInfo.getOsVersion();
String appJavaVersion = AppServerInfo.getJavaVersion();
String appServerTime = AppServerInfo.getServerTime("yyyy-MM-dd HH:mm:ss");
String fullHostname = AppServerInfo.getUrl();
String baseDirLabel = AppServerInfo.getBaseDirPath();
long baseDirDiskUsage = AppServerInfo.getDiskUsage(baseDirLabel);


//  Learn Version
String learnVersion = "";
learnVersion = blackboard.platform.LicenseUtil.getBuildNumber();
String contentDirLabel = AppServerInfo.getContentDirPath();
long contentDirDiskUsage = AppServerInfo.getDiskUsage(contentDirLabel);


// Db Info
String dbVersion = "";
String dbServerTime = "";
String dbType = DbServerInfo.getDatabaseType();
// also declaring dbType for jstl (see set earlier too)
pageContext.setAttribute("dbType2", dbType);

String dbMainSchema = DbServerInfo.getMainSchema();
double dbSize = -1;
List<String> dbListSchemas = DbServerInfo.getAllSchemas();

// Merged docstores
String CMSdocstores="Unknown";
String docstoreqrystr = "";
switch (dbType) {
    case "oracle":
        docstoreqrystr = "select count(*) from dba_users where username like '%CMS%'";
        break;
    case "mssql":
        docstoreqrystr = "select count(*) from sys.databases WHERE name like '%CMS%'";
        break;
    case "pgsql":
        docstoreqrystr = "SELECT count(*) FROM pg_database where datname like '%cms%'";
        break;
    default:
    // nothing to do
}

// TODO: move to class
Connection dbConnection = Db.getConnection();
Statement dbStatement = Db.createStatement(dbConnection);
ResultSet rs = null;
try {
    try {
        boolean wasExecuted = dbStatement.execute(docstoreqrystr);
        if (wasExecuted) {
            rs = dbStatement.getResultSet();   
            if (rs.next()) {
               int docstorecount=rs.getInt(1);
                if (docstorecount==2) {
                    CMSdocstores=docstorecount+" (Merged Docstores)";
                } else if (docstorecount==7){
                    CMSdocstores=docstorecount+" (Unmerged Docstores)";
                } 
            }
        }
    } finally {
        if (rs != null) {
            rs.close();
        }
        if (dbStatement != null) {
            dbStatement.close();
        }
        if(dbConnection != null){
            dbConnection.close();
        }
    }
} catch (Exception e) {
    // TODO: log in logs
    //dbVersion = "exception " + e + " " ;
}
    
    
    
    
// User info
int totalCoursesCount = -1;
int activeCoursesCount = -1;
int accessedLastYearCoursesCount = -1;
int activeUsers = -1;


// Building Blocks, large courses and auth providers
List<CourseHelper> largeCourses = new ArrayList<CourseHelper>();
List<B2Helper> b2s = new ArrayList<B2Helper>();
List<AuthHelper> authProviders = new ArrayList<AuthHelper>();        

// Pull info from the DB and then close connections
try {
        // Db server information
        dbVersion = DbServerInfo.getDatabaseVersion();
        dbServerTime = DbServerInfo.getDatabaseTimeAndTimezone("yyyy-MM-dd HH:mm:ss");
        dbSize = DbServerInfo.getDbSize();        
        
        // Courses info
        totalCoursesCount = CourseInfo.getTotalCourses();
        activeCoursesCount = CourseInfo.getActiveCourses();
        accessedLastYearCoursesCount = CourseInfo.getAccessedSince(365);
        largeCourses = CourseInfo.getLargeCourses();
        
        // Users info
        activeUsers = UserInfo.getActiveUsers();
        
        // Building Blocks
        b2s = B2HelperFactory.getB2s();
        
        // Auth Providers
        authProviders = AuthHelperFactory.getAuthProviders();
        
} catch(Exception e) {
        // TODO: write in logs
}
// check how to move the code into servlet and remove this
pageContext.setAttribute("dbListSchemas", dbListSchemas);
%>
<bbNG:genericPage ctxId="ctx" entitlement="system.buildingblocks.VIEW">
    <bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main">
        <bbNG:breadcrumb title="Learn Migration Information Gathering" href="<%= cancelUrl %>" />
        <bbNG:breadcrumb><%=thisPage%></bbNG:breadcrumb>
    </bbNG:breadcrumbBar>
    <bbNG:pageHeader instructions="<%=pageInstructionsTop%>">
        <bbNG:pageTitleBar ><%=pageTitle%></bbNG:pageTitleBar>
    </bbNG:pageHeader>

    <bbNG:dataCollection>

        <bbNG:step title="Summary">
            <bbNG:dataElement label="Learn Version" isRequired="yes" labelFor="LV">
                <%=learnVersion%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Active Users" isRequired="yes" labelFor="activeUsers">
                <%=activeUsers%>
           </bbNG:dataElement>
                <bbNG:dataElement label="Total Courses" isRequired="yes" labelFor="totalCourses">
                    <%=totalCoursesCount%>
                </bbNG:dataElement>
            <bbNG:dataElement isSubElement="true" label="Licensed Platforms" isRequired="yes" labelFor="licensedPlatforms2">
                <bbNG:dataElement isSubElement="true"><bbNG:ifLicensed component="ENTERPRISE_LEARNING">Course Delivery</bbNG:ifLicensed> </bbNG:dataElement>
                <bbNG:dataElement isSubElement="true"><bbNG:ifLicensed component="ENTERPRISE_CONTENT_SYSTEM">Content Management</bbNG:ifLicensed> </bbNG:dataElement>
                <bbNG:dataElement isSubElement="true"><bbNG:ifLicensed component="ENTERPRISE_COMMUNITY">Community Engagement</bbNG:ifLicensed> </bbNG:dataElement>
                <bbNG:dataElement isSubElement="true"><bbNG:ifLicensed component="ENTERPRISE_OUTCOMES">Outcomes Assessment</bbNG:ifLicensed> </bbNG:dataElement>
            </bbNG:dataElement>
            <bbNG:dataElement label="Database server type" isRequired="yes" labelFor="dbtype">
                <%=dbType%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Database main schema" isRequired="yes" labelFor="dbMainSchema">
                <%=dbMainSchema%>
            </bbNG:dataElement>
            <bbNG:dataElement label="CMS schemas" isRequired="yes" labelFor="CMSdocstores">
                <%=CMSdocstores%>
            </bbNG:dataElement>
        </bbNG:step>


        <bbNG:step title="Storage Usage">
            <bbNG:dataElement label="Base dir disk usage" isRequired="yes" labelFor="appServerBaseDirDf">
                <%=baseDirDiskUsage%> GB
            </bbNG:dataElement>
            <bbNG:dataElement label="Content dir path" isRequired="yes" labelFor="appServerContentDir">
                <%=contentDirLabel%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Content disk usage" isRequired="yes" labelFor="appServerontentDirDf">
                <%=contentDirDiskUsage%> GB
            </bbNG:dataElement>
            <bbNG:dataElement label="Database size" isRequired="yes" labelFor="dbsize">
            <c:choose>
                <c:when test="${dbType2 != 'mssql'}">
                    <%=dbSize%> GB
                </c:when> 
                <c:otherwise>
                    Unknown
                </c:otherwise>
             </c:choose>
           </bbNG:dataElement>

        </bbNG:step>

        <bbNG:step title="Application Server Detail">
            <bbNG:dataElement label="Full Hostname" isRequired="yes" labelFor="fullhostname">
                <%=fullHostname%>
            </bbNG:dataElement>
            <bbNG:dataElement label="OS" isRequired="yes" labelFor="appOsName">
                <%=appOsName%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Architecture" isRequired="yes" labelFor="appOsArch">
                <%=appOsArch%>
            </bbNG:dataElement>
            <bbNG:dataElement label="OS Version" isRequired="yes" labelFor="appOsversion">
                <%=appOsversion%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Java version" isRequired="yes" labelFor="appJavaVersion">
                <%=appJavaVersion%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Server time and timezone" isRequired="yes" labelFor="appServerTime">
                <%=appServerTime%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Base dir path" isRequired="yes" labelFor="appServerBaseDir">
                <%=baseDirLabel%>
            </bbNG:dataElement>

        </bbNG:step>



        <bbNG:step title="Database Server Detail">

            <bbNG:dataElement isSubElement="true" label="Database schemas" isRequired="yes" labelFor="dbListSchemas">
                 <c:forEach items="${dbListSchemas}" var="theSchemas">
                     <bbNG:dataElement isSubElement="true">
                         ${theSchemas}
                     </bbNG:dataElement>
                 </c:forEach>
            </bbNG:dataElement>
                
            <bbNG:dataElement label="Database server version" isRequired="yes" labelFor="dbversion">
                <%=dbVersion%>
            </bbNG:dataElement>

            <bbNG:dataElement label="Server time and timezone" isRequired="yes" labelFor="dbServerTime">
                <%=dbServerTime%>
            </bbNG:dataElement>
        </bbNG:step>
        

        <bbNG:step title="Courses information">
            <bbNG:dataElement label=" Total Courses" isRequired="yes" labelFor="totalCourses">
                <%=totalCoursesCount%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Active Courses" isRequired="yes" labelFor="activecourses">
                <%=activeCoursesCount%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Accessed in the last year" isRequired="yes" labelFor="courseAccessedInLastYear">
                <%=accessedLastYearCoursesCount%>
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Courses with large number of enrollments"> 
            <bbNG:inventoryList collection="<%=largeCourses%>" objectVar="ux" className="CourseHelper" description="Courses with large number of enrollments" emptyMsg="No courses with large number of enrollments found" showAll="true" displayPagingControls="false">
                <bbNG:listElement isRowHeader="true" label="Course ID" name="CourseId">
                    <%=ux.id%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Course Name" name="CourseName">
                    <%=ux.name%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Enrollments" name="countenrollments">
                    <%=ux.countEnrollments%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Availability" name="courseavail">
                    <%=ux.availableFlag%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Status" name="coursestatus">
                    <%=ux.statusFlag%>
                </bbNG:listElement>
            </bbNG:inventoryList>
        </bbNG:step>

        <bbNG:step title="Authentication"> 
            <bbNG:inventoryList collection="<%=authProviders%>" objectVar="ux" className="AuthHelper" description="Authentication providers" emptyMsg="No authentication providers found" showAll="true" displayPagingControls="false">
                <bbNG:listElement isRowHeader="true" label="Name" name="authName">
                    <%=ux.name%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="Type" name="authType">
                    <%=ux.type%>
                </bbNG:listElement>
                <bbNG:listElement isRowHeader="false" label="State" name="authState">
                    <%=ux.availableFlag%>
                </bbNG:listElement>
            </bbNG:inventoryList>
        </bbNG:step>

        <bbNG:step title="Building Blocks"> 
            <bbNG:inventoryList collection="<%=b2s%>" objectVar="ux" className="B2Helper" description="Building Blocks" emptyMsg="No plugins found" showAll="true" displayPagingControls="false">
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
            </bbNG:inventoryList>
        </bbNG:step>
<% /* commenting out for now, until we remove the word doc entirely
        <bbNG:step title="Additional Comments" instructions="expected usage growth, major changes occurring during the next 12 months or any comments relevant to a transition to Managed Hosting or Saas">
            <bbNG:dataElement label="Comments" isRequired="yes" labelFor="comments">
                <bbNG:textbox name="comments" label="comments"  />
            </bbNG:dataElement>
        </bbNG:step>
 */ %>               
        <bbNG:stepSubmit showCancelButton="false">
            <bbNG:stepSubmitButton label="OK" url="index.jsp"/>
        </bbNG:stepSubmit>
            

    </bbNG:dataCollection>
</bbNG:genericPage>
