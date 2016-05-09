/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package blackboard.bbmh;

import java.util.Date;
import java.util.TimeZone;
import java.text.SimpleDateFormat;
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
}
