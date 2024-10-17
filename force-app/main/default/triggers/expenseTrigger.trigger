trigger expenseTrigger on litify_pm__Expense__c (before insert,before update,after insert, after update,before delete) {
    
  /*  if(!Disable_Triggers__c.getOrgDefaults().disabled__c){
        if(trigger.isBefore && trigger.isInsert){
            expenseTriggerHandler.beforeInsert(trigger.new);
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            expenseTriggerHandler.afterUpdate(trigger.new,trigger.oldMap);
        }
        if(trigger.isBefore && trigger.isUpdate){
            expenseTriggerHandler.beforeUpdate(trigger.new,trigger.oldMap);
        }
        
        if(trigger.isBefore && trigger.isDelete){
            
            expenseTriggerHandler.beforeDelete(trigger.oldMap.values());
        }
        if(trigger.isAfter && trigger.isInsert){
            expenseTriggerHandler.afterInsert(trigger.new);
        }
        
    }
    
*/
    
}