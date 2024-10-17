trigger WDIMatterTrigger on litify_pm__Matter__c (before update, after insert) {

    If (wdi_queueable_helper.env.AED_Integration_Enabled || Test.isRunningTest())  {
 
    
    List<litify_pm__Matter__c> updaterecs = new List<litify_pm__Matter__c>();

    if (trigger.isafter && trigger.isInsert) {
        for (litify_pm__Matter__c rec : Trigger.new) {
            updaterecs.add(rec);
        }
    }
    
    if (trigger.isBefore && trigger.isUpdate) {
        for (litify_pm__Matter__c newRec : Trigger.new) {
            litify_pm__Matter__c oldRec = Trigger.oldmap.get(newRec.ID);

            String previousVersion = oldRec.litify_pm__Display_Name__c;
            String newVersion = newRec.litify_pm__Display_Name__c;
            if (previousVersion != newVersion ) {
                updaterecs.add(newRec);
            }
        }   
    }

    
    if (updaterecs.size() > 0) {
        WDIMatterTriggerHandler.processrecs(updaterecs);    
    }
}
}