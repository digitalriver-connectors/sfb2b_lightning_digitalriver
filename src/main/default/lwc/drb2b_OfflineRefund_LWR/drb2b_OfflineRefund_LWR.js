import { LightningElement, wire,api } from "lwc";
import getDROrderIdFromOrderSummary from "@salesforce/apex/DRB2B_OrderSummaryController.getDROrderIdFromOrderSummary";
import getRefunds from "@salesforce/apex/DRB2B_OrderService.getRefundsWithPendingInformation";
import getSummaryId from "@salesforce/apex/DRB2B_OrderSummaryController.getSummaryId";
import refundHeading from "@salesforce/label/c.DR_Refund_Heading";
import msgNoRefundData from "@salesforce/label/c.DR_Msg_No_Refund_Data";
import msgRefundFormSubmitted from "@salesforce/label/c.DR_Msg_Refund_Form_Submitted";
import { getNamespacePrefix } from "c/commons";
import communityPath from "@salesforce/community/basePath";
import communityId from "@salesforce/community/Id";
import isGuestUser from "@salesforce/user/isGuest";

// For event publisher
import { MessageContext, subscribe } from "lightning/messageService";
import drMessageChannel from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { CurrentPageReference } from 'lightning/navigation';

const eventType = "offlineRefundForm";

export default class drb2b_OfflineRefund_LWR extends LightningElement {
    orderNumber;
    drOrderId;
    refunds;
    isRefundAvailable;
    @wire(MessageContext) messageContext;
    isLoading = false;
    isSpinning = false;
    isConnectedCallback = false;
    isRefundFormSubmitted = false;
    @api summaryId;
    labels = {
        refundHeading,
        msgNoRefundData,
        msgRefundFormSubmitted
    };

    
    @wire(CurrentPageReference)
    getUrlParameters(currentPageReference) {
       if (currentPageReference) {
        if(currentPageReference.attributes?.objectApiName=="OrderSummary")
        {
            this.summaryId = currentPageReference.attributes?.recordId; 
        }
       }
    }



    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.getDROrderIdFromOrderSummary(this.summaryId);
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);
        this.subscribeToMessageChannel();
    }

    callResponseHandler(msg) {
        let url = window.location.protocol + "//" + window.location.hostname;
        if (msg.origin != url) {
            return false;
        }
        let component = this;
        component.handleVFResponse(msg.data);
    }

    async getDROrderIdFromOrderSummary(summaryId) {
        if (isGuestUser) {
            await getSummaryId({ orderNumber: summaryId })
                .then((result) => {
                    this.orderNumber = result;
                })
                .catch((error) => {
                    console.log("error " + error);
                })
                .finally(() => (this.isLoading = false));
        } else {
            this.orderNumber = this.summaryId;
        }
        getDROrderIdFromOrderSummary({ summaryId: this.orderNumber })
            .then((result) => {
                this.drOrderId = result;
                this.getRefunds();
            })
            .catch((error) => {
                console.log("error " + error);
            })
            .finally(() => (this.isLoading = false));
    }

    getRefunds() {
        getRefunds({ drOrderId: this.drOrderId })
            .then((result) => {
                let response = result;
                this.refunds = JSON.parse(response);
                if (this.refunds.length > 0) {
                    this.isRefundAvailable = true;
                } else {
                    this.isRefundAvailable = false;
                }
            })
            .catch((error) => {
                console.log("error " + error);
            })
            .finally(() => (this.isLoading = false));
    }

    handleOfflineRefundForm(event) {
        this.fireEventLWC(event.currentTarget.dataset.token);
        this.isSpinning = true;
    }
    disconnectedCallback() {
        window.removeEventListener("message", this._listenForMessage);
    }
    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath + "vforcesite";
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    fireEventLWC(evt) {
        let component = this;
        let pMessage = {
            event: eventType,
            data: {
                code: evt
            }
        };
        component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
    }
    iframeLoaded() {
        this.fireEventLWC();
    }

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        switch (msg.event) {
            case "successMountRefund":
                this.showRefundForm = true;
                this.isSpinning = false;
                break;
            case "refundFormSubmitted":
                this.isRefundFormSubmitted = msg.obj;
                break;
        }
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, drMessageChannel, (message) =>
                this.handleMessage(message)
            );
        }
    }
    handleMessage(message) {
        if (message.purpose == "reloadOfflineRefund") {
            this.fireEventLWC("unmountRefundForm");
            this.getRefunds();
            this.isRefundFormSubmitted = false;
        }
    }
}
