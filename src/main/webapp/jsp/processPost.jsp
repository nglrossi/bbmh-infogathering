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
String pageTitle = "Bb Managed Hosting Info gathering";
String cancelUrl = "index.jsp";
//String submitUrl = "processPost.jsp";
String pageInstructions = "Bbmh tool for gathering information as part of the onboarding to managed hosting.\n"
+ "<br/>Report completed";
%>
<%
// Initialize db
Db db = new Db();
Connection conn = Db.getConnection();

// Detect App server info
String appOsName = AppServerInfo.getOsName();
String appOsArch = AppServerInfo.getOsArch();
String appOsversion = AppServerInfo.getOsVersion();
String appJavaVersion = AppServerInfo.getJavaVersion();
String appServerTime = AppServerInfo.getServerTime("yyyy-MM-dd HH:mm:ss");

// Detect Learn Version
String learnVersion = "";
learnVersion = blackboard.platform.LicenseUtil.getBuildNumber();

// Detect whether MSSQL/Oracle/Postgres
String dbVersion = "";
String dbServerTime = "";
String dbType = DbServerInfo.getDatabaseType();

int totalCoursesCount = -1;
int activeCoursesCount = -1;
int accessedLastYearCoursesCount = -1;

int activeUsers = -1;
int i30daysLogins = -1;
int i60daysLogins = -1;
int i120daysLogins = -1;
int i180daysLogins = -1;

List<B2Helper> b2s = new ArrayList<B2Helper>();

// Pull info from the DB and then close connections
try {
        // create connection that will be used for all the queries
        //stmt = Db.createStatement(conn);
        
        // Db server information
        DbServerInfo dbInfo = new DbServerInfo();
        dbVersion = DbServerInfo.getDatabaseVersion(conn);
        dbServerTime = DbServerInfo.getDatabaseTimeAndTimezone(conn, "yyyy-MM-dd HH:mm:ss");
        
        // Courses info
        totalCoursesCount = CourseInfo.getTotalCourses(conn);
        activeCoursesCount = CourseInfo.getActiveCourses(conn);
        accessedLastYearCoursesCount = CourseInfo.getAccessedSince(conn, 365);
        
        // Users info
        activeUsers = UserInfo.getActiveUsers(conn);
        i30daysLogins = UserInfo.getUniqueLoginsSince(conn, 30);
        i60daysLogins = UserInfo.getUniqueLoginsSince(conn, 60);
        i120daysLogins = UserInfo.getUniqueLoginsSince(conn, 120);
        i180daysLogins = UserInfo.getUniqueLoginsSince(conn, 180);
        
        // Building Blocks
        B2HelperFactory b2factory = new B2HelperFactory();
        b2s = b2factory.getB2s(conn);
        
} catch(Exception e) {
        // TODO: write in logs
}finally {
    // close connections
     if(conn != null){
        conn.close();
    }
}
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

        <bbNG:step title="Application server">
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
   
        </bbNG:step>

        <bbNG:step title="Database server backend">
            <bbNG:dataElement label="Database server type" isRequired="yes" labelFor="dbtype">
                <%=dbType%>
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
        
        <bbNG:step title="Users information">
            <bbNG:dataElement label="Active Users" isRequired="yes" labelFor="activeUsers">
                <%=activeUsers%>
            </bbNG:dataElement>
            <bbNG:dataElement label="30 days unique logins" isRequired="yes" labelFor="i30daysLogins">
                <%=i30daysLogins%>      
            </bbNG:dataElement>
            <bbNG:dataElement label="60 days unique logins" isRequired="yes" labelFor="i60daysLogins">
                <%=i60daysLogins%>
            </bbNG:dataElement>
            <bbNG:dataElement label="120 days unique logins" isRequired="yes" labelFor="i120daysLogins">
                <%=i120daysLogins%>
            </bbNG:dataElement>
            <bbNG:dataElement label="180 days unique logins" isRequired="yes" labelFor="i180daysLogins">
                <%=i180daysLogins%>
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Building Blocks"> 
            <bbNG:inventoryList collection="<%=b2s%>" objectVar="ux" className="B2Helper" description="Building Blocks" emptyMsg="No plugins found" showAll="true" displayPagingControls="false" initialSortCol="b2Name">
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

        <bbNG:stepSubmit cancelUrl="<%=cancelUrl%>" />

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