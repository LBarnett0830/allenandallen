trigger DSMatterTrigger on litify_pm__Matter__c (before insert, before update) {
    if(DSUnitities.isDisabled()) {
        return;
    }
    if(Trigger.isInsert && Trigger.isBefore){
        DSUnitities.updateMatters(Trigger.new, null);
    } 
    else if (Trigger.isBefore && Trigger.isUpdate) {
        DSUnitities.updateMatters(Trigger.new, Trigger.oldMap);
    }
}