/**
 * Created by chana.landau on 01/03/2022.
 */

public with sharing class PriorityService {

    public PriorityObjectMapping mappingClass = new PriorityObjectMapping();

    public  void updateAccount(List<Account> accountList) {
        if (accountList != null && !accountList.isEmpty()) {
            system.debug('@@@accountList' + accountList);
            PriorityRESTObjects.AccountRequest request = mappingClass.accountMapping(accountList[0]);
            String jsonRequest = mappingClass.setAccountJsonNewOrder(request);
            PriorityRESTObjects.UpdateResponse res = new PriorityRESTObjects.UpdateResponse();
            res = PriorityRESTService.updateAccount(jsonRequest);
            system.debug('@@@account res' + res);
            Interface_Log_Table__c logTable = new Interface_Log_Table__c();
            logTable.Run_Time__c = Datetime.now();
            logTable.Account__c = request.EXTCUST;
            logTable.Request_Message__c = jsonRequest;
            logTable.Post_Message__c = res.toString();
            logTable.Line__c = res.LINE;
            if (res.SUCCESS == 'Y') {
                system.debug('@@@@@@success' + logTable);
                accountList[0] = updateAccountPriorityData(accountList[0], res.CUSTNAME, 'מעודכן');
                logTable.Result__c = 'Success';
                logTable.External_ID__c = res.ID;
            } else {
                system.debug('@@@@@@faillll' + logTable);
                accountList[0] = updateAccountPriorityData(accountList[0], res.CUSTNAME, 'ריצה אחרונה הסתיימה בשגיאה');
                logTable.Result__c = 'Error';
                logTable.Error_Message__c = 'קריאת HTTP נכשלה';
                //logTable.Error_Details__c = res.errorMassage;
            }
            System.debug('@@@logTable' + logTable);
            update accountList;
            insert logTable;


        }

    }

    public  void updateContact(List<Contact> contactList) {
        Set<Id> accIdSet = new Set<Id>();
        if (contactList != null && !contactList.isEmpty()) {
            for (Contact contactItem : contactList) {
                accIdSet.add(contactItem.AccountId);
            }
            List<Account> accountList = [SELECT Id,Priority_Customer_Code__c,Main_Contact__c FROM Account WHERE Id in:accIdSet];
              //update accountList;
            PriorityRESTObjects.ContactRequest conRequest = mappingClass.contactMapping(contactList[0], accountList[0]);
            String jsonContact = mappingClass.setContactJsonNewOrder(conRequest);
            PriorityRESTObjects.UpdateResponse res = new PriorityRESTObjects.UpdateResponse();

            res = PriorityRESTService.updateContact(jsonContact);
            system.debug('@@@Contact res' + res);
            Interface_Log_Table__c logTableCon = new Interface_Log_Table__c();
            logTableCon.Run_Time__c = Datetime.now();
            logTableCon.Contact__c = contactList[0].id ;
            logTableCon.Request_Message__c = jsonContact;
            logTableCon.Post_Message__c = res.toString();
            logTableCon.Line__c = res.LINE;
            contactList[0].Priority_Interface_Datetime__c = Datetime.now();
            if (res.SUCCESS == 'Y') {
                system.debug('@@@@@@success' + logTableCon);
                contactList[0].Priority_Interface_Status__c = 'מעודכן';
                logTableCon.Result__c = 'Success';
                logTableCon.External_ID__c = res.ID;
            } else {
                system.debug('@@@@@@faillll' + logTableCon);
                contactList[0].Priority_Interface_Status__c = 'ריצה אחרונה הסתיימה בשגיאה';
                logTableCon.Result__c = 'Error';
                logTableCon.Error_Message__c = 'קריאת HTTP נכשלה';
                //logTableCon.Error_Details__c = res.errorMassage;
            }
            System.debug('@@@logTableCon' + logTableCon);
            update contactList;
            insert logTableCon;
        }


    }

    public  void updateOrder(List<Order>orderList) {
        system.debug('orderList= '+orderList);
        set<Id> orderIdSet = new Set<Id>();
        Map<Id,List<Contact>> contactIdToContactListMap = new Map<Id,List<Contact>>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        if (orderList != null && !orderList.isEmpty()) {
            for(Order orderItem : orderList){
                orderIdSet.add(orderItem.AccountId);
            }
            List<Contact> contactsSqlList = [SELECT AccountId,Name,Account.Main_Contact__c,Account.Priority_Customer_Code__c,
                                            MobilePhone,ID__c,Email,Relation_to_Customer__c,Aging_Contact__c,Invoice_Contact__c,MailingAddress
                                            ,MailingCity ,MailingCountry,MailingGeocodeAccuracy ,MailingLatitude ,MailingLongitude
                                            ,MailingPostalCode ,MailingState,MailingStreet,
                                            Personal_Guaranty_Contact__c,Title,Status__c, Priority_Contact_ID__c
                                            FROM Contact WHERE AccountId in: orderIdSet];

            for(Contact contactItem : contactsSqlList){
                if (!contactIdToContactListMap.containsKey(contactItem.AccountId)){
                    contactIdToContactListMap.put(contactItem.AccountId, new List<Contact>());
                }contactIdToContactListMap.get(contactItem.AccountId).add(contactItem);
            }
            List<PriorityRESTObjects.OrderRequest> requestList = new List<PriorityRESTObjects.OrderRequest>();
            List<Interface_Log_Table__c> orderLogList = new List<Interface_Log_Table__c>();
            for(Order orderItem : orderList) {
                List<Contact> contactList = contactIdToContactListMap.get(orderItem.AccountId);
                PriorityRESTObjects.OrderRequest request = mappingClass.orderMapping(orderItem,  contactList);
                String jsonRequest = mappingClass.setOrderJsonNewOrder(request);
                PriorityRESTObjects.UpdateResponse res = new PriorityRESTObjects.UpdateResponse();
                res = PriorityRESTService.updateOrder(jsonRequest);
                system.debug('@@@Order res' + res);
                Interface_Log_Table__c orderLogTable = new Interface_Log_Table__c();
                orderLogTable.Run_Time__c = Datetime.now();
                orderLogTable.Order__c = request.PRIT_SFORDNAME;
                orderLogTable.Request_Message__c = jsonRequest;
                orderLogTable.Post_Message__c = res.toString();
                orderLogTable.Line__c = res.LINE;
                orderItem.Priority_Interface_Datetime__c = Datetime.now();
                if (res.SUCCESS == 'Y') {
                    system.debug('@@@@@@success' + orderLogTable);
                    orderItem.Priority_Interface_Status__c = 'מעודכן';
                    orderItem.Priority_Order_Code__c = res.ORDNAME2 != null ? res.ORDNAME2 : orderItem.Priority_Order_Code__c;
                    orderLogTable.Result__c = 'Success';
                    orderLogTable.External_ID__c = res.ID;
                    orderItem.Account = updateAccountPriorityData(orderItem.Account, res.CUSTNAME, 'מעודכן');
                    contactList = updateContactPriorityData(contactList, 'מעודכן');
                } else if (res.SUCCESS == '20') {
                    orderItem.Account = orderItem.Account = updateAccountPriorityData(orderItem.Account, res.CUSTNAME, 'מעודכן');
                    contactList = updateContactPriorityData(contactList, 'מעודכן');
                    orderItem.Priority_Interface_Status__c = 'ריצה אחרונה הסתיימה בשגיאה';
                    orderLogTable.Result__c = 'Error';
                    orderLogTable.Error_Message__c = 'קריאת HTTP נכשלה';
                } else if (res.SUCCESS == '10') {
                    orderItem.Account = updateAccountPriorityData(orderItem.Account, null, 'ריצה אחרונה הסתיימה בשגיאה');
                    contactList = updateContactPriorityData(contactList, 'ריצה אחרונה הסתיימה בשגיאה');
                    orderItem.Priority_Interface_Status__c = 'ריצה אחרונה הסתיימה בשגיאה';
                    orderLogTable.Result__c = 'Error';
                    orderLogTable.Error_Message__c = 'קריאת HTTP נכשלה';
                } else {
                    system.debug('@@@@@@faillll' + orderLogTable);
                    orderItem.Account = updateAccountPriorityData(orderItem.Account, null, 'ריצה אחרונה הסתיימה בשגיאה');
                    contactList = updateContactPriorityData(contactList, 'ריצה אחרונה הסתיימה בשגיאה');
                    orderItem.Priority_Interface_Status__c = 'ריצה אחרונה הסתיימה בשגיאה';
                    orderLogTable.Result__c = 'Error';
                    orderLogTable.Error_Message__c = 'קריאת HTTP נכשלה';
                }
                System.debug('@@@logTable' + orderLogTable);
                if(orderItem.Account != null){
                    accountMap.put(orderItem.AccountId,orderItem.Account);
                }
                orderLogList.add(orderLogTable);
            }
            update orderList;
            update accountMap.values();
            update contactsSqlList;
            insert orderLogList;
        }
    }

    private  Account updateAccountPriorityData(Account accItem, string CUSTNAME, string status){
        if(accItem != null){
            if((String.isEmpty(accItem.Priority_Customer_Code__c) || accItem.Priority_Customer_Code__c != accItem.ID__c) && status == 'מעודכן' && CUSTNAME != null){
                accItem.Priority_Customer_Code__c  =  CUSTNAME ;
            }
            accItem.Priority_Interface_Datetime__c = Datetime.now() ;
            accItem.Priority_Interface_Status__c = status;
        }
        return accItem;
    }

    private  List<Contact>  updateContactPriorityData(List<Contact> conList, string status){
        if(conList != null) {
            for (Contact conItem : conList) {
                conItem.Priority_Interface_Datetime__c = Datetime.now() ;
                conItem.Priority_Interface_Status__c = status;
            }
        }
        return conList;
    }

    private  Interface_Log_Table__c cerateLog(String jsonRequest){
        Interface_Log_Table__c logTable= new Interface_Log_Table__c();
        return logTable;
    }


}