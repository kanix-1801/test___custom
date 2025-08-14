/**
 * Created by chana.landau on 06/03/2022.
 */

@IsTest
private class PriorityServiceTest {

    
    @IsTest
    static void accountTest() {
        Contact con = new Contact(LastName = 'hhh',MobilePhone='856');
        insert con;
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(name = 'YYY',Mobile__c = '876',Main_Contact__c =con.Id));
        insert accounts;
        PriorityHttpCalloutMock mock = new PriorityHttpCalloutMock('PRIT_LOADDOC');
        Test.setMock(HttpCalloutMock.class, mock);
        PriorityService serviceClass = new PriorityService();
        Test.startTest();
        serviceClass.updateAccount(accounts);
        Test.stopTest();
    }

    @IsTest
    static void contactTest() {
        
		Account ac = new Account(name = 'YYY',Mobile__c = '876');
        insert ac;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'gggg',MobilePhone='8666',AccountId = ac.Id));
        insert contacts;
        PriorityHttpCalloutMock mock = new PriorityHttpCalloutMock('PRIT_LOADDOC');
        Test.setMock(HttpCalloutMock.class, mock);
        PriorityService serviceClass = new PriorityService();
        Test.startTest();
        serviceClass.updateContact(contacts);
        Test.stopTest();
    }

    @IsTest
    static void orderTest() {
        Account ac = new Account(name = 'YYY',Mobile__c = '876');
        insert ac;
        Order ord = new Order();
        ord.AccountId = ac.Id;
        ord.EffectiveDate = Date.today();
        ord.Status = 'בהמתנה לחיוב';
        ord.Exit_Date__c = Date.today();
        List<Order> orders = new List<Order>();
        orders.add(ord);
        insert orders;
        PriorityHttpCalloutMock mock = new PriorityHttpCalloutMock('PRIT_LOADDOC');
        Test.setMock(HttpCalloutMock.class, mock);
        PriorityService serviceClass = new PriorityService();
        Test.startTest();
        serviceClass.updateOrder(orders);
        Test.stopTest();
    }
}