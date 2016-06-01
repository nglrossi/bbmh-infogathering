/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package blackboard.bbmh;

import java.sql.*;
import blackboard.db.*;
/**
 *
 * @author arossi
 */
public class Db {

    public Db() {   
    }
    
    public static Connection getConnection() {
        ConnectionManager conman = null;
        Connection conn = null;
        //Statement stmt = null;
        try {

            // Create Conn to correct database
            int j = 0;

            BbDatabase bbDb = DbUtil.safeGetBbDatabase();
            conman = bbDb.getConnectionManager();
            while (conn == null && j < 10) {
                try {
                    conn = conman.getConnection();
                } catch (ConnectionNotAvailableException cnae) {
                    Thread.sleep(1000);
                    ++j;
                }
            }

        } catch (Exception e) {
            // TODO: write in the logs
        }
        return conn;
    }
    
    public static Statement createStatement(Connection conn) {
        Statement stmt = null;
        try {
            stmt = conn.createStatement();
        } catch (Exception e) {
            // TODO: write in the logs
        }
        return stmt;
    }
    
    public static String debugStatement(Connection conn) {
        Statement stmt = null;
        String dbg = "";
        try {
            stmt = conn.createStatement();
            dbg = "here dbg";
        } catch (Exception e) {
            // TODO: write in the logs
            dbg += e;
        }
        return dbg + " " + stmt;
    }
}
