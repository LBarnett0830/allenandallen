trigger APDisbursementTrigger on AcctSeed__AP_Disbursement__c (before insert,after insert,before update,after update,before delete,after delete) {
    if(!Disable_Triggers__c.getOrgDefaults().disabled__c){
        if(Trigger.isAfter && Trigger.isInsert){       
           // APDisbursementTriggerHandler.onAfterInsert(Trigger.new);
        }
        if(Trigger.isBefore && Trigger.isDelete){
            system.debug('######isDelete Called');
            //APDisbursementTriggerHandler.onBeforeDelete(trigger.oldMap.values());
        }
    }
}