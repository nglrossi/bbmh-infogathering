/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package blackboard.bbmh;

/**
 *
 * @author arossi
 */
public class AuthHelper {
    public String name = "";
    public String type = "";
    public String availableFlag = "";
    public int position = -1;
    
    public void setName(String name) {
        // TODO: use APIs instead of hardcoded translation
        switch (name) {
            case "default.provider.instance.name":
                this.name = "Default";
                break;
            case "legacy.provider.instance.name":
                this.name = "Legacy";
                break;
            default:
                this.name = name;
                break;
        }
    }
    
    public void setType(String type) {
        switch (type) {
            case "blackboard.platform.defaultAuthProviderType":
                this.type = "Learn Default";
                break;
            case "blackboard.platform.legacyAuthProviderType":
                this.type = "Learn Legacy";
                break;
            case "blackboard.platform.ldapAuthProvider":
                this.type = "LDAP";
                break;
            case "blackboard.platform.casAuthProvider":
                this.type = "CAS";
                break;
            case "blackboard.platform.shibbolethAuthProvider":
                this.type = "Shbboleth";
                break;
            default:
                this.type = type;
                break;
                //
        }
//this.type = type;
    }
    
    public void setStatus(String availableFlag) {
        switch (availableFlag) {
            case "N":
                this.availableFlag = "Inactive";
                break;
            case "Y":
                this.availableFlag = "Active";
                break;
            default:
                this.availableFlag = "Unrecognized Status";
                break;
        }
    }
    
    public void setPosition(int pos) {
        this.position = pos;
    }
}
