/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AcctSeed_Account_Payable_LineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AcctSeed_Account_Payable_a1mTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new AcctSeed__Account_Payable_Line__c());
    }
}