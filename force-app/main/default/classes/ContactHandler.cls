/**
 * Created by chana.landau on 06/03/2022.
 */

public with sharing class ContactHandler {

    @Future(Callout=true)
    public static void futureMethod(Set<id> setIdContact) {
        List<Contact>listToSend = new List<Contact>();
        //
        listToSend = [SELECT AccountId,Name,Account.Main_Contact__c,Account.Priority_Customer_Code__c,
                MobilePhone,ID__c,Email,Relation_to_Customer__c,Aging_Contact__c,Invoice_Contact__c,MailingAddress
                ,MailingCity
                ,MailingCountry
                ,MailingGeocodeAccuracy
                ,MailingLatitude
                ,MailingLongitude
                ,MailingPostalCode
                ,MailingState
                ,MailingStreet,
                Personal_Guaranty_Contact__c,Title,Status__c, Priority_Contact_ID__c
        		FROM Contact WHERE id IN :setIdContact];
        if (listToSend != null && !listToSend.isEmpty()) {
            PriorityService serviceClass = new PriorityService();
            serviceClass.updateContact(listToSend);
        }
    }

    public void calloutWhenStatusChange(Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {

        Set<id> setIdContact = new Set<id>();

        for (Contact contactItem : newMap.values()) {
            if (contactItem.Priority_Interface_Status__c != oldMap.get(contactItem.Id).Priority_Interface_Status__c && contactItem.Priority_Interface_Status__c == 'ממתין לשידור') {
                setIdContact.add(contactItem.Id);
            }
        }
        if (setIdContact != null && !setIdContact.isEmpty()) {
            futureMethod(setIdContact);
        }

    }

}