import { LightningElement, api, wire } from "lwc";
import communityPath from "@salesforce/community/basePath";
import communityId from "@salesforce/community/Id";
import { getNamespacePrefix } from "c/commons";
import getCartEntity from "@salesforce/apex/DRB2B_DrElementController.getCartEntity";
import getComplianceAddress from "@salesforce/apex/DRB2B_DrElementController.getComplianceAddress";
import getOrderEntity from "@salesforce/apex/DRB2B_ComplainceController.getSellingEntity";
import getOrderComplianceAddress from "@salesforce/apex/DRB2B_ComplainceController.getOrderComplianceAddress";
import { registerListener, unregisterAllListeners } from "c/pubsub";
const CART_API_NAME = "Webcart";

//WEBCART FIELD
import SELLING_ENTITY_FIELD from "@salesforce/schema/Webcart.DR_Selling_Entity__c";
import { MessageContext, subscribe } from "lightning/messageService";
import drMessageChannel from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";

import { NavigationMixin } from "lightning/navigation";

let drSFCartId = "";
let drSFSummaryId = "";

export default class DRB2B_DrCompliance extends NavigationMixin(LightningElement) {
    @api header;
    @api recordId;
    @api objectApiName;
    isRenderd = false;
    isLoading = false;
    isIntilized = false;
    cartEntity;
    drSFSummaryOrCartId;

    @wire(MessageContext) messageContext;

    connectedCallback() {
        drSFSummaryId = this.recordId;
        if (this.isIntilized) return;
        this.isIntilized = false;
        this.isLoading = true;
        this.subscribeToMessageChannel();
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
            case "reloadCompliance":
                this.iframeLoaded();
                break;
        }
    }

    iframeLoaded() {
        // if (this.isRenderd) return;
        // this.isRenderd = true;
        registerListener("CALCULATE_TAX", this.getCartEntityJs, this);
        if (this.recordId && this.recordId.startsWith("1Os")) {
            this.getSellingEntityFromOrderSummaryId(this.recordId);
            return;
        }
        this.objectApiName == CART_API_NAME || (this.recordId && this.recordId.startsWith("0a6"))
            ? this.getCartEntityJs()
            : this.fireEventLWC();
    }

    getSellingEntityFromOrderSummaryId(recordId) {
        getOrderEntity({ recordId: recordId })
            .then((result) => {
                if (result) this.cartEntity = { entity: result };
                this.getDrSFCartId();
            })
            .catch((error) => {
                console.log("error:", error);
            });
    }
    async getDrSFCartId() {
        await getOrderComplianceAddress({ summaryId: this.recordId })
            .then((data) => {
                drSFCartId = JSON.parse(data).DR_SF_CartId;
                this.drSFSummaryOrCartId = drSFCartId;
                this.getComplianceData();
            })
            .catch((error) => {
                console.log("error:", error);
            });
    }

    async getCartEntityJs() {
        await getCartEntity({ cartId: this.recordId })
            .then((result) => {
                if (result) {
                    let cart = JSON.parse(result);
                    this.cartEntity = { entity: cart[SELLING_ENTITY_FIELD.fieldApiName] };
                }
                this.getComplianceData();
            })
            .catch((error) => {
                console.log("error cartEntity:", error);
            });
    }

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath.slice(0, communityPath.lastIndexOf("/s"));
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    cartShippingCountry;
    cartBillingCountry;
    cartLanguage;
    cartType;

    async getComplianceData() {
        if (!this.recordId.startsWith("1Os")) {
            this.drSFSummaryOrCartId = drSFSummaryId;
        }

        await getComplianceAddress({ CartId: this.drSFSummaryOrCartId })
            .then((result) => {
                if (result) {
                    let cart = JSON.parse(result);
                    this.cartBillingCountry = "billToCountry" in cart ? cart.billToCountry : undefined;
                    this.cartShippingCountry = "shipToCountry" in cart ? cart.shipToCountry : undefined;
                    this.cartType = cart.cartType;
                    this.cartLanguage = cart.userLanguage;
                }
                this.fireEventLWC();
            })
            .catch((error) => {
                console.log("error", error);
            });
    }

    fireEventLWC() {
        let component = this;
        let arrayVar = {};
        arrayVar.cartEntity = this.cartEntity;
        arrayVar.cartshipToCountry = this.cartShippingCountry;
        arrayVar.cartBillToCountry = this.cartBillingCountry;
        arrayVar.cartType = this.cartType;
        arrayVar.cartLanguage = this.cartLanguage;
        let pMessage = {
            event: "compliance",
            data: arrayVar
        };

        component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
        component.isLoading = false;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}
