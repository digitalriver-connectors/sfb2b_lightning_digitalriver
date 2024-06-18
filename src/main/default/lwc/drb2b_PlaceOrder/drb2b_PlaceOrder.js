import { LightningElement,wire,track, api } from 'lwc';
import placeOrderBtnLbl from "@salesforce/label/c.DR_Place_Order_Button";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import showPlaceOrderButton from '@salesforce/messageChannel/DigitalRiverMessageChannel__c';
import { registerListener, unregisterAllListeners } from "c/pubsub";
export default class Drb2b_PlaceOrder extends LightningElement {

    @wire(MessageContext)
    messageContext;
    @api displayPlaceOrderButton;
    @track disableButton = false;
    @api isSyncCheckout;
    isRendered = false;

    labels = {
        placeOrderBtnLbl
    };

    renderedCallback() {
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        registerListener("SHOW_PLACE_ORDER_BUTTON", this.displayPlaceOrderButtonfunc, this);
        registerListener("DISABLE_PLACE_ORDER_BUTTON", this.disablePlaceOrderButtonfunc, this);
        this.subscribeToMessageChannel();
    }

    displayPlaceOrderButtonfunc(){
        this.displayPlaceOrderButton = true;
    }

    disablePlaceOrderButtonfunc(){
        this.disableButton = true;
    }
    
    handlePlaceOrderBtn() {
        publish(this.messageContext, showPlaceOrderButton, {
            purpose: 'placeOrder' 
        });
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                showPlaceOrderButton,
                (message) => this.handleMessage(message),
            );
        }
    }

    handleMessage(message){
        switch (message.purpose) {
            case "toggleShowPOComponent":
                this.toggleShowPOComponent(message.payload);
                break;
            case "onPrevious" :
                this.handlePreviousButton();
                break;

        }
    }

    handlePreviousButton(){
        if(this.isSyncCheckout){
            // this.displayPlaceOrderButton = true;
            return;
        }else{
            this.displayPlaceOrderButton = false;
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    toggleShowPOComponent(data){
        let dataobj = JSON.parse(data);
        this.displayPlaceOrderButton = dataobj?.isShow;
    }
}