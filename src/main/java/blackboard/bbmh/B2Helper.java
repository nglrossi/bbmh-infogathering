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
import java.util.Date;
import java.text.SimpleDateFormat;


/**
 *
 * @author arossi
 */
public class B2Helper {
    //public static String VENDOR_ID = "oslt";
    //public static String HANDLE = "jshack";
    
    public String name = "";
    public String localizedName = "";
    public String vendor_id = "";
    public String vendorName = "";
    public String handle = "";    
    public String status = "";
    public String availableFlag = "";    
    public String version = "";
    public int hits = -1;
    public String dateModified = "";
    
    public B2Helper(String vendor_id, String handle)
    {
        this.vendor_id = vendor_id;
        this.handle = handle;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public void setVendorName(String vendorName) {
        this.vendorName = vendorName;
    }
    
    public void setDateModified(Date dateModified) {
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        this.dateModified = formatter.format(dateModified);
    }
   
    /*
    public String getDateModified() {
        
        return dateModified.toString();
    }
    */
    
    public void setAvailableFlag(String availableFlag) {
        switch(availableFlag) {
            case "I":
                this.availableFlag = "Inactive";
                break;
            case "Y":
                this.availableFlag = "Available";
                break;
            case "U":
                this.availableFlag = "Unavailable";
                break;
            default:
                this.availableFlag = "Unrecognized Status";
                break;
        }
    }
    
    public void setLocalizedName(String key) {
        this.localizedName = getLocalisationString(key, this.vendor_id, this.handle);
    }
    
    public void setVersion(int major, int minor, int patch, int build) {
        this.version = major + "." + minor;
        if ( patch != -1 ) this.version += "." + patch;
        if ( build != -1 ) this.version += "." + build;
    }
    
    public void setHits(int hits) {
        this.hits = hits;
    }
    
    public String getLocalisationString(String key) {
        PlugInManager pluginMgr = PlugInManagerFactory.getInstance();
    
        PlugIn plugin = pluginMgr.getPlugIn(vendor_id, handle);

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
}
