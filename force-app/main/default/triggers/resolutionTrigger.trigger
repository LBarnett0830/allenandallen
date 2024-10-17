trigger resolutionTrigger on litify_pm__Resolution__c (after update) {
    if(!Disable_Triggers__c.getOrgDefaults().disabled__c){

        if(trigger.isBefore && trigger.isUpdate){
            resolutionTriggerHandler.beforeUpdate(trigger.new);
        }
        if(trigger.isAfter && trigger.isupdate ){
            resolutionTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
        }
    }
}