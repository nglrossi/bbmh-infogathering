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
public class CourseHelper {
    
    public String id;
    public String name;
    public int countEnrollments;
    public String availableFlag;
    public String statusFlag;
    
    public void setId(String id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setCountEnrollments(int countEnrollments) {
        this.countEnrollments = countEnrollments;
    }

    public void setAvailableFlag(String availableFlag) {
        switch (availableFlag) {
            case "Y":
                this.availableFlag = "Available";
                break;
            case "N":
                this.availableFlag = "Unavailable";
                break;
            default:
                this.availableFlag = "Unrecognized Flag";
                break;
        }
    }

    public void setStatus(int statusFlag) {
        switch (statusFlag) {
            case 0:
                this.statusFlag = "Active";
                break;
            default:
                this.statusFlag = "Inactive";
                break;
        }
    }
        
    
}
