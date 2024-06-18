import { CurrentPageReference } from "lightning/navigation";
import { LightningElement, api, wire, track } from "lwc";
import getCart from "@salesforce/apex/DRB2B_DropinController.getCart";
import attachSource from "@salesforce/apex/DRB2B_CheckoutController.attachSource";
import refreshCartBasedOnDrRecord from "@salesforce/apex/DRB2B_CheckoutController.refreshCartBasedOnDrRecord";
import attachSourceWithCustomer from "@salesforce/apex/DRB2B_CheckoutController.attachSourceWithCustomer";
import { FlowNavigationNextEvent, FlowAttributeChangeEvent } from "lightning/flowSupport";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { subscribe, MessageContext,unsubscribe } from "lightning/messageService";

import { getRecord } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_EMAIL from "@salesforce/schema/User.Email";
import USER_PHONE from "@salesforce/schema/User.Phone";

import USER_ID from "@salesforce/user/Id";
//labels
import storePayments from "@salesforce/label/c.DR_Stored_Payment";
import otherPayments from "@salesforce/label/c.DR_Other_Payments";
import paymentFailure from "@salesforce/label/c.DR_PaymentFailure_Error";
import cardx from "@salesforce/label/c.DR_Card_Ending_with";
import savePaymentMsg from "@salesforce/label/c.DR_Save_Payment_Msg";

import { fireEvent, unregisterAllListeners } from "c/pubsub";
const POST_ADDRESS = "postAddress";
const Payment_Error = "paymentError";

export default class Drb2b_Payments extends LightningElement {
    @api webCartId;
    @api paymentType;
    @api paymentInfo;
    @api dropinConfig;
    @api publishZeroDollarEvent;
    @api disableSavedPayemnts;
    @api enableOverridePayments;
    @api isSyncCheckout;
    @api skipCurrentPage;
    isShow = true;

    isCountryStateEnabled = false;
    isLoading = true;
    cart;
    ContactId;
    UserId = USER_ID;
    currentUser;
    @track showPaymentCmp = true;
    ShowPayment;
    isRenderd = false;
    labels = {
        cardx,
        storePayments,
        otherPayments,
        paymentFailure,
        savePaymentMsg
    };
    @track enabledPaymentMethods = [];
    @track disabledPaymentMethods = [];

    @wire(MessageContext) messageContext;

    @wire(CurrentPageReference)
    pageRef;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID, USER_EMAIL, USER_PHONE]
    })
    wireuser({ error, data }) {
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: "error",
                    mode: "sticky"
                })
            );
        } else if (data) {
            this.currentUser = data.fields;
        }
    }
    connectedCallback() {
        if (this.isRenderd) return;
        this.isRenderd = true;
        this.showPaymentCmp = !this.enableOverridePayments;
        this.startLoading();
        this.getCartInfo().finally(this.stopLoading.bind(this));
        this.subscribeToMessageChannel();
        
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, dr_lms, (message) => this.handleMessage(message));
        }
    }

    handleMessage(message) {
        switch (message.purpose) {
            case "overridePayments":
                this.handleOverridePayment(message.payload);
                break;
            case "toggleShowPaymentComponent":
                this.toggleShowPaymentComponent(message.payload);
                break;
            case "reloadPaymentComponent":
                this.reloadPaymentComponent();
                break;
        }
    }

    //method will be used to reload payment component
    reloadPaymentComponent(){
        setTimeout(() => {
            this.template.querySelector("c-drb2b_-dropin").reloadpaymentDropin();
        }, 500);
    }

    //method will be used to show/hide component 
    toggleShowPaymentComponent(data) {
        let dataobj = JSON.parse(data);
        this.isShow = dataobj?.isShow;
    }

    handleOverridePayment(data) {
        let dataobj = JSON.parse(data);
        this.disabledPaymentMethods = dataobj?.disabledPaymentMethods;
        this.enabledPaymentMethods = dataobj?.enabledPaymentMethods;
        this.showPaymentCmp = true;
        setTimeout(() => {
            this.template.querySelector("c-drb2b_-dropin").reloadpaymentDropin();
        }, 500);
    }

    getCartInfo() {
        return getCart({ cartId: this.webCartId })
            .then((result) => {
                this.cart = result.cart;
                this.isCountryStateEnabled = result.isCountryStateEnabled;
            })
            .catch((error) => {
                console.log("\n\n error => " + JSON.stringify(error, null, 2));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error",
                        mode: "sticky"
                    })
                );
            });
    }

    handlePaymentSuccess(data) {
        /*if (this.cart.isRecurring && "readyForStorage" in data.detail && !data.detail.readyForStorage) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Warning",
                    message: this.labels.savePaymentMsg,
                    variant: "warning",
                    mode: "dismissible"
                })
            );
            const paymentError = {
                IsError: true
            };
            fireEvent(this.pageRef, Payment_Error, paymentError);
            return;
        }*/
        this.startLoading();
        let paymentDetail = data.detail.source.type;
        if ("creditCard" in data.detail.source)
            paymentDetail = `${paymentDetail} : xxxx-xxxx-xxxx-xxxx-${data.detail.source.creditCard.lastFourDigits}`;
        const attributeChangeEvent = new FlowAttributeChangeEvent("paymentInfo", paymentDetail);
        this.dispatchEvent(attributeChangeEvent);
        // this.hasSuccessNotification = true;
        if (data.detail.readyForStorage || this.cart.isRecurring) {
            attachSourceWithCustomer({
                jsonString: JSON.stringify({
                    sourceId: data.detail.source.id,
                    paymentType: data.detail.source.type,
                    contactId: this.currentUser.ContactId.value,
                    userId: this.UserId,
                    cartId: this.webCartId
                })
            })
                .then((result) => {
                    let resultData = JSON.parse(result);
                    if (resultData.isSuccess) {
                        this.handleAttachSource(data);
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error",
                                message: this.labels.paymentFailure,
                                variant: "error",
                                mode: "dismissable"
                            })
                        );
                    }
                })
                .catch((error) => {
                    console.log("\n\n error => " + JSON.stringify(error, null, 2));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: this.labels.paymentFailure,
                            variant: "error",
                            mode: "dismissable"
                        })
                    );
                    const paymentError = {
                        IsError: true
                    };
                    fireEvent(this.pageRef, Payment_Error, paymentError);
                    this.stopLoading();
                });
        } else {
            this.handleAttachSource(data);
        }
    }

    handleAttachSource(data) {
        return attachSource({ cartId: this.webCartId, sourceString: JSON.stringify(data.detail.source) })
            .then(() => {
                return refreshCartBasedOnDrRecord({ cartId: this.webCartId });
            })
            .then(() => {
                // this.publishBillingAddressEvent(data.detail.source);

                this.dispatchEvent(new FlowNavigationNextEvent());
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: this.labels.paymentFailure,
                        variant: "error",
                        mode: "dismissable"
                    })
                );
                const paymentError = {
                    IsError: true
                };
                fireEvent(this.pageRef, Payment_Error, paymentError);
                console.error("Payment Process Error", JSON.stringify(error));
                this.stopLoading();
            });
    }

    startLoading() {
        this.isLoading = true;
    }

    stopLoading() {
        this.isLoading = false;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /*Will be used to show/hide payment component */
    handleShowPayment(evt) {
        this.showPaymentCmp = evt.detail;
    }
}
