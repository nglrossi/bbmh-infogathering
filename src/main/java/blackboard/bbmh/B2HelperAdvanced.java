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
public class B2HelperAdvanced extends B2Helper {
    
    public int hits = -1;

    public B2HelperAdvanced(String vendor_id, String handle)
    {
        super(vendor_id, handle);
    }
    
    public void setHits(int hits) {
        this.hits = hits;
    }
}
