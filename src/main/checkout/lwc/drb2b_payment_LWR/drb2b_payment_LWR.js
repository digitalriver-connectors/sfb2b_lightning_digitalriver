import { CurrentPageReference } from "lightning/navigation";
import { api, wire, track } from "lwc";
import getCart from "@salesforce/apex/DRB2B_DropinController.getCart";
import attachSourceLWR from "@salesforce/apex/DRB2B_CheckoutController.attachSourceLWR";
import refreshCartBasedOnDrRecord from "@salesforce/apex/DRB2B_CheckoutController.refreshCartBasedOnDrRecord";
import attachSourceWithCustomer from "@salesforce/apex/DRB2B_CheckoutController.attachSourceWithCustomer";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { publish, subscribe, MessageContext, unsubscribe } from "lightning/messageService";
import detachSources from "@salesforce/apex/DRB2B_DropinController.deattachAllSourcesFromCheckout";
import { getRecord } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_EMAIL from "@salesforce/schema/User.Email";
import USER_PHONE from "@salesforce/schema/User.Phone";

import USER_ID from "@salesforce/user/Id";
//labels
import storePayments from "@salesforce/label/c.DR_Stored_Payment";
import otherPayments from "@salesforce/label/c.DR_Other_Payments";
import paymentFailure from "@salesforce/label/c.DR_PaymentFailure_Error";
import drTaxIdApplyError from "@salesforce/label/c.DR_TaxId_Apply_Error";
import cardx from "@salesforce/label/c.DR_Card_Ending_with";
import savePaymentMsg from "@salesforce/label/c.DR_Save_Payment_Msg";
import drPaymentNotCompleteError from "@salesforce/label/c.DR_Payment_Not_Complete_Error";
import drPaymentError from "@salesforce/label/c.DR_Payment_Error";
import { fireEvent, registerListener, unregisterAllListeners } from "c/pubsub";
import ToastContainer from "lightning/toastContainer";
import Toast from "lightning/toast";
import clearTransactionPaymentData from "@salesforce/apex/DRB2B_ClearData.clearTransactionPaymentData";
import { CheckoutComponentBase, CheckoutInformationAdapter } from "commerce/checkoutApi";
import isGuestUser from "@salesforce/user/isGuest";
import { CartSummaryAdapter } from "commerce/cartApi";

const CheckoutStage = {
    CHECK_VALIDITY_UPDATE: "CHECK_VALIDITY_UPDATE",
    REPORT_VALIDITY_SAVE: "REPORT_VALIDITY_SAVE",
    BEFORE_PAYMENT: "BEFORE_PAYMENT",
    PAYMENT: "PAYMENT",
    BEFORE_PLACE_ORDER: "BEFORE_PLACE_ORDER",
    PLACE_ORDER: "PLACE_ORDER"
};

const Payment_Error = "paymentError";

export default class drb2b_payment_LWR extends CheckoutComponentBase {
    @api webCartId;
    @api checkoutId;
    @api paymentType;
    @api paymentInfo;
    @api dropinConfig;
    @api publishZeroDollarEvent;
    @api publishZeroDollarEventBoolean;
    @api disableSavedPayemnts;
    @api enableOverridePayments;
    @api isSyncCheckout;
    @api skipCurrentPage;
    @api componentVisibility;
    isShow = true;
    isPaymentShow = true;
    isZeroDollar = false;

    isCountryStateEnabled = false;
    isLoading = true;
    cart;
    @api billingDetails;
    @api buyerName;
    ContactId;
    UserId = USER_ID;
    currentUser;
    @api guestUser = false;
    @track showPaymentCmp = true;
    ShowPayment;
    isRendered = false;
    isConnectedCallback = false;
    newPaymentSessionId = null;
    prevPaymentSessionId = null;
    labels = {
        cardx,
        storePayments,
        otherPayments,
        paymentFailure,
        savePaymentMsg,
        drPaymentNotCompleteError,
        drPaymentError,
        drTaxIdApplyError
    };
    @track enabledPaymentMethods = [];
    @track disabledPaymentMethods = [];

    @wire(MessageContext) messageContext;

    @wire(CurrentPageReference)
    pageRef;
    @api recordId;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID, USER_EMAIL, USER_PHONE]
    })
    wireuser({ error, data }) {
        if (error) {
            this.showToast({ title: "Error", message: error.body.message, variant: "error" });
        } else if (data) {
            this.currentUser = data.fields;
            this.guestUser = false;
        } else {
            this.guestUser = true;
        }
    }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.webCartId = data.cartId;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(CheckoutInformationAdapter, { recordId: "$recordId" })
    wiredRecord(result) {
        this.record = result;
        if (result.data && result.data.checkoutStatus == 200) {
            {
                this.checkoutId = result.data.checkoutId;
                this.refreshData();
            }
        }
    }

    refreshData() {
        this.getUpdatedCartPaymentSessionFromAdapter();
    }

    summary;
    _checkoutMode = 1;
    stageAction(checkoutStage /*CheckoutStage*/) {
        switch (checkoutStage) {
            case CheckoutStage.CHECK_VALIDITY_UPDATE:
                return Promise.resolve(this.checkValidity());
            case CheckoutStage.REPORT_VALIDITY_SAVE:
                return Promise.resolve(this.reportValidity());
            default:
                return Promise.resolve(true);
        }
    }
    //report validity
    reportValidity() {
        return getCart({ cartId: this.webCartId })
            .then((result) => {
                this.cart = result.cart;
                if (this.cart.remainingAmount != 0) {
                    this.showToast({
                        title: "Error",
                        message: this.labels.drPaymentNotCompleteError,
                        variant: "error"
                    });
                    return false;
                } else {
                    return true;
                }
            })
            .catch((error) => {
                console.log("drb2b_Payment_LWR error while handle checkbox method " + JSON.stringify(error));
                this.showToast({ title: "Error", message: this.labels.drPaymentError, variant: "error" });
                return false;
            });
    }

    checkValidity() {
        return true;
    }

    setAspect(newAspect /*CheckoutContainerAspect*/) {
        if (this.summary == newAspect.summary) {
            return;
        }
        this.summary = newAspect.summary;
        if (this.summary) {
            this.setCheckoutMode(3);
        } else {
            this.setCheckoutMode(1);
        }
    }

    //-------------------------------
    _checkedByDefault;
    checked;
    showError = false;
    _checkoutMode = 1;
    isDisabled = false;
    /**
     * @type {CheckoutMode}
     */
    @api get checkoutMode() {
        return this._checkoutMode;
    }

    /**
     * Handles the checkout mode and puts the component in the right state
     * If the component is not currently being edited it'll go into disabled state
     */
    set checkoutMode(value) {
        this.setCheckoutMode(value);
    }

    setCheckoutMode(value) {
        switch (value) {
            case 1:
                this.isLoading = true;
                setTimeout(() => {
                    this.getCartInfoforPaymentThruAdapter();
                }, 1000);
                this.isDisabled = false;
                this.isLoading = false;
                if (
                    this.isZeroDollar &&
                    this.cart.remainingAmount == 0 &&
                    this.cart.remainingAmount == this.cart.grandTotalAmount
                ) {
                    this.isShow = false;
                    this.isLoading = false;
                } else {
                    this.isPaymentShow = true;
                    this.isLoading = false;
                }
                break;
            case 2:
                this.isDisabled = true;
                break;
            case 3:
                this.isDisabled = true;
                break;
            case 4:
                break;
        }
        this._checkoutMode = value;
    }

    //-------------------------------

    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.showPaymentCmp = !this.enableOverridePayments;
        this.startLoading();
        this.subscribeToMessageChannel();
    }

    async reloadPaymentCC() {
        let cart = await getCart({ cartId: this.webCartId });
        this.cart = cart.cart;
        if (this.cart.remainingAmount == 0) {
            this.isPaymentShow = false;
            setTimeout(() => {
                this.template.querySelector("c-drb2b_payment_-details_-l-w-r").handleValueChange();
            }, 500);
        }
    }

    detachAllSources() {
        detachSources({ inputData: JSON.stringify({ cartId: this.webCartId }) })
            .then((result) => {
                this.clearTransactionPaymentData();
            })
            .catch((error) => {
                console.log("drb2b_payment There is some error while detach sources" + JSON.stringify(error));
            });
    }
    renderedCallback() {
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        this.startLoading();
        this.subscribeToMessageChannel();
    }

    refreshData1() {
        this.getUpdatedCartPaymentSessionFromAdapter();
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
                this.refreshData1();
                break;
            case "reloadPaymentCC":
                this.reloadPaymentCC();
                break;
        }
    }

    //method will be used to reload payment component
    reloadPaymentComponent() {
        setTimeout(() => {
            this.template.querySelector("c-drb2b_-dropin_-l-w-r").reloadpaymentDropin();
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
            this.template.querySelector("c-drb2b_-dropin_-l-w-r").reloadpaymentDropin();
        }, 500);
    }
    paymentProcesswhileLoadingDropIn(webCartId, cart) {
        //           this.isCountryStateEnabled = result.isCountryStateEnabled;
        if (this.cart.remainingAmount == 0) {
            this.isZeroDollar = true;
        }
        if (
            this.isZeroDollar &&
            this.cart.remainingAmount == 0 &&
            this.cart.remainingAmount == this.cart.grandTotalAmount
        ) {
            if(this.publishZeroDollarEventBoolean) {
                publish(this.messageContext, dr_lms, {
                    purpose: "fireZeroDollarEvent"
                });
            }
            this.isShow = false;
            this.isLoading = false;
        }
        this.stopLoading();
        fireEvent(this.pageRef, "reloadpaymentDropin", "reloadpaymentDropin");
    }

    getUpdatedCartPaymentSessionFromAdapter() {
        this.cart = null;
        this.getCartInfoforPaymentThruAdapter();
    }

    isInSitePreview = () =>
        ["sitepreview", "livepreview", "live-preview", "live.", ".builder."].some((substring) =>
            document.URL.includes(substring)
        );

    async getCartInfoforPaymentThruAdapter() {
        this.detachAllSources();
        this.isPreview = this.isInSitePreview();
        if (!this.isPreview) {
            getCart({ cartId: this.webCartId }).then((result) => {
                this.cart = result.cart;
                this.newPaymentSessionId = this.cart.paymentSession;
                if (
                    (this.newPaymentSessionId != undefined && this.prevPaymentSessionId == undefined) ||
                    (this.newPaymentSessionId != undefined && this.newPaymentSessionId != this.prevPaymentSessionId)
                ) {
                    //send result using fireevent to result in a event to taxidentifier getCartEvent using register listener
                    this.paymentProcesswhileLoadingDropIn(this.webCartId, this.cart);
                }
                this.prevPaymentSessionId = this.newPaymentSessionId;
            });
        }
    }

    showToast(obj) {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = "top-center";
        Toast.show(
            {
                label: obj.title,
                message: obj.message,
                mode: "dismissible",
                variant: obj.variant
            },
            this
        );
    }

    executePaymentDetailMethod() {
        this.template.querySelector("c-drb2b_payment_-details_-l-w-r").handleValueChange();
        this.stopLoading();
    }

    handlePaymentSuccess(data) {
        //   fireEvent(this.pageRef, 'SHOW_TERMS_ELEMENT', 'SHOW_TERMS_ELEMENT');
        this.startLoading();
        this.isPaymentShow = false;
        let paymentDetail = data.detail.source.type;
        if ("creditCard" in data.detail.source)
            paymentDetail = `${paymentDetail} : xxxx-xxxx-xxxx-xxxx-${data.detail.source.creditCard.lastFourDigits}`;
        if (data.detail.readyForStorage || this.cart.isRecurring) {
            // if not guest proceed with below method.else we need to skip below and display an error using catch
            if (!isGuestUser) {
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
                            this.showToast({ title: "Error", message: this.labels.paymentFailure, variant: "error" });
                        }
                    })
                    .catch((error) => {
                        console.log("drb2b_payment handlePaymentSuccess error" + JSON.stringify(error, null, 2));
                        this.showToast({ title: "Error", message: this.labels.paymentFailure, variant: "error" });
                        const paymentError = {
                            IsError: true
                        };
                        fireEvent(this.pageRef, Payment_Error, paymentError);
                    });
            } else {
                this.showToast({ title: "Error", message: this.labels.savePaymentMsg, variant: "error" });
                const paymentError = {
                    IsError: true
                };
                fireEvent(this.pageRef, Payment_Error, paymentError);
            }
        } else {
            this.handleAttachSource(data);
        }
        fireEvent(this.pageRef, "SHOW_TERMS_ELEMENT", "SHOW_TERMS_ELEMENT");
        //   this.stopLoading();
    }

    handleAttachSource(data) {
        this.startLoading();
        let paymentSourceId = JSON.stringify(data.detail.source.id);
        return attachSourceLWR({ cartId: this.webCartId, sourceString: JSON.stringify(data.detail.source) }).then((result) => {
                if(!result) {
                this.showToast({ title: "Warning", message: this.labels.drTaxIdApplyError, variant: "warning" });
                } 
             })
            .then(() => {
                return refreshCartBasedOnDrRecord({ cartId: this.webCartId });
            })
            .then(() => {
                fireEvent(this.pageRef, "CALCULATE_TAX", "");
                this.executePaymentDetailMethod();
            })
            .catch((error) => {
                console.log("drb2bpayment after refreshCartBasedOnDrRecord catch block  error", error);
                if (JSON.stringify(error.body.message).includes("taxIdentifiers")) {
                    this.showToast({ title: "Error", message: this.labels.drTaxIdApplyError, variant: "error" });
                } else {
                    this.showToast({ title: "Error", message: this.labels.paymentFailure, variant: "error" });
                }
                const paymentError = {
                    IsError: true
                };
                this.stopLoading();
                fireEvent(this.pageRef, Payment_Error, paymentError);
                console.error("Payment Process Error", JSON.stringify(error));
            });
    }

    clearTransactionPaymentData() {
        clearTransactionPaymentData({ cartId: this.webCartId })
            .then(() => {})
            .catch((error) => {
                console.log("drb2b_payment Error facing while clear transaction payment object data" + error);
            });
    }

    startLoading() {
        this.isLoading = true;
        publish(this.messageContext, dr_lms, {
            purpose: "paymentIsProcessing",
            payload: true
        });
    }

    stopLoading() {
        this.isLoading = false;
        publish(this.messageContext, dr_lms, {
            purpose: "paymentIsProcessing",
            payload: false
        });
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
