/**
 * Created by shira.hai on 29/09/2022.
 */
@IsTest
public with sharing class UpdateOrderInPriorityBatchTest {

    static testMethod void excuteTest(){

        Set<Id> orderIdSet = new Set<Id>();
        List<Order> orderList = new List<Order>();
        Account account = new Account(name = 'YYY',Mobile__c = '876');
        insert account;


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
            orderIdSet.add(orderItem.Id);
        }

        update orderList;

        Test.startTest();
        Database.executeBatch(new UpdateOrderInPriorityBatch(orderIdSet), 20);
        Test.stopTest();
    }
}