/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Trust_Cash_ReceiptTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Trust_Cash_ReceiptTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Trust_Cash_Receipt__c());
    }
}