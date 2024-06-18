import { LightningElement, api, track, wire } from "lwc";
import getTaxIds from "@salesforce/apex/DRB2B_MyTaxIdentifierController.getTaxIdentifier";
import applyTaxIdenifier from "@salesforce/apex/DRB2B_MyTaxIdentifierController.applyTaxIdenifier";
//updated by Abhishek[Cybage]
import updateDRRemainingField from "@salesforce/apex/DRB2B_MyTaxIdentifierController.updateDRRemainingField";
import saveTaxId from "@salesforce/apex/DRB2B_MyTaxIdentifierController.saveTaxIdentifier";
import getCart from "@salesforce/apex/DRB2B_MyTaxIdentifierController.getCart";
import TAX_ID_FIELD from "@salesforce/schema/Webcart.DR_Tax_Identifiers__c";
import CART_ID_FIELD from "@salesforce/schema/Webcart.Id";
import updateCart from "@salesforce/apex/DRB2B_BuyerInfoController.updateCart";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import {publish, subscribe, MessageContext,unsubscribe } from 'lightning/messageService';
import { registerListener, unregisterAllListeners } from "c/pubsub";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getNamespacePrefix } from "c/commons";
import communityPath from "@salesforce/community/basePath";
import addError from "@salesforce/label/c.DR_TaxId_Add_Error_Msg";
import newTaxId from "@salesforce/label/c.DR_New_Tax_ID_Label";
import taxIdentifier from "@salesforce/label/c.DR_Tax_Identifiers";
import savedTaxId from "@salesforce/label/c.DR_Saved_TaxId";
import otherTaxId from "@salesforce/label/c.DR_Other_TaxId";
import applyTaxId from "@salesforce/label/c.DR_Apply_TaxId";
import applySucessError from "@salesforce/label/c.DR_TaxId_Apply_Error";
import applySuccessMsg from "@salesforce/label/c.DR_TaxId_Apply_Success";
import alreadySavedValidation from "@salesforce/label/c.DR_Already_Saved_validation";
import removedTaxIdSuccess from "@salesforce/label/c.DR_Removed_TaxId";
import allRemovedSuccess from "@salesforce/label/c.DR_All_TaxID_Removed_Success";
import close from "@salesforce/label/c.DR_Close_Label";
import { fireEvent } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";
import communityId from "@salesforce/community/Id";
import  dr_lms from '@salesforce/messageChannel/DigitalRiverMessageChannel__c';

export default class Drb2b_taxIdentifier extends LightningElement {
    @track taxData = [];
    @api selectedTax;
    isInitilized = false;
    isRendered = false;
    @api webcartId;
    value = [];
    savedAndSelectedTaxidValues = [];
    showModal = false;
    selectedTaxIds = [];
    @track pillData = [];
    cart;
    removedPill;
    taxSize = 0;
    isLoading = true;
    addedTaxId = [];
    selectedSavedTaxIds = [];
    createPill = false;
    appliedOnce = false;
    _selectedTax = {};
    @api autoInitialize;
    showTIComponent = true;
    showTermsComponent;

    label = {
        addError,
        newTaxId,
        taxIdentifier,
        savedTaxId,
        otherTaxId,
        applyTaxId,
        applySucessError,
        applySuccessMsg,
        close,
        alreadySavedValidation,
        removedTaxIdSuccess,
        allRemovedSuccess
    };

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        if (this.isInitilized) return;
        this.isInitilized = true;
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);
        this.subscribeToMessageChannel();
        // this.getCartInfo();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                dr_lms,
                (message) => this.showTaxIdentifierComponent(message),
            );
        }
    }

    showTaxIdentifierComponent(message){
        switch (message.purpose) {
            case "toggleShowTIComponent":
                this.toggleShowTIComponent(message.payload);
                break;
        }
    }

    toggleShowTIComponent(data){
        let dataobj = JSON.parse(data);
        this.showTermsComponent = dataobj?.isShow; //dataobj; 
        this.autoInitialize = dataobj?.isShow;
    }

    get showTaxIDComponent() {
        return this.showTermsComponent && this.autoInitilize;
    }

    callResponseHandler(msg) {
        var url = window.location.protocol + "//" + window.location.hostname;
        if (msg.origin != url) {
            return false;
        }
        let component = this;
        component.handleVFResponse(msg.data);
    }


    
    disconnectedCallback() {
        window.removeEventListener("message", this._listenForMessage);
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    renderedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
        if (this.selectedTax) {
            let selectedTax = JSON.parse(this.selectedTax);
            if ("taxId" in selectedTax) this.value = selectedTax.taxId;
            if ("pill" in selectedTax) this.pillData = selectedTax.pill;
        }
    }

    @wire(CurrentPageReference)
    pageRef;

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        switch (msg.event) {
            case "taxidCheckout":
                this.isLoading = true;
                this.initilizeSave(msg.obj);
                break;
            case "notApplicableCheckout":
                console.log("not applicable");
                this.isLoading = false;
                break;
            case "hideLoader":
                this.showTaxSection();
                break;
        }
    }

    showTaxSection() {
        this.hideLoader();
        this.getTaxIds();
    }
    hideLoader() {
        this.template.querySelector(".taxidentifier").classList.remove("slds-hide");
    }
    initilizeSave(evt) {
        this.taxSize = Object.keys(evt).length;
        for (let taxid in evt) {
            let ajaxTaxID = {
                type: evt[taxid].type,
                value: evt[taxid].value
            };
            this.saveTaxIdentifier(ajaxTaxID);
        }
    }

    saveTaxIdentifier(data) {
        this.pillData = [];
        this.addedTaxId = [];
        saveTaxId({ jsonString: JSON.stringify(data), cartId: this.webcartId })
            .then((result) => {
                let response = JSON.parse(result);
                if (response.errors) {
                    this.showToast({ message: response.errors[0].message, variant: "error" });
                    this.isLoading = false;
                } else {
                    this.createPill = true;
                    this.addedTaxId.push(response.id);
                    if (this.addedTaxId.length != this.taxSize) return;
                    this.appyTaxIdToCheckout(this.addedTaxId);
                    this.value = [];
                }
            })
            .catch((error) => {
                this.showToast({ message: this.label.addError + ":" + data.value, variant: "error" });
                console.log(error);
            });
        // .finally(() => {
        //     this.isLoading = false;
        // });
    }

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath.slice(0, communityPath.lastIndexOf("/s"));
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    getCartInfo() {
        getCart({ cartId: this.webcartId })
            .then((result) => {
                this.cart = result;
                this.fireEventLWC();
                // this.getTaxIds();
            })
            .catch((error) => {
                console.log("error" + error);
            });
    }

    getTaxIds() {
        getTaxIds()
            .then((result) => {
                if (result) {
                    let taxIds = JSON.parse(result).taxIdentifiers;
                    if (taxIds) this.reformData(taxIds);
                }
            })
            .catch((error) => {
                console.log(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    reformData(data) {
        this.savedAndSelectedTaxidValues = data.map((ele) => ele.value);
        this.taxData = data.map((ele) => ({ ...ele, label: ele.value, value: ele.id }));
    }

    handleSelectTaxId(event) {
        //console.log('event.detail.value '+event.detail.value);
        this.selectedSavedTaxIds = event.detail.value;
        if(this.selectedSavedTaxIds==''|| this.selectedSavedTaxIds==undefined)
        {
            this.isLoading = true;
            this.appliedOnce = true;
            this.appyTaxIdToCheckout(this.selectedSavedTaxIds);
        }
    
    }

    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }

    handleApplyTaxIdentifier() {
        this.isLoading = true;
        this.appliedOnce = true;
        this.appyTaxIdToCheckout(this.selectedSavedTaxIds);
    }

    async appyTaxIdToCheckout(data) {
        this.pillData = [];
        await applyTaxIdenifier({ checkoutId: this.cart.drcheckoutId, taxIds: data, cartId: this.webcartId })
            .then((result) => {
                let response = JSON.parse(result);
                if (response.errors) {
                    this.showToast({
                        message: this.label.applySucessError,
                        variant: "error"
                    });
                    this.isLoading = false;
                    this.removedPill = null;
                    this.createPill = false;
                } else {
                    this.updateDRRemainingFieldJs(response);}
                   
            })
            .catch((error) => {
                this.showToast({ message: JSON.stringify(error), variant: "error" });
            });
           
    }

    updateTaxIdCart(data) {
        const fields = {};
        fields[CART_ID_FIELD.fieldApiName] = this.webcartId;
        fields[TAX_ID_FIELD.fieldApiName] = data;
        updateCart({ cart: JSON.stringify(fields) })
            .then((result) => {
               
            })
            .catch((error) => {
                this.showToast({ message: JSON.stringify(error), variant: "error" });
            });
    }

    reset() {
        this.selectedTaxIds = [];
        this.pillData = [];
    }

    get disableApply() {
        return this.selectedSavedTaxIds.length == 0 && !this.appliedOnce;
    }

    fireEventLWC() {
        let component = this;
        let pMessage = {
            event: "taxId",
            data: {
                session: this.cart.paymentSession,
                customerType: this.cart.customerType
            }
        };
        //   setTimeout(() => {
        component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
        //    }, 1000);
    }

    iframeLoaded() {
        console.log("tax identifier iframe");
        this.getCartInfo();
    }

    handleRemoveTaxId(event) {
        this.removedPill = event.target.label;
        this.pillData = this.pillData.filter((ele) => ele.id != event.target.name);
        this.selectedTaxIds = this.selectedTaxIds.filter((ele) => ele != event.target.name);
        this.createPill = true;
        this.appyTaxIdToCheckout(this.pillData.map((ele) => ele.id));
    }

    handleCancel() {
        this.template.querySelector("c-drb2b-modal").close();
        this.showModal = false;
    }

    handleOpenTaxIdModal() {
        this.showModal = true;
        this.template.querySelector("c-drb2b-modal").open();
    }

    async updateDRRemainingFieldJs(response){
       
       await updateDRRemainingField({cartId :this.webcartId}).then((res)=>{
        if(response!=undefined &&response.taxIdentifiers){
            if (this.createPill) {
                for (let ele of response.taxIdentifiers) {
                    let pillData = { id: ele.id, value: ele.value };
                    this.pillData.push(pillData);
                }
                this._selectedTax.pill = this.pillData;
                this.fireEventLWC();
            }
            let taxValues = response.taxIdentifiers.map((ele) => ele.value).join(", ");
            let taxIds = response.taxIdentifiers.map((ele) => ele.id).join(", ");
            this._selectedTax.taxId = taxIds;
            this.updateTaxIdCart(taxIds);
            if (this.removedPill)
                this.showToast({
                    message: `${this.label.removedTaxIdSuccess} :` + this.removedPill,
                    variant: "success"
                });
            else this.showToast({ message: `${this.label.applySuccessMsg} :` + taxValues, variant: "success" });
        } else {
            this._selectedTax = {};
            this.updateTaxIdCart("");
            if (this.removedPill)
                this.showToast({
                    message: `${this.label.removedTaxIdSuccess} :` + this.removedPill,
                    variant: "success"
                });
            else
                this.showToast({
                    message: `${this.label.allRemovedSuccess} `,
                    variant: "success"
                });
        }
        fireEvent(this.pageRef, "CALCULATE_TAX", "");
                const attributeChangeEvent = new FlowAttributeChangeEvent(
                    "selectedTax",
                    JSON.stringify(this._selectedTax)
                );
                this.dispatchEvent(attributeChangeEvent);
       }).catch((error)=>{
            this.showToast({ message: JSON.stringify(error), variant: "error" });
        })
        .finally(() => {
            this.isLoading = false;
            this.removedPill = null;
            this.createPill = false;
        });
    }
}