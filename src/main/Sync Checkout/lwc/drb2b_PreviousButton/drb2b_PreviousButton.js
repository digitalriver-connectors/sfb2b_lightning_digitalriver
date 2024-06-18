import { LightningElement, wire } from 'lwc';
import { FlowNavigationBackEvent } from "lightning/flowSupport";
import { publish, MessageContext } from 'lightning/messageService';
import showPlaceOrderButton from '@salesforce/messageChannel/DigitalRiverMessageChannel__c';
export default class Drb2b_PreviousButton extends LightningElement {

    @wire(MessageContext)
    messageContext;

    handlePreviousBtn(){
            publish(this.messageContext, showPlaceOrderButton, {
                purpose: 'onPrevious' 
            });
            this.dispatchEvent(new FlowNavigationBackEvent());
    }
}