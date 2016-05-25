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
String pageTitle = "Bb Managed Hosting Info Gathering - Advanced Report";
String cancelUrl = "index.jsp";
//String submitUrl = "../index.jsp";
String pageInstructions = "Bbmh tool for gathering information as part of the onboarding to managed hosting.\n"
+ "<br/>Report completed";
%>
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
String dbMainSchema = DbServerInfo.getMainSchema();
double dbSize = -1;
List<String> dbListSchemas = DbServerInfo.getAllSchemas();

// User info
int totalCoursesCount = -1;
int activeCoursesCount = -1;
int accessedLastYearCoursesCount = -1;
int activeUsers = -1;


// Building Blocks, large courses and auth providers
List<CourseHelper> largeCourses = new ArrayList<CourseHelper>();
List<B2Helper> b2s = new ArrayList<B2Helper>();
List<AuthHelper> authProviders = new ArrayList<AuthHelper>();

// test list logins

List<Integer> howManyDays = new ArrayList<Integer>();
howManyDays.add(30);
howManyDays.add(60);
howManyDays.add(90);
howManyDays.add(120);
howManyDays.add(180);

Map<Integer, Integer> totalLogins = new TreeMap<Integer, Integer>();
        

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
        totalLogins = UserInfo.getUniqueLoginsSince(howManyDays);
        
        // Building Blocks
        b2s = B2HelperFactory.getB2s();
        
        // Auth Providers
        authProviders = AuthHelperFactory.getAuthProviders();
        
} catch(Exception e) {
        // TODO: write in logs
}
// check how to move the code into servlet and remove this
pageContext.setAttribute("totalLogins", totalLogins);
pageContext.setAttribute("dbListSchemas", dbListSchemas);

%>
<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
    <bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main">
        <bbNG:breadcrumb title="BB Support Tools" href="<%= cancelUrl %>" />
        <bbNG:breadcrumb><%=pageTitle%></bbNG:breadcrumb>
    </bbNG:breadcrumbBar>
    <bbNG:pageHeader instructions="<%=pageInstructions%>">
        <bbNG:pageTitleBar ><%=pageTitle%></bbNG:pageTitleBar>
    </bbNG:pageHeader>

    <bbNG:dataCollection>
<!--
        <bbNG:step title="Debug">
            <bbNG:dataElement label="debug" isRequired="yes" labelFor="debug">
                <%=debug%>
            </bbNG:dataElement>
        </bbNG:step>
-->        
        <bbNG:step title="Application server">
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
            <bbNG:dataElement label="Base dir disk usage" isRequired="yes" labelFor="appServerBaseDirDf">
                <%=baseDirDiskUsage%> gb
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Learn Version">
            <bbNG:dataElement label="Learn Version" isRequired="yes" labelFor="LV">
                <%=learnVersion%>
            </bbNG:dataElement>

            <bbNG:dataElement isSubElement="true" label="Licensed Platforms" isRequired="yes" labelFor="licensedPlatforms2">
                <bbNG:dataElement isSubElement="true"><bbNG:ifLicensed component="ENTERPRISE_LEARNING">Course Delivery</bbNG:ifLicensed> </bbNG:dataElement>
                <bbNG:dataElement isSubElement="true"><bbNG:ifLicensed component="ENTERPRISE_CONTENT_SYSTEM">Content Management</bbNG:ifLicensed> </bbNG:dataElement>
                <bbNG:dataElement isSubElement="true"><bbNG:ifLicensed component="ENTERPRISE_COMMUNITY">Community Engagement</bbNG:ifLicensed> </bbNG:dataElement>
                <bbNG:dataElement isSubElement="true"><bbNG:ifLicensed component="ENTERPRISE_OUTCOMES">Outcomes Assessment</bbNG:ifLicensed> </bbNG:dataElement>
            </bbNG:dataElement>
                
            <bbNG:dataElement label="Content dir path" isRequired="yes" labelFor="appServerContentDir">
                <%=contentDirLabel%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Content disk usage" isRequired="yes" labelFor="appServerontentDirDf">
                <%=contentDirDiskUsage%> gb
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Database server backend">
            <bbNG:dataElement label="Database server type" isRequired="yes" labelFor="dbtype">
                <%=dbType%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Database main schema" isRequired="yes" labelFor="dbMainSchema">
                <%=dbMainSchema%>
            </bbNG:dataElement>
            
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
            <bbNG:dataElement label="Database size" isRequired="yes" labelFor="dbsize">
                <%=dbSize%> gb
            </bbNG:dataElement>
            <bbNG:dataElement label="Server time and timezone" isRequired="yes" labelFor="dbServerTime">
                <%=dbServerTime%>
            </bbNG:dataElement>
        </bbNG:step>
        
        <bbNG:step title="Users information">
            <bbNG:dataElement label="Active Users" isRequired="yes" labelFor="activeUsers">
                <%=activeUsers%> 
           </bbNG:dataElement>
            
            <c:forEach items="${totalLogins}" var="quantiLogin">
                <bbNG:dataElement label="${quantiLogin.key} days unique logins" isRequired="false">
                    ${quantiLogin.value}
                </bbNG:dataElement>
            </c:forEach>
        
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
                <bbNG:listElement isRowHeader="false" label="Hits Last Year" name="hitslastyear">
                    <%=ux.hits%>
                </bbNG:listElement>
            </bbNG:inventoryList>
        </bbNG:step>

        <bbNG:step title="Additional Comments" instructions="expected usage growth, major changes occurring during the next 12 months or any comments relevant to a transition to Managed Hosting or Saas">
            <bbNG:dataElement label="Comments" isRequired="yes" labelFor="comments">
                <bbNG:textbox name="comments" label="comments"  />
            </bbNG:dataElement>
        </bbNG:step>
                
        <bbNG:stepSubmit showCancelButton="false">
            <bbNG:stepSubmitButton label="OK" url="index.jsp"/>
        </bbNG:stepSubmit>
            

    </bbNG:dataCollection>
</bbNG:genericPage>



<%
   //String returnUrl="index.jsp";
   //response.sendRedirect(returnUrl);
%>
<%!
//code methods in here e.g. private static boolean pingUrl (String address) {....}

/*
if(blackboard.util.PlatformUtil.osIsWindows()){
    osFlavour = "Windows not yet supported";
}else{
    osFlavour = "UNIX system";
}
/*
// Detect app server OS details via command line
String appOsDetails = "";
String baseDIR;
String command;
if(blackboard.util.PlatformUtil.osIsWindows()){
    appOsDetails = "Windows details, not yet supported";
    baseDIR = ConfigurationServiceFactory.getInstance().getBbProperty(BbConfig.BASEDIR_WIN);
    command = "windows command";
}else{
    appOsDetails = "Freebsd 1.2.3.4";
    baseDIR = ConfigurationServiceFactory.getInstance().getBbProperty(BbConfig.BASEDIR);
    command = "cat /proc/version";

         try
        {
            String line;
            Process p=Runtime.getRuntime().exec(command,null,( new File("/tmp")));
            BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));

            appOsDetails = in.readLine();
            in.close();
            p.waitFor();
        } catch(IOException e1) {
        } catch(InterruptedException e2) {
        }
}

*/


%>