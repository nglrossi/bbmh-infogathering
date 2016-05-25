
package blackboard.bbmh;


import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import blackboard.bbmh.B2Helper;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author arossi
 */
public class AuthHelperFactory {
    public static List<AuthHelper> getAuthProviders() {
        Logging.writeLog("Start: getAuthProviders");
        Connection dbConnection = Db.getConnection();
        List<AuthHelper> authList = new ArrayList<AuthHelper>();
        //SimpleDateFormat anotherdbformatter = new SimpleDateFormat("yyyy-MM-dd");
        String qrystr = "select * from AUTH_PROVIDER order by position";
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        try {
            try {
                boolean wasExecuted = dbStatement.execute(qrystr);
                if (wasExecuted) {
                    rs = dbStatement.getResultSet();
                    while (rs.next()) {
                        AuthHelper authlocal = new AuthHelper();
                        authlocal.setName(rs.getString("name"));
                        authlocal.setType(rs.getString("extension_id"));
                        authlocal.setStatus(rs.getString("enabled_ind"));
                        authlocal.setPosition(rs.getInt("position"));
//                        b2local.setVendorName(rs.getString("vendor_name"));
//                        b2local.setVersion(rs.getInt("version_major"), rs.getInt("version_minor"), rs.getInt("version_patch"), rs.getInt("version_build"));
//                        b2local.setAvailableFlag(rs.getString("available_flag"));
//                        b2local.setDateModified(anotherdbformatter.parse(rs.getString("dtmodified")));

                        authList.add(authlocal);
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
        Logging.writeLog("End: getAuthProviders");
        return authList;
    }
}
