/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_litify_pm_Matter_Team_MemberTrigger on litify_pm__Matter_Team_Member__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(litify_pm__Matter_Team_Member__c.SObjectType);
}