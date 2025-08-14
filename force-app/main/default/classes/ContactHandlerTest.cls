/**
 * Created by chana.landau on 07/03/2022.
 */

@IsTest
private class ContactHandlerTest {
    @IsTest
    static void testBehavior() {

        Account account = new Account(name = 'YYY',Mobile__c = '876');
        insert account;

        Contact contact = new Contact(LastName = 'hhh',MobilePhone='856',AccountId = account.Id);
        contact.Priority_Interface_Status__c = 'לא קיים' ;
        insert contact;
        contact.Priority_Interface_Status__c = 'ממתין לשידור' ;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());


        Test.startTest();
        update contact;
        Test.stopTest();

    }
}