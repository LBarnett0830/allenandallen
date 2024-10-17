/**
 * @author      Litify Professional Services
 * @version     1.0.0
 */

public class PreventEventDeletionHandler {

    /**
     * Returns Custom Setting whether the trigger is enabled
     */
    public static Boolean isTriggerActive(){
        return Trigger_PreventEventDeletion__c.getOrgDefaults().Active__c;
    }    
    
    /**
     * Set error if user's profile is in Excluded Profiles
     * 
     * @param tasks A list of Events from before delete Trigger
     */    
    public static void preventDeletion(List<Event> events){
        if(!isUsersProfileExcluded(UserInfo.getProfileId())){
            for(Event t : events) {
                t.addError(getErrorMessage());
            }
        }        
    }
    
    /**
     * Returns true if User's profile is not excluded
     * 
     * @param userProfileID User's profile id
     */   
    private static Boolean isUsersProfileExcluded(Id userProfileID){
        
        if(getExcludedProfiles() == null) {
            return false;
        }
        
        List<String> excludedProfiles = getExcludedProfiles().split(';');
        
       
        
        Set<Id> profileIds = (new Map<Id, Profile>([SELECT Id
                                                    FROM Profile
                                                    WHERE Name IN :excludedProfiles])
                             ).keySet();
        
        return profileIds.contains(userProfileID);
    }
    
    /**
     * Returns Excluded Profiles
     * 
     */      
    private static String getExcludedProfiles(){
        return Trigger_PreventEventDeletion__c.getOrgDefaults().Excluded_Profiles__c;
    }

    /**
     * Returns Error message
     * 
     */       
    private static String getErrorMessage(){
        if(Trigger_PreventEventDeletion__c.getOrgDefaults().Error_Message__c == null) {
            return 'ERROR: You have no permissions to delete Events. Please contact your System Admin.';
        }
        return Trigger_PreventEventDeletion__c.getOrgDefaults().Error_Message__c;
    }
}