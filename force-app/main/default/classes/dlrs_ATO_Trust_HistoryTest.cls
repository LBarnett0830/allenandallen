/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_ATO_Trust_HistoryTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_ATO_Trust_HistoryTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new ATO_Trust_History__c());
    }
}