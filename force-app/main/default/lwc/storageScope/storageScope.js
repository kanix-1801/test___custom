/**
 * Created by hadar.berman on 09/12/2021.
 */

 import { LightningElement, track, api, wire } from 'lwc';
 
 import PRODUCT_STORAGE_FIELD from '@salesforce/schema/Product_in_Opportunity__c.Storage_Product_For_Dev_Only__c';
 import PRODUCT_DELIVERY_FIELD from '@salesforce/schema/Product_in_Opportunity__c.Transport_Product_For_Dev_Only__c';
 import NUMERATOR_FIELD from '@salesforce/schema/Opportunity.Storage_Scope_Dev_Numerator2__c';
 import ID_FIELD from '@salesforce/schema/Opportunity.Id';
 import getInitData from '@salesforce/apex/StorageScopeCtrl.getInitData';
 import getData from '@salesforce/apex/StorageScopeCtrl.getTableData'; 
 import addProduct from '@salesforce/apex/StorageScopeCtrl.addProduct';
 import validateProducts from '@salesforce/apex/StorageScopeCtrl.validateStorageProducts';
 import saveProducts from '@salesforce/apex/StorageScopeCtrl.saveProducts';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import myStyleResource from '@salesforce/resourceUrl/StorageScopeStyle';
 import { loadStyle } from 'lightning/platformResourceLoader';
 import { CloseActionScreenEvent } from 'lightning/actions';
 import { updateRecord, getRecord } from 'lightning/uiRecordApi';
 
 const columns = [
     { label: 'מק"ט', fieldName: 'prioritySKU', editable: false, cellAttributes: {class: {fieldName:'styleClassName'}} },
     { label: 'תיאור', fieldName: 'description', editable: true, cellAttributes: {class: {fieldName:'styleClassName'}} },//slds-col slds-size_3-of-12
     { label: 'כמות', fieldName: 'quantity', type: 'number', editable: true, cellAttributes: {class:{fieldName:'styleClassName'}} },
     { label: 'נפח', fieldName: 'volume', type: 'number', editable: true, cellAttributes: {class:{fieldName:'styleClassName'}}  },
     { label: 'ערך ביטוחי', fieldName: 'insuranceValue', type: 'number', editable: true, cellAttributes: {class:{fieldName:'styleClassName'}}  },
     { label: 'הובלה בלבד', fieldName: 'transportOnly', type: 'boolean', editable: true, cellAttributes: {class:{fieldName:'styleClassName'}} },
     { label: 'סה"כ נפח', fieldName: 'totalVolume', type: 'number', editable: false, cellAttributes: {class:{fieldName:'styleClassName'}} },
     { label: 'סה"כ ערך ביטוחי', fieldName: 'totalInsuranceValue', type: 'number', editable: false, cellAttributes: {class:{fieldName:'styleClassName'}} },
 ];

 const deliveryColumns = [
    { label: 'מק"ט', fieldName: 'prioritySKU', editable: false, cellAttributes: {class: {fieldName:'styleClassName'}} },
    { label: 'תיאור', fieldName: 'description', editable: true, cellAttributes: {class: {fieldName:'styleClassName'}} },   
    { label: 'כמות', fieldName: 'quantity', type: 'number', editable: true, cellAttributes: {class:{fieldName:'styleClassName'}} },    
    { label: 'מחיר כולל מע"מ', fieldName: 'price', type: 'number', editable: true, cellAttributes: {class:{fieldName:'styleClassName'}} },
    { label: 'סה"כ מחיר כולל מע"מ', fieldName: 'totalPrice', type: 'number', editable: false, cellAttributes: {class:{fieldName:'styleClassName'}} },
];

 const OPPORTUNITY_FIELDS = [
    'Opportunity.Ask_User_To_Verify_Insurance__c',
    'Opportunity.Storage_Scope_Dev_Numerator2__c',
 ];
 
 export default class StorageScope extends LightningElement {
 
     @api recordId;
     @api oppRecordId = '0060900000GNBxcAAH';     
     productStorageField = PRODUCT_STORAGE_FIELD;
     productDeliveryField = PRODUCT_DELIVERY_FIELD;
     @track openSelectContentList = false;
     @track openTableSection = false;
     @track openTransportSection = false;     
     @track openModalAddProduct = false;
     @track addStorageProduct = false;
     @track addDeliveryProduct = false;
     @track openModalExit = false;
     //@track openModalSave = false;
     @track openModalSaveValidation=false;
     toUpdateNum2 = false;
     selectedContentListId = '';
     @track productIdToAdd;
 
     selectedStorageList;
     selectedDeliveryList;
     storageList = [];
     deliveryList = [];
 
     @track data = [];
     columns = columns;
     rowOffset = 0;
     draftValues = [];
     totalVolume = 0;
     totalInsuranceValue = 0;
     totalQuantity = 0;

     @track deliveryData = [];
     deliveryColumns = deliveryColumns;     
     deliveryDraftValues = [];
     totalPrice = 0;
     totalDeliveryQuantity = 0;

     @track styleButtonNO = 'slds-button slds-button_neutral';
     @track styleButtonYes = 'slds-button slds-button_neutral';
     @track openLoading = false;

     @wire(getRecord, { recordId: '$recordId', fields: OPPORTUNITY_FIELDS })
     opportunityRecord;

     connectedCallback() {
         loadStyle(this, myStyleResource);
         console.log('connected===============');
         console.log('this.recordId: ' + this.recordId);

         setTimeout(() => {            
            this.getInitData();
        }, 5);
 
     }
 
     renderedCallback() {
        console.log('rendered....');
        console.log('this.recordId: ' + this.recordId);
     }

     handleEnter(event){
         console.log('handleEnter');
        if(event.keyCode === 13){
            console.log('keyCode 13');
            this.handleAddItem();
        }
      }

     getInitData(){
        console.log('getInitData this.recordId: ' + this.recordId);
        if(this.recordId){
            //get init data:
            getInitData({oppId : this.recordId})
            .then((response) => {
                if (response.isSuccess) {
                    this.storageList = response.storageContentList;                     
                    this.deliveryList = response.deliveryContentList;
                    if(response.existStorageList){
                        this.selectedStorageList = response.existStorageList;
                    }
                    if(response.existDeliveryList){
                    this.selectedDeliveryList = response.existDeliveryList;
                    }
                    this.openSelectContentList = true;                     
                } else {
                this.showToast('Process failed', response.errorMsg, 'error');
                }
            })
            .catch((error) => {
                console.log("getInitData error");
                this.showToast('Process failed', error.body.message, 'error');
            });

        }

     }
 
     updateSelectedStorage(event){
         this.selectedStorageList = event.detail.value;         
     }

     updateSelectedDelivery(event){
        this.selectedDeliveryList = event.detail.value;        
    }
 
     afterOppUpdated(event){
         console.log('this.selectedStorageList: '+this.selectedStorageList);  
         console.log('this.selectedDeliveryList: '+this.selectedDeliveryList);  
         if(!this.selectedStorageList || !this.selectedDeliveryList){
            this.showToast('לא ניתן להמשיך', 'חובה לבחור רשימות תכולה', 'error');
            return false;
         }
         
         //get table data:
         getData({oppId : this.recordId, storageContentListId : this.selectedStorageList, deliveryContentListId : this.selectedDeliveryList})
             .then((response) => {
                 if (response.isSuccess) {
                     this.data = response.productItemList;
                     this.updateTotalFields();
                     this.openSelectContentList = false;
                     this.openTableSection = true;
                 } else {
                   this.showToast('Process failed', response.errorMsg, 'error');
                 }
             })
             .catch((error) => {
                 console.log("getTableData error");
                 this.showToast('Process failed', error.body.message, 'error');
         });
     }
 
     showToast(title, message, variant){
         var theMode = variant === 'error'? 'sticky' : 'dismissible';         
         const evt = new ShowToastEvent({
             title: title,
             message: message,
             variant: variant, //info (default), success, warning or error.
             mode: theMode
         });
         this.dispatchEvent(evt);
     }
 
     handleChange(event){
         let draftChange = event.detail.draftValues[0];
         console.log('draftChange : '+ JSON.stringify(draftChange));
         var updatedFieldName;
         var newValue;
         for(var name in draftChange) {
             console.log('label : '+ JSON.stringify(name));
             updatedFieldName = name;
             newValue = draftChange[name];
             console.log('newValue : '+ newValue);
            if(name != 'index'){
                break;
            }
         }
 
        var i = Number(draftChange.index);
        if(i || i==0){
             console.log('i : '+ i);
         }else{
             console.log('i : '+ i);
             i = draftChange.index.substring(4, 5);
             console.log('i : '+ i);
         }
 
         if(updatedFieldName === 'transportOnly'){
             this.data[i].transportOnly = newValue;
         }
         if(updatedFieldName === 'description'){
             this.data[i].description = newValue;
         }else{
             if(updatedFieldName === 'volume'){
                 this.data[i].volume = newValue;
                 this.data[i].totalVolume = newValue * this.data[i].quantity;
             }
             if(updatedFieldName === 'insuranceValue'){
                 this.data[i].insuranceValue = newValue;
                 this.data[i].totalInsuranceValue = newValue * this.data[i].quantity;
             }
             if(updatedFieldName === 'quantity'){
                 if(newValue == ""){
                     newValue = 0;
                 }
                 if(newValue > 0){
                     this.data[i].styleClassName = 'line-with-quantity';
                 }else{
                     this.data[i].styleClassName = 'line-without-quantity';
                 }
                 this.data[i].quantity = newValue;
                 this.data[i].totalVolume = newValue * this.data[i].volume;
                 this.data[i].totalInsuranceValue = newValue * this.data[i].insuranceValue;
             }
 
             this.updateTotalFields();
         }
     }

     handleDeliveryChange(event){
        let draftChange = event.detail.draftValues[0];
        console.log('draftChange : '+ JSON.stringify(draftChange));
        var updatedFieldName;
        var newValue;
        for(var name in draftChange) {
            console.log('label : '+ JSON.stringify(name));
            updatedFieldName = name;
            newValue = draftChange[name];
            console.log('newValue : '+ newValue);
            if(name != 'index'){
               break;
            }
        }        
        var i = Number(draftChange.index);

        if(i || i==0){
            console.log('i : '+ i);
        }else{
            i = draftChange.index.substring(4, 5);
        }
        
        if(updatedFieldName === 'description'){
            this.deliveryData[i].description = newValue;
        }else{
            if(updatedFieldName === 'price'){
                this.deliveryData[i].price = newValue;
                this.deliveryData[i].totalPrice = newValue * this.deliveryData[i].quantity;
            }            
            if(updatedFieldName === 'quantity'){
                if(newValue == ""){
                    newValue = 0;
                }
                if(newValue > 0){
                    this.deliveryData[i].styleClassName = 'line-with-quantity';
                }else{
                    this.deliveryData[i].styleClassName = 'line-without-quantity';
                }
                this.deliveryData[i].quantity = newValue;
                this.deliveryData[i].totalPrice = newValue * this.deliveryData[i].price;
            }            
            this.updateDeliveryTotalFields();
        }
     }
 
 
     updateTotalFields(){
         var totalVolume = 0;
         var totalInsuranceValue = 0;
         var totalQuantity = 0;
         for(let i = 0; i < this.data.length; i++) {
             let product = this.data[i];
             totalVolume+= Number(product.totalVolume);
             totalInsuranceValue+= Number(product.totalInsuranceValue);
             totalQuantity+= Number(product.quantity);
         }
         this.totalVolume = Number.isInteger(totalVolume)? totalVolume : totalVolume.toFixed(2);   
         this.totalInsuranceValue = Number.isInteger(totalInsuranceValue)? totalInsuranceValue : totalInsuranceValue.toFixed(2);
         this.totalQuantity = Number.isInteger(totalQuantity)? totalQuantity : totalQuantity.toFixed(2);
     }

     updateDeliveryTotalFields(){
        var totalPrice = 0;
        var totalQuantity = 0;
        for(let i = 0; i < this.deliveryData.length; i++) {
            let product = this.deliveryData[i];
            totalPrice+= Number(product.totalPrice);            
            totalQuantity+= Number(product.quantity);
        }
        this.totalPrice = Number.isInteger(totalPrice)? totalPrice : totalPrice.toFixed(2);
        this.totalDeliveryQuantity = Number.isInteger(totalQuantity)? totalQuantity : totalQuantity.toFixed(2);        
    }
 
     addStorageItemButton(){
         this.openModalAddProduct = true; 
         this.addStorageProduct = true;
     }

     addDeliveryItemButton(){
        this.openModalAddProduct = true; 
        this.addDeliveryProduct = true;
    }
 
     closeModals(){
         this.openModalAddProduct = false;
         this.addStorageProduct = false;
         this.addDeliveryProduct = false;
         this.openModalExit = false;
         //this.openModalSave = false;
     }
 
     changeProductToAdd(event){
         this.productIdToAdd = event.detail.value[0];
     }
 
     handleAddItem(){
         console.log('handleAddItem  ' + this.productIdToAdd);
         //get productItem and push to table
         addProduct({productId : this.productIdToAdd})
             .then((response) => {
                 if (response.isSuccess) {
                     if(response.isStorage){
                        response.productItemList[0].index = Number(this.data.length);
                        //push
                        this.data = [...this.data, response.productItemList[0]];
                        this.updateTotalFields();
                     }else{
                        response.productItemList[0].index = Number(this.deliveryData.length);
                        //push
                        this.deliveryData = [...this.deliveryData, response.productItemList[0]];
                        this.updateDeliveryTotalFields();
                     }                     
                 } else {
                   this.showToast('Process failed', response.errorMsg, 'error');
                 }
             })
             .catch((error) => {
                 this.showToast('Process failed', error.body.message, 'error');
         });
 
         this.closeModals();
     }
 
     showWarningExit(){
         this.openModalExit = true;
     }
 
     handleExit(){
         this.openModalExit = false; //remove when its not a tab anymore
         this.openTableSection = false; //remove when its not a tab anymore
         this.openSelectContentList = false; //remove when its not a tab anymore
 
         this.dispatchEvent(new CloseActionScreenEvent());
     }
     
     handleContinue(){
        //send to ctrl to validate
        validateProducts({oppId : this.recordId, productListStr : JSON.stringify(this.data), deliveryContentListId : this.selectedDeliveryList})
            .then((response) => {
                if (response.isSuccess) {
                    if(response.isValid){ 
                        this.data = response.productItemList; //only valid storage products
                        this.deliveryData = response.deliveryProductItemList;                        
                        this.updateDeliveryTotalFields();                   
                        this.continueToTransportScreen();
                    }else{                                                
                        this.showToast('רגע...', response.errorMsg, 'error');
                    }
                } else {
                  this.showToast('Process failed', response.errorMsg, 'error');
                }
            })
            .catch((error) => {
                console.log('Process failed handleContinue: '+error);
                this.showToast('Process failed', '', 'error');
        });

    }

    continueToTransportScreen(){
        this.openTableSection = false;
        this.openTransportSection = true;
    }

     handleSave(){
         //this.openModalSave = false;

         if(this.opportunityRecord.data.fields.Ask_User_To_Verify_Insurance__c.value){
              this.openModalSaveValidation=true;
         }else{
             this.saveProducts();
         }
     }

     updateOpportunity(){
         const fields = {};
         fields[ID_FIELD.fieldApiName] = this.recordId;
         fields[NUMERATOR_FIELD.fieldApiName] = this.opportunityRecord.data.fields.Storage_Scope_Dev_Numerator2__c.value==null? 1 : this.opportunityRecord.data.fields.Storage_Scope_Dev_Numerator2__c.value+1;
         const recordInput = { fields };

         updateRecord(recordInput)
            .then(() => {
                console.log('Storage_Scope_Dev_Numerator2__c field updated successfully')
             })
             .catch(error => {
                 console.log('Storage_Scope_Dev_Numerator2__c field update failed')
             });
     }

     saveProducts(){
         saveProducts({oppId : this.recordId, storageProductListStr : JSON.stringify(this.data), deliveryProductListStr : JSON.stringify(this.deliveryData), toUpdateNum2 : this.toUpdateNum2})
              .then((response) => {
                  if (response.isSuccess) {
                      this.openLoading = false;
                      if(response.isValid){
                         this.showToast('הנתונים נשמרו בהצלחה', response.errorMsg, 'success');
                         this.navigateToOpportunityPage();
                      }else{
                         this.showToast('רגע...', response.errorMsg, 'error');
                      }
                  } else {
                    this.showToast('Process failed', response.errorMsg, 'error');
                  }
              })
              .catch((error) => {
                  console.log('error '+error);
                  this.showToast('Process failed', 'javaScript error occurred: '+error, 'error');
              })
              .finally(() => {
                  if(this.openModalSaveValidation){
                      this.openModalSaveValidation=false;
                  }
              });
     }
      
     navigateToOpportunityPage() {
        window.location = '/'+this.recordId;
     }

     handleClickValidationYes(){
         this.openLoading = true;
         this.toUpdateNum2 = true;
         this.saveProducts();
     }

     handleClickValidationNo(){
         this.openLoading = true;
         this.saveProducts();
     }

     handleKeyboardLeftRight(event){
         console.log('inside Keyboard onkeydown event='+event.keyCode);
         if(this.openModalSaveValidation){

             if(event.keyCode === 37){ //left
                 this.styleButtonYes = 'slds-button slds-button_neutral';
                 this.styleButtonNo = 'custom-selected-button slds-button slds-button_neutral';
             }else if(event.keyCode === 39){
                 this.styleButtonNo = 'slds-button slds-button_neutral';
                this.styleButtonYes = 'custom-selected-button slds-button slds-button_neutral';
             }else if(event.keyCode === 13){
         console.log('this.styleButtonYes='+this.styleButtonYes);

                 if(this.styleButtonYes. includes('custom-selected-button')){
                     this.handleClickValidationYes();
                 }else{
                     this.handleClickValidationNo();
                 }

             }
         }

     }
 }