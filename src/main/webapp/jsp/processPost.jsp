<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@ page	language="java"
         import="java.util.*,
         java.util.*,
         java.io.*,
         java.sql.*,
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
         blackboard.platform.LicenseComponent
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
// Detect OS via API
// TODO: move code as a method in a JAR
String osFlavour = "";
if(blackboard.util.PlatformUtil.osIsWindows()){
    osFlavour = "Windows not yet supported";
}else{
    osFlavour = "UNIX system";
}

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
%>

<%
// Detect Learn Version
// TODO: move code as a method in a JAR
String learnVersion = "";

learnVersion = blackboard.platform.LicenseUtil.getBuildNumber();

%>

<%
// Detect licensed platforms
// TODO: move code as a method in a JAR
String licensedPlatforms = "<b>needs cleanup and show only the available ones</b>";

//blackboard.platform.LicenseDescriptor ld = new blackboard.platform.LicenseDescriptor("/usr/local/blackboard/system/tooldefs/system/LicenseUpdate/license-handlers/enterprise.contentsystem/license-handler.xml");
//licensedPlatforms = ld.getTitle();

//if (blackboard.platform.LicenseComponent.isAvailable(blackboard.platform.LicenseComponent.ENTERPRISE_CONTENT_SYSTEM)) {
//    licensedPlatforms = "content system yes";
//} else {
//    licensedPlatforms = "content system no";
//}

for (blackboard.platform.LicenseComponent c : blackboard.platform.LicenseComponent.values()) {
    licensedPlatforms += "<br/>" + c;

if (c.isAvailable()) licensedPlatforms += " YES!";
    }
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
    case "mssqlserver":
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
                ResultSetMetaData rsMetaData = rs.getMetaData();

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
        ResultSetMetaData rsMetaData = rs.getMetaData();
        if (rs.next()) {
            coursesCount = rs.getInt(1);
        }
    }
    if (stmt.execute(qrystrActiveCoursesCount)) {
        rs = stmt.getResultSet();
        ResultSetMetaData rsMetaData = rs.getMetaData();
        if (rs.next()) {
            activeCoursesCount = rs.getInt(1);
        }
    }
    if (stmt.execute(qrystrActiveAndAvailCoursesCount)) {
        rs = stmt.getResultSet();
        ResultSetMetaData rsMetaData = rs.getMetaData();
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


<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
    <bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main">
        <bbNG:breadcrumb title="BB Support Tools" href="<%= cancelUrl %>" />
        <bbNG:breadcrumb><%=pageTitle%></bbNG:breadcrumb>
    </bbNG:breadcrumbBar>
    <bbNG:pageHeader instructions="<%=pageInstructions%>">
        <bbNG:pageTitleBar ><%=pageTitle%></bbNG:pageTitleBar>
    </bbNG:pageHeader>

    <bbNG:dataCollection>

        <bbNG:step title="Operating System">
            <bbNG:dataElement label="OS" isRequired="yes" labelFor="OS">
                <%=osFlavour%>
            </bbNG:dataElement>
            <bbNG:dataElement label="App OS details" isRequired="yes" labelFor="App OS details">
                <%=appOsDetails%>
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Learn Version">
            <bbNG:dataElement label="Learn Version" isRequired="yes" labelFor="LV">
                <%=learnVersion%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Licensed Platforms" isRequired="yes" labelFor="licensedPlatforms">
                <%=licensedPlatforms%>
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Database server backend">
            <bbNG:dataElement label="Database server type" isRequired="yes" labelFor="dbtype">
                <%=dbType%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Database server version" isRequired="yes" labelFor="dbversion">
                <%=dbVersion%>
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