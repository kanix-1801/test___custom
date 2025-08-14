/**
 * Created by chana.landau on 16/03/2022.
 */

public with sharing class OrderHandler {

    public void calloutWhenStatusChange(Map<Id, Order> newMap, Map<Id, Order> oldMap) {
        Set<id> setOrderIds = new Set<id>();
        for (Order orderItem : newMap.values()) {
            if (orderItem.Priority_Interface_Status__c != oldMap.get(orderItem.Id).Priority_Interface_Status__c && orderItem.Priority_Interface_Status__c == 'ממתין לשידור') {
                setOrderIds.add(orderItem.Id);
            }
        }

        if (setOrderIds != null && !setOrderIds.isEmpty()) {
            if(setOrderIds.size() > 1) {
                Database.executeBatch(new UpdateOrderInPriorityBatch(setOrderIds), 20);
            }else{
                System.enqueueJob(new updatePriorityWithOrderQueueable(setOrderIds));
            }

        }
    }

    public with sharing class updatePriorityWithOrderQueueable implements Queueable, Database.AllowsCallouts {
        private Set<Id> orderIdSet ;

        public updatePriorityWithOrderQueueable(Set<id> orderIdSet) {
            this.orderIdSet = orderIdSet;
        }

        public void execute(QueueableContext context) {
            List<Order>listToSend = new List<Order>();
            listToSend = [
                    SELECT Account.Priority_Customer_Code__c,Account.Id,Priority_Order_Code__c,
                            Account.Allow_Email__c,Account.Receipt_Sent_By__c,Account.Invoice_Sent_By__c,
                            Account.Name,Account.Mobile__c,Account.Fax,Account.Phone,Account.Email__c,
                            Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,
                            Account.Main_Contact__c,Account.ID__c,Account.Payment_Method__c,
                            Account.Credit_Card_Token__c,Account.X4_Last_Digits_Of_Credit_Card__c,
                            Account.Credit_Card_Expiry_Date__c,Account.Bank_Account_Owner_ID__c,
                            Account.Bank_Code__c,Account.Bank_Branch_Code__c,Account.Bank_Account_Number__c,
                            //
                            Id,Status,Billing_Intervals__c,Over_A_Year_Discount__c,X12th_Month_Free__c,
                            Comments__c,Mover__r.Mobile__c,Type,Exit_Date__c,Additional_Details__c,
                            External_Agent__r.Mobile__c,Warehouse_Entry_Code__c,
                            Branch__r.Priority_Code__c, Priority_Agent_Code__c, X50_off_every_12_month__c, EffectiveDate,
                            //
                            //OwnerId,
                    (
                            SELECT Id,Product__r.Priority_SKU__c,Product_Description__c,Quantity__c,Price__c,Discount_Percent__c,
                                    Comments__c,Fixed_Monthly_Price__c,Start_Billing_Date__c,End_Billing_Date__c,Product_Type__c, Closed__c
                            FROM Product_in_Orders__r
                    ), (
                            SELECT Id,Warehouse__r.Priority_Code__c,Description__c,Quantity__c,Price__c,
                                    Fixed_Monthly_Price__c,Billing_Start_Date__c,Billing_End_Date__c,Discount_Percent__c,Reserved_Status__c,Comments__c
                            FROM Reserved_Warehouses__r
                    )
                    FROM Order
                    WHERE Id IN :orderIdSet
            ];
            if (listToSend != null && !listToSend.isEmpty()) {
                PriorityService serviceClass = new PriorityService();
                serviceClass.updateOrder(listToSend);
            }
        }
    }




}