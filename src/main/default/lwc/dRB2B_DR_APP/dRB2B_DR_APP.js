/**
 * @description       :
 * @author            : Devanshu Sood
 * @group             :
 * @last modified on  : 04-12-2021
 * @last modified by  : Arun Sood
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-05-2021   Devanshu Sood   Initial Version
 **/
 import { LightningElement, track } from "lwc";
 import getTabsAndConfiguration from "@salesforce/apex/DRB2B_AppConfigController.getTabsAndConfiguration";
 import updateBulkMetadata from "@salesforce/apex/DRB2B_AppConfigController.updateBulkMetadata";
 import syncProducts from "@salesforce/apex/DRB2B_AppConfigController.syncProducts";
 import checkConnection from "@salesforce/apex/DRB2B_AppConfigController.checkConnection";
 import { ShowToastEvent } from "lightning/platformShowToastEvent";
 import USER_ID from "@salesforce/user/Id";
 // Import custom labels
 import configSaveError from "@salesforce/label/c.DR_Config_Save_Failure";
 import configSaveSucess from "@salesforce/label/c.DR_Config_Save_Success";
 import testConnection from "@salesforce/label/c.DR_Test_Connection";
 import DR_Save from "@salesforce/label/c.DR_Save";
 import Sync_Products from "@salesforce/label/c.Sync_Products";
 import DR_ReSync_All from "@salesforce/label/c.DR_ReSync_All";
 import ConnectionSuccess from "@salesforce/label/c.DR_Connection_Success";
 import ConnectionError from "@salesforce/label/c.DR_Connection_Error";
 import DR_Re_Sync_Btn_Title from "@salesforce/label/c.DR_Re_Sync_Product_Btn_Title";
 import DR_Sync_Btn_Title from "@salesforce/label/c.DR_Sync_Product_Btn_Title";
 const INVALID_TOKEN = "INVALID TOKEN";
 export default class DRB2B_DR_APP extends LightningElement {
     isLoading = false;
     @track configData = [];
     updatedConfigData = {};
     initilized = false;
     isProductTabActive = false;
     disableButton = false;
     isRendered = false;
     label = {
         configSaveError,
         configSaveSucess,
         testConnection,
         DR_Save,
         Sync_Products,
         DR_ReSync_All,
         ConnectionSuccess,
         ConnectionError,
         DR_Re_Sync_Btn_Title,
         DR_Sync_Btn_Title
     };
     connectedCallback() {
         if (this.initilized) return;
         this.isLoading = true;
         this.initilized = true;
         this.getTabsAndConfigrationJS();
     }
 
     renderedCallback() {
         this.clearApiKeyField();
         if (this.isRendered) return;
         this.isRendered = true;
     }
 
     //get all tabs and config
     getTabsAndConfigrationJS() {
         getTabsAndConfiguration()
             .then((result) => {
                 let configData = JSON.parse(result);
                 for (let key in configData) {
                     this.configData.push({ value: configData[key], key: key });
                 }
                 this.configData.reverse();
             })
             .catch((error) => {
                 console.log(error);
             })
             .finally(() => (this.isLoading = false));
     }
 
     handleGenricChange(event) {
         this.updatedConfigData[event.currentTarget.dataset.id] = event.currentTarget.value;
         if (this.isProductTabActive) {
             this.disableButton = true;
         }
     }
 
     handleSave() {
         updateBulkMetadata({ jsonString: JSON.stringify(this.updatedConfigData) })
             .then((result) => {
                 if (result) this.clearApiKeyField();
                 this.disableButton = false;
                 this.showToast({ message: this.label.configSaveSucess, variant: "success" });
             })
             .catch((error) => {
                 console.log(error);
             });
     }
 
     clearApiKeyField() {
         let allInputs = this.template.querySelectorAll("lightning-input");
         for (let ele of allInputs) {
             if (["DR Secret Key", "DR Public Key"].includes(ele.label)) ele.value = "";
         }
     }
 
     //common method to show toast
     showToast(obj) {
         const event = new ShowToastEvent(obj);
         this.dispatchEvent(event);
     }
 
     tabChangeHandler(event) {
         if (event.target.value.includes("Product")) {
             this.isProductTabActive = true;
         } else {
             this.isProductTabActive = false;
         }
     }
 
     handleProductSyncAll(event) {
         let syncall = event.target.dataset.syncall;
         let syncproduct = event.target.dataset.syncproduct;
 
         syncProducts({ jsonString: JSON.stringify({ isSyncAll: syncall, isSyncProduct: syncproduct }) })
             .then((result) => {
                 let resultData = JSON.parse(result);
                 if (resultData.isSuccess) {
                     this.showToast({ message: resultData.msg, variant: "success" });
                 } else {
                     this.showToast({ message: resultData.msg, variant: "error" });
                 }
             })
             .catch((error) => {
                 console.log(error);
             });
     }
 
     handleTestConnection() {
         this.isLoading = true;
         checkConnection({ userid: USER_ID })
             .then((result) => {
                 this.isLoading = true;
                 let response = JSON.parse(result);
                 if (response.errors[0].message == INVALID_TOKEN) {
                     this.showToast({ message: this.label.ConnectionError, variant: "error" });
                 } else {
                     this.showToast({ message: this.label.ConnectionSuccess, variant: "success" });
                 }
             })
             .catch((error) => {
                 console.log("error:", error);
                 this.showToast({ message: this.label.ConnectionError, variant: "error" });
             })
             .finally(() => (this.isLoading = false));
     }
    @track selectFromConfigOptions= 
          [
             { label: 'Default', value: 'None' },
             { label: 'Order Level Scope', value: 'Order-level' },
             { label: 'Item Level Scope', value: 'Item-level' },
         ];
 }