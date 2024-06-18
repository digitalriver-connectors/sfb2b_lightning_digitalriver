import { LightningElement, track, api, wire } from "lwc";

import getPaymentDetail from "@salesforce/apex/DRB2B_PaymentDetails.getPaymentDetail";
import getPaymentDetailByCartId from "@salesforce/apex/DRB2B_PaymentDetails.getPaymentDetailByCartId";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import paymentInformation from "@salesforce/label/c.DR_Payment_Information";
import creditCard from "@salesforce/label/c.DR_Credit_Card";
import wiretransfer from "@salesforce/label/c.DR_Wire_Transfer";
import wiretransferInformation from "@salesforce/label/c.DR_Delayed_Payment_Information";

import { MessageContext, subscribe } from "lightning/messageService";
import drMessageChannel from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";

const columns = [
    { label: "", fieldName: "key", type: "text" },
    { label: "", fieldName: "value", type: "text" }
];

export default class Drb2b_PaymentDetails extends LightningElement {
    initilized = false;
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

    @api autoInitilize;

    connectedCallback() {
        if (this.initilized) return;
        this.initilized = true;
        this.isLoading = true;
        this.getPaymentDetails();
        this.subscribeToMessageChannel();
    }
    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
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
        this.autoInitilize = dataobj?.isShow;
    }

    getPaymentDetails() {
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
                    console.log(error);
                    this.isLoading = false;
                    this.showToast({ message: error.body.message, variant: "error" });
                })
                .finally(() => (this.isLoading = false));
        } else {
            getPaymentDetailByCartId({ cartId: this.webcartId })
                .then((result) => {
                    let paymentDetail = JSON.parse(result);
                    if (paymentDetail.isSuccess) {
                        this.showPaymentDetails = true;
                        this.appliedPayments = paymentDetail.paymentDetails;
                    }
                })
                .catch((error) => {
                    console.log(error);
                    this.isLoading = false;
                    this.showToast({ message: error.body.message, variant: "error" });
                })
                .finally(() => (this.isLoading = false));
        }
    }

    get showPayments() {
        return this.showPaymentDetails && this.autoInitilize;
    }
}

function isOrderConfirmationPage(recordId = "") {
    const orderSummaryIdPrefix = "1Os";
    return recordId.startsWith(orderSummaryIdPrefix);
}
