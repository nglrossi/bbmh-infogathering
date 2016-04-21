<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@ page	language="java"
         import="java.util.*,
         java.util.*,
         java.io.*,
         java.sql.*,
         java.lang.System.*,
         blackboard.platform.LicenseUtil,
         blackboard.platform.config.BbConfig,
         blackboard.platform.config.ConfigurationServiceFactory,
         blackboard.data.*,
         blackboard.db.*,
         blackboard.platform.*,
         blackboard.platform.db.*,
         blackboard.base.*,
         blackboard.data.*,
         blackboard.data.user.*,
         blackboard.data.course.*,
         blackboard.persist.*,
         blackboard.persist.user.*,
         blackboard.persist.course.*,
         blackboard.platform.*,
         blackboard.platform.session.*,
         blackboard.platform.tracking.TrackingEventManager,
         blackboard.platform.tracking.data.TrackingEvent,
         org.apache.commons.lang.StringEscapeUtils,
         blackboard.platform.security.SecurityUtil,
         blackboard.platform.LicenseComponent,
         java.util.TimeZone,
         java.text.SimpleDateFormat,
         blackboard.platform.plugin.PlugIn,
         blackboard.platform.plugin.PlugInManagerFactory,
         blackboard.platform.plugin.PlugInManager,
         blackboard.platform.intl.BbResourceBundle,
         blackboard.platform.intl.BundleManager,
         blackboard.platform.intl.BundleManagerFactory,
         blackboard.bbmh.B2Helper,
         blackboard.bbmh.Db,
         blackboard.bbmh.AppServerInfo,
         blackboard.bbmh.DbServerInfo,
         blackboard.bbmh.CourseInfo
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
String content = "";
%>

<%
// Initialize db
Db db = new Db();
Connection conn = Db.getConnection();
Statement stmt = null;

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

// Pull info from the DB and then close connections
try {
        // create connection that will be used for all the queries
        stmt = Db.createStatement(conn);
        
        // Db server information
        DbServerInfo dbInfo = new DbServerInfo();
        dbVersion = DbServerInfo.getDatabaseVersion(stmt);
        dbServerTime = DbServerInfo.getDatabaseTimeAndTimezone(stmt, "yyyy-MM-dd HH:mm:ss");
        
        // Courses info
        totalCoursesCount = CourseInfo.getTotalCourses(stmt);
        activeCoursesCount = CourseInfo.getActiveCourses(stmt);
        accessedLastYearCoursesCount = CourseInfo.getAccessedSince(stmt, 365);
        
} catch(Exception e) {
        // TODO: write in logs
}finally {
    // close connections
     if(stmt != null){
        stmt.close();
    }
}

    
// Courses stats
//TODO: move to a library
//int totalCoursesCount = -1;
//int activeCoursesCount = -1;
//int activeAndAvailCoursesCount = -1;

//String qrystrCoursesCount = "select count(*) from course_main";
//String qrystrActiveCoursesCount = "select count(*) from course_main where row_status=0";
//String qrystrActiveAndAvailCoursesCount = "select count(*) from course_main where row_status=0 and available_ind='Y'";

ConnectionManager conman  = null;
Connection conn2 = null;
//Statement stmt = null;
ResultSet rs = null;
 /*
try {

    // Create Conn to correct database
    int j=0;

    BbDatabase bbDb = DbUtil.safeGetBbDatabase();
    conman = bbDb.getConnectionManager();
    while(conn2 == null && j<10){
        try {
                conn2 = conman.getConnection();
        }catch(ConnectionNotAvailableException cnae){
            Thread.sleep(1000);
            ++j;
        }
    }

    stmt = conn2.createStatement();
   if (stmt.execute(qrystrCoursesCount)) {
        rs = stmt.getResultSet();
        if (rs.next()) {
            coursesCount = rs.getInt(1);
        }
    }

    if (stmt.execute(qrystrActiveCoursesCount)) {
        rs = stmt.getResultSet();
        if (rs.next()) {
            activeCoursesCount = rs.getInt(1);
        }
    }


    if (stmt.execute(qrystrActiveAndAvailCoursesCount)) {
        rs = stmt.getResultSet();
        if (rs.next()) {
            activeAndAvailCoursesCount = rs.getInt(1);
        }
    }
    

}catch(Exception e) {
    out.println("query failed<br/>");
    out.println(e);
}finally{
    if(rs != null){
        rs.close();
    }
    if(stmt != null){
        stmt.close();
    }
    if(conman != null){
        conman.releaseConnection(conn2);
    }
}
*/
%>

<%
 
// Users stats
// TODO: move to a library

int activeUsers = -1;
int i30daysLogins = -1;
int i60daysLogins = -1;
int i120daysLogins = -1;
int i180daysLogins = -1;


String qrystrActiveUsers = "SELECT COUNT(u.user_id) ct FROM users u WHERE EXISTS ( SELECT 'x' FROM course_users cu " +
        "WHERE cu.users_pk1 = u.pk1 AND cu.row_status = 0  AND cu.available_ind='Y' AND crsmain_pk1 in (" +
        "select pk1 from course_main where course_main.row_status=0  AND course_main.available_ind='Y' AND course_main.service_level='F' ) ) " +
        "AND u.row_status = 0 AND u.available_ind = 'Y'";
String qrystrUniqueLogins = "";

// Detect db server version
switch(ConfigurationServiceFactory.getInstance().getBbProperty( blackboard.platform.config.BbConfig.DATABASE_TYPE )) {
    case "oracle":
        qrystrUniqueLogins = "SELECT count(distinct (user_pk1)) valuen " +
        "from activity_accumulator where event_type = 'LOGIN_ATTEMPT' " +
        "and data = 'Login succeeded.' and timestamp >= sysdate-?";
        break;
    case "mssql":
        // TODO detect MSSQL version and put the right case label
        qrystrUniqueLogins = "SELECT count(distinct (user_pk1)) valuen " +
        "from activity_accumulator where event_type = 'LOGIN_ATTEMPT' " +
        "and data = 'Login succeeded.' and timestamp >= DATEADD(DAY, -?, GETDATE ())";
        
        break;
    case "pgsql":
        qrystrUniqueLogins = "SELECT count(distinct (user_pk1)) valuen " +
        "from activity_accumulator where event_type = 'LOGIN_ATTEMPT' " +
        "and data = 'Login succeeded.' and timestamp >= current_date - ( ? * INTERVAL '1' DAY)";
        break;
    default:
        dbVersion = "unable to detect db version";
}


//ConnectionManager conman  = null;
Connection conn3 = null;
//Statement stmt = null;
//ResultSet rs = null;
try {
    // Create Conn to correct database
    int j=0;

    BbDatabase bbDb = DbUtil.safeGetBbDatabase();
    conman = bbDb.getConnectionManager();
    while(conn3 == null && j<10){
        try {
                conn3 = conman.getConnection();
        }catch(ConnectionNotAvailableException cnae){
            Thread.sleep(1000);
            ++j;
        }
    }

    stmt = conn3.createStatement();
    
    // active users
    if (stmt.execute(qrystrActiveUsers)) {
        rs = stmt.getResultSet();
        ResultSetMetaData rsMetaData = rs.getMetaData();
        if (rs.next()) {
            activeUsers = rs.getInt(1);
        }
    }
    
    PreparedStatement preStatement=conn3.prepareStatement(qrystrUniqueLogins);
    
    preStatement.setInt(1, 30);   
    rs = preStatement.executeQuery();  
    if (rs.next()) {
        i30daysLogins = rs.getInt(1);
    }
     preStatement.setInt(1, 60);   
    rs = preStatement.executeQuery();  
    if (rs.next()) {
        i60daysLogins = rs.getInt(1);
    }   
    
    preStatement.setInt(1, 120);   
    rs = preStatement.executeQuery();  
    if (rs.next()) {
        i120daysLogins = rs.getInt(1);
    }    
    
    preStatement.setInt(1, 180);   
    rs = preStatement.executeQuery();  
    if (rs.next()) {
        i180daysLogins = rs.getInt(1);
    }
}catch(Exception e) {
    out.println("query failed<br/>");
    out.println(e);
}finally{
    if(rs != null){
        rs.close();
    }
    if(stmt != null){
        stmt.close();
    }
    if(conman != null){
        conman.releaseConnection(conn3);
    }
}
%>

<%    
    
// List building blocks
// TODO: move to external JAR

//B2Helper b2local = new B2Helper();

String ListOfB2s = "";
//List<String> b2s = new ArrayList<String>();
List<B2Helper> b2s = new ArrayList<B2Helper>();

SimpleDateFormat anotherdbformatter = new SimpleDateFormat("yyyy-MM-dd");

String b2qrystr = "select name, vendor_id, handle, vendor_name, version_major, version_minor, version_patch, version_build, available_flag, dtmodified from plugins";

//BundleManager bm = BundleManagerFactory.getInstance();
//BbResourceBundle bundle = new BbResourceBundle;

String vendor_id = "'";
String handle = "";

//ConnectionManager conman  = null;
Connection conn5 = null;
//Statement stmt = null;
//ResultSet rs = null;
try {

    // Create Conn to correct database
    int j=0;

    BbDatabase bbDb = DbUtil.safeGetBbDatabase();
    conman = bbDb.getConnectionManager();
    while(conn5 == null && j<10){
        try {
                conn5 = conman.getConnection();
        }catch(ConnectionNotAvailableException cnae){
            Thread.sleep(1000);
            ++j;
        }
    }

    stmt = conn5.createStatement();
    if (stmt.execute(b2qrystr)) {
        rs = stmt.getResultSet();
        while (rs.next()) {
            
            B2Helper b2local = new B2Helper( rs.getString("vendor_id"), rs.getString("handle") );
            b2local.setName(rs.getString("name"));
            b2local.setLocalizedName(rs.getString("name"));
            b2local.setVendorName(rs.getString("vendor_name"));
            b2local.setVersion( rs.getInt("version_major"), rs.getInt("version_minor"), rs.getInt("version_patch"), rs.getInt("version_build") );
            b2local.setAvailableFlag(rs.getString("available_flag"));
            b2local.setDateModified( anotherdbformatter.parse(rs.getString("dtmodified")) );
            
            b2s.add ( b2local );
        }
    }
    
}catch(Exception e) {
    out.println("query failed<br/>");
    out.println(e);
}finally{
    if(rs != null){
        rs.close();
    }
    if(stmt != null){
        stmt.close();
    }
    if(conman != null){
        conman.releaseConnection(conn5);
    }
}

ListOfB2s = " " + b2s.size();
%>


<%
// Release db connection
// TODO: implement and call Db methods
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
            <bbNG:inventoryList collection="<%=b2s%>" objectVar="ux" className="B2Helper" description="List Description" emptyMsg="No plugins found">
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
    <%=content%>
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