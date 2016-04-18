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
         java.text.SimpleDateFormat
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
// Detect OS via Java API
// TODO: move code as a method in a JAR
String appOsName = System.getProperty("os.name");
String appOsArch = System.getProperty("os.arch");
String appOsversion = System.getProperty("os.version");
String appJavaVersion = System.getProperty("java.version");

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

<%
// Detect Learn Version
// TODO: move code as a method in a JAR
String learnVersion = "";

learnVersion = blackboard.platform.LicenseUtil.getBuildNumber();

%>

<%
// App sever time and timezone
// TODO: move code as a method in a JAR

String appServerTime = "";
SimpleDateFormat appFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

java.util.Date dtAppServerTime = new java.util.Date();
TimeZone tz = TimeZone.getDefault();

appServerTime = appFormatter.format(dtAppServerTime) + " - "  + tz.getID() + " - " + tz.getDisplayName();

%>

<%
// Detect whether MSSQL/Oracle/Postgres
// TODO: move code as a method in a JAR
String dbType = "";
String dbVersion = "";
dbType = ConfigurationServiceFactory.getInstance().getBbProperty( blackboard.platform.config.BbConfig.DATABASE_TYPE );
String qrystr = "";

// Detect db server version
switch(dbType) {
    case "oracle":
        qrystr = "select * from v$version";
        // SELECT version();
        break;
    case "mssql":
        // TODO detect MSSQL version and put the right case label
        qrystr = "Select @@version";
        break;
    case "pgsql":
        // TODO detect ORACLE version and put the right case label
        qrystr = "select version()";
        break;
    default:
        dbVersion = "unable to detect db version";
}


ConnectionManager conman  = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
try {
 
        // Create Conn to correct database
            int j=0;

            BbDatabase bbDb = DbUtil.safeGetBbDatabase();
            conman = bbDb.getConnectionManager();
            while(conn == null && j<10){
                try {
                    conn = conman.getConnection();
                }
                catch(ConnectionNotAvailableException cnae){
                    Thread.sleep(1000);
                    ++j;
                }
            }

        stmt = conn.createStatement();
        boolean wasExecuted = stmt.execute(qrystr);
        if (wasExecuted) {
                rs = stmt.getResultSet();

                if (rs.next()) {
                    dbVersion = rs.getString(1);
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
            conman.releaseConnection(conn);
            }
        }
%>

<%
// DB sever time and timezone
// TODO: move code as a method in a JAR

String tzqrystr = "";
String dbServerTime = "";
SimpleDateFormat dbformatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

//java.util.Date dtAppServerTime = new java.util.Date();
java.util.Date dtDbServerTime = new java.util.Date();
String dbTzString = "";
//TimeZone tz = TimeZone.getDefault();

//appServerTime = dbformatter.format(dtAppServerTime) + " - "  + tz.getID() + " - " + tz.getDisplayName();

// Detect db server version

switch(dbType) {
    case "oracle":
        tzqrystr = "SELECT TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS'), TO_CHAR(SYSTIMESTAMP, 'TZH:TZM') FROM DUAL";
        break;
    case "mssql":
        tzqrystr = "Select convert(char, SYSDATETIME()), DATENAME(TZoffset, SYSDATETIMEOffset())";
        break;
    case "pgsql":
        tzqrystr = "SELECT  NOW(), current_setting('TIMEZONE')";
        break;
    default:
        tzqrystr = "unable to detect db version";
}

//ConnectionManager conman  = null;
Connection conn4 = null;
//Statement stmt = null;
//ResultSet rs = null;
try {

    // Create Conn to correct database
    int j=0;

    BbDatabase bbDb = DbUtil.safeGetBbDatabase();
    conman = bbDb.getConnectionManager();
    while(conn4 == null && j<10){
        try {
                conn4 = conman.getConnection();
        }catch(ConnectionNotAvailableException cnae){
            Thread.sleep(1000);
            ++j;
        }
    }

    stmt = conn4.createStatement();
    if (stmt.execute(tzqrystr)) {
        rs = stmt.getResultSet();
        if (rs.next()) {
            dtDbServerTime = dbformatter.parse(rs.getString(1));
            dbTzString = rs.getString(2);
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
        conman.releaseConnection(conn4);
    }
}

dbServerTime = dbformatter.format(dtDbServerTime) + " " + dbTzString; // + " - "  + tz.getID() + " - " + tz.getDisplayName();

%>

<%
    
// Courses stats
//TODO: move to a library
int coursesCount = -1;
int activeCoursesCount = -1;
int activeAndAvailCoursesCount = -1;

String qrystrCoursesCount = "select count(*) from course_main";
String qrystrActiveCoursesCount = "select count(*) from course_main where row_status=0";
String qrystrActiveAndAvailCoursesCount = "select count(*) from course_main where row_status=0 and available_ind='Y'";

//ConnectionManager conman  = null;
Connection conn2 = null;
//Statement stmt = null;
//ResultSet rs = null;
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
            <bbNG:dataElement label="Courses" isRequired="yes" labelFor="courses">
                <%=coursesCount%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Courses enabled" isRequired="yes" labelFor="activecourses">
                <%=activeCoursesCount%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Courses enabled and available" isRequired="yes" labelFor="activeandavailcourses">
                <%=activeAndAvailCoursesCount%>
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
%>