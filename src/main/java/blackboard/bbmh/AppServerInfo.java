/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package blackboard.bbmh;

import java.util.Date;
import java.util.TimeZone;
import java.text.SimpleDateFormat;
import java.io.File;
//import java.util.logging.Level;
//import java.util.logging.Logger;
import blackboard.platform.config.BbConfig;
import blackboard.platform.config.ConfigurationServiceFactory;

/**
 *
 * @author arossi
 */


public class AppServerInfo {
    public String osName = "";
    
    public static String getOsName() {
        return System.getProperty("os.name");
    }
    
    public static String getOsArch() {
        return System.getProperty("os.arch");
    }
    
    public static String getOsVersion() {
        return System.getProperty("os.version");
    }
    
    public static String getJavaVersion() {
        return System.getProperty("java.version");
    }    
    
    public static String getServerTime(String format) {
        SimpleDateFormat appFormatter = new SimpleDateFormat(format);
        java.util.Date dtAppServerTime = new java.util.Date();
        TimeZone tz = TimeZone.getDefault();
        return appFormatter.format(dtAppServerTime) + " - "  + tz.getID() + " - " + tz.getDisplayName();
    }   

    public static String getUrl() {
        String fullHostName = BbConfig.APPSERVER_FULLHOSTNAME;
        return ConfigurationServiceFactory.getInstance().getBbProperty( fullHostName, fullHostName + " not found in bb-config.properties");
    }  

    public static String getBaseDirPath() {
        // get either BASEDIR or BASEDIR_WIN
        return ConfigurationServiceFactory.getInstance().getBbProperty(BbConfig.BASEDIR, BbConfig.BASEDIR_WIN);
    }

    public static String getContentDirPath() {
        // get either BASE_SHARED_DIR  or BASE_SHARED_DIR_WIN 
        return ConfigurationServiceFactory.getInstance().getBbProperty(BbConfig.BASE_SHARED_DIR, BbConfig.BASE_SHARED_DIR_WIN );
    }
    
    
    
    public static long getDiskUsage(String fs) {
        Logging.writeLog("Start: getDiskUsage");
        // all in GB
        File ff = new File (fs);
        long du = -1;
        try {
            du = (ff.getTotalSpace() - ff.getFreeSpace()) / (1024*1024*1024);
        } catch (Exception e) {
            //Logger.getLogger(AppServerInfo.class.getName()).log(Level.SEVERE, null, e);
            //throw new RuntimeException("Problem while trying to get Building Block Config Directory", e);
        }
        Logging.writeLog("End: getDiskUsage");
        return du;
    }
    
    
}
