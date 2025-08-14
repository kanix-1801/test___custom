/**
 * Created by chana.landau on 01/03/2022.
 */

public with sharing class PriorityObjectMapping {

    public  PriorityRESTObjects.AccountRequest accountMapping(Account accountItem) {
        PriorityRESTObjects.AccountRequest accountRequest = new PriorityRESTObjects.AccountRequest();
        accountRequest.ID = accountItem.ID__c == NULL ? '' : accountItem.ID__c ;
        accountRequest.EXTCUST = accountItem.Id == NULL ? '' : accountItem.Id ;

        if (accountItem.Priority_Customer_Code__c != null) {
            accountRequest.CUSTNAME = accountItem.Priority_Customer_Code__c ;
        }else{
            accountRequest.CUSTNAME = '';
        }

        //accountRequest.CUSTNAME = '21211' ;
        accountRequest.CUSTDES = accountItem.Name == NULL ? '' : accountItem.Name ;
        accountRequest.LOADCODE = '100';
      //  accountRequest.CUSTSTATDES = 'פעיל';
        accountRequest.PHONE1 = accountItem.Mobile__c == NULL ? '' : accountItem.Mobile__c ;
        accountRequest.PHONE2 = accountItem.Fax == NULL ? '' : accountItem.Fax ;
        accountRequest.PHONE3 = accountItem.Phone == null ? '' : accountItem.Phone;
        accountRequest.EMAIL = accountItem.Email__c == NULL ? '' : accountItem.Email__c ;
        accountRequest.ADDRESS = accountItem.ShippingStreet == NULL ? '' : accountItem.ShippingStreet ;
        accountRequest.CITY = accountItem.ShippingCity == NULL ? '' : accountItem.ShippingCity ;
        accountRequest.ZIP = accountItem.ShippingPostalCode == NULL ? '' : accountItem.ShippingPostalCode ;
        accountRequest.PRIT_CUSTSPEC_SUBFORM = createPritCustspecSubformList(accountItem.Allow_Email__c,accountItem.Receipt_Sent_By__c,accountItem.Invoice_Sent_By__c);

        accountRequest.PRIT_LOADPAY_SUBFORM = createPritLoadpaySubformList(accountItem);

        List<PriorityRESTObjects.PritInterfaceSubform> pritInterfaceSubformList = new List<PriorityRESTObjects.PritInterfaceSubform>();

        PriorityRESTObjects.PritInterfaceSubform pritInterfaceSubform = new PriorityRESTObjects.PritInterfaceSubform();
        pritInterfaceSubform.EXECUTE = 'Y';
        pritInterfaceSubformList.add(pritInterfaceSubform);
        accountRequest.PRIT_INTERFACE_SUBFORM = pritInterfaceSubformList;
        System.debug('!!!accountRequest' + accountRequest);
        return accountRequest;
    }

    public   List<PriorityRESTObjects.PritLoadpaySubform> createPritLoadpaySubformList(Account accountItem){
        List<PriorityRESTObjects.PritLoadpaySubform> pritLoadpaySubformList = new List<PriorityRESTObjects.PritLoadpaySubform>();
        PriorityRESTObjects.PritLoadpaySubform pritLoadpaySubform = new PriorityRESTObjects.PritLoadpaySubform();
        pritLoadpaySubform.PAYTYPE = String.isBlank(accountItem.Payment_Method__c) ? '9' : accountItem.Payment_Method__c ;
        pritLoadpaySubform.CCUID = accountItem.Credit_Card_Token__c == NULL ? '' : accountItem.Credit_Card_Token__c ;
        String str = accountItem.X4_Last_Digits_Of_Credit_Card__c != null ? string.valueOf(accountItem.X4_Last_Digits_Of_Credit_Card__c) : accountItem.Bank_Account_Number__c != null ? string.valueOf(accountItem.Bank_Account_Number__c) : '';
        pritLoadpaySubform.CARDNUM = str.remove(',');
        pritLoadpaySubform.CARDVALID = accountItem.Credit_Card_Expiry_Date__c == NULL ? null : accountItem.Credit_Card_Expiry_Date__c ;
        pritLoadpaySubform.PRIT_IDNUM = accountItem.Bank_Account_Owner_ID__c == NULL ? '' : accountItem.Bank_Account_Owner_ID__c ;
        pritLoadpaySubform.BANK = accountItem.Bank_Code__c == null ? '' : string.valueOf(accountItem.Bank_Code__c) ;
        pritLoadpaySubform.BANKBRANCH = accountItem.Bank_Branch_Code__c == null ? '' : string.valueOf(accountItem.Bank_Branch_Code__c) ;
        pritLoadpaySubformList.add(pritLoadpaySubform);
        return pritLoadpaySubformList;
    }

    public   List<PriorityRESTObjects.PritCustspecSubform> createPritCustspecSubformList(string allowEmail,string receiptSentBy, string invoiceSentBy) {
        List<PriorityRESTObjects.PritCustspecSubform> pritCustspecSubformList = new List<PriorityRESTObjects.PritCustspecSubform>();
        PriorityRESTObjects.PritCustspecSubform prit1 = new PriorityRESTObjects.PritCustspecSubform();
        prit1.SPECNUM = 4;
        prit1.SPECVALUE = allowEmail == NULL ? '' : allowEmail;
        pritCustspecSubformList.add(prit1);
        PriorityRESTObjects.PritCustspecSubform prit2 = new PriorityRESTObjects.PritCustspecSubform();
        prit2.SPECNUM = 3;
        prit2.SPECVALUE = receiptSentBy == NULL ? '' : receiptSentBy ;
        pritCustspecSubformList.add(prit2);
        PriorityRESTObjects.PritCustspecSubform prit3 = new PriorityRESTObjects.PritCustspecSubform();
        prit3.SPECNUM = 2;
        prit3.SPECVALUE = invoiceSentBy == NULL ? '' : invoiceSentBy ;
        pritCustspecSubformList.add(prit3);
        return pritCustspecSubformList;
    }

    public  String setAccountJsonNewOrder(PriorityRESTObjects.AccountRequest accountRequest){
        Map<String, Object> jsonObj = new Map<String, Object>();
        jsonObj.put('PRIT_INTERFACE_SUBFORM', AccountRequest.PRIT_INTERFACE_SUBFORM);
        jsonObj.put('PRIT_LOADPAY_SUBFORM', AccountRequest.PRIT_LOADPAY_SUBFORM);
        jsonObj.put('PRIT_CUSTSPEC_SUBFORM', AccountRequest.PRIT_CUSTSPEC_SUBFORM);
        jsonObj.put('ZIP', AccountRequest.ZIP);
        jsonObj.put('CITY', AccountRequest.CITY);
        jsonObj.put('ADDRESS', AccountRequest.ADDRESS);
        jsonObj.put('EMAIL', AccountRequest.EMAIL);
        jsonObj.put('PHONE3', AccountRequest.PHONE3);
        jsonObj.put('PHONE2', AccountRequest.PHONE2);
        jsonObj.put('PHONE1', AccountRequest.PHONE1);
     //   jsonObj.put('CUSTSTATDES', AccountRequest.CUSTSTATDES);
        jsonObj.put('LOADCODE', AccountRequest.LOADCODE);
        jsonObj.put('CUSTDES', AccountRequest.CUSTDES);
        jsonObj.put('CUSTNAME', AccountRequest.CUSTNAME);
        jsonObj.put('EXTCUST', AccountRequest.EXTCUST);
        jsonObj.put('ID', AccountRequest.ID);

        String jsonOutput = JSON.serialize(jsonObj,true);
        System.debug('!!!jsonOutput Account' + jsonOutput);
        return jsonOutput;
    }

    public  PriorityRESTObjects.ContactRequest contactMapping(Contact contactItem, Account accItem) {

        PriorityRESTObjects.ContactRequest contactRequest = new PriorityRESTObjects.ContactRequest();
        if (accItem != null) {
            if (accItem.Priority_Customer_Code__c != null) {
                contactRequest.CUSTNAME = accItem.Priority_Customer_Code__c ;
            }
            contactItem.AccountId = accItem.id;
            contactRequest.EXTCUST = contactItem.AccountId == NULL ? '' : contactItem.AccountId;
        }

        contactRequest.LOADCODE = '101';
        List<PriorityRESTObjects.PritCustpersonnelSubform> pritCustpersonnelSubformList = new List<PriorityRESTObjects.PritCustpersonnelSubform>();
        pritCustpersonnelSubformList.add(mapContact(contactItem));
        contactRequest.PRIT_CUSTPERSONNEL_SUBFORM = pritCustpersonnelSubformList ;

        List<PriorityRESTObjects.PritInterfaceSubform> pritInterfaceSubformList = new List<PriorityRESTObjects.PritInterfaceSubform>();

        PriorityRESTObjects.PritInterfaceSubform pritInterfaceSubform = new PriorityRESTObjects.PritInterfaceSubform();
        pritInterfaceSubform.EXECUTE = 'Y';
        pritInterfaceSubformList.add(pritInterfaceSubform);
        contactRequest.PRIT_INTERFACE_SUBFORM = pritInterfaceSubformList;

        return contactRequest;


    }

    private  PriorityRESTObjects.PritCustpersonnelSubform mapContact(Contact contactItem){
        PriorityRESTObjects.PritCustpersonnelSubform pritCustpersonnelSubform = new PriorityRESTObjects.PritCustpersonnelSubform();
        pritCustpersonnelSubform.PRIT_EXTERNALPHONE = contactItem.Id ;
        pritCustpersonnelSubform.NAME = contactItem.Name == NULL ? '' : contactItem.Name;
        pritCustpersonnelSubform.CELLPHONE = contactItem.MobilePhone == null ? '' : contactItem.MobilePhone;
        pritCustpersonnelSubform.HOMEPHONE = contactItem.ID__c == null ? '' : contactItem.ID__c;
        pritCustpersonnelSubform.EMAIL = contactItem.Email == null ? '' : contactItem.Email;
        pritCustpersonnelSubform.PRIT_ASSISTANTNAME = contactItem.Relation_to_Customer__c == null ? '' : contactItem.Relation_to_Customer__c;
        pritCustpersonnelSubform.MAINPHONE = contactItem.Account.Main_Contact__c == contactItem.Id ? 'Y' : 'N';
        pritCustpersonnelSubform.TIVFLAG = contactItem.Aging_Contact__c == true ? 'Y' : (contactItem.Aging_Contact__c == false) ? 'N' : null;
        pritCustpersonnelSubform.CIVFLAG = contactItem.Invoice_Contact__c == true ? 'Y' : contactItem.Invoice_Contact__c == false ? 'N' : null;
        pritCustpersonnelSubform.GUARANTEE = contactItem.Personal_Guaranty_Contact__c == true ? 'Y' : contactItem.Personal_Guaranty_Contact__c == false ? 'N' : null;
        pritCustpersonnelSubform.PROFESSION = contactItem.Title == null ? '' : contactItem.Title;
        String fullAddress;
        fullAddress = createAddressString( contactItem.MailingStreet,  fullAddress);
        fullAddress = createAddressString( contactItem.MailingCity,  fullAddress);
        fullAddress = createAddressString( contactItem.MailingPostalCode,  fullAddress);
        fullAddress = createAddressString( contactItem.MailingCountry,  fullAddress);
        pritCustpersonnelSubform.POSITIONDES = fullAddress == null ? '' : fullAddress;
        pritCustpersonnelSubform.STATDES = contactItem.Status__c == null ? '' : contactItem.Status__c;
        return pritCustpersonnelSubform;
    }


    private  string createAddressString(String addressItem, String fullAddress){
        if(addressItem != null && fullAddress == null){
            return  addressItem;
        }
        if(addressItem != null && fullAddress != null){
            fullAddress += ' ' + addressItem;
        }
        return fullAddress;
    }

    public  String setContactJsonNewOrder(PriorityRESTObjects.ContactRequest contactRequest){
        Map<String, Object> jsonObj = new Map<String, Object>();
        jsonObj.put('PRIT_INTERFACE_SUBFORM', contactRequest.PRIT_INTERFACE_SUBFORM);
        jsonObj.put('PRIT_CUSTPERSONNEL_SUBFORM', contactRequest.PRIT_CUSTPERSONNEL_SUBFORM);
        jsonObj.put('LOADCODE', contactRequest.LOADCODE);
        jsonObj.put('CUSTNAME', contactRequest.CUSTNAME);
        jsonObj.put('EXTCUST', contactRequest.EXTCUST);

        String jsonOutput = JSON.serialize(jsonObj,true);
        System.debug('!!!jsonOutput Contact' + jsonOutput);
        return jsonOutput;
    }

    public  PriorityRESTObjects.OrderRequest orderMapping(Order orderItem, List<Contact> contactsList) {

        PriorityRESTObjects.OrderRequest orderRequest = new PriorityRESTObjects.OrderRequest();

        orderRequest.LOADCODE = '200';
        if (orderItem.Account.Priority_Customer_Code__c != null) {
            orderRequest.CUSTNAME = orderItem.Account.Priority_Customer_Code__c;
        }
        orderRequest.EXTCUST = orderItem.Account.Id == null ? '' : orderItem.Account.Id;
        OrderRequest.ID = orderItem.Account.ID__c == NULL ? '' : orderItem.Account.ID__c ;
        OrderRequest.CUSTDES = orderItem.Account.Name == NULL ? '' : orderItem.Account.Name ;
        OrderRequest.PHONE1 = orderItem.Account.Mobile__c == NULL ? '' : orderItem.Account.Mobile__c ;
        OrderRequest.PHONE2 = orderItem.Account.Fax == NULL ? '' : orderItem.Account.Fax ;
        OrderRequest.PHONE3 = orderItem.Account.Phone == null ? '' : orderItem.Account.Phone;
        OrderRequest.EMAIL = orderItem.Account.Email__c == NULL ? '' : orderItem.Account.Email__c ;
        OrderRequest.ADDRESS = orderItem.Account.ShippingStreet == NULL ? '' : orderItem.Account.ShippingStreet ;
        OrderRequest.CITY = orderItem.Account.ShippingCity == NULL ? '' : orderItem.Account.ShippingCity ;
        OrderRequest.ZIP = orderItem.Account.ShippingPostalCode == NULL ? '' : orderItem.Account.ShippingPostalCode ;
     //   OrderRequest.CUSTSTATDES = 'פעיל';
        if(orderItem.Priority_Order_Code__c != null){
            orderRequest.UPDDOCNO = orderItem.Priority_Order_Code__c;
        }
        orderRequest.PRIT_SFORDNAME = orderItem.Id == null ? '' : orderItem.Id;
        orderRequest.PRIT_BILLFREQUENCY = orderItem.Billing_Intervals__c == null ? '' : orderItem.Billing_Intervals__c;
        orderRequest.PRIT_OYEARDISCOUNT = orderItem.Over_A_Year_Discount__c == true ? 'Y' : orderItem.Over_A_Year_Discount__c == false ? 'N' : '';
        orderRequest.PRIT_XIIMONTHFREE = orderItem.X12th_Month_Free__c == true ? 'Y' : orderItem.X12th_Month_Free__c == false ? 'N' : '';
        orderRequest.DETAILS = orderItem.Comments__c == null ? '' : orderItem.Comments__c;
        orderRequest.PRIT_DETAILS = orderItem.Additional_Details__c == null ? '' : orderItem.Additional_Details__c;
        orderRequest.PRIT_SHIPREMARK = orderItem.Warehouse_Entry_Code__c == null ? '' : orderItem.Warehouse_Entry_Code__c;
        orderRequest.PRIT_AGENTPHONE2 = orderItem.External_Agent__r.Mobile__c == null ? '' : orderItem.External_Agent__r.Mobile__c;
        orderRequest.AGENTCODE = orderItem.Priority_Agent_Code__c  == null ? '' : orderItem.Priority_Agent_Code__c;
        orderRequest.PRIT_STCODE = orderItem.Mover__r.Mobile__c == null ? '' : orderItem.Mover__r.Mobile__c;
        orderRequest.WARHSNAME = orderItem.Branch__r.Priority_Code__c == null ? '' : orderItem.Branch__r.Priority_Code__c;
        orderRequest.PDATE = orderItem.Exit_Date__c == null ? null : String.valueOf(orderItem.Exit_Date__c);
        orderRequest.TYPECODE = orderItem.Type == null ? '' : orderItem.Type;
        orderRequest.STATDES = orderItem.Status == null ? '' : orderItem.Status;
        orderRequest.DOCDATE = orderItem.EffectiveDate == null? '' : String.valueOf(orderItem.EffectiveDate);
        orderRequest.PRIT_DISCOUNTFLAG = orderItem.X50_off_every_12_month__c == true ? 'Y' : orderItem.X50_off_every_12_month__c == false ? 'N' : '';


        System.debug('contactsList ' + contactsList);
        List<PriorityRESTObjects.PritCustpersonnelSubform> pritCustpersonnelSubformList = new List<PriorityRESTObjects.PritCustpersonnelSubform>();
        if(contactsList != null) {
            for (Contact contactItem : contactsList) {
                pritCustpersonnelSubformList.add(mapContact(contactItem));
            }
        }
        orderRequest.PRIT_CUSTPERSONNEL_SUBFORM = pritCustpersonnelSubformList;


        List<PriorityRESTObjects.PritDoclineSubform> pritDoclineSubformList = new List<PriorityRESTObjects.PritDoclineSubform>();

        for (Product_in_Order__c productInOrder : orderItem.Product_in_Orders__r) {
            if (productInOrder.Product_Type__c != 'אחסנה' && productInOrder.Product_Type__c != 'כללי לא לממשק') {
                PriorityRESTObjects.PritDoclineSubform pritDoclineSubformItem = new PriorityRESTObjects.PritDoclineSubform();
                pritDoclineSubformItem.PARTNAME = productInOrder.Product__r.Priority_SKU__c == null ? '' : productInOrder.Product__r.Priority_SKU__c;
                pritDoclineSubformItem.PDES = productInOrder.Product_Description__c == null ? '' : productInOrder.Product_Description__c;
                pritDoclineSubformItem.QUANT = productInOrder.Quantity__c;
                pritDoclineSubformItem.PRICE = productInOrder.Price__c;
                pritDoclineSubformItem.PRIT_MONCHARGECONST = productInOrder.Fixed_Monthly_Price__c == true ? 'Y' : productInOrder.Fixed_Monthly_Price__c == false ? 'N' : '';
                pritDoclineSubformItem.DUEDATE = productInOrder.Start_Billing_Date__c == null ? null : String.valueOf(productInOrder.Start_Billing_Date__c);
                pritDoclineSubformItem.PRIT_BILLINGENDDATE = productInOrder.End_Billing_Date__c == null ? null : String.valueOf(productInOrder.End_Billing_Date__c);
                pritDoclineSubformItem.DISCOUNT = productInOrder.Discount_Percent__c;
                pritDoclineSubformItem.REMARK = productInOrder.Comments__c;
                pritDoclineSubformItem.PRIT_CLOSEDBOOL = productInOrder.Closed__c == true ? 'Y' : productInOrder.Closed__c == false ? 'N' : '';
                pritDoclineSubformList.add(pritDoclineSubformItem);

            }
        }
        orderRequest.PRIT_DOCLINE_SUBFORM = pritDoclineSubformList;
        for (Reserved_Warehouses__c reservedWarehouses : orderItem.Reserved_Warehouses__r) {
            if (reservedWarehouses.Reserved_Status__c != 'ביטול שיריון') {
                PriorityRESTObjects.PritDoclineSubform pritDoclineSubformItem = new PriorityRESTObjects.PritDoclineSubform();
                pritDoclineSubformItem.PARTNAME = reservedWarehouses.Warehouse__r.Priority_Code__c == null ? '' : reservedWarehouses.Warehouse__r.Priority_Code__c;
                pritDoclineSubformItem.PDES = reservedWarehouses.Description__c == null ? '' : reservedWarehouses.Description__c;
                pritDoclineSubformItem.QUANT = reservedWarehouses.Quantity__c;
                pritDoclineSubformItem.PRICE = reservedWarehouses.Price__c;
                pritDoclineSubformItem.PRIT_MONCHARGECONST = reservedWarehouses.Fixed_Monthly_Price__c == true ? 'Y' : reservedWarehouses.Fixed_Monthly_Price__c == false ? 'N' : '';
                pritDoclineSubformItem.DUEDATE = String.valueOf(reservedWarehouses.Billing_Start_Date__c);
                pritDoclineSubformItem.PRIT_BILLINGENDDATE = String.valueOf(reservedWarehouses.Billing_End_Date__c);
                pritDoclineSubformItem.DISCOUNT = reservedWarehouses.Discount_Percent__c;
                pritDoclineSubformItem.REMARK = reservedWarehouses.Comments__c;
                pritDoclineSubformList.add(pritDoclineSubformItem);
            }

        }
        orderRequest.PRIT_DOCLINE_SUBFORM = pritDoclineSubformList;
        if(orderItem.Account != null) {
            orderRequest.PRIT_CUSTSPEC_SUBFORM = createPritCustspecSubformList(orderItem.Account.Allow_Email__c, orderItem.Account.Receipt_Sent_By__c, orderItem.Account.Invoice_Sent_By__c);
            orderRequest.PRIT_LOADPAY_SUBFORM = createPritLoadpaySubformList(orderItem.Account);
        }
        List<PriorityRESTObjects.PritInterfaceSubform> pritInterfaceSubformList = new List<PriorityRESTObjects.PritInterfaceSubform>();

        PriorityRESTObjects.PritInterfaceSubform pritInterfaceSubform = new PriorityRESTObjects.PritInterfaceSubform();
        pritInterfaceSubform.EXECUTE = 'Y';
        pritInterfaceSubformList.add(pritInterfaceSubform);
        orderRequest.PRIT_INTERFACE_SUBFORM = pritInterfaceSubformList;
        System.debug('+++orderRequest' + orderRequest);
        return orderRequest;
    }

    public  String setOrderJsonNewOrder(PriorityRESTObjects.OrderRequest orderRequest){
        Map<String, Object> jsonObj = new Map<String, Object>();
        jsonObj.put('PRIT_INTERFACE_SUBFORM', orderRequest.PRIT_INTERFACE_SUBFORM);
        jsonObj.put('PRIT_LOADPAY_SUBFORM', orderRequest.PRIT_LOADPAY_SUBFORM);
        jsonObj.put('PRIT_CUSTSPEC_SUBFORM',OrderRequest.PRIT_CUSTSPEC_SUBFORM);
        jsonObj.put('PRIT_DOCLINE_SUBFORM', orderRequest.PRIT_DOCLINE_SUBFORM);
        jsonObj.put('PRIT_CUSTPERSONNEL_SUBFORM', orderRequest.PRIT_CUSTPERSONNEL_SUBFORM);
        jsonObj.put('PRIT_DISCOUNTFLAG', orderRequest.PRIT_DISCOUNTFLAG);
        jsonObj.put('STATDES', orderRequest.STATDES);
        jsonObj.put('TYPECODE', orderRequest.TYPECODE);
        jsonObj.put('AGENTCODE', orderRequest.AGENTCODE);
        jsonObj.put('PDATE', orderRequest.PDATE);
        jsonObj.put('WARHSNAME', orderRequest.WARHSNAME);
        jsonObj.put('PRIT_STCODE', orderRequest.PRIT_STCODE);
        jsonObj.put('PRIT_AGENTPHONE2', orderRequest.PRIT_AGENTPHONE2);
        jsonObj.put('PRIT_SHIPREMARK', orderRequest.PRIT_SHIPREMARK);
        jsonObj.put('PRIT_DETAILS', orderRequest.PRIT_DETAILS);
        jsonObj.put('DETAILS', orderRequest.DETAILS);
        jsonObj.put('PRIT_XIIMONTHFREE', orderRequest.PRIT_XIIMONTHFREE);
        jsonObj.put('PRIT_OYEARDISCOUNT', orderRequest.PRIT_OYEARDISCOUNT);
        jsonObj.put('PRIT_BILLFREQUENCY', orderRequest.PRIT_BILLFREQUENCY);
        jsonObj.put('PRIT_SFORDNAME', orderRequest.PRIT_SFORDNAME);
        jsonObj.put('UPDDOCNO', orderRequest.UPDDOCNO);
        jsonObj.put('ZIP', orderRequest.ZIP);
        jsonObj.put('CITY', orderRequest.CITY);
        jsonObj.put('ADDRESS', orderRequest.ADDRESS);
        jsonObj.put('EMAIL', orderRequest.EMAIL);
        jsonObj.put('PHONE3', orderRequest.PHONE3);
        jsonObj.put('PHONE2', orderRequest.PHONE2);
        jsonObj.put('PHONE1', orderRequest.PHONE1);
      //  jsonObj.put('CUSTSTATDES', orderRequest.CUSTSTATDES);
        jsonObj.put('LOADCODE', orderRequest.LOADCODE);
        jsonObj.put('CUSTDES', orderRequest.CUSTDES);
        jsonObj.put('DOCDATE', orderRequest.DOCDATE);
        jsonObj.put('CUSTNAME', orderRequest.CUSTNAME);
        jsonObj.put('EXTCUST', orderRequest.EXTCUST);
        jsonObj.put('ID', orderRequest.ID);

        String jsonOutput = JSON.serialize(jsonObj,true);
        System.debug('!!!jsonOutput order' + jsonOutput);
        return jsonOutput;
    }
}