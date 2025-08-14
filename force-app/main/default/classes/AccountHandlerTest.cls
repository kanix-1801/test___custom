/**
 * Created by chana.landau on 03/03/2022.
 */

@IsTest
private class AccountHandlerTest {
    @IsTest
    static void testBehavior() {

        Contact con = new Contact(LastName = 'hhh',MobilePhone='856');
        insert con;


        Account account1 = new Account(name = 'YYY',Mobile__c = '876',Main_Contact__c =con.Id);
        account1.Priority_Interface_Status__c = 'לא קיים' ;
        account1.Payment_Method__c = '1';
        insert account1;
        account1.Priority_Interface_Status__c = 'ממתין לשידור' ;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());



        Test.startTest();
        update account1;
        Test.stopTest();

    }
}