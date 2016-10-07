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
// Filename
SimpleDateFormat appFormatter = new SimpleDateFormat("yyyy-MM-dd");
java.util.Date dtAppServerTime = new java.util.Date();
String appServerDate = appFormatter.format(dtAppServerTime);
String fullHostname = AppServerInfo.getUrl();
String outputFileName = "userPK1s-"+fullHostname+"-"+appServerDate+".csv";

String outcsv = "\"User ID\",\"User PK1\"\n";
    Connection dbConnection = Db.getConnection();
    // query is the same for all DB types 
    String qrystr = "select user_id,pk1 from users order by user_id asc";
    
    Statement dbStatement = Db.createStatement(dbConnection);
    ResultSet rs = null;
    try {
        try {
            boolean wasExecuted = dbStatement.execute(qrystr);
            if (wasExecuted) {
                rs = dbStatement.getResultSet();
                while (rs.next()) {
                    // append to csv
                    outcsv=outcsv + rs.getString("user_id") +","+ rs.getInt("pk1") +"\n";
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