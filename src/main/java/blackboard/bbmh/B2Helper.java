/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package blackboard.bbmh;

import blackboard.platform.*;
import blackboard.platform.intl.BundleManager;
import blackboard.platform.intl.BundleManagerFactory;
import blackboard.platform.intl.BbResourceBundle;
import blackboard.platform.plugin.PlugIn;
import blackboard.platform.plugin.PlugInManager;
import blackboard.platform.plugin.PlugInManagerFactory;

/**
 *
 * @author arossi
 */
public class B2Helper {
    public static String VENDOR_ID = "oslt";
    public static String HANDLE = "jshack";
    
    public String name = "";
    public String vendor = "";
    public String handle = "";
    
    
    
    public static String getLocalisationString(String key) {
        PlugInManager pluginMgr = PlugInManagerFactory.getInstance();
    
        PlugIn plugin = pluginMgr.getPlugIn(B2Helper.VENDOR_ID, B2Helper.HANDLE);

        BundleManager bm = BundleManagerFactory.getInstance();
        BbResourceBundle bundle = bm.getPluginBundle(plugin.getId());

        return bundle.getStringWithFallback(key, key);
    }
    
    public static String getLocalisationString(String key, String vendor_id, String handle) {
        PlugInManager pluginMgr = PlugInManagerFactory.getInstance();
    
        PlugIn plugin = pluginMgr.getPlugIn(vendor_id, handle);

        BundleManager bm = BundleManagerFactory.getInstance();
        BbResourceBundle bundle = bm.getPluginBundle(plugin.getId());

        return bundle.getStringWithFallback(key, key);
    }
    
    
    
 /*   
    public static String getString() {
//    PlugInManager pluginMgr = PlugInManagerFactory.getInstance();
    blackboard.platform.plugin.PlugInManager pluginMgr = blackboard.platform.plugin.PlugInManagerFactory.getInstance();
        return "Hello World";
    }
*/
}
