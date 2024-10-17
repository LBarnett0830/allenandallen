trigger matterTrigger on litify_pm__Matter__c (after insert) {
    if(!Disable_Triggers__c.getOrgDefaults().disabled__c){
        if(trigger.isInsert && trigger.isAfter){
            matterTriggerHandler.afterInsert(trigger.New);
        }
    }
}