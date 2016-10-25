/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package blackboard.bbmh;

import java.sql.*;
import java.util.*;
import java.text.SimpleDateFormat;


/**
 *
 * @author arossi
 */
public class B2HelperFactoryAdvanced {
    
    public static List<B2HelperAdvanced> getB2s() {
        Logging.writeLog("Start: getB2s");
        
        // TODO: refactoring
        // replacr SQL query with public java.util.List<blackboard.platform.plugin.PlugIn> getPlugIns()
        // http://library.blackboard.com/ref/16ce28ed-bbca-4c63-8a85-8427e135a710/blackboard/platform/plugin/PlugInManager.html#getPlugIns--
        
        Connection dbConnection = Db.getConnection();
        List<B2HelperAdvanced> b2s = new ArrayList<B2HelperAdvanced>();
        SimpleDateFormat anotherdbformatter = new SimpleDateFormat("yyyy-MM-dd");
        String qrystr = "";
        switch (DbServerInfo.getDatabaseType()) {
            case "oracle":
                qrystr = "select name, vendor_id, handle, vendor_name, available_flag, dtmodified, " +
"  NVL(mycount,0) hits_last_year " +
"FROM plugins " +
"LEFT OUTER JOIN " +
"  (SELECT COUNT(1) mycount, " +
"    SUBSTR(data,1,instr(SUBSTR(data,1,instr(data,'/',10,1)),'-',-1,1) -1 ) mydata " +
"  FROM activity_accumulator " +
"  WHERE TIMESTAMP >= sysdate -365 " +
"  AND data LIKE '/webapps/%-%/%' " +
"  GROUP BY SUBSTR(data,1,instr(SUBSTR(data,1,instr(data,'/',10,1)),'-',-1,1) -1 ) " +
"  ) aa " +
"ON aa.mydata= '/webapps/' " +
"  || Vendor_ID  || '-'  || Handle " +
"ORDER BY hits_last_year desc";
                break;
            case "mssql":
                qrystr = "SELECT name, vendor_id, handle, vendor_name, available_flag, dtmodified, " +
                        "coalesce(mycount,0) hits_last_year " +
                        "from plugins left outer join " +
                        "(select count(1) mycount, substring(data,1,charindex('-',substring(data,1,charindex('/',data,10)),-1) ) mydata " +
                        "from activity_accumulator " +
                        "where timestamp >= getdate() -365 " +
                        "and data like '/webapps/%-%/%' " +
                        "group by substring(data,1,charindex('-',substring(data,1,charindex('/',data,10)),-1) )) aa " +
                        "on aa.mydata= '/webapps/'+ vendor_ID + '-' + Handle " +
                        "ORDER BY Name;";
                break;
            case "pgsql":
                qrystr = "select name, vendor_id, handle, vendor_name, available_flag, dtmodified, 123 as hits_last_year from plugins order by name";
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
                    while (rs.next()) {
                        B2HelperAdvanced b2local = new B2HelperAdvanced(rs.getString("vendor_id"), rs.getString("handle"));
                        b2local.setName(rs.getString("name"));
                        b2local.setLocalizedName(rs.getString("name"));
                        b2local.setVendorName(rs.getString("vendor_name"));
                        b2local.setVersion();
                        b2local.setAvailableFlag(rs.getString("available_flag"));
                        b2local.setDateModified(anotherdbformatter.parse(rs.getString("dtmodified")));
                        b2local.setHits(rs.getInt("hits_last_year"));

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
        Logging.writeLog("End: getB2s");
        return b2s;
    }
}