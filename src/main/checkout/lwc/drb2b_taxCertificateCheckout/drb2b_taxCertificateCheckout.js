import { LightningElement,wire } from 'lwc';
import taxCertificatesLink from "@salesforce/label/c.DR_TAX_CERTIFICATES_LINK";
import { subscribe, MessageContext,unsubscribe } from 'lightning/messageService';
import toggleShowTC from '@salesforce/messageChannel/TaxCertificateMessageChannel__c';


export default class Drb2b_taxCertificateCheckout extends LightningElement {

    labels = {
        taxCertificatesLink
    };
    showLink = false;
    isinitilized = false;
    subscription = null;

    @wire(MessageContext) messageContext;

    connectedCallback(){
        this.subscribeToMessageChannel();
    }
    
     // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
     subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                toggleShowTC,
                (message) => this.handleMessage(message),
            );
        }
    }

    handleTaxCertificates(){
        this.template.querySelector("c-drb2b-modal").open();
    }

    setShowLink(message){
        this.showLink = message.showLink;
    }

    handleMessage(message){
        this.showLink = message.showLink;
    }

    
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

}