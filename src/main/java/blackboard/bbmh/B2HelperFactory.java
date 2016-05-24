/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package blackboard.bbmh;

import java.sql.*;
import java.util.*;
import java.text.SimpleDateFormat;
import blackboard.bbmh.B2Helper;
//import blackboard.bbmh.*;


/**
 *
 * @author arossi
 */
public class B2HelperFactory {
    
    public static List<B2Helper> getB2s() {
        
        // TODO: refactoring
        // replacr SQL query with public java.util.List<blackboard.platform.plugin.PlugIn> getPlugIns()
        // http://library.blackboard.com/ref/16ce28ed-bbca-4c63-8a85-8427e135a710/blackboard/platform/plugin/PlugInManager.html#getPlugIns--
        
        Connection dbConnection = Db.getConnection();
        List<B2Helper> b2s = new ArrayList<B2Helper>();
        SimpleDateFormat anotherdbformatter = new SimpleDateFormat("yyyy-MM-dd");
        String qrystr = "select name, vendor_id, handle, vendor_name, version_major, version_minor, version_patch, version_build, available_flag, dtmodified from plugins";
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        try {
            try {
                boolean wasExecuted = dbStatement.execute(qrystr);
                if (wasExecuted) {
                    rs = dbStatement.getResultSet();
                    while (rs.next()) {
                        B2Helper b2local = new B2Helper(rs.getString("vendor_id"), rs.getString("handle"));
                        b2local.setName(rs.getString("name"));
                        b2local.setLocalizedName(rs.getString("name"));
                        b2local.setVendorName(rs.getString("vendor_name"));
                        b2local.setVersion(rs.getInt("version_major"), rs.getInt("version_minor"), rs.getInt("version_patch"), rs.getInt("version_build"));
                        b2local.setAvailableFlag(rs.getString("available_flag"));
                        b2local.setDateModified(anotherdbformatter.parse(rs.getString("dtmodified")));

                        b2s.add(b2local);
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
        return b2s;
    }
}