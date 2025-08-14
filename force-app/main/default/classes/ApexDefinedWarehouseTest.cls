@isTest
private class ApexDefinedWarehouseTest {

    @isTest
    static void testParameterizedConstructor() {
        // --- 1. Prepare Test Data ---
        Date testDate = Date.today();
        Decimal testDecimal = 150.75;
        String testString = 'Test Value';

        // --- 2. Call the Constructor to create an instance of the class ---
        Test.startTest();
        ApexDefinedWarehouse warehouse = new ApexDefinedWarehouse(
            testDate.addDays(30),                          // Billing_End_Date
            testDate,                                      // Billing_Start_Date
            true,                                          // Current_Date_In_Reservation_Range
            'Test Customer',                               // Customer
            'Test Description',                            // Description
            10.5,                                          // Discount_Percent
            false,                                         // Fixed_Monthly_Price
            true,                                          // Future_Reserved
            '006xxxxxxxxxxxxxxx',                          // Opportunity
            '801xxxxxxxxxxxxxxx',                          // Orders
            false,                                         // Order_Without_End_Date
            testDecimal,                                   // Price
            testDate.addDays(60),                          // Reservation_End_Date
            testDate.addDays(1),                           // Reservation_Start_Date
            'Reserved',                                    // Reserved_Status
            5000,                                          // Total_Line_Sum
            5850,                                          // Total_Line_Sum_Plus_VAT
            'Test Warehouse',                              // Warehouse
            30.0,                                          // Warehouse_Volume_m3
            'Main Branch',                                 // Branch
            'Warehouse A-101',                             // Name
            'HIGH',                                        // Priority_Code
            25.5,                                          // Volume_m3
            '10x2.55x1m',                                  // Dimensions
            '24/7 Access',                                 // Accessibility
            'Building A',                                  // Building
            'West Wing',                                   // Wing
            'Door 3',                                      // Door
            'Test Price List',                             // Warehouse_Price_List
            testDate.addDays(90),                          // ExitDate
            'temp12345'                                    // tempId
        );
        Test.stopTest();

        // --- 3. Assert and Verify ---
        System.assertNotEquals(null, warehouse, 'The warehouse object should not be null.');
        System.assertEquals(testDate, warehouse.Billing_Start_Date, 'Billing_Start_Date was not set correctly.');
        System.assertEquals('Test Customer', warehouse.Customer, 'Customer was not set correctly.');
        System.assertEquals(testDecimal, warehouse.Price, 'Price was not set correctly.');
        System.assertEquals(true, warehouse.Future_Reserved, 'Future_Reserved was not set correctly.');
        System.assertEquals('temp12345', warehouse.tempId, 'tempId was not set correctly.');
        
        System.assertEquals(null, warehouse.Quantity, 'Quantity should be null initially as it is not in the constructor.');
        warehouse.Quantity = 50;
        System.assertEquals(50, warehouse.Quantity, 'Quantity should be updatable.');
    }

    @isTest
    static void testNoArgumentConstructor() {
        // --- 1. Call the no-argument constructor ---
        Test.startTest();
        ApexDefinedWarehouse warehouse = new ApexDefinedWarehouse();
        Test.stopTest();

        // --- 2. Assert and Verify ---
        System.assertNotEquals(null, warehouse, 'The warehouse object should not be null.');
        
        // Verify its properties are null/default.
        System.assertEquals(null, warehouse.Customer, 'Customer should be null for a new object.');
        System.assertEquals(null, warehouse.Price, 'Price should be null for a new object.');
        
        // **CORRECTED** Boolean properties in a class initialize to null, not false.
        System.assertEquals(null, warehouse.Fixed_Monthly_Price, 'Boolean properties should be null upon initialization.');
    }
}