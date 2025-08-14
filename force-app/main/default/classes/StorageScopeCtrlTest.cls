/**
 * Created by hadar.berman on 20/12/2021.
 */
@IsTest
public with sharing class StorageScopeCtrlTest {

    @testSetup
    static void prepareRecords(){
        Account acc= new Account();
        acc.ShippingCity = 'Hadera';
        acc.ShippingStreet = 'Oren';
        acc.Name = 'Test';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'opp test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Storage Scope';
        opp.CloseDate = System.now().date().addMonths(2);
        insert opp;

        List<Content_List__c> contList = new List<Content_List__c>();
        Content_List__c contentList1 = new Content_List__c();
        contentList1.Type__c = 'אחסנה';
        contList.add(contentList1);
        Content_List__c contentList2 = new Content_List__c();
        contentList2.Type__c = 'הובלה';
        contList.add(contentList2);
        insert contList;

        List<Product__c> productList = new List<Product__c>();
        Product__c product1 = new Product__c();
        product1.Priority_SKU__c = '12345';
        product1.Product_Type__c = 'אחסנה';
        productList.add(product1);
        Product__c product2 = new Product__c();
        product2.Priority_SKU__c = '12344';
        product2.Product_Type__c = 'אחסנה';
        productList.add(product2);
        insert productList;

        Products_in_Content_List__c productStorageCL = new Products_in_Content_List__c();
        productStorageCL.Content_List__c = contentList1.Id;
        productStorageCL.Product_c__c = product1.Id;
        //productDeliveryCL
        insert productStorageCL;

        Product_in_Opportunity__c productOpp = new Product_in_Opportunity__c();
        productOpp.Opportunity__c = opp.Id;
        productOpp.Product__c = product2.Id;
        insert productOpp;
    }



    @isTest
    static void testGetInitData(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        Test.startTest();
        StorageScopeCtrl.getInitData(oppId);
        //go to exception
        StorageScopeCtrl.getInitData(null);
        Test.stopTest();
    }

    @isTest
    static void testGetTableData(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Id contentListId = [SELECT Id FROM Content_List__c LIMIT 1].Id;

        Test.startTest();
        StorageScopeCtrl.getTableData(oppId, contentListId, contentListId);
        //go to exception
        StorageScopeCtrl.getTableData('', '', '');
        Test.stopTest();
    }

    @isTest
    static void testAddProduct(){
        Id productId = [SELECT Id FROM Product__c LIMIT 1].Id;

        Test.startTest();
        StorageScopeCtrl.addProduct(productId);
        //go to exception
        StorageScopeCtrl.addProduct('');
        Test.stopTest();
    }

    @isTest
    static void testValidateStorageProducts(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Id contentListId = [SELECT Id FROM Content_List__c WHERE Type__c = 'הובלה' LIMIT 1].Id;

        Test.startTest();
        String notValidItems = '[{"description":"מערכת מושבים פינתית","index":0,"insuranceValue":2750,"prioritySKU":"2299012","quantity":"-2","recordId":"a000900000KicEUAAZ","styleTest":"styleClass1","totalInsuranceValue":-5500,"totalVolume":-10,"volume":5},{"description":" ","index":1,"insuranceValue":2750,"prioritySKU":"2299012","quantity":1,"recordId":"a000900000KicEUAAZ","styleTest":"styleClass1","totalInsuranceValue":2750,"totalVolume":5,"volume":5},{"description":"מכונת כביסה","index":2,"insuranceValue":0,"prioritySKU":"664546","quantity":0,"recordId":"a000900000KiZduAAF","styleTest":"styleClass1","totalInsuranceValue":0,"totalVolume":0,"volume":0}]';
        StorageScopeCtrl.validateStorageProducts(oppId, notValidItems, '');

        String validItems = '[{"description":"מערכת מושבים פינתית","index":0,"insuranceValue":2750,"prioritySKU":"2299012","quantity":1,"recordId":"a000900000KicEUAAZ","styleTest":"styleClass1","totalInsuranceValue":-5500,"totalVolume":-10,"transportOnly":true,"volume":5}]';
        StorageScopeCtrl.validateStorageProducts(oppId, validItems, contentListId);

        //go to exception
        StorageScopeCtrl.validateStorageProducts(oppId, validItems, '');
        Test.stopTest();
    }

    @isTest
    static void testSaveProducts(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        Test.startTest();
        String notValidItems = '[{"description":"מערכת מושבים פינתית","index":0,"insuranceValue":2750,"prioritySKU":"2299012","quantity":"-2","recordId":"a000900000KicEUAAZ","styleTest":"styleClass1","totalInsuranceValue":-5500,"totalVolume":-10,"volume":5},{"description":" ","index":1,"insuranceValue":2750,"prioritySKU":"2299012","quantity":1,"recordId":"a000900000KicEUAAZ","styleTest":"styleClass1","totalInsuranceValue":2750,"totalVolume":5,"volume":5},{"description":"מכונת כביסה","index":2,"insuranceValue":0,"prioritySKU":"664546","quantity":0,"recordId":"a000900000KiZduAAF","styleTest":"styleClass1","totalInsuranceValue":0,"totalVolume":0,"volume":0}]';
        StorageScopeCtrl.saveProducts(oppId, notValidItems, notValidItems, true);

        String validItems = '[{"description":"מערכת מושבים פינתית","index":0,"insuranceValue":2750,"prioritySKU":"2299012","quantity":1,"recordId":"a000900000KicEUAAZ","styleTest":"styleClass1","totalInsuranceValue":-5500,"totalVolume":-10,"transportOnly":true,"volume":5}]';
        StorageScopeCtrl.saveProducts(oppId, validItems, validItems, true);

        //go to exception
        StorageScopeCtrl.saveProducts(oppId, '', '', false);
        Test.stopTest();
    }



}