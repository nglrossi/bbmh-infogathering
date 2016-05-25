

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package blackboard.bbmh;


import java.sql.*;
import blackboard.platform.config.ConfigurationServiceFactory;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author arossi
 */
public class CourseInfo {
    
    public static int getTotalCourses() {
        Logging.writeLog("Start: " + Logging.getMethodName());
        Connection dbConnection = Db.getConnection();
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        String qrystr = "select count(*) from course_main";
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
        Logging.writeLog("End: " + Logging.getMethodName());
        return count;
    }
    public static int getActiveCourses() {
        Logging.writeLog("Start: " + Logging.getMethodName());
        Connection dbConnection = Db.getConnection();
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        String qrystr = "select count(*) from course_main where row_status=0 and available_ind='Y'";
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
        Logging.writeLog("End: " + Logging.getMethodName());
        return count;
    }

    public static int getAccessedSince(int howmanydays) {
        Logging.writeLog("Start: " + Logging.getMethodName());
        Connection dbConnection = Db.getConnection();
        ResultSet rs = null;
        String qrystr = "";
        PreparedStatement prepStatement = null;
        int count = -1;
        switch (ConfigurationServiceFactory.getInstance().getBbProperty(blackboard.platform.config.BbConfig.DATABASE_TYPE)) {
            case "oracle":
                qrystr = "select count(*) from (select crsmain_pk1, max(last_access_date) last_access_date FROM course_users GROUP BY crsmain_pk1) where last_access_date >= sysdate-?";
                break;
            case "mssql":
                qrystr = "select count(*) from (select crsmain_pk1, max(last_access_date) last_access_date FROM course_users GROUP BY crsmain_pk1) as derivedTable where last_access_date >= DATEADD(DAY, -?, GETDATE ());";
                break;
            case "pgsql":
                qrystr = "select count(*) from (select crsmain_pk1, max(last_access_date) last_access_date FROM course_users GROUP BY crsmain_pk1) as derivedTable where last_access_date >= current_date - ( ? * INTERVAL '1' DAY)";
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
        Logging.writeLog("Start: " + Logging.getMethodName());
        return count;
    }
    
    public static List<CourseHelper> getLargeCourses() {
        Logging.writeLog("Start: " + Logging.getMethodName());
        Connection dbConnection = Db.getConnection();
        List<CourseHelper> largeCourses = new ArrayList<CourseHelper>();
        String qrystr = "select c.pk1,c.course_id,c.course_name,c.available_ind,c.row_status,count(*) howmany from course_main c left join course_users e on c.pk1=e.crsmain_pk1 group by c.pk1,c.course_id,c.course_name,c.available_ind,c.row_status having count(*)>0 order by count(*) desc";
        Statement dbStatement = Db.createStatement(dbConnection);
        ResultSet rs = null;
        int limit = 1;
        try {
            try {
                boolean wasExecuted = dbStatement.execute(qrystr);
                if (wasExecuted) {
                    rs = dbStatement.getResultSet();
                    while (rs.next() && limit <= 10) {
                        CourseHelper courseLocal = new CourseHelper();
                        courseLocal.setName(rs.getString("course_name"));
                        courseLocal.setId(rs.getString("course_id"));
                        courseLocal.setCountEnrollments(rs.getInt("howmany"));
                        courseLocal.setAvailableFlag(rs.getString("available_ind"));
                        courseLocal.setStatus(rs.getInt("row_status"));

                        largeCourses.add(courseLocal);
                        limit += 1;
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
        Logging.writeLog("End: " + Logging.getMethodName());
        return largeCourses;
    }
}
