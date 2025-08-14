/**
 * Created by chana.landau on 03/03/2022.
 */

public with sharing class AccountHandler {

    @future(callout=true)

    public static void futureMethod(Set<id> setIdAccount) {
        List<Account>listToSend = new List<Account>();
        listToSend = [SELECT ID__c,Id,Priority_Customer_Code__c,Name,Mobile__c,
                Fax,Email__c,Phone,ShippingStreet,ShippingCity,ShippingPostalCode,Allow_Email__c,
                Receipt_Sent_By__c,Invoice_Sent_By__c,Payment_Method__c,Credit_Card_Token__c,
                X4_Last_Digits_Of_Credit_Card__c,Credit_Card_Expiry_Date__c,Bank_Code__c,Bank_Branch_Code__c,
                Bank_Account_Number__c,Bank_Account_Owner_ID__c
        FROM Account WHERE id IN :setIdAccount];
        if (listToSend != null && !listToSend.isEmpty()) {
            PriorityService serviceClass = new PriorityService();
            System.debug('before send to PriorityService');
            serviceClass.updateAccount(listToSend);
        }

    }


    //updateAccountInPriority
    public void calloutWhenStatusChange(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        Set<id> setIdAccount = new Set<id>();
        for (Account accountItem : newMap.values()) {
            if (accountItem.Priority_Interface_Status__c != oldMap.get(accountItem.Id).Priority_Interface_Status__c && accountItem.Priority_Interface_Status__c == 'ממתין לשידור') {
                setIdAccount.add(accountItem.Id);
            }
        }
        if (setIdAccount != null && !setIdAccount.isEmpty()) {
            futureMethod(setIdAccount);
        }
    }


}