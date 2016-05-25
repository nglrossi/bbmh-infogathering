/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package blackboard.bbmh;


import blackboard.platform.config.BbConfig;
import blackboard.platform.config.ConfigurationServiceFactory;
import java.text.SimpleDateFormat;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.TimeZone;

/**
 *
 * @author arossi
 */


public class DbServerInfo {
    
    //public String osName = "";
    public static String getDatabaseType() {
        return ConfigurationServiceFactory.getInstance().getBbProperty(BbConfig.DATABASE_TYPE);
    }

    public static String getMainSchema() {
        return ConfigurationServiceFactory.getInstance().getBbProperty(BbConfig.DATABASE_IDENTIFIER);
    }

    public static String getDatabaseVersion() {
        Logging.writeLog("Start: getDatabaseVersion");
        Connection dbConnection = Db.getConnection();
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        String qrystr = "";
        String dbVersion = "";
        switch (getDatabaseType()) {
            case "oracle":
                qrystr = "select * from v$version";
                break;
            case "mssql":
                qrystr = "Select @@version";
                break;
            case "pgsql":
                qrystr = "select version()";
                break;
            default:
                dbVersion = "unable to detect db version";
        }
        try {
            try {
                boolean wasExecuted = dbStatement.execute(qrystr);
                if (wasExecuted) {
                    rs = dbStatement.getResultSet();
                    if (rs.next()) {
                        dbVersion = rs.getString(1);
                    }
                }
            } finally {
                if (rs != null) {
                    rs.close();
                }
                if (dbStatement != null) {
                    dbStatement.close();
                }
                if (dbConnection != null) {
                    dbConnection.close();
                }
            }
        } catch (Exception e) {
            // TODO: log in logs
            //dbVersion = "exception " + e + " " ;
        }
        Logging.writeLog("End: getDatabaseVersion");
        return dbVersion;
    }

    public static List<String> getAllSchemas() {
        Logging.writeLog("Start: getAllSchemas");
        Connection dbConnection = Db.getConnection();
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        String qrystr = "";
        List<String> schemas = new ArrayList<String>();
        switch (getDatabaseType()) {
            case "oracle":
                qrystr = "select * from dba_users";
                break;
            case "mssql":
                qrystr = "select * from sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')";
                break;
            case "pgsql":
                qrystr = "SELECT usename FROM pg_user order by pg_user";
                break;
            default:
            // nothing to do
        }
        try {
            try {
                boolean wasExecuted = dbStatement.execute(qrystr);
                if (wasExecuted) {
                    rs = dbStatement.getResultSet();
                    while (rs.next()) {
                        schemas.add(rs.getString(1));
                    }
                }
            } finally {
                if (rs != null) {
                    rs.close();
                }
                if (dbStatement != null) {
                    dbStatement.close();
                }
                if (dbConnection != null) {
                    dbConnection.close();
                }
            }
        } catch (Exception e) {
            // TODO: log in logs
            //dbVersion = "exception " + e + " " ;
        }
        Logging.writeLog("End: getAllSchemas");
        return schemas;
    }

    public static String getDatabaseTimeAndTimezone(String format) {
        Logging.writeLog("Start: getDatabaseTimeAndTimezone");
        Connection dbConnection = Db.getConnection();
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        String qrystr = "";
        //String dbServerTimeAndTimezone = "";
        java.util.Date dtDbServerTime = new java.util.Date();
        String dbTzString = "";
        SimpleDateFormat formatter = new SimpleDateFormat(format);
        switch (getDatabaseType()) {
            case "oracle":
                qrystr = "SELECT TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS'), TO_CHAR(SYSTIMESTAMP, 'TZH:TZM') FROM DUAL";
                break;
            case "mssql":
                qrystr = "Select convert(char, SYSDATETIME()), DATENAME(TZoffset, SYSDATETIMEOffset())";
                break;
            case "pgsql":
                qrystr = "SELECT  NOW(), current_setting('TIMEZONE')";
                break;
            default:
                qrystr = "unable to detect db version";
        }
        try {
            try {
                boolean wasExecuted = dbStatement.execute(qrystr);
                if (wasExecuted) {
                    rs = dbStatement.getResultSet();
                    if (rs.next()) {
                        dtDbServerTime = formatter.parse(rs.getString(1));
                        dbTzString = rs.getString(2);
                    }
                }
            } finally {
                if (rs != null) {
                    rs.close();
                }
                if (dbStatement != null) {
                    dbStatement.close();
                }
                if (dbConnection != null) {
                    dbConnection.close();
                }
            }
        } catch (Exception e) {
            // TODO: log in logs
        }
        Logging.writeLog("End: getDatabaseTimeAndTimezone");
        return formatter.format(dtDbServerTime) + " " + dbTzString;
    }

    public static double getDbSize() {
        // Size in GB
        Logging.writeLog("Start: getDbSize");
        Connection dbConnection = Db.getConnection();
        ResultSet rs = null;
        String qrystr = "";
        Statement dbStatement = Db.createStatement(dbConnection);
        //String debug = "";
        double size = -1;
        switch (ConfigurationServiceFactory.getInstance().getBbProperty(blackboard.platform.config.BbConfig.DATABASE_TYPE)) {
            case "oracle":
                qrystr = "SELECT ROUND(A.DATA_SIZE + B.TEMP_SIZE + C.REDO_SIZE + D.CONTROLFILE_SIZE, 2) "
                        + "FROM (SELECT SUM (BYTES) / 1024 / 1024/1024 DATA_SIZE FROM DBA_DATA_FILES) A, "
                        + "(SELECT NVL (SUM (BYTES), 0) / 1024 / 1024/1024 TEMP_SIZE "
                        + "FROM DBA_TEMP_FILES) B, "
                        + "(SELECT SUM (BYTES) / 1024 / 1024/1024 REDO_SIZE FROM SYS.V_$LOG) C, "
                        + "(SELECT SUM (BLOCK_SIZE * FILE_SIZE_BLKS) / 1024 / 1024/1024 "
                        + "CONTROLFILE_SIZE "
                        + "FROM V$CONTROLFILE) D";
                break;
            case "mssql":
                qrystr = "TODO";
                break;
            case "pgsql":
                qrystr = "select pg_database_size(current_database())/(1024*1024*1024)";
                break;
            default:
                qrystr = "";
        }
        try {
            try {
                boolean wasExecuted = dbStatement.execute(qrystr);
                if (wasExecuted) {
                    rs = dbStatement.getResultSet();
                    if (rs.next()) {
                        size = rs.getDouble(1);
                    }
                }
            } finally {
                if (rs != null) {
                    rs.close();
                }
                if (dbStatement != null) {
                    dbStatement.close();
                }
                if (dbConnection != null) {
                    dbConnection.close();
                }
            }
        } catch (Exception e) {
            // TODO: log in logs
            //debug = "exception " + e + " " ;
        }
        Logging.writeLog("End: getDbSize");
        return size;
    }
}
