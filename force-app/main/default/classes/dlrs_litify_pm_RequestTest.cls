/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_litify_pm_RequestTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_litify_pm_RequestTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new litify_pm__Request__c());
    }
}