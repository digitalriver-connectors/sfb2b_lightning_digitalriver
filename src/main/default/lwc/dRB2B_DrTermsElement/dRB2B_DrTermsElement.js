import { LightningElement, track, api, wire } from "lwc";
import communityPath from "@salesforce/community/basePath";
import { getNamespacePrefix } from "c/commons";
import getCartEntity from "@salesforce/apex/DRB2B_DrElementController.getCartEntity";
import getComplianceAddress from "@salesforce/apex/DRB2B_DrElementController.getComplianceAddress";
import updateTerms from "@salesforce/apex/DRB2B_TermsController.updateCheckoutWithTerms";
import drTermsError from "@salesforce/label/c.DR_Terms_ERROR";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { unregisterAllListeners, fireEvent } from "c/pubsub";
import communityId from '@salesforce/community/Id';

import { publish,subscribe, unsubscribe,MessageContext } from 'lightning/messageService';
import toggleCheckboxMS from '@salesforce/messageChannel/DRTermsMessageChannel__c';

//WEBCART FIELD
import SELLING_ENTITY_FIELD from "@salesforce/schema/Webcart.DR_Selling_Entity__c";
import RECURRING_FIELD from "@salesforce/schema/Webcart.Recurring_Line_Item_Count__c";
const US_LOCALE = "EN_US";
import  dr_lms from '@salesforce/messageChannel/DigitalRiverMessageChannel__c';


export default class DRB2B_DrElement extends LightningElement {
    @track drDisclosure;
    showTermsCheckbox = false;
    isInitilized = false;
    isRendered = false;
    isLoading = false;
    locale;
    acceptedDisclousreAsString = '';
    showAutoRenewalForSubs = false;
    @api header;
    @api recordId;
    @api objectApiName;
    @api webcartId;
    @api bypassValidation;
    @api hideTermsUI;
    @api autoInitialize;
    isFireFromPlaceOrder = false;
    termsString;
    acceptedTerms;
    isSubscriptionProduct = false;

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath.slice(0, communityPath.lastIndexOf("/s"));
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    labels = {
        drTermsError
    };

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        if (this.isInitilized) return;
        this.isLoading = true;
        this.isInitilized = true;
        this.subscribeToMessageChannel();
        let component = this;
        window.addEventListener("message", function (event) {
            let url = window.location.protocol+'//'+window.location.hostname;
            if(event.origin != url)
            {
              return false;
            }
            component.handleVFResponse(event.data);
        });
    }

    renderedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
       
    }

    handlePreviousButton(){
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    getCartEntityJs() {
        getCartEntity({ cartId: this.webcartId })
            .then((result) => {
                if (result){ 
                    let cart =  JSON.parse(result);
                    this.isSubscriptionProduct = cart[RECURRING_FIELD.fieldApiName] > 0;
                    this.cartEntity = {entity: cart[SELLING_ENTITY_FIELD.fieldApiName] }
                    // if(this.isSubscriptionProduct){
                    //    this.template.host.style.setProperty('--termsheight','171 px');
                    //     css.setProperty('--modalHeight','171 px');
                    // }
                };
               // this.fireEventLWC();
               this.getComplianceData();
            })
            .catch((error) => {
                console.log("error:", error);
            });
    }

    cartShippingCountry;
    cartBillingCountry;
    cartLanguage;
    cartType;

    async getComplianceData() {
        await    getComplianceAddress({ CartId: this.webcartId })
        .then((result) => {
           
            if (result) {
                let cart = JSON.parse(result); 
                this.cartBillingCountry ="billToCountry" in cart?cart.billToCountry:undefined
                this.cartShippingCountry ="shipToCountry" in cart?cart.shipToCountry:undefined
                this.cartType = cart.cartType;
                this.cartLanguage = cart.userLanguage; 
            }
            this.fireEventLWC();
        })
        .catch((error) => {
            console.log("error", error);
            
        });
    }

    fireEventLWC() {
        let component = this;
        let arrayVar = {}; 
        arrayVar.cartEntity = this.cartEntity;
        arrayVar.cartshipToCountry =this.cartShippingCountry;
        arrayVar.cartBillToCountry = this.cartBillingCountry;
        arrayVar.cartType = this.cartType;
        arrayVar.cartLanguage=this.cartLanguage;
        let pMessage = {
                    event: "terms",
                    data: arrayVar
                    
                };
       
        this.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
        this.isLoading = false;
        
        
    }

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        this.locale = msg.locale;
        switch (msg.event) {
            case "DRterms":
                 this.constructDrTerms(msg.obj);
                break;
        }
    }

    iframeLoaded(){
        //this.fireEventLWC();
        this.getCartEntityJs();
    }

    constructDrTerms(msg) {
        this.drDisclosure = msg.disclosure;
        this.termsString = msg.disclosure.autorenewalPlanTerms.localizedText;
        this.showTermsCheckbox = true;
        this.acceptedTerms = `${this.drDisclosure.confirmDisclosure.localizedText}`;
        if(this.isSubscriptionProduct)
            this.acceptedTerms =  `${this.acceptedTerms} ${this.termsString}`;
        
        
        publish(this.messageContext, toggleCheckboxMS, {
            isSelected: false,
            termsString:  this.acceptedTerms
        });

        //this.showAutoRenewalForSubs = this.locale.toUpperCase() == US_LOCALE && this.isSubscriptionProduct;
        // setTimeout(() => {
        //     if(this.isSubscriptionProduct)
        //     this.template.querySelector('.input').classList.add('input-checkbox');
        // }, 1000);
        
    }   

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                dr_lms,
                (message) => this.validateCheckBox(message),
            );
        }
    }

    validateCheckBox(message){
        if(message.purpose == 'checkTermsAndCondtions'){
            let checkValidation = this.validate(); 
            this.isFireFromPlaceOrder = true;
            if(checkValidation.isValid){ 
                if(this.bypassValidation && this.isSubscriptionProduct){
                 this.updateTerms();
                }
                fireEvent(this.pageRef, "PLACE_ORDER", "");
                this.handlePreviousButton();
            }
        }else if(message.purpose == 'updateCheckoutWithTermsString'){
            if(this.isSubscriptionProduct){
                this.updateTerms();
            }
            fireEvent(this.pageRef, "PLACE_ORDER", "");
        }else if(message.purpose == 'toggleShowTermsComponent'){
            this.toggleShowTermsComponent(message.payload);
        }
    }

    toggleShowTermsComponent(data){
        let dataobj = JSON.parse(data);
        this.hideTermsUI = !dataobj?.isShow; //dataobj; 
        this.autoInitialize = dataobj?.isShow;
    }
    @api
    validate() {
        this.checkValidity();
        return this.handleNextClick();
    }

    allValid = false;
    checkValidity() {
        this.allValid = [...this.template.querySelectorAll(".input")].reduce((validSoFar, inputCmp) => {
            return validSoFar && inputCmp.checkValidity();
        }, true) ;
    }

    handleNextClick() {
        if(this.isSubscriptionProduct){
            if(!this.isFireFromPlaceOrder){
                this.updateTerms();
            }
        }
        if(this.bypassValidation){
            return { isValid: true };
        }else{
            if (this.allValid) {
                return { isValid: true };
            } else if (!this.allValid) {
                this.showToast({ message: this.labels.drTermsError, variant: "error" });
            }
            return { isValid: false, errorMessage: "" };
        }
    }

    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    updateTerms(){
        updateTerms({cartId : this.webcartId,terms : this.termsString})
        .then((result) => {
        })
        .catch((error) => {
            console.log("error:", error);
        });
    }

    handleCheckBoxChange(event){
        publish(this.messageContext, toggleCheckboxMS, {
            isSelected: event.target.checked,
            termsString:this.acceptedTerms
        });
    }

}
