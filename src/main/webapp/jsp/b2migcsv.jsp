<%@ page	language="java"
         import="java.util.*,
         java.sql.*,
         java.util.*,
         blackboard.bbmh.*,
         java.text.SimpleDateFormat,
         java.io.File,
         blackboard.platform.plugin.*"
         pageEncoding="UTF-8"
         %>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%

// get the request type from query sting
String req=request.getParameter("req");
String header="No query defined";
String filename = "undefined";
String orasql="";
String mssql="";
String pgsql="";

// Add new CSV definitions here, they can be called by adding the key to the query string value req
switch (req) {
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