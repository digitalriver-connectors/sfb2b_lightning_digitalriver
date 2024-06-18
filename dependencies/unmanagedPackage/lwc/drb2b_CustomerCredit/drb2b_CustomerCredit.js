import { LightningElement,api,track,wire } from 'lwc';
import addCustomerCreditSourceToCheckout from "@salesforce/apex/digitalriverv3__DRB2B_CustomerCreditService.addCustomerCreditSourceToCheckout";
import deattachPaymentToCheckout from "@salesforce/apex/digitalriverv3__DRB2B_CustomerCreditService.deattachPaymentToCheckout";
import getCartDetailsById from "@salesforce/apex/digitalriverv3__DRB2B_CustomerCreditService.getCartDetailsById";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, MessageContext } from 'lightning/messageService';
import dr_lms from '@salesforce/messageChannel/digitalriverv3__DigitalRiverMessageChannel__c';
import currencyCode from '@salesforce/i18n/number.currencySymbol';


export default class Drb2b_CustomerCredit extends LightningElement {
    initilized = false;
    isLoading = false;
    @api webcartId;
    @track amount
    createPill = false;
    pillValue;
    pillId;
    @track showCustomerCreditMocker = false;
    @track pillData = [];
    connectedCallback() {
        if (this.initilized) return;
        this.initilized = true;
        this.isLoading = true;
        this.getCartDetails();
        console.log('event ::');
    }
    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }

    @wire(MessageContext)
    messageContext;
    
    handleReloadDropin(){
        publish(this.messageContext, dr_lms, {
            purpose: 'reloadDropin' 
        });
    }

    handleReloadCheckoutSummary(){
        publish(this.messageContext, dr_lms, {
            purpose: 'reloadCheckoutSummary' 
        });
    }

    
    //get cart details to check whether cart contains subscription product
    getCartDetails() {
        getCartDetailsById({cartId:this.webcartId })
            .then((result) => {
                this.showCustomerCreditMocker = !result;            
            })
            .catch((error) => {
                console.log("error " + error);
            });
        }

    handleAddCustomerCredit(event){
        var ccAmount = this.template.querySelector("[data-id=amount]").value;
        addCustomerCreditSourceToCheckout({
            inputData : JSON.stringify({
                cartId : this.webcartId,
                amount : ccAmount
            })
        }).then((result) => {
                this.template.querySelector("[data-id=amount]").value = '';
                console.log('resultData : '+result);
                if (result.isSuccess) {
                    this.createPill = true;
                    this.pillValue = 'Customer Credit '+currencyCode+ccAmount;
                    this.pillId = result.sourceId;
                    let pillData = { id: this.pillId, value: this.pillValue };
                    this.pillData.push(pillData);
                    this.handleReloadDropin();
                    this.handleReloadCheckoutSummary();
                    
                }else {
                    this.showToast({ message: result.errorMessage, variant: "error" });
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log("\n\n error => " + JSON.stringify(error, null, 2));
                this.showToast({ message: error.body.message, variant: "error" });
            });
    }
     
    handleRemoveCustomerCredit(event){
        var sourceId = event.target.name;
        deattachPaymentToCheckout({
            inputData : JSON.stringify({
                cartId : this.webcartId,
                sourceId : sourceId
            })
        }).then((result) => {
                if (result.isSuccess) {
                    this.pillData = this.pillData.filter((elem) => elem.id != sourceId);
                    this.createPill = true;
                    this.showToast({ message: 'Successfully removed', variant: "success" });
                    this.handleReloadDropin();
                    this.handleReloadCheckoutSummary();
                }else {
                    this.showToast({ message: result.errorMessage, variant: "error" });
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log("\n\n error => " + JSON.stringify(error, null, 2));
                this.showToast({ message: error.body.message, variant: "error" });
            });
    }
}