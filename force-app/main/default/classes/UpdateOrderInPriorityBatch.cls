/**
 * Created by shira.hai on 25/09/2022.
 */

global with sharing class UpdateOrderInPriorityBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    public Set<Id> setOrderIds = new Set<Id>();

    global UpdateOrderInPriorityBatch(Set<id> setOrderIds){
        this.setOrderIds = setOrderIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Account.Priority_Customer_Code__c,Account.Id,Priority_Order_Code__c,
        Account.Allow_Email__c,Account.Receipt_Sent_By__c,Account.Invoice_Sent_By__c,
        Account.Name,Account.Mobile__c,Account.Fax,Account.Phone,Account.Email__c,
        Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,
        Account.Main_Contact__c,Account.ID__c,Account.Payment_Method__c,
        Account.Credit_Card_Token__c,Account.X4_Last_Digits_Of_Credit_Card__c,
        Account.Credit_Card_Expiry_Date__c,Account.Bank_Account_Owner_ID__c,
        Account.Bank_Code__c,Account.Bank_Branch_Code__c,Account.Bank_Account_Number__c,
        Id,Status,Billing_Intervals__c,Over_A_Year_Discount__c,X12th_Month_Free__c,
        Comments__c,Mover__r.Mobile__c,Type,Exit_Date__c,Additional_Details__c,
        External_Agent__r.Mobile__c,Warehouse_Entry_Code__c,
        Branch__r.Priority_Code__c, Priority_Agent_Code__c, X50_off_every_12_month__c,EffectiveDate,
        (
        SELECT Id,Product__r.Priority_SKU__c,Product_Description__c,Quantity__c,Price__c,Discount_Percent__c,
        Comments__c,Fixed_Monthly_Price__c,Start_Billing_Date__c,End_Billing_Date__c,Product_Type__c,Closed__c
        FROM Product_in_Orders__r
        ), (
        SELECT Id,Warehouse__r.Priority_Code__c,Description__c,Quantity__c,Price__c,
        Fixed_Monthly_Price__c,Billing_Start_Date__c,Billing_End_Date__c,Discount_Percent__c,Reserved_Status__c,Comments__c
        FROM Reserved_Warehouses__r
        )
        FROM Order
        WHERE Id IN :setOrderIds]);
    }

    global void execute(Database.BatchableContext BC, List<Order> scope){
        System.debug('scope= '+scope);

        if(!Test.isRunningTest() && !scope.isEmpty()) {
            system.debug(LoggingLevel.DEBUG,'### scope : '+scope);
            PriorityService serviceClass = new PriorityService();
            serviceClass.updateOrder(scope);
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}