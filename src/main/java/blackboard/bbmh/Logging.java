/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package blackboard.bbmh;

import blackboard.platform.log.Log;
import blackboard.platform.log.LogService;
import blackboard.platform.log.LogServiceFactory;
import blackboard.platform.plugin.PlugInUtil;
import blackboard.platform.plugin.PlugInException;
import blackboard.platform.plugin.PlugInManager;
import blackboard.platform.plugin.PlugInManagerFactory;
import blackboard.platform.plugin.PlugIn;
import blackboard.platform.BbServiceException;
import java.io.File;

/**
 *
 * @author arossi
 */

public class Logging {
    
    
    public static File oldGetRootConfigDir() {
        
        /* old version that "does the right thing" by logging in the official log directory
        instead of the plugin directory but it's more painful as the log could end up 
        on any app server.
        */
        
        //TODO: remove hardcoded vendor id and b2 name
        return PlugInUtil.getLogDirectory("bbmh", "info-gathering");
    }
    
    public static File getRootConfigDir() {
        
        /* new version that is more versatile as it logs in the plugin directory on the shared 
        filesystem.  Less elegant than using the API provided but it's easier to retrieve the 
        log file when needed.  In particular way if we need to ask clients to send it back.
        */
        
        //TODO: remove hardcoded vendor id and b2 name
        PlugInManager pm = PlugInManagerFactory.getInstance();
        PlugIn pi = new PlugIn();
        pi = pm.getPlugIn("bbmh", "info-gathering");
        return pm.getPlugInDir(pi);
    }
    
    public static String getLogFile() {
        // TODO create /log directory and start returning that instead of the main dir of the plugin
        // do somethng like create if not exist or add to the B2 install procedure
        File rootConfigDirectory = getRootConfigDir();
        return rootConfigDirectory.getAbsolutePath() + "/service.log";
    }
    
    public static String getSeverity() {
        String verb = "";

        try {
            LogServiceFactory.getInstance().defineNewFileLog("bbmhdebug", getLogFile(), LogService.Verbosity.DEBUG, false);
        } catch (BbServiceException ex) {
        }
        Log theLog = LogServiceFactory.getInstance().getConfiguredLog("bbmhdebug");
        verb = theLog.getVerbosityLevel().toExternalString();
        return verb;
    }
    
    public static String getMethodName() {
        StackTraceElement[] stacktrace = Thread.currentThread().getStackTrace();
        StackTraceElement e = stacktrace[2];//coz 0th will be getStackTrace, 1st getMethodName so 2nd
        String methodName = e.getMethodName();
        return (methodName);
    }
    
    public static void writeLog(String message) {
        Log theLog;
        try {
            LogServiceFactory.getInstance().defineNewFileLog("bbmhdebug", getLogFile(), LogService.Verbosity.WARNING, false);
        } catch (BbServiceException ex) {
            
        }
        theLog = LogServiceFactory.getInstance().getConfiguredLog("bbmhdebug");
        theLog.logWarning("DEBUG: " + message);
    }
    
    
}
