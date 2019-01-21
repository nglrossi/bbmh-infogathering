<%@ page	language="java"
         import="java.util.*,
         java.sql.*,
         java.util.*,
         blackboard.bbmh.*,
         java.text.SimpleDateFormat,
         java.io.File,
         blackboard.platform.security.SecurityUtil,
         blackboard.platform.plugin.*"
         pageEncoding="UTF-8"
         %>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="/bbNG" prefix="bbNG"%>

<%
// Entitlement check - fail if user it not system admin.  TODO: This is working in that it stops non-admin from viewing the page, but it is generating an error itself
// access denied ("blackboard.data.AttributePermission" "user.authinfo" "get")
blackboard.platform.security.SecurityUtil.checkEntitlement("system.buildingblocks.VIEW","System Admin permissions are required");

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


// MAKE CSVS
// turn the lists into CSVs
String schemaCSV = "";
int index = 0 ;
while (dbListSchemas.size()> index) {
    schemaCSV=schemaCSV+",";
    String curSchema = dbListSchemas.get(index);
    schemaCSV = schemaCSV +  "\"" + curSchema + "\",";
    index++ ;
    if(dbListSchemas.size()>index) {schemaCSV = schemaCSV + "\n";}

}
String largeCoursesCSV = ",\"Course Name\",\"Course ID\",\"Enrollments\",\"Availabilty\",\"Status\"\n";
int index2 = 0 ;
while (largeCourses.size()> index2) {
    largeCoursesCSV=largeCoursesCSV+",";
    CourseHelper curCourse = largeCourses.get(index2);
    largeCoursesCSV = largeCoursesCSV +  "\"" + curCourse.name + "\",";
    largeCoursesCSV = largeCoursesCSV +  "\"" + curCourse.id + "\",";
    largeCoursesCSV = largeCoursesCSV +  "\"" + curCourse.countEnrollments + "\",";
    largeCoursesCSV = largeCoursesCSV +  "\"" + curCourse.availableFlag + "\",";
    largeCoursesCSV = largeCoursesCSV +  "\"" + curCourse.statusFlag + "\",";
    index2++ ;
    if(largeCourses.size()>index2) {largeCoursesCSV = largeCoursesCSV + "\n";}
}
    
    String AuthCSV = ",\"Name\",\"Type\",\"State\"\n";
int index3 = 0 ;
while (authProviders.size()> index3) {
    AuthCSV=AuthCSV+",";
    AuthHelper curAuth = authProviders.get(index3);
    AuthCSV = AuthCSV +  "\"" + curAuth.name + "\",";
    AuthCSV = AuthCSV +  "\"" + curAuth.type + "\",";
    AuthCSV = AuthCSV +  "\"" + curAuth.availableFlag + "\",";
    index3++ ;
    if(authProviders.size()>index3) {AuthCSV = AuthCSV + "\n";}
}
// output as CSV
SimpleDateFormat appFormatter = new SimpleDateFormat("yyyy-MM-dd");
java.util.Date dtAppServerTime = new java.util.Date();
String appServerDate = appFormatter.format(dtAppServerTime);

String outputFileName = "mainReport-"+fullHostname+"-"+appServerDate+".csv";

response.setContentType("text/csv");
response.setHeader("Content-Disposition", "attachment; filename="+outputFileName);
%>"SUMMARY","--------------------"
"Learn Version","<%=learnVersion%>"
"Active Users",<%=activeUsers%>
"Total Courses",<%=totalCoursesCount%>
"Licensed Platforms",<bbNG:ifLicensed component="ENTERPRISE_LEARNING">"Course Delivery"
</bbNG:ifLicensed>
<bbNG:ifLicensed component="ENTERPRISE_CONTENT_SYSTEM">,"Content Management"
</bbNG:ifLicensed>
<bbNG:ifLicensed component="ENTERPRISE_COMMUNITY">,"Community Engagement"
</bbNG:ifLicensed>
<bbNG:ifLicensed component="ENTERPRISE_OUTCOMES">,"Outcomes Assessment"
</bbNG:ifLicensed>
"Database server type","<%=dbType%>"
"Database main schema","<%=dbMainSchema%>"
"CMS schemas","<%=CMSdocstores%>"
,,
"STORAGE USAGE","--------------------"
"Base dir disk usage","<%=baseDirDiskUsage%> GB"
"Content dir path","<%=contentDirLabel%>"
"Content disk usage","<%=contentDirDiskUsage%> GB"
"Database size","<c:choose>
                <c:when test="${dbType2 != 'mssql'}"><%=dbSize%> GB</c:when> 
                <c:otherwise>Unknown</c:otherwise>
</c:choose>"
,,
"APPLICATION SERVER DETAIL","--------------------"
"Full Hostname","<%=fullHostname%>"
"OS","<%=appOsName%>"
"Architecture","<%=appOsArch%>"
"OS Version","<%=appOsversion%>"
"Java version","<%=appJavaVersion%>"
"Server time and timezone","<%=appServerTime%>"
"Base dir path","<%=baseDirLabel%>"
,,
"DATABASE SERVER DETAIL","--------------------"
"Database Schemas"<%=schemaCSV%>
,,
"Database server version","<%=dbVersion%>"
"Server time and timezone","<%=dbServerTime%>"
,,
"COURSES INFORMATION","--------------------"
"Total Courses","<%=totalCoursesCount%>"
"Active Courses","<%=activeCoursesCount%>"
"Accessed in the last year","<%=accessedLastYearCoursesCount%>"
"Courses with large number of enrollments"<%=largeCoursesCSV%>
,,
"AUTHENTICATION","--------------------"
"Configured Authentication Providers"<%=AuthCSV%>
