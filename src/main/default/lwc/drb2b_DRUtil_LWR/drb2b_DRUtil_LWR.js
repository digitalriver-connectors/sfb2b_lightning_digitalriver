import { LightningElement, wire } from "lwc";
import { fireEvent, unregisterAllListeners } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";
import clearAllDataLWR from "@salesforce/apex/DRB2B_CartService.clearAllDataLWR";
import { subscribe, MessageContext, publish, unsubscribe } from "lightning/messageService";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { CartSummaryAdapter } from "commerce/cartApi";
import { CheckoutInformationAdapter } from "commerce/checkoutApi";
import communityId from "@salesforce/community/Id";
import communityPath from "@salesforce/community/basePath";
import setIpAddress from "@salesforce/apex/DRB2B_CartService.setIpAddress";
import { getNamespacePrefix } from "c/commons";

export default class Drb2b_DRUtil_LWR extends LightningElement {
    webcartId;
    isRendered = false;

    @wire(CurrentPageReference)
    pageRef;

    @wire(MessageContext)
    messageContext;

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.webcartId = data.cartId;
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
            }
        }
    }

    connectedCallback() {
        this.getCartIdRecord();
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        fireEvent(this.pageRef, "CALCULATE_TAX", "");
        this.subscribeToMessageChannel();
    }

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath + "vforcesite";
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    iframeLoaded() {
        this.fireEventLWC();
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);
    }

    fireEventLWC() {
        let component = this;
        let pMessage = {
            event: "GetIPAddress",
            data: {
                code: "GetIPAddress"
            }
        };
        component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
        component.isLoading = false;
    }

    callResponseHandler(msg) {
        var url = window.location.protocol + "//" + window.location.hostname;
        if (msg.origin != url) {
            return false;
        }
        let component = this;
        component.handleVFResponse(msg.data);
    }

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        switch (msg.event) {
            case "GetIPAddress":
                let ipaddress = msg.obj;
                setIpAddress({ ipaddress: ipaddress, cartId: this.webcartId });
                break;
        }
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, dr_lms, (message) => this.handleMessageChannel(message));
        }
    }

    handleMessageChannel(message) {
        switch (message.purpose) {
            case "calculateTaxRefresh":
                publish(this.messageContext, dr_lms, {
                    purpose: "reloadPaymentComponent"
                });
                publish(this.messageContext, dr_lms, {
                    purpose: "reloadTIComponent"
                });
                fireEvent(this.pageRef, "CALCULATE_TAX", "");
                break;
            default:
                break;
        }
    }

    //get Cart record and clear all cart Data

    getCartIdRecord() {
        this.clearAllCartData(this.webcartId);
        this.isLoading = false;
    }

    clearAllCartData(cartIdJs) {
        if (this.webcartId !== undefined) {
            clearAllDataLWR({ cartId: cartIdJs }).catch((error) => {
                console.log("Error facing while clear  data", JSON.stringify(error));
            });
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}
