import { LightningElement, api, track, wire } from "lwc";
import {subscribe, MessageContext,unsubscribe } from 'lightning/messageService';
import  dr_lms from '@salesforce/messageChannel/digitalriverv3__DigitalRiverMessageChannel__c';

export default class drb2b_spinner_sample extends LightningElement {
    isConnectedCallback = false;
    displayLoader = false;
    paymentIsProcessing = false;
    taxIdentifierIsProcessing = false;
    customerCreditIsProcessing = false;
    isPlacingOrder = false;
       

    @wire(MessageContext)
    messageContext;

  
    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.subscribeToMessageChannel(); 
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                dr_lms,
                (message) => this.showLoadingComponent(message),
            );
        }
    }

    showLoadingComponent(message){
        console.log("message purpose value " , message.purpose );
              switch (message.purpose) {
                case "paymentIsProcessing":
                    this.paymentIsProcessing = message.payload;
                    this.toggleLoader();                  
                    break;
                case "taxIdentifierIsProcessing":
                    this.taxIdentifierIsProcessing = message.payload;
                this.toggleLoader();                  
                    break;
                case "customerCreditIsProcessing":
                    this.customerCreditIsProcessing = message.payload;
                    this.toggleLoader();                  
                break;   
                case "isPlacingOrder":
                    this.isPlacingOrder = message.payload;
                    this.toggleLoader();                  
                break;  
            default:
                break;            
            }
        }

       toggleLoader() {
        this.displayLoader = this.paymentIsProcessing || this.taxIdentifierIsProcessing || this.customerCreditIsProcessing || this.isPlacingOrder;
        console.log("toggleLoader value " , this.displayLoader);
        }
       
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
     
    }