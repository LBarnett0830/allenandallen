/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Trust_Cash_ReceiptTrigger on Trust_Cash_Receipt__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Trust_Cash_Receipt__c.SObjectType);
}