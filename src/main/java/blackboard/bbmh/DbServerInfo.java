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
    
    public static String getSchemaName() {
        return ConfigurationServiceFactory.getInstance().getBbProperty(BbConfig.DATABASE_IDENTIFIER);
    }   
    
    public static String getDatabaseVersion() {
        Connection dbConnection = Db.getConnection();
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        String qrystr = "";
        String dbVersion = "";
        switch(getDatabaseType()) {
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
                if(rs != null){
                    rs.close();
                }
                if(dbStatement != null){
                    dbStatement.close();
                }
                if(dbConnection != null){
                    dbConnection.close();
                }
            }
        } catch(Exception e) {
            // TODO: log in logs
            //dbVersion = "exception " + e + " " ;
        }
        return dbVersion;
    }
    
    public static String getDatabaseTimeAndTimezone(String format) {
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
                if(dbConnection != null){
                    dbConnection.close();
                }
            }
        } catch (Exception e) {
            // TODO: log in logs
        }
        return formatter.format(dtDbServerTime) + " " + dbTzString;
    }
}




