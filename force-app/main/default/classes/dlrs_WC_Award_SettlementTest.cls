/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_WC_Award_SettlementTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_WC_Award_SettlementTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new WC_Award_Settlement__c());
    }
}