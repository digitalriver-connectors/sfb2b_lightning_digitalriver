import { LightningElement, wire, track } from "lwc";
import { subscribe, MessageContext, publish } from "lightning/messageService";
import termsMC from "@salesforce/messageChannel/digitalriverv3__DRTermsMessageChannel__c";
import dr_lms from "@salesforce/messageChannel/digitalriverv3__DigitalRiverMessageChannel__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Drb2b_testValidation extends LightningElement {
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, termsMC, (message) => this.handleMessage(message));
        }
    }

    handleMessage(message) {
        this.data = message;
    }

    handlePlaceOrder() {
        console.log(this.data.isSelected);
        console.log(this.template.querySelector(".cterms").checked);
        if (this.data.isSelected && this.template.querySelector(".cterms").checked) {
            //place order logic
            publish(this.messageContext, dr_lms, {
                purpose: "updateCheckoutWithTermsString"
            });
        } else {
            this.showToast({ message: "Validation Failed", variant: "error" });
        }
    }

    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }
}
