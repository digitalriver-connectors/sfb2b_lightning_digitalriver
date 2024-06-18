import { LightningElement, api, wire } from "lwc";
import communityPath from "@salesforce/community/basePath";
import communityId from "@salesforce/community/Id";
import { getNamespacePrefix } from "c/commons";
import Toast from 'lightning/toast';
import { registerListener, unregisterAllListeners } from "c/pubsub";
import { publish, subscribe, MessageContext,unsubscribe } from "lightning/messageService";
import { FlowNavigationNextEvent, FlowNavigationBackEvent, FlowAttributeChangeEvent } from "lightning/flowSupport";
import detachSources from "@salesforce/apex/DRB2B_DropinController.deattachAllSourcesFromCheckout";
import getCart from "@salesforce/apex/DRB2B_DropinController.getCart";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import ToastContainer from 'lightning/toastContainer';
import paymentFailure from "@salesforce/label/c.DR_PaymentFailure_Error";
import isGuestUser from "@salesforce/user/isGuest";

const EVENTSTRING = "dropIn";
const Payment_Error = "paymentError";
const FLOW_ATTRIBUTE_SKIPCURRENTPAGE = "skipCurrentPage";
const FLOW_VALUE_SKIPCURRENTPAGE  = true;
export default class Drb2b_Dropin_LWR extends LightningElement {
    @api cartId;
    @api cart;
    @api isCountryStateEnabled = false;
    @api dropinConfig;
    @api disableSavedPayemnts;
    @api customerCreditEnabled;
    @api publishZeroDollarEvent;
    @api publishZeroDollarEventBoolean
    @api enabledPaymentMethods = [];
    @api disabledPaymentMethods = [];
    @api skipCurrentPage;
    isLoading = true;
    hasSuccessNotification = false;
    subscription = null;
    isConnectedCallBackInitialized = false;
    isRendered = false;

    label = {
        paymentFailure
    };

    @wire(MessageContext) messageContext;

    renderedCallback() {
        registerListener('reloadpaymentDropin',this.reloadpaymentDropin,this);
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        this.subscribeToMessageChannel();
        registerListener(Payment_Error, this.paymentError, this);
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);

        /*Zero dollar
        checking if cart has zero dollar amount and has no subscription product */
        if (this.cart.grandTotalAmount == 0 && !this.cart.isRecurring) {
            this.dispatchEvent(new FlowAttributeChangeEvent(FLOW_ATTRIBUTE_SKIPCURRENTPAGE, FLOW_VALUE_SKIPCURRENTPAGE));
            if(this.skipCurrentPage){
                this.dispatchEvent(new FlowNavigationBackEvent());
                return;
            }
            if (this.publishZeroDollarEventBoolean) {
                this.handleZeroDollarEvent();
            } else {
                this.moveToNext();
            }
           // return;
        }
    }

    get communityLWRURL() {
        let nameSpace = getNamespacePrefix();
        return `/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

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
        }
    }

    @api
    reloadpaymentDropin() {
        this.fireEventLWC();
        this.hideLoader();
    }

    detachAllSources() {
        detachSources({ inputData: JSON.stringify({ cartId: this.cart.id }) })
            .then((result) => {
                this.handleReloadCheckoutSummary();            
            })
            .catch((error) => {
                console.log("Drb2b_Dropin_LWR detachAllSources error while detach sources" + error);
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
        let cURL = communityPath + 'vforcesite';
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    getCountryAndISOCodeMap(component){
        if(component.template.querySelector("c-drb2b_country-picklist")){
		return component.template.querySelector("c-drb2b_country-picklist").getCountryPickListMapWithKeyUpperCase();
        }else{
            this.getCountryAndISOCodeMap(component);
        }
    }

    fireEventLWC() {
        let component = this;
        if(component.cart.paymentSession == undefined || !(component.cart.paymentSession))
        return;
       // let countryAndISOCodeMap;
        if(this.isCountryStateEnabled){
            component.cart = {
                ...component.cart,
            };
        } 
        if (this.isCountryStateEnabled) {
           component.cart.countryCode = component.cart.billingAddress.countryCode;
        }
        if(isGuestUser){
            this.disableSavedPayemnts = isGuestUser;
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
        component.isLoading = false;
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
    
     showToast(obj) {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';
        Toast.show({
            label: obj.title,
            message: obj.message,
            mode: 'dismissible',
            variant: obj.variant,
                    }, this);
    }

    handleError(data) {
     
        this.showToast({title: "Payment failure" , message: this.label.paymentFailure, variant: "error" });
    }

     hideLoader() {
        this.isLoading = false;
    }

    handlePaymentSuccess(data) {
        if (!this.hasSuccessNotification) {
            this.hasSuccessNotification = true;
            this.isLoading = false;
            this.handleReloadPaymentDetails();
            const selectedEvent = new CustomEvent("getsource", { detail: data });
            this.dispatchEvent(selectedEvent);
        }
    }

    
    handleReloadPaymentDetails() {
     publish(this.messageContext, dr_lms, {
        purpose: "reloadPaymentDetails"
    });
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