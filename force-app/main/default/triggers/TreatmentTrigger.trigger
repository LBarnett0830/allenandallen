trigger TreatmentTrigger on litify_pm__Treatment__c (before insert, after insert, before update, after update, after delete) {
    if(TreatmentTriggerHandler.isDisabled()) {
        return;
    }
    if(TreatmentTriggerHandler.dontInvokeTrigger){
        System.debug('Trigger was stopped with Boolean variable');
        return;
    } 
    TreatmentTriggerHandler handler = new TreatmentTriggerHandler(Trigger.isExecuting, Trigger.size);
    if(Trigger.isInsert&& Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }  
    else if(Trigger.isInsert&& Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }  
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }   
    else if(Trigger.isAfter && Trigger.isDelete){
        handler.OnAfterDelete(Trigger.old,Trigger.oldMap);
    } 
}