public with sharing class ProductItem {
     
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