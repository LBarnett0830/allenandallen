trigger AccountPayableLineTrigger on AcctSeed__Account_Payable_Line__c (after insert, after update, before update,before insert, before delete, after delete) {
    AccountPayableLineTriggerHelper.newList = Trigger.new;
    AccountPayableLineTriggerHelper.oldList = Trigger.old;
    AccountPayableLineTriggerHelper.newMap = Trigger.newMap;
    AccountPayableLineTriggerHelper.oldMap = Trigger.oldMap;  
    
    if(!Disable_Triggers__c.getOrgDefaults().disabled__c){
        if(Trigger.IsInsert && Trigger.IsAfter){
            AccountPayableLineTriggerHelper.afterInsertOperation();                                                                           
        } 
        if(Trigger.IsUpdate && Trigger.IsAfter){
            AccountPayableLineTriggerHelper.afterUpdateOperation();                                                                           
        } 
        if(Trigger.IsDelete && Trigger.IsAfter){
            AccountPayableLineTriggerHelper.afterDeleteOperation();                                                                           
        } 
        if(Trigger.IsDelete && Trigger.IsBefore){
            AccountPayableLineTriggerHelper.beforeDeleteOperation();                                                                           
        } 
    }
    
}