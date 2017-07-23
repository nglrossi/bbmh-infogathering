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

// Add new CSV definitions here, they can be called by adding the key to the query string value req
switch (req) {
// GENERIC EXPORTS
    case "coursePK1s":
        // Course PK1s. Needed for many B2s.
        header = "\"Course ID\",\"Course PK1\"";
        filename = "coursePK1s";
        orasql = "select course_id,pk1 from course_main order by course_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;
    case "userPK1s":
        // User PK1s. Needed for many B2s.
        header = "\"User ID\",\"User PK1\"";
        filename = "userPK1s";
        orasql = "select user_id,pk1 from users order by user_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;
// SAFFEASSIGN - DEPRECATED
    case "safeassignments":
        // Course PK1s. Needed for many B2s.
        header = "\"Content Item PK1\",\"Content Item Title\",\"Course ID\",\"Parent Content Item Title\",\"Position\"";
        filename = "safeassignments";
        orasql =    "select a.pk1, a.title, b.course_id, c.title parent_title, a.position from "
                +   "course_contents a  inner join course_main b on (a.crsmain_pk1 = b.pk1)"
                +   "inner join course_contents c on (a.parent_pk1 = c.pk1)"
                +   "where a.cnthndlr_handle = 'resource/x-mdb-assignment'";
        mssql = orasql;
        pgsql = orasql;
        break;
    case "coursePK1sSafeassign":
        // Course PK1s, only courses that have Safeassignment (submissions?).
        header = "\"Course ID\",\"Course PK1\"";
        filename = "coursePK1sSafeassign";
        orasql = "select course_id,pk1 from course_main where exists (select * from mdb_safeassign_item where course_main.pk1=mdb_safeassign_item.crsmain_pk1) order by course_id asc";
        mssql = orasql;
        pgsql = orasql;
        break;
// CROCODOC ASSIGNMENTS
    case "crocodocLicense":
        // Course PK1s, only courses that have Safeassignment (submissions?).
        header = "\"Crocodoc License Key\"";
        filename = "crocodocLicense";
        orasql = "SELECT registry_value FROM system_registry WHERE registry_key = 'crocodoc.license.key'";
        mssql = orasql;
        pgsql = orasql;
        break;
    case "crocodocAnnotations":
        // Course PK1s, only courses that have Safeassignment (submissions?).
        header = "\"Files PK1\",\"File Name\",\"File Size\",\"Link Name\",\"Files Crocodoc Data PK1\",\"Crocodoc UUID\",\"Attempt PK1\",\"Attempt Date\",\"Course ID\",\"User ID\"   ";
        filename = "crocodocAnnotations";
        orasql  = "SELECT f.pk1 AS files_pk1,f.file_name AS file_name,f.file_size AS file_size,f.link_name AS link_name,fcd.pk1 AS files_crocodoc_data_pk1,fcd.uuid AS crocodoc_uuid,a.pk1 AS attempt_pk1,TO_CHAR(a.attempt_date, 'YYYY-MM-DD HH24:MI:SS') AS attempt_date, cm.course_id AS course_id, u.user_id AS user_id,u.user_id AS user_id"
                + " FROM files_crocodoc_data fcd LEFT JOIN files f ON f.pk1 = fcd.files_pk1 LEFT JOIN attempt_files af ON af.files_pk1 = f.pk1 LEFT JOIN attempt a ON a.pk1 = af.attempt_pk1 LEFT JOIN gradebook_grade gg ON gg.pk1 = a.gradebook_grade_pk1 LEFT JOIN course_users cu ON cu.pk1 = gg.course_users_pk1 LEFT JOIN course_main cm ON cm.pk1 = cu.crsmain_pk1 LEFT JOIN users u ON u.pk1 = cu.users_pk1";
     
        mssql   = "SELECT f.pk1 AS files_pk1,f.file_name AS file_name,f.file_size AS file_size,f.link_name AS link_name,fcd.pk1 AS files_crocodoc_data_pk1,fcd.uuid AS crocodoc_uuid,a.pk1 AS attempt_pk1,CONVERT(CHAR(19), a.attempt_date, 20) AS attempt_date, cm.course_id AS course_id, u.user_id AS user_id,u.user_id AS user_id"
                + " FROM files_crocodoc_data fcd LEFT JOIN files f ON f.pk1 = fcd.files_pk1 LEFT JOIN attempt_files af ON af.files_pk1 = f.pk1 LEFT JOIN attempt a ON a.pk1 = af.attempt_pk1 LEFT JOIN gradebook_grade gg ON gg.pk1 = a.gradebook_grade_pk1 LEFT JOIN course_users cu ON cu.pk1 = gg.course_users_pk1 LEFT JOIN course_main cm ON cm.pk1 = cu.crsmain_pk1 LEFT JOIN users u ON u.pk1 = cu.users_pk1";
        pgsql = orasql; // untested
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
String outputFileName = filename+"-"+fullHostname+"-"+appServerDate+".csv";

String outcsv = header+"\n";
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
                // append to csv
                for(int i = 1; i <= numOfCols; i++) {
                    // TODO: use rsmd.getColumnClassName(i) and output dates, string etc differently. TBD
                    outcsv=outcsv + "\""+ rs.getString(i)+"\"";
                    if (i==numOfCols) {
                        outcsv=outcsv + "\n";
                    } else {
                        outcsv=outcsv + ",";
                    }
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
// output as CSV
response.setContentType("text/csv");
response.setHeader("Content-Disposition", "attachment; filename="+outputFileName);
%>
<%=outcsv%>