/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Warehouses_In_QuoteTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Warehouses_In_QuoteTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Warehouses_In_Quote__c());
    }
}