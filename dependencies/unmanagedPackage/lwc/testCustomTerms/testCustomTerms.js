import { LightningElement,wire,track } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import toggleCheckboxMS from '@salesforce/messageChannel/digitalriverv3__DRTermsMessageChannel__c';
import dr_lms from '@salesforce/messageChannel/digitalriverv3__DigitalRiverMessageChannel__c';

export default class TestCustomTerms extends LightningElement {
    @wire(MessageContext) messageContext;
    @track data;

    connectedCallback(){
        this.subscribeToMessageChannel();
    }

    handleTestPlaceOrderBtnClick(event){
        this.publishUpdateTermsStringEvent();
    }
    publishUpdateTermsStringEvent(){
        publish(this.messageContext, dr_lms, {
            purpose: 'updateCheckoutWithTermsString' ,
            termsString : this.data.termsString
        });
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