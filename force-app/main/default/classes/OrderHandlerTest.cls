/**
 * Created by chana.landau on 20/03/2022.
 */

@IsTest
private class OrderHandlerTest {
    @IsTest
    static void updatePriorityWithOrderQueueableTest() {

        Account account = new Account(name = 'YYY',Mobile__c = '876');
        insert account;

        /*
        Contact contact = new Contact(LastName = 'hhh',MobilePhone='856',AccountId = account.Id);
        contact.Priority_Interface_Status__c = 'לא קיים' ;
        insert contact;*/

        Order order = new Order();
        order.AccountId = account.Id;
        order.EffectiveDate = Date.today();
        order.Status = 'בהמתנה לחיוב';
        order.Priority_Interface_Status__c ='לא קיים' ;
        order.Exit_Date__c = Date.today();
        insert order;
        order.Priority_Interface_Status__c = 'ממתין לשידור' ;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());



        Test.startTest();
        update order;
        Test.stopTest();

    }
    
     @IsTest
    static void UpdateOrderInPriorityBatchTest() {

        List<Order> orderList = new List<Order>();
        Account account = new Account(name = 'YYY',Mobile__c = '876');
        insert account;

        /*
        Contact contact = new Contact(LastName = 'hhh',MobilePhone='856',AccountId = account.Id);
        contact.Priority_Interface_Status__c = 'לא קיים' ;
        insert contact;*/

        for(integer i=0; i<=1; i++){
            Order order = new Order();
            order.AccountId = account.Id;
            order.EffectiveDate = Date.today();
            order.Status = 'בהמתנה לחיוב';
            order.Priority_Interface_Status__c ='לא קיים' ;
            order.Exit_Date__c = Date.today();        
            orderList.add(order);
        }
        
        insert orderList;
        for(Order orderItem : orderList){
        	orderItem.Priority_Interface_Status__c = 'ממתין לשידור' ;
        }
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());



        Test.startTest();
        update orderList;
        Test.stopTest();

    }
}