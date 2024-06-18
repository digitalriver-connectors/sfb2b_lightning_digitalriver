import { LightningElement, track, api, wire } from "lwc";

import getPaymentDetail from "@salesforce/apex/DRB2B_PaymentDetails.getPaymentDetail";
import getPaymentDetailByCartId from "@salesforce/apex/DRB2B_PaymentDetails.getPaymentDetailByCartId";
import Toast from "lightning/toast";
import ToastContainer from "lightning/toastContainer";

import paymentInformation from "@salesforce/label/c.DR_Payment_Information";
import creditCard from "@salesforce/label/c.DR_Credit_Card";
import wiretransfer from "@salesforce/label/c.DR_Wire_Transfer";
import wiretransferInformation from "@salesforce/label/c.DR_Delayed_Payment_Information";

import { MessageContext, subscribe } from "lightning/messageService";
import drMessageChannel from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { CartSummaryAdapter } from "commerce/cartApi";

import isGuestUser from "@salesforce/user/isGuest";
import getSummaryId from "@salesforce/apex/DRB2B_OrderSummaryController.getSummaryId";
import { CurrentPageReference } from "lightning/navigation";

const columns = [
    { label: "", fieldName: "key", type: "text" },
    { label: "", fieldName: "value", type: "text" }
];

export default class drb2b_payment_Details_LWR extends LightningElement {
    isConnectedCallback = false;
    loggedInUser = false;
    isLoading = false;
    isCreditCard = false;
    isWireTransfer = false;
    otherPayments = false;
    isCustomerCredit = false;
    cardNumber;
    paymentType;
    otherPayment;
    customerCreditPayment;
    showPaymentDetails;
    appliedPayments;
    amount;
    appliedCustomerCredit;
    @track configData = [];
    @track data;
    @track _columns = columns;
    @api recordId;
    @api webcartId;
    @api orderNumber;

    wiretransferInstruction;
    label = {
        paymentInformation,
        creditCard,
        wiretransfer,
        wiretransferInformation
    };
    subscription = null;

    @wire(MessageContext)
    messageContext;

    @api autoInitialize;
    isLoading = true;

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.webcartId = data.cartId;
        }
    }

    @wire(CurrentPageReference)
    getUrlParameters(currentPageReference) {
        if (currentPageReference) {
            if (currentPageReference.attributes?.objectApiName == "OrderSummary") {
                if (isGuestUser) {
                    this.orderNumber = currentPageReference.attributes?.recordId;
                } else {
                    this.recordId = currentPageReference.attributes?.recordId;
                }
            } else {
                this.orderNumber = currentPageReference.state?.orderNumber;
                if (!isGuestUser) {
                    this.loggedInUser = true;
                }
            }
        }
    }

    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.isLoading = true;
        if (this.recordId || this.orderNumber) {
            this.getPaymentDetails();
        }
        this.subscribeToMessageChannel();
    }

    // @api runRenderedCallbackMethod=false;
    @api handleValueChange() {
        this.startLoading();
        this.getPaymentDetails();
    }

    startLoading() {
        this.isLoading = true;
    }

    stopLoading() {
        this.isLoading = false;
    }

    //common method to show toast
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

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, drMessageChannel, (message) =>
                this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        switch (message.purpose) {
            case "toggleShowPDComponent":
                this.toggleShowPDComponent(message.payload);
                break;
        }
    }

    toggleShowPDComponent(data) {
        let dataobj = JSON.parse(data);
        this.autoInitialize = dataobj?.isShow;
    }

    async getPaymentDetails() {
        if (isGuestUser || this.loggedInUser) {
            if (this.orderNumber) {
                await getSummaryId({ orderNumber: this.orderNumber.trim() })
                    .then((result) => {
                        this.recordId = result;
                    })
                    .catch((error) => {
                        console.log("GetPaymentDetails getSummaryId", error);
                    });
            }
        }
        if (isOrderConfirmationPage(this.recordId)) {
            getPaymentDetail({ orderSummaryId: this.recordId })
                .then((result) => {
                    let paymentDetail = JSON.parse(result);
                    if (paymentDetail.isSuccess) {
                        this.showPaymentDetails = true;
                        this.appliedPayments = paymentDetail.paymentDetails;
                    }
                })
                .catch((error) => {
                    console.log("drb2b_payment_Details_LWR getPaymentDetails error ", error);
                    this.isLoading = false;
                    this.showToast({ title: "Error", message: error.body.message, variant: "error" });
                })
                .finally(() => (this.isLoading = false));
        } else {
            getPaymentDetailByCartId({ cartId: this.webcartId })
                .then((result) => {
                    let paymentDetail = JSON.parse(result);
                    if (paymentDetail.isSuccess) {
                        //this.isGetPaymentButtonDisabled=true;
                        this.showPaymentDetails = true;
                        this.appliedPayments = paymentDetail.paymentDetails;
                        this.stopLoading();
                    }
                })
                .catch((error) => {
                    console.log("drb2b_payment_Details_LWR getPaymentDetailByCartId error", error);
                    this.isLoading = false;
                    this.showToast({ title: "Error", message: error.body.message, variant: "error" });
                })
                .finally(() => (this.isLoading = false));
        }
    }

    get showPayments() {
        return this.showPaymentDetails && this.autoInitialize;
    }
}

function isOrderConfirmationPage(recordId = "") {
    const orderSummaryIdPrefix = "1Os";
    return recordId.startsWith(orderSummaryIdPrefix);
}
