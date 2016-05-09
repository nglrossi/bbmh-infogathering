/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package blackboard.bbmh;


import java.sql.*;
import blackboard.platform.config.ConfigurationServiceFactory;

/**
 *
 * @author arossi
 */
public class UserInfo {
    public static int getActiveUsers() {
        Connection dbConnection = Db.getConnection();
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        //String qrystr = "select count(*) from users";
        String qrystr = "SELECT COUNT(u.user_id) ct FROM users u WHERE EXISTS ( SELECT 'x' FROM course_users cu "
                + "WHERE cu.users_pk1 = u.pk1 AND cu.row_status = 0  AND cu.available_ind='Y' AND crsmain_pk1 in ("
                + "select pk1 from course_main where course_main.row_status=0  AND course_main.available_ind='Y' AND course_main.service_level='F' ) ) "
                + "AND u.row_status = 0 AND u.available_ind = 'Y'";
        int count = -1;
        try {
            try {
                boolean wasExecuted = dbStatement.execute(qrystr);
                if (wasExecuted) {
                    rs = dbStatement.getResultSet();
                    if (rs.next()) {
                        count = rs.getInt(1);
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
        return count;
    }

    public static int getUniqueLoginsSince(int howmanydays) {
        Connection dbConnection = Db.getConnection();
        ResultSet rs = null;
        String qrystr = "";
        PreparedStatement prepStatement = null;
        int count = -1;
        switch (ConfigurationServiceFactory.getInstance().getBbProperty(blackboard.platform.config.BbConfig.DATABASE_TYPE)) {
            case "oracle":
                qrystr = "SELECT count(distinct (user_pk1)) valuen "
                        + "from activity_accumulator where event_type = 'LOGIN_ATTEMPT' "
                        + "and data = 'Login succeeded.' and timestamp >= sysdate-?";
                break;
            case "mssql":
                qrystr = "SELECT count(distinct (user_pk1)) valuen "
                        + "from activity_accumulator where event_type = 'LOGIN_ATTEMPT' "
                        + "and data = 'Login succeeded.' and timestamp >= DATEADD(DAY, -?, GETDATE ())";
                break;
            case "pgsql":
                qrystr = "SELECT count(distinct (user_pk1)) valuen "
                        + "from activity_accumulator where event_type = 'LOGIN_ATTEMPT' "
                        + "and data = 'Login succeeded.' and timestamp >= current_date - ( ? * INTERVAL '1' DAY)";
                break;
            default:
                qrystr = "";
        }
        try {
            try {
                prepStatement = dbConnection.prepareStatement(qrystr);
                prepStatement.setInt(1, howmanydays);
                rs = prepStatement.executeQuery();
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            } finally {
                if (rs != null) {
                    rs.close();
                }
                if (prepStatement != null) {
                    prepStatement.close();
                }
                if (dbConnection != null) {
                    dbConnection.close();
                }
            }
        } catch (Exception e) {
            // TODO: log in logs
            //dbVersion = "exception " + e + " " ;
        }
        return count;
    }
    
}
