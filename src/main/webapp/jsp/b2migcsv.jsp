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

<%
// Entitlement check - fail if user it not system admin.  TODO: This is working in that it stops non-admin from viewing the page, but it is generating an error itself
// access denied ("blackboard.data.AttributePermission" "user.authinfo" "get")
blackboard.platform.security.SecurityUtil.checkEntitlement("system.buildingblocks.VIEW","System Admin permissions are required");
   
// get the request type from query sting
String req=request.getParameter("req");
String header="No query defined";
String filename = "undefined";
String orasql="";
String mssql="";
String pgsql="";
String sep="\t";
String txtqual=""; // actually applied to all fields

// Tab separated outputs for compatibility with existing Safeassign migration tool
switch (req) {
// GENERIC EXPORTS
    case "coursePK1s":
        // Course PK1s. Could be used for many B2s
        header = "\"Course ID\",\"Course PK1\"";
        sep=",";
        filename = "coursePK1s";
        orasql = "select course_id,pk1 from course_main order by course_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;
    case "userPK1s":
        // User PK1s. Could be used for many B2s.
        header = "\"User ID\",\"User PK1\"";
        sep=",";
        filename = "userPK1s";
        orasql = "select user_id,pk1 from users order by user_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;
// NEW BOX VIEW ASSIGNMENTS
      case "nbv-assignmentFiles":
        header = "files_pk1|file_name|file_size|link_name|attempt_pk1|attempt_date|course_id|user_id";
        sep="|";
        filename = "nbv-assignmentFiles";
        orasql = "SELECT f.pk1 AS files_pk1,f.file_name AS file_name,f.file_size AS file_size,f.link_name AS link_name,a.pk1 AS attempt_pk1, TO_CHAR(a.attempt_date, 'YYYY-MM-DD HH24:MI:SS') AS attempt_date,cm.course_id AS course_id,u.user_id AS user_id"
        +" FROM files f LEFT JOIN attempt_files af ON af.files_pk1 = f.pk1 LEFT JOIN attempt a ON a.pk1 = af.attempt_pk1 LEFT JOIN gradebook_grade gg ON gg.pk1 = a.gradebook_grade_pk1"
        + " LEFT JOIN course_users cu ON cu.pk1 = gg.course_users_pk1 LEFT JOIN course_main cm ON cm.pk1 = cu.crsmain_pk1 LEFT JOIN users u ON u.pk1 = cu.users_pk1";
       mssql = "SELECT f.pk1 AS files_pk1,f.file_name AS file_name,f.file_size AS file_size,f.link_name AS link_name,a.pk1 AS attempt_pk1, CONVERT(CHAR(19), a.attempt_date, 20) AS attempt_date,cm.course_id AS course_id,u.user_id AS user_id"
        +" FROM files f LEFT JOIN attempt_files af ON af.files_pk1 = f.pk1 LEFT JOIN attempt a ON a.pk1 = af.attempt_pk1 LEFT JOIN gradebook_grade gg ON gg.pk1 = a.gradebook_grade_pk1"
        + " LEFT JOIN course_users cu ON cu.pk1 = gg.course_users_pk1 LEFT JOIN course_main cm ON cm.pk1 = cu.crsmain_pk1 LEFT JOIN users u ON u.pk1 = cu.users_pk1";
        pgsql = orasql;
        break;
// NEW BOX VIEW FILES
    case "nbv-boxFiles":
        sep="|";
        filename = "nbv-boxFiles";
        header = "pk1|files_pk1|uuid|status|annotatable_uuid|rawdoc_uuid|raw_status";
        orasql = "SELECT pk1, files_pk1, uuid, status, annotatable_uuid, rawdoc_uuid, raw_status FROM files_crocodoc_data";
        mssql = orasql;
        pgsql = orasql;
        break;
   // CROCODOC ASSIGNMENTS
    case "crocodocLicense":
        // Course PK1s, only courses that have Safeassignment (submissions?).
        sep=": ";
        filename = "crocodocLicense";
        header = "# registry_key: registry_value";
        orasql = "SELECT registry_key, registry_value FROM system_registry WHERE registry_key in ('bb_cloud_site_id', 'crocodoc.license.key')";
        mssql = orasql;
        pgsql = orasql;
        break;
    case "crocodocAnnotations":
        // Course PK1s, only courses that have Safeassignment (submissions?).
        header = "files_pk1|file_name|file_size|link_name|files_crocodoc_data_pk1|crocodoc_uuid|attempt_pk1|attempt_date|course_id|user_id";
        sep="|";
        filename = "crocodocAnnotations";
                                        
        orasql  = "SELECT f.pk1 AS files_pk1, f.file_name AS file_name, f.file_size AS file_size, f.link_name AS link_name, fcd.pk1 AS files_crocodoc_data_pk1, "
                + "fcd.uuid AS crocodoc_uuid, a.pk1 AS attempt_pk1,TO_CHAR(a.attempt_date, 'YYYY-MM-DD HH24:MI:SS') AS attempt_date, cm.course_id AS course_id, u.user_id AS user_id "
                + "FROM files f LEFT JOIN files_crocodoc_data fcd ON fcd.files_pk1 = f.pk1 LEFT JOIN attempt_files af ON af.files_pk1 = f.pk1 LEFT JOIN attempt a ON a.pk1 = af.attempt_pk1 LEFT JOIN gradebook_grade gg ON gg.pk1 = a.gradebook_grade_pk1 "
                + "LEFT JOIN course_users cu ON cu.pk1 = gg.course_users_pk1 LEFT JOIN course_main cm ON cm.pk1 = cu.crsmain_pk1 LEFT JOIN users u ON u.pk1 = cu.users_pk1";                             
     
        mssql  = "SELECT f.pk1 AS files_pk1, f.file_name AS file_name, f.file_size AS file_size, f.link_name AS link_name, fcd.pk1 AS files_crocodoc_data_pk1, "
                + "fcd.uuid AS crocodoc_uuid, a.pk1 AS attempt_pk1,CONVERT(CHAR(19), a.attempt_date, 20) AS attempt_date, cm.course_id AS course_id, u.user_id AS user_id "
                + "FROM files f LEFT JOIN files_crocodoc_data fcd ON fcd.files_pk1 = f.pk1 LEFT JOIN attempt_files af ON af.files_pk1 = f.pk1 LEFT JOIN attempt a ON a.pk1 = af.attempt_pk1 LEFT JOIN gradebook_grade gg ON gg.pk1 = a.gradebook_grade_pk1 "
                + "LEFT JOIN course_users cu ON cu.pk1 = gg.course_users_pk1 LEFT JOIN course_main cm ON cm.pk1 = cu.crsmain_pk1 LEFT JOIN users u ON u.pk1 = cu.users_pk1";                                   
     
        pgsql = orasql; // untested
        break;
//SAFEASSIGN
   case "SA-USERS":
        // User PK1s. Needed for many B2s.
        header = "# user_id pk1"; txtqual="";
        filename = "SA-USERS";
        orasql = "select user_id,pk1 from users order by user_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;
    case "SA-COURSES":
        // Course PK1s. Needed for many B2s.
        header = "# course_id pk1"; txtqual="";
        filename = "SA-COURSES";
        orasql = "select course_id,pk1 from course_main order by course_id asc";
        mssql = orasql;
        pgsql = orasql;
    
        break;
    case "SA-ASSIGNMENTS":
        // Safeassignments.
        header = "# assignment_title parent_title course_id position pk1";
        filename = "SA-ASSIGNMENTS";
        orasql =    "select a.title assignment_title, c.title parent_title, b.course_id, a.position, a.pk1 from "
                +   "course_contents a inner join course_main b on (a.crsmain_pk1 = b.pk1) "
                +   "inner join course_contents c on (a.parent_pk1 = c.pk1) "
                +   "where a.cnthndlr_handle = 'resource/x-mdb-assignment'";
  
        mssql = orasql;
        pgsql = orasql;
        break;
    case "SA-GRADEBOOK":
        // Gradebook
        header = "# pk1 course_pk1 title position score_provider_handle data_added";
        filename = "SA-GRADEBOOK";
        orasql =    "SELECT pk1, crsmain_pk1, title, position, score_provider_handle, TO_CHAR(date_added, 'YYYY-MM-DD HH24:MI:SS') date_added "
                +   "FROM gradebook_main ORDER BY pk1";
        mssql  =    "SELECT pk1, crsmain_pk1, title, position, score_provider_handle, CONVERT(CHAR(19), date_added, 20) AS date_added "
                +   "FROM gradebook_main ORDER BY pk1";
        pgsql = orasql;
        break;
    case "SA-ATTEMPTS":
        // Assignment Attempts
        header = "# attempt_pk1 attempt_date gradebook_pk1 course_pk1 user_id";
        filename = "SA-ATTEMPTS";
        orasql =    "SELECT a.pk1 attempt_pk1, TO_CHAR(a.attempt_date, 'YYYY-MM-DD HH24:MI:SS')  attempt_date, gm.pk1  gradebook_pk1, gm.crsmain_pk1  course_pk1, u.user_id "
                +   "FROM attempt a LEFT JOIN gradebook_grade gg on gg.pk1 = a.gradebook_grade_pk1 LEFT JOIN gradebook_main gm on gm.pk1 = gg.gradebook_main_pk1 "
                +   "LEFT JOIN course_users cu on cu.pk1 = gg.course_users_pk1 LEFT JOIN users u on u.pk1 = cu.users_pk1 ORDER BY a.pk1";
        mssql =    "SELECT a.pk1 attempt_pk1, CONVERT(CHAR(19), a.attempt_date, 20) AS attempt_date, gm.pk1 gradebook_pk1, gm.crsmain_pk1  course_pk1, u.user_id "
                +   "FROM attempt a LEFT JOIN gradebook_grade gg on gg.pk1 = a.gradebook_grade_pk1 LEFT JOIN gradebook_main gm on gm.pk1 = gg.gradebook_main_pk1 "
                +   "LEFT JOIN course_users cu on cu.pk1 = gg.course_users_pk1 LEFT JOIN users u on u.pk1 = cu.users_pk1 ORDER BY a.pk1";
        pgsql = orasql;
        break;
   case "SA-ITEMS":
        // SA Items
        header = "# pk1 crsmain_pk1 gradebook_main_pk1 safeassign_uuid disabled";
        filename = "SA-ITEMS";
        orasql =    "SELECT pk1, crsmain_pk1, gradebook_main_pk1, safeassign_uuid, disabled FROM mdb_safeassign_item ORDER BY pk1";
        mssql = orasql;
        pgsql = orasql;
        break; 
    case "SA-SUBMISSIONS":
        // SA Submissions
        header = "# pk1 submission_uuid mdb_sa_item_pk1 attempt_pk1 attempt_data_type submission_id submission_data_type";
        filename = "SA-SUBMISSIONS";
        orasql =    "SELECT pk1,submission_uuid,mdb_sa_item_pk1,attempt_pk1,attempt_data_type,submission_id,submission_data_type FROM mdb_safeassign_submission ORDER BY pk1";
        mssql = orasql;
        pgsql = orasql;
        break;   
    case "SA-PROPERTIES":
        // SA Submissions
        header = "# registry_key: registry_value";
        sep=": ";
        filename = "SA-PROPERTIES";
        orasql =    "SELECT registry_key, registry_value FROM system_registry WHERE registry_key LIKE 'sa.prop.%'";
        mssql = orasql;
        pgsql = orasql;
        break;   
// COURSE LISTS
// Not really B2 migration related 
    case "courseids-allactive":
        // All enabled and active courses
        header = "Course ID";
        sep=",";
        filename = "courseids-allactive";
        orasql = "select course_id from course_main where row_status=0 and available_ind='Y' order by course_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;
    case "coursedetails-allnotactive":
        // All inactive or disabled courses
        header = "\"Course ID\",\"Course Name\",\"Row Status\",\"Available Ind\"";
        sep=",";txtqual="\""; 
        filename = "coursedetails-allnotactive";
        orasql = "select course_id,course_name,row_status,available_ind from course_main where row_status!=0 or available_ind!='Y' order by course_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;    
case "coursedetails-allactive":
         // All  courses
        header = "\"Course ID\",\"Course Name\",\"Row Status\",\"Available Ind\"";
        sep=",";txtqual="\""; 
        filename = "coursedetails-allactive";
        orasql = "select course_id,course_name,row_status,available_ind from course_main where row_status=0 and available_ind='Y' order by course_id asc";
        mssql = orasql;
        pgsql = orasql;
        break; 
   case "coursedetails-all":
         // All  courses
        header = "\"Course ID\",\"Course Name\",\"Row Status\",\"Available Ind\"";
        sep=",";txtqual="\""; 
        filename = "coursedetails-all";
        orasql = "select course_id,course_name,row_status,available_ind from course_main order by course_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;    
      
   default:
        // nothing to do
        // page ends up giving a generic error
}


   
// Filename
SimpleDateFormat appFormatter = new SimpleDateFormat("yyyy-MM-dd");
java.util.Date dtAppServerTime = new java.util.Date();
String appServerDate = appFormatter.format(dtAppServerTime);
String fullHostname = AppServerInfo.getUrl();
String outputFileName = filename+"-"+fullHostname+"-"+appServerDate+".txt";

   
// output as Text
response.setContentType("text/plain");
response.setHeader("Content-Disposition", "attachment; filename="+outputFileName);

out.println(header);
Connection dbConnection = Db.getConnection();
// get the right query string
String qrystr="";
switch (DbServerInfo.getDatabaseType()) {
    case "oracle":
        qrystr = orasql;
        break;
    case "mssql":
        qrystr = mssql;
        break;
    case "pgsql":
        qrystr = pgsql;
        break;
    default:
    // nothing to do
}

String outcsv = ""; 

Statement dbStatement = Db.createStatement(dbConnection);
ResultSet rs = null;
try {
    try {
        boolean wasExecuted = dbStatement.execute(qrystr);
        if (wasExecuted) {
            rs = dbStatement.getResultSet();
            ResultSetMetaData rsmd = rs.getMetaData();
            int numOfCols = rsmd.getColumnCount();
   
            while (rs.next()) {
                outcsv="";
                for(int i = 1; i <= numOfCols; i++) {
                    // TODO: use rsmd.getColumnClassName(i) and output dates, string etc differently. TBD
                    outcsv=outcsv + txtqual + rs.getString(i)+ txtqual;
                    if (i!=numOfCols) {
                        outcsv=outcsv + sep;
                    }
                }
                out.println(outcsv);
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
%>
