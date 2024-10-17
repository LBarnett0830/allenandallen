trigger DSIntakeTrigger on litify_pm__Intake__c (before insert, before update) {
    if(DSUnitities.isDisabled()) {
        return;
    }
    if(Trigger.isInsert && Trigger.isBefore){
        DSUnitities.updateIntakes(Trigger.new, null);
    } 
    else if (Trigger.isBefore && Trigger.isUpdate) {
        DSUnitities.updateIntakes(Trigger.new, Trigger.oldMap);
    }
}