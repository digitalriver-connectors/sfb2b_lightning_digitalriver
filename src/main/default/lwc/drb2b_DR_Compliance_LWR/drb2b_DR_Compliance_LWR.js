import { LightningElement, api, wire } from "lwc";
import communityPath from "@salesforce/community/basePath";
import communityId from "@salesforce/community/Id";
import { getNamespacePrefix } from "c/commons";
import getCartEntity from "@salesforce/apex/DRB2B_DrElementController.getCartEntity";
import getComplianceAddress from "@salesforce/apex/DRB2B_DrElementController.getComplianceAddress";
import getOrderEntity from "@salesforce/apex/DRB2B_ComplainceController.getSellingEntity";
import getOrderComplianceAddress from "@salesforce/apex/DRB2B_ComplainceController.getOrderComplianceAddress";
import { registerListener, unregisterAllListeners } from "c/pubsub";
import { CartSummaryAdapter } from "commerce/cartApi";

const CART_API_NAME = "Webcart";

//WEBCART FIELD
import SELLING_ENTITY_FIELD from "@salesforce/schema/Webcart.DR_Selling_Entity__c";
import { MessageContext, subscribe } from "lightning/messageService";
import drMessageChannel from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { CheckoutInformationAdapter } from "commerce/checkoutApi";

let drSFCartId = "";
let drSFSummaryId = "";
let prevCartEntity = "";
let newCartEntity = "";

export default class DRB2B_DrCompliance_LWR extends NavigationMixin(LightningElement) {
    @api header;
    @api objectApiName;
    @api cartId;
    @api useDefaultSellingEntity;
    isRendered = false;
    isConnectedCallback = false;
    isLoading = false;
    isInitialized = false;
    cartEntity;
    drSFSummaryOrCartId;
    @api recordId;
    cart;

    @wire(CheckoutInformationAdapter, { recordId: "$recordId", fields: [SELLING_ENTITY_FIELD] })
    wiredRecord(result) {
        this.record = result;
        if (result.data && result.data.checkoutStatus == 200) {
            this.refreshData();
        }
    }

    refreshData() {
        if (!this.useDefaultSellingEntity) {
            this.getCartEntityJs();
        }
    }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.recordId = data.cartId;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(MessageContext) messageContext;
    @wire(CurrentPageReference)
    getUrlParameters(currentPageReference) {
        if (currentPageReference) {
            if (currentPageReference.attributes?.objectApiName == "OrderSummary") {
                this.recordId = currentPageReference.attributes?.recordId;
            } else {
                this.recordId = currentPageReference.state?.orderNumber;
            }
        }
    }

    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        drSFSummaryId = this.recordId;
        if (this.isInitialized) return;
        this.isInitialized = false;
        this.prevCartEntity = "";
        this.newCartEntity = "";
        this.isLoading = true;
        this.subscribeToMessageChannel();
    }

    renderedCallback() {
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        let urlPrm = window.location.href;
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
        registerListener("CALCULATE_TAX", this.getCartEntityJs, this);
        if (!this.useDefaultSellingEntity) {
            if (this.recordId && this.recordId.startsWith("1Os")) {
                this.getSellingEntityFromOrderSummaryId(this.recordId);
                return;
            } else {
                this.objectApiName == CART_API_NAME || (this.recordId && this.recordId.startsWith("0a6"))
                    ? this.getCartEntityJs()
                    : this.fireEventLWC();
            }
        } else {
            this.fireEventLWC();
        }
    }

    getSellingEntityFromOrderSummaryId(recordId) {
        getOrderEntity({ recordId: recordId })
            .then((result) => {
                if (result) this.cartEntity = { entity: result };
                this.getDrSFCartId();
            })
            .catch((error) => {
                console.log("DRB2B_DRCompliance getSellingEntityFromOrderSummaryId Error", error);
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
                console.log("DRB2B_DRCompliance getDrSFCartId Error", error);
            });
    }

    async getCartEntityJs() {
        if (this.recordId != undefined && this.recordId.startsWith("0a6")) {
            await getCartEntity({ cartId: this.recordId })
                .then((result) => {
                    if (result) {
                        let cart = JSON.parse(result);
                        this.cartEntity = { entity: cart[SELLING_ENTITY_FIELD.fieldApiName] };
                        if (this.cartEntity == undefined || this.cartEntity.entity == undefined) {
                            this.fireEventLWC();
                        } else {
                            this.newCartEntity = this.cartEntity;
                            if (
                                this.newCartEntity != undefined &&
                                this.prevCartEntity != undefined &&
                                ((this.newCartEntity.entity != undefined && this.prevCartEntity.entity == undefined) ||
                                    (this.newCartEntity.entity == undefined &&
                                        this.prevCartEntity.entity != undefined) ||
                                    (this.newCartEntity.entity != undefined &&
                                        this.newCartEntity.entity != this.prevCartEntity.entity))
                            ) {
                                this.getComplianceData();
                            }
                            this.prevCartEntity = this.newCartEntity;
                        }
                    }
                })
                .catch((error) => {
                    console.log("DRB2B_DRCompliance getCartEntityJs Error", error);
                });
        }
    }

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath + "vforcesite";
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    cartShippingCountry;
    cartBillingCountry;
    cartLanguage;
    cartType;

    async getComplianceData() {
        if (!this.recordId.startsWith("1Os")) {
            this.drSFSummaryOrCartId = this.recordId;
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
                console.log("DRB2B_DRCompliance getComplianceData Error displaying Compliance component", error);
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
