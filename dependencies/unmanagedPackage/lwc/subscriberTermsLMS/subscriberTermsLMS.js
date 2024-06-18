import { LightningElement,wire,track } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import toggleCheckboxMS from '@salesforce/messageChannel/digitalriverv3__DRTermsMessageChannel__c';

export default class SubscriberTermsLMS extends LightningElement {
    @wire(MessageContext) messageContext;
    @track data;

    connectedCallback(){
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                toggleCheckboxMS,
                (message) => this.handleMessage(message),
            );
        }
    }

    handleMessage(message){
        this.data = message;

    }


}