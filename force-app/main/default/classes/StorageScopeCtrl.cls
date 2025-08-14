/**
 * Created by hadar.berman on 09/12/2021.
 */

public with sharing class StorageScopeCtrl {


    @AuraEnabled
    public static ResponseObj getInitData(String oppId){
        ResponseObj resObj = new ResponseObj();
        List<ContentList> storageList = new List<ContentList>();
        List<ContentList> deliveryList = new List<ContentList>();
        StorageScopeCtrl ctrl = new StorageScopeCtrl();

        try{
            resObj.isSuccess = true;
            List<Content_List__c> contentList = ctrl.soqlContentList();
            Opportunity oppItem = ctrl.soqlOpportunity(oppId);

            for(Content_List__c item : contentList){
                ContentList obj = new ContentList();
                obj.label = item.Name;
                obj.value = item.Id;
                if(item.Type__c == 'אחסנה'){
                    storageList.add(obj);
                }else if(item.Type__c == 'הובלה'){
                    deliveryList.add(obj);
                }
            }

            resObj.storageContentList = storageList;
            resObj.deliveryContentList = deliveryList;
            resObj.existStorageList = oppItem.Content_List__c != null? oppItem.Content_List__c : null;
            resObj.existDeliveryList = oppItem.Transport_Content_List__c != null? oppItem.Transport_Content_List__c : null;

        }catch(Exception e){
            System.debug('getInitData failed: '+e.getMessage() + ': ' + e.getStackTraceString());
            resObj.isSuccess = false;
            resObj.errorMsg = 'getInitData failed: ' + e.getMessage();
        }

        System.debug('getInitData: '+ resObj);
        return resObj;
    }

    @AuraEnabled
    public static ResponseObj getTableData(String oppId, String storageContentListId, String deliveryContentListId){
        ResponseObj resObj = new ResponseObj();
        List<ProductItem> itemList = new List<ProductItem>();
        StorageScopeCtrl ctrl = new StorageScopeCtrl();
        Set<String> priorityIdSet = new Set<String>();

        try{
            System.debug('storageContentListId: '+storageContentListId + ' deliveryContentListId: '+ deliveryContentListId);
            ctrl.updateOpportunity(oppId, storageContentListId, deliveryContentListId);
            List<Product_in_Opportunity__c> productInOppList = ctrl.soqlProductInOpportunity(oppId, 'אחסנה');
            List<Products_in_Content_List__c> productInContentList = ctrl.soqlProductInContentList(storageContentListId);

            ctrl.convertProductInOppList(productInOppList, priorityIdSet , itemList);
            ctrl.convertProductInContentList(productInContentList, priorityIdSet , itemList);
            ctrl.populateIndex(itemList);

            resObj.isSuccess = true;
            resObj.productItemList = itemList;

        }catch (Exception e){
            System.debug('getTableData failed: '+e.getMessage() + ': ' + e.getStackTraceString());
            resObj.isSuccess = false;
            resObj.errorMsg = 'getTableData failed: ' + e.getMessage() + ': ' + e.getStackTraceString();
        }

        return resObj;
    }

    @AuraEnabled
    public static ResponseObj addProduct(String productId){

        ResponseObj resObj = new ResponseObj();
        List<ProductItem> itemList = new List<ProductItem>();
        StorageScopeCtrl ctrl = new StorageScopeCtrl();

        try{
            Product__c productObj = [SELECT Id, Product_Type__c, Priority_SKU__c, Product_Description__c, Base_Volume__c, Base_Price__c, Price_With_VAT__c FROM Product__c WHERE Id =: productId];
            itemList.add(ctrl.convertProductToProductItem(productObj));

            resObj.isStorage = productObj.Product_Type__c == 'אחסנה'? true : false;
            resObj.isSuccess = true;
            resObj.productItemList = itemList;

        }catch (Exception e){
            System.debug('CTRL.addProduct failed: '+e.getMessage() + ': ' + e.getStackTraceString());
            resObj.isSuccess = false;
            resObj.errorMsg = 'addProduct failed: ' + e.getMessage();
            resObj.errorMsg = e.getMessage();
        }

        return resObj;
    }

    @AuraEnabled
    public static ResponseObj validateStorageProducts(String oppId, String productListStr, String deliveryContentListId){
        ResponseObj resObj = new ResponseObj();
        List<ProductItem> validStorageItemList = new List<ProductItem>();
        List<ProductItem> notValidItemList = new List<ProductItem>();
        List<ProductItem> deliveryItemList = new List<ProductItem>();
        Set<String> priorityIdSet = new Set<String>();
        StorageScopeCtrl ctrl = new StorageScopeCtrl();

        try{
            resObj.isSuccess = true;
            List<ProductItem> productList = (List<ProductItem>) JSON.deserialize(productListStr, List<ProductItem>.class);
            Boolean isValid = ctrl.validateProducts(productList, validStorageItemList , notValidItemList);

            if(isValid){
                //get data of delivery products:
                List<Product_in_Opportunity__c> productInOppList = ctrl.soqlProductInOpportunity(oppId, 'הובלה%');
                List<Products_in_Content_List__c> productInContentList = ctrl.soqlProductInContentList(deliveryContentListId);
                ctrl.convertProductInOppList(productInOppList, priorityIdSet , deliveryItemList);
                ctrl.convertProductInContentList(productInContentList, priorityIdSet , deliveryItemList);
                ctrl.populateIndex(deliveryItemList);

                resObj.isValid = true;
                resObj.productItemList = validStorageItemList;
                resObj.deliveryProductItemList = deliveryItemList;
            }else{ //not valid
                resObj.isValid = false;
                resObj.errorMsg = ctrl.getErrorDescription(notValidItemList);
            }

        }catch (Exception e){
            System.debug('CTRL.validateStorageProducts failed: '+e.getMessage() + ': ' + e.getStackTraceString());
            resObj.isSuccess = false;
            resObj.errorMsg = resObj.errorMsg = 'validateStorageProducts failed: ' + e.getMessage();
        }

        return resObj;
    }

    @AuraEnabled
    public static ResponseObj saveProducts(String oppId, String storageProductListStr, String deliveryProductListStr, Boolean toUpdateNum2){
        ResponseObj resObj = new ResponseObj();
        List<ProductItem> validItemList = new List<ProductItem>();
        List<ProductItem> notValidItemList = new List<ProductItem>();
        StorageScopeCtrl ctrl = new StorageScopeCtrl();

        try{
            resObj.isSuccess = true;
            List<ProductItem> storageProductList = (List<ProductItem>) JSON.deserialize(storageProductListStr, List<ProductItem>.class);
            List<ProductItem> deliveryProductList = (List<ProductItem>) JSON.deserialize(deliveryProductListStr, List<ProductItem>.class);
            Boolean isValid = ctrl.validateProducts(deliveryProductList, validItemList, notValidItemList);

            if(isValid){
                resObj.isValid = true;
                validItemList.addAll(storageProductList);
                ctrl.deleteExistProducts(oppId);
                ctrl.convertAndInsertProducts(oppId, validItemList);
                ctrl.soqlAndUpdateOpp(oppId, toUpdateNum2);
            }else{ //not valid
                resObj.isValid = false;
                resObj.errorMsg = ctrl.getErrorDescription(notValidItemList);
            }

        }catch (Exception e){
            System.debug('CTRL.saveProducts failed: '+e.getMessage() + ': ' + e.getStackTraceString());
            resObj.isSuccess = false;
            resObj.errorMsg = resObj.errorMsg = 'saveProducts failed: ' + e.getMessage();
        }

        return resObj;
    }





    private List<Content_List__c> soqlContentList(){
        return [SELECT Name, Id, Type__c
                FROM Content_List__c
                WHERE Active__c = TRUE];
    }

    private Opportunity soqlOpportunity(Id oppId){
        return [SELECT Id, Content_List__c, Transport_Content_List__c
                FROM Opportunity
                WHERE Id =: oppId];
    }

    private List<Product_in_Opportunity__c> soqlProductInOpportunity(Id oppId, String productType){
        List<Product_in_Opportunity__c> productInOppList = [SELECT Id, Name, Product_Description__c, Product__c, Product__r.Priority_SKU__c, Volume_m3__c, Opportunity__c,
                                                                    Insurance_Value_Of_Product__c, Quantity__c, Transport_Only__c, Unit_Price_With_Vat__c, Product_Type__c
                                                            FROM Product_in_Opportunity__c
                                                            WHERE Opportunity__c =: oppId
                                                            AND Product_Type__c LIKE: productType];

        return productInOppList;
    }

    private List<Products_in_Content_List__c> soqlProductInContentList(Id contentListId){
        List<Products_in_Content_List__c> productInContentList = [SELECT Id, Content_List__c, Product_c__c, Product_c__r.Priority_SKU__c, Product_c__r.Product_Type__c, Product_c__r.Product_Description__c,
                                                                        Product_c__r.Base_Volume__c, Product_c__r.Base_Price__c, Product_c__r.Price_With_VAT__c, Sort_Display__c
                                                                  FROM Products_in_Content_List__c
                                                                  WHERE Content_List__c =: contentListId
                                                                  ORDER BY Sort_Display__c];

        return productInContentList;
    }

    private void updateOpportunity(String oppId, String storageContentListId, String deliveryContentListId){
        if(storageContentListId != null || deliveryContentListId != null){
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.Content_List__c = storageContentListId;
            opp.Transport_Content_List__c = deliveryContentListId;
            update opp;
        }

    }

    private void convertProductInOppList(List<Product_in_Opportunity__c> productInOppList, Set<String> priorityIdSet, List<ProductItem> itemList){
        for(Product_in_Opportunity__c productInOppJunction : productInOppList){
            itemList.add(convertProductInOppToProductItem(productInOppJunction));
            priorityIdSet.add(productInOppJunction.Product__c);
        }
    }

    private void convertProductInContentList(List<Products_in_Content_List__c> productInContentList, Set<String> priorityIdSet , List<ProductItem> itemList){
        for(Products_in_Content_List__c productInContentListJunction : productInContentList){
            //filter the duplicate items (by Priority_SKU) from productInContentList:
            if(!priorityIdSet.contains(productInContentListJunction.Product_c__c)){
                itemList.add(convertProductInContentToProductItem(productInContentListJunction));
            }
        }
    }

    private ProductItem convertProductInOppToProductItem(Product_in_Opportunity__c productJunction){
        ProductItem item = new ProductItem();
        item.recordId = productJunction.Product__c;
        item.prioritySKU = productJunction.Product__r.Priority_SKU__c;
        item.productType = productJunction.Product_Type__c == 'אחסנה'? 'Storage' : 'Delivery';
        item.description = productJunction.Product_Description__c;
        item.volume = productJunction.Volume_m3__c != null? productJunction.Volume_m3__c : 0;
        item.insuranceValue = productJunction.Insurance_Value_Of_Product__c != null? productJunction.Insurance_Value_Of_Product__c : 0;
        item.quantity = productJunction.Quantity__c != null? productJunction.Quantity__c : 0;
        item.transportOnly = productJunction.Transport_Only__c;
        item.totalVolume = item.volume * item.quantity;
        item.totalInsuranceValue = item.insuranceValue * item.quantity;
        item.styleClassName = item.quantity > 0 ? 'line-with-quantity' : 'line-without-quantity';

        if(item.productType != 'Storage'){
            item.price = productJunction.Unit_Price_With_Vat__c != null? productJunction.Unit_Price_With_Vat__c : 0;
            item.totalPrice = item.price * item.quantity;
        }

        return item;
    }

    private ProductItem convertProductInContentToProductItem(Products_in_Content_List__c productJunction){
        ProductItem item = new ProductItem();
        item.recordId = productJunction.Product_c__c;
        item.prioritySKU = productJunction.Product_c__r.Priority_SKU__c;
        item.productType = productJunction.Product_c__r.Product_Type__c == 'אחסנה'? 'Storage' : 'Delivery';
        item.description = productJunction.Product_c__r.Product_Description__c;
        item.volume = productJunction.Product_c__r.Base_Volume__c != null? productJunction.Product_c__r.Base_Volume__c : 0;
        item.insuranceValue = productJunction.Product_c__r.Base_Price__c != null? productJunction.Product_c__r.Base_Price__c : 0;
        item.quantity = 0;
        item.transportOnly = false;
        item.totalVolume = 0;
        item.totalInsuranceValue = 0;
        item.styleClassName = 'line-without-quantity';

        if(item.productType != 'Storage'){
            item.price = productJunction.Product_c__r.Price_With_VAT__c != null? productJunction.Product_c__r.Price_With_VAT__c : 0;
            item.totalPrice = item.price * item.quantity;
        }

        return item;
    }

    private ProductItem convertProductToProductItem(Product__c productObj){
        ProductItem item = new ProductItem();
        item.recordId = productObj.Id;
        item.prioritySKU = productObj.Priority_SKU__c;
        item.productType = productObj.Product_Type__c == 'אחסנה'? 'Storage' : 'Delivery';
        item.description = productObj.Product_Description__c;
        item.volume = productObj.Base_Volume__c != null? productObj.Base_Volume__c : 0;
        item.insuranceValue = productObj.Base_Price__c != null? productObj.Base_Price__c : 0;
        item.quantity = 1;
        item.transportOnly = false;
        item.totalVolume = item.volume * item.quantity;
        item.totalInsuranceValue = item.insuranceValue * item.quantity;
        item.styleClassName = 'line-with-quantity';

        if(item.productType != 'Storage'){
            item.price = productObj.Price_With_VAT__c != null? productObj.Price_With_VAT__c : 0;
            item.totalPrice = item.price * item.quantity;
        }

        return item;
    }

    private void populateIndex(List<ProductItem> itemList){
        Integer i = 0;
        for(ProductItem item : itemList){
            item.index = i;
            i++;
        }
    }

    private Boolean validateProducts(List<ProductItem> productList, List<ProductItem> validItemList, List<ProductItem> notValidItemList){
        Boolean isValid = true;

        for(ProductItem item : productList){
            if(item.quantity > 0){
                if(String.isBlank(item.description)){ //not valid
                    item.notValidMsg = getValidationMessage('חסר  תיאור', item);
                    notValidItemList.add(item);
                    isValid = false;
                }else { //valid item
                    validItemList.add(item);
                }
            }else if(item.quantity < 0){ //not valid
                item.notValidMsg = getValidationMessage('כמות קטנה מ-0', item);
                notValidItemList.add(item);
                isValid = false;
            }
        }

        return isValid;
    }

    private String getValidationMessage(String errorDescription, ProductItem item){
        String errorMsg = 'בשורה ';
        Integer i = item.index + 1;
        errorMsg += i;
        errorMsg += ': ';
        errorMsg += errorDescription;

        return errorMsg;
    }

    private void deleteExistProducts(String oppId){
        List<Product_in_Opportunity__c> existProductInOppList = soqlProductInOpportunity(oppId, 'אחסנה');
        existProductInOppList.addAll(soqlProductInOpportunity(oppId, 'הובלה%'));
        delete existProductInOppList;
    }

    private void convertAndInsertProducts(String oppId, List<ProductItem> validItemList){
        List<Product_in_Opportunity__c> productInOppList = new List<Product_in_Opportunity__c>();

        for(ProductItem item : validItemList){
            productInOppList.add(convertObjToProductInOpp(oppId, item));
        }

        insert productInOppList;
    }

    private Product_in_Opportunity__c convertObjToProductInOpp(String oppId, ProductItem item){
        Product_in_Opportunity__c productObj = new Product_in_Opportunity__c();

        productObj.Product__c = item.recordId;
        productObj.Opportunity__c = oppId;
        productObj.Product_Description__c = item.description;
        productObj.Volume_m3__c = item.volume;
        productObj.Quantity__c = item.quantity;
        productObj.Created_By_Dev__c = true;

        if(item.productType == 'Storage'){
            productObj.Insurance_Value_Of_Product__c = item.insuranceValue;
            productObj.Transport_Only__c = item.transportOnly;
        }else{
            productObj.Unit_Price_With_Vat__c = item.price;
        }

        System.debug('productObj: '+productObj);
        return productObj;
    }

    private void soqlAndUpdateOpp(Id oppId, Boolean toUpdateNum2){
        Opportunity opp = [SELECT Id, Storage_Scope_Dev_Numerator__c, Storage_Scope_Dev_Numerator2__c FROM Opportunity WHERE Id =: oppId];
        opp.Storage_Scope_Dev_Numerator__c = opp.Storage_Scope_Dev_Numerator__c == null? 1 : opp.Storage_Scope_Dev_Numerator__c + 1;
        if(toUpdateNum2)
		    opp.Storage_Scope_Dev_Numerator2__c = opp.Storage_Scope_Dev_Numerator2__c == null? 1 : opp.Storage_Scope_Dev_Numerator2__c + 1;
        update opp;
    }

    private String getErrorDescription(List<ProductItem> notValidItemList){
        String errorMsg = '';
        for(ProductItem item : notValidItemList){
            errorMsg += item.notValidMsg + '\n';
        }

        return errorMsg;
    }


    public class ResponseObj{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public Boolean isStorage;
        @AuraEnabled public String errorMsg;
        @AuraEnabled public List<ProductItem> productItemList;
        @AuraEnabled public List<ProductItem> deliveryProductItemList;
        @AuraEnabled public List<ContentList> storageContentList;
        @AuraEnabled public List<ContentList> deliveryContentList;
        @AuraEnabled public String existStorageList;
        @AuraEnabled public String existDeliveryList;
    }

    public class ProductItem{
        @AuraEnabled public Integer index;
        @AuraEnabled public String recordId;
        @AuraEnabled public String productType;
        @AuraEnabled public String prioritySKU;
        @AuraEnabled public String description;
        @AuraEnabled public Decimal volume;
        @AuraEnabled public Decimal insuranceValue;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Boolean transportOnly;
        @AuraEnabled public Decimal totalVolume;
        @AuraEnabled public Decimal totalInsuranceValue;
        @AuraEnabled public String notValidMsg;
        @AuraEnabled public String styleClassName;

        @AuraEnabled public Decimal price;
        @AuraEnabled public Decimal totalPrice;

    }

    public class ContentList{
        @AuraEnabled public String label; //name of content list
        @AuraEnabled public String value; //id of content list
    }









}