import { LightningElement, api, wire } from "lwc";
import communityPath from "@salesforce/community/basePath";
import communityId from "@salesforce/community/Id";
import { getNamespacePrefix } from "c/commons";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { registerListener, unregisterAllListeners } from "c/pubsub";
// import reloadDropInMS from '@salesforce/messageChannel/DigitalRiverMessageChannel__c';
import { publish, subscribe, MessageContext,unsubscribe } from "lightning/messageService";
import { FlowNavigationNextEvent, FlowNavigationBackEvent, FlowAttributeChangeEvent } from "lightning/flowSupport";
import detachSources from "@salesforce/apex/DRB2B_DropinController.deattachAllSourcesFromCheckout";
import getCart from "@salesforce/apex/DRB2B_DropinController.getCart";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";

const EVENTSTRING = "dropIn";
const Payment_Error = "paymentError";
const FLOW_ATTRIBUTE_SKIPCURRENTPAGE = "skipCurrentPage";
const FLOW_VALUE_SKIPCURRENTPAGE  = true;
export default class Drb2b_Dropin extends LightningElement {
    @api cartId;
    @api cart;
    @api isCountryStateEnabled = false;
    @api dropinConfig;
    @api disableSavedPayemnts;
    @api customerCreditEnabled;
    @api publishZeroDollarEvent;
    @api enabledPaymentMethods = [];
    @api disabledPaymentMethods = [];
    @api isSyncCheckout;
    @api skipCurrentPage;

    isLoading = true;
    hasSuccessNotification = false;
    subscription = null;
    isConnectedCallBackInitilized = false;

    @wire(MessageContext) messageContext;

    renderedCallback() {
        if (this.isRenderd) return;
        this.isRenderd = true;
        this.subscribeToMessageChannel();

        //verify if some source is already attacged remove those source
        if (this.cart.remainingAmount != this.cart.grandTotalAmount && !this.isSyncCheckout) this.detachAllSources();
        
        if(this.isSyncCheckout){
            this.detachAllSources();
        }
        registerListener(Payment_Error, this.paymentError, this);
        // this.fireEventLWC();
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);

        /*Zero dollor
        checking if cart has zero dollar amount and has no subscrption product */
        if (this.cart.grandTotalAmount == 0 && !this.cart.isRecurring) {
            this.dispatchEvent(new FlowAttributeChangeEvent(FLOW_ATTRIBUTE_SKIPCURRENTPAGE, FLOW_VALUE_SKIPCURRENTPAGE));
            if(this.skipCurrentPage){
                this.dispatchEvent(new FlowNavigationBackEvent());
                return;
            }
            if (this.publishZeroDollarEvent) {
                this.handleZeroDollarEvent();
            } else {
                this.moveToNext();
            }
            return;
        }
    }

    // connectedCallback(){
    //     if (this.isConnectedCallBackInitilized) return;
    //         this.isConnectedCallBackInitilized = true;

    // }

    handleReloadCheckoutSummary() {
        publish(this.messageContext, dr_lms, {
            purpose: "reloadCheckoutSummary"
        });
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, dr_lms, (message) => this.handleMessage(message));
        }
    }

    handleMessage(message) {
        switch (message.purpose) {
            case "reloadDropin":
                this.reloadDropin();
                break;
            case "skipCurrentPage":
                console.log('reset the flag');
                this.skipCurrentPage = true;
                break;
        }
    }

    async reloadDropin() {
        let cart = await getCart({ cartId: this.cart.id });
        this.cart = cart.cart;
        if (this.cart.remainingAmount == 0) {
            this.moveToNext();
            return;
        }
        if (this.cart.remainingAmount != this.cart.grandTotalAmount) {
            this.fireEventLWC();
            //this.detachAllSources();
        }
    }

    @api
    reloadpaymentDropin() {
        this.fireEventLWC();
    }

    detachAllSources() {
        detachSources({ inputData: JSON.stringify({ cartId: this.cart.id }) })
            .then((result) => {
                this.handleReloadCheckoutSummary();
              
            })
            .catch((error) => {
                console.log("There is some error while detach sources" + error);
            });
    }

    callResponseHandler(msg) {
        let url = window.location.protocol+'//'+window.location.hostname;
        if(msg.origin != url)
            {
                return false;
            }
        let component = this;
        component.handleVFResponse(msg.data);
    }

    disconnectedCallback() {
        window.removeEventListener("message", this._listenForMessage);
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    paymentError(data) {
        if (data.IsError) {
            this.hasSuccessNotification = false;
        }
    }

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath.slice(0, communityPath.lastIndexOf("/s"));
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    fireEventLWC() {
        let component = this;

        // setTimeout(() => {
        let countryAndISOCodeMap = component.template
            .querySelector("c-drb2b_country-picklist")
            .getCountryPickListMapWithKeyUpperCase();

        component.cart = {
            ...component.cart,
            countryCode: countryAndISOCodeMap[component.cart.billingAddress.country.toUpperCase()]
        };
        if (this.isCountryStateEnabled) {
            component.cart.countryCode = component.cart.billingAddress.countryCode;
        }

        let pMessage = {
            event: EVENTSTRING,
            data: {
                cart: component.cart,
                dropinConfig: this.dropinConfig,
                disableSavedPayemnts: this.disableSavedPayemnts,
                enabledPaymentMethods: this.enabledPaymentMethods,
                disabledPaymentMethods: this.disabledPaymentMethods
            }
        };
        component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");

        //  }, 1500);
    }

    iframeLoaded() {
        this.fireEventLWC();
    }

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        switch (msg.event) {
            case "dropInReady":
                this.hideLoader();
                break;
            case "dropInSuccess":
                this.handlePaymentSuccess(msg.obj);
                registerListener(Payment_Error, this.paymentError, this);
                break;
            case "dropInError":
                this.handleError(msg.obj);
                break;
        }
    }

    handleError(data) {
        let errorString = "";
        if (data.errors.length == 1) {
            errorString = data.errors[0].message;
        } else {
            for (i = 0; i < data.errors.length; i++) {
                errorString = errorString + (i + 1) + ". " + data.errors[i].message + "<br/>";
            }
        }
        this.showToast({ message: errorString, variant: "error" });
    }

    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }

    hideLoader() {
        this.isLoading = false;
    }

    handlePaymentSuccess(data) {
        if (!this.hasSuccessNotification) {
            this.hasSuccessNotification = true;
            this.isLoading = false;
            const selectedEvent = new CustomEvent("getsource", { detail: data });
            this.dispatchEvent(selectedEvent);
        }
    }

    /*Handle logic to take user to next page or fire event based on publishZeroDollarEvent value*/
    moveToNext() {
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    /*will fire two events one 
    1. First event will pe used by parent component to hide payment component
    2. Second event will be published by client to perform custom logic */
    handleZeroDollarEvent() {
        // 1. First event will pe used by parent component to hide payment component
        this.hidePaymentComponent(false);

        //2. Second event will be published by client to perform custom logic
        publish(this.messageContext, dr_lms, {
            purpose: "fireZeroDollarEvent"
        });
    }

    hidePaymentComponent(evt) {
        const selectedEvent = new CustomEvent("hidepayment", { detail: evt });
        this.dispatchEvent(selectedEvent);
    }
}
