/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Reserved_WarehousesTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Reserved_WarehousesTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Reserved_Warehouses__c());
    }
}