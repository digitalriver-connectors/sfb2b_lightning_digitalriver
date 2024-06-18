import { LightningElement, wire, track } from "lwc";
import { subscribe, MessageContext } from "lightning/messageService";
import dr_lms from '@salesforce/messageChannel/digitalriverv3__DigitalRiverMessageChannel__c';
export default class Drb2b_genricSubscriber extends LightningElement {
    @wire(MessageContext) messageContext;
    @track data;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, dr_lms, (message) => this.handleMessage(message));
        }
    }

    handleMessage(message) {
        console.log("message  " + message);
        this.data = JSON.stringify(message);
    }
}
