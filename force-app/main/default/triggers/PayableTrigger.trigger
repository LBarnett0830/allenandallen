trigger PayableTrigger on AcctSeed__Account_Payable__c (before insert,before delete, after update) {
    payableTriggerHandler.newList = Trigger.new;
    payableTriggerHandler.oldList = Trigger.old;
    payableTriggerHandler.newMap = Trigger.newMap;
    payableTriggerHandler.oldMap = Trigger.oldMap;   
    
    if(!Disable_Triggers__c.getOrgDefaults().disabled__c){
        if(trigger.isBefore && trigger.isDelete){
            
            //payableTriggerHandler.beforeDelete(trigger.oldMap.values());
            payableTriggerHandler.beforeDeleteOperation();
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            payableTriggerHandler.afterUpdateOperation();
        }
    }
    
}