import { LightningElement, api, track, wire } from "lwc";
import getTaxIds from "@salesforce/apex/DRB2B_MyTaxIdentifierController.getTaxIdentifier";
import applyTaxIdenifier from "@salesforce/apex/DRB2B_MyTaxIdentifierController.applyTaxIdenifier";
import saveTaxId from "@salesforce/apex/DRB2B_MyTaxIdentifierController.saveTaxIdentifier";
import updateDRRemainingField from "@salesforce/apex/DRB2B_MyTaxIdentifierController.updateDRRemainingField";
import getCart from "@salesforce/apex/DRB2B_MyTaxIdentifierController.getCart";
import getUpdatedCart from "@salesforce/apex/DRB2B_MyTaxIdentifierController.getCart";
import TAX_ID_FIELD from "@salesforce/schema/Webcart.DR_Tax_Identifiers__c";
import CART_ID_FIELD from "@salesforce/schema/Webcart.Id";
import updateCart from "@salesforce/apex/DRB2B_BuyerInfoController.updateCart";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import { publish, subscribe, MessageContext, unsubscribe } from "lightning/messageService";
import { registerListener, unregisterAllListeners } from "c/pubsub";
import ToastContainer from "lightning/toastContainer";
import Toast from "lightning/toast";
import { getNamespacePrefix } from "c/commons";
import communityPath from "@salesforce/community/basePath";
import addError from "@salesforce/label/c.DR_TaxId_Add_Error_Msg";
import newTaxId from "@salesforce/label/c.DR_New_Tax_ID_Label";
import taxIdentifier from "@salesforce/label/c.DR_Tax_Identifiers";
import savedTaxId from "@salesforce/label/c.DR_Saved_TaxId";
import otherTaxId from "@salesforce/label/c.DR_Other_TaxId";
import applyTaxId from "@salesforce/label/c.DR_Apply_TaxId";
import applySucessError from "@salesforce/label/c.DR_TaxId_Apply_Error";
import applySuccessMsg from "@salesforce/label/c.DR_TaxId_Apply_Success";
import alreadySavedValidation from "@salesforce/label/c.DR_Already_Saved_validation";
import removedTaxIdSuccess from "@salesforce/label/c.DR_Removed_TaxId";
import allRemovedSuccess from "@salesforce/label/c.DR_All_TaxID_Removed_Success";
import close from "@salesforce/label/c.DR_Close_Label";
import { fireEvent } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";
import communityId from "@salesforce/community/Id";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import getCartIdWithCommunityId from "@salesforce/apex/DRB2B_CartHelper.getCartIdWithCommunityId";
import { CheckoutInformationAdapter } from "commerce/checkoutApi";
import { CheckoutComponentBase } from "commerce/checkoutApi";
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

export default class drb2b_taxIdentifier_LWR extends CheckoutComponentBase {
    @track taxData = [];
    @api selectedTax;
    isInitilized = false;
    isRendered = false;
    isConnectedCallback = false;
    @api webCartId;
    value = [];
    savedAndSelectedTaxidValues = [];
    showModal = false;
    selectedTaxIds = [];
    @track pillData = [];
    cart;
    removedPill;
    taxSize = 0;
    isLoading = true;
    addedTaxId = [];
    selectedSavedTaxIds = [];
    createPill = false;
    appliedOnce = false;
    _selectedTax = {};
    @api autoInitialize;
    showTIComponent = true;
    showTermsComponent;
    summary;
    _checkoutMode = 1;
    currentUser = true;

    label = {
        addError,
        newTaxId,
        taxIdentifier,
        savedTaxId,
        otherTaxId,
        applyTaxId,
        applySucessError,
        applySuccessMsg,
        close,
        alreadySavedValidation,
        removedTaxIdSuccess,
        allRemovedSuccess
    };

    @wire(MessageContext)
    messageContext;

    setAspect(newAspect /*CheckoutContainerAspect*/) {
        if (this.summary == newAspect.summary) {
            return;
        }
        this.summary = newAspect.summary;
        if (this.summary) {
            this.setCheckoutMode(3);
        } else {
            this.setCheckoutMode(4);
            this.setCheckoutMode(1);
        }
    }

    set checkoutMode(value) {
        this.setCheckoutMode(value);
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
    setCheckoutMode(value) {
        switch (value) {
            case 1:
                this.reset();
                this.isDisabled = true;
                break;
            case 2:
                this.isDisabled = true;
                break;
            case 3:
                this.isDisabled = true;
                break;
            case 4:
                this.isLoading = true;
                this.cart = null;
                this.getCartInfoRecord();
                this.isDisabled = false;
                break;
        }
        this._checkoutMode = value;
    }

    isReloadedCartData = false;
    reloadCartData() {
        if (!this.isReloadedCartData) {
            this.isReloadedCartData = true;
            this.getCartInfoRecord();
        }
    }

    @wire(CheckoutInformationAdapter, { recordId: "$recordId" })
    wiredRecord(result) {
        this.record = result;
        if (result.data && result.data.checkoutStatus == 200) {
            this.refreshData();
        }
    }

    refreshData() {
        this.getCartInfoRecord();
    }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.webCartId = data.cartId;
        } else if (error) {
            console.error(error);
        }
    }

    //-------------------------------
    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.startLoading();
        if (this.isInitilized) return;
        this.isInitilized = true;
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);
        this.subscribeToMessageChannel();
    }

    renderedCallback() {
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        this.currentUser = !isGuestUser;
        if (this.selectedTax) {
            let selectedTax = JSON.parse(this.selectedTax);
            if ("taxId" in selectedTax) this.value = selectedTax.taxId;
            if ("pill" in selectedTax) this.pillData = selectedTax.pill;
        }
        this.stopLoading();
    }

    getCartInfoRecord() {
         setTimeout(() => {
            this.getCartInfo();
        }, 1000);
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, dr_lms, (message) =>
                this.showTaxIdentifierComponent(message)
            );
        }
    }

    showTaxIdentifierComponent(message) {
        switch (message.purpose) {
            case "toggleShowTIComponent":
                this.toggleShowTIComponent(message.payload);
                break;
            case "reloadTIComponent":
                this.refreshData();
                // this.reloadTIComponent(message.payload);
                break;
            default:
                this.reloadTIComponent(message.payload);
        }
    }

    toggleShowTIComponent(data) {
        let dataobj = JSON.parse(data);
        this.showTIComponent = dataobj?.isShow; //dataobj;
        this.autoInitialize = dataobj?.isShow;
    }
    reloadTIComponent(data) {
        setTimeout(() => {
            this.template.querySelector("c-drb2b_my-tax-identifiers_-l-w-r").reloadTaxIDComponent();
        }, 500);
    }

    /*get showTIComponent() {
        return this.autoInitialize;
    }*/

    callResponseHandler(msg) {
        var url = window.location.protocol + "//" + window.location.hostname;
        if (msg.origin != url) {
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

    startLoading() {
        this.isLoading = true;
        publish(this.messageContext, dr_lms, {
            purpose: "taxIdentifierIsProcessing",
            payload: true
        });
    }

    stopLoading() {
        this.isLoading = false;
        publish(this.messageContext, dr_lms, {
            purpose: "taxIdentifierIsProcessing",
            payload: false
        });
    }

    @wire(CurrentPageReference)
    pageRef;

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        switch (msg.event) {
            case "taxidCheckout":
                this.isLoading = true;
                this.initilizeSave(msg.obj);
                break;
            case "notApplicableCheckout":
                this.isLoading = false;
                this.hideTaxIdentifierComp();
                break;
            case "hideLoader":
                this.showTaxSection();
                break;
        }
    }

    showTaxSection() {
        this.hideLoader();
        if (this.currentUser) {
            this.getTaxIds();
        }
    }

    hideTaxIdentifierComp() {
        this.template.querySelector(".taxidentifier").classList.add("slds-hide");
    }
    hideLoader() {
        this.template.querySelector(".taxidentifier").classList.remove("slds-hide");
    }
    initilizeSave(evt) {
        this.taxSize = Object.keys(evt).length;
        for (let taxid in evt) {
            let ajaxTaxID = {
                type: evt[taxid].type,
                value: evt[taxid].value
            };
            this.saveTaxIdentifier(ajaxTaxID);
        }
    }

    saveTaxIdentifier(data) {
        this.pillData = [];
        this.addedTaxId = [];
        saveTaxId({ jsonString: JSON.stringify(data), cartId: this.webCartId })
            .then((result) => {
                let response = JSON.parse(result);
                if (response.errors) {
                    this.showToast({ title: "Error", message: response.errors[0].message, variant: "error" });
                    this.isLoading = false;
                } else {
                    this.createPill = true;
                    this.addedTaxId.push(response.id);
                    if (this.addedTaxId.length != this.taxSize) return;
                    this.appyTaxIdToCheckout(this.addedTaxId);
                    this.value = [];
                }
            })
            .catch((error) => {
                this.showToast({ title: "Error", message: this.label.addError + ":" + data.value, variant: "error" });
                console.log("drb2b_taxIdentifier_LWR saveTaxIdentifier" + error);
            });
    }

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath + "vforcesite";
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    isInSitePreview = () =>
        ["sitepreview", "livepreview", "live-preview", "live.", ".builder."].some((substring) =>
            document.URL.includes(substring)
        );

    getCartInfo() {
        this.isPreview = this.isInSitePreview();
        if (!this.isPreview) {
            getCart({ cartId: this.webCartId })
                .then((result) => {
                    this.cart = result;
                    this.fireEventLWC();
                })
                .catch((error) => {
                    console.log("drb2b_taxIdentifier_LWR getCartid error" + error);
                });
        } else {
            return null;
        }
    }

    getTaxIds() {
        getTaxIds({ cartId: this.webCartId })
            .then((result) => {
                if (result) {
                    let taxIds = JSON.parse(result).taxIdentifiers;
                    if (taxIds) this.reformData(taxIds);
                }
            })
            .catch((error) => {
                console.log("drb2b_taxIdentifier_LWR getTaxIds error" + error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    reformData(data) {
        this.savedAndSelectedTaxidValues = data.map((ele) => ele.value);
        this.taxData = data.map((ele) => ({ ...ele, label: ele.value, value: ele.id }));
    }

    handleSelectTaxId(event) {
        this.selectedSavedTaxIds = event.detail.value;
        if (this.selectedSavedTaxIds == "" || this.selectedSavedTaxIds == undefined) {
            this.isLoading = true;
            this.appliedOnce = true;
            this.appyTaxIdToCheckout(this.selectedSavedTaxIds);
        }
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

    handleApplyTaxIdentifier() {
        this.startLoading();
        this.appliedOnce = true;
        this.appyTaxIdToCheckout(this.selectedSavedTaxIds);
    }

    async appyTaxIdToCheckout(data) {
        try {
            this.startLoading();
            this.pillData = [];
            let result = await applyTaxIdenifier({
                checkoutId: this.cart.drcheckoutId,
                taxIds: data,
                cartId: this.webCartId
            });
            let response = JSON.parse(result);
            if (response.errors) {
                this.showToast({
                    title: "Error",
                    message: this.label.applySucessError,
                    variant: "error"
                });
                this.isLoading = false;
                this.removedPill = null;
                this.createPill = false;
            } else {
                this.updateDRRemainingFieldJs(response);
            }
        } catch (error) {
            this.showToast({ title: "Error", message: JSON.stringify(error), variant: "error" });
        }
        this.stopLoading();
    }

    updateTaxIdCart(data) {
        const fields = {};
        fields[CART_ID_FIELD.fieldApiName] = this.webCartId;
        fields[TAX_ID_FIELD.fieldApiName] = data;
        updateCart({ cart: JSON.stringify(fields) })
            .then((result) => {})
            .catch((error) => {
                this.showToast({ title: "Error", message: JSON.stringify(error), variant: "error" });
            });
    }

    reset() {
        this.selectedTaxIds = [];
        this.pillData = [];
        //extra addition
        this.selectedSavedTaxIds = [];
        this.value = [];
    }

    get disableApply() {
        return this.selectedSavedTaxIds.length == 0 && !this.appliedOnce;
    }

    fireEventLWC() {
        if (!this.isConnected) return;
        let component = this;
        let pMessage = {
            event: "taxId",
            data: {
                session: this.cart.paymentSession,
                customerType: this.cart.customerType
            }
        };
        component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
    }

    iframeLoaded() {
        //  this.fireEventLWC();
    }

    handleRemoveTaxId(event) {
        this.removedPill = event.target.label;
        this.pillData = this.pillData.filter((ele) => ele.id != event.target.name);
        this.selectedTaxIds = this.selectedTaxIds.filter((ele) => ele != event.target.name);
        this.createPill = true;
        this.selectedSavedTaxIds = [];
        this.value = [];
        this.appyTaxIdToCheckout(this.pillData.map((ele) => ele.id));
    }

    handleCancel() {
        this.template.querySelector("c-drb2b-modal").close();
        this.showModal = false;
    }

    handleOpenTaxIdModal() {
        this.showModal = true;
        this.template.querySelector("c-drb2b-modal").open();
    }

    async updateDRRemainingFieldJs(response) {
        await updateDRRemainingField({ cartId: this.webCartId })
            .then((res) => {
                if (response != undefined && response.taxIdentifiers) {
                    this.createPill = true;
                } else {
                    this.createPill = false;
                }
                if (response != undefined && response.taxIdentifiers) {
                    if (this.createPill) {
                        for (let ele of response.taxIdentifiers) {
                            let pillData = { id: ele.id, value: ele.value };
                            this.pillData.push(pillData);
                        }
                        this._selectedTax.pill = this.pillData;
                        this.fireEventLWC();
                    }
                    let taxValues = response.taxIdentifiers.map((ele) => ele.value).join(", ");
                    let taxIds = response.taxIdentifiers.map((ele) => ele.id).join(", ");
                    this._selectedTax.taxId = taxIds;
                    this.updateTaxIdCart(taxIds);
                    if (this.removedPill)
                        this.showToast({
                            title: "Success",
                            message: `${this.label.removedTaxIdSuccess} :` + this.removedPill,
                            variant: "success"
                        });
                    else
                        this.showToast({
                            title: "Success",
                            message: `${this.label.applySuccessMsg} :` + taxValues,
                            variant: "success"
                        });
                } else {
                    this._selectedTax = {};
                    this.updateTaxIdCart("");
                    if (this.removedPill)
                        this.showToast({
                            title: "Success",
                            message: `${this.label.removedTaxIdSuccess} :` + this.removedPill,
                            variant: "success"
                        });
                    else
                        this.showToast({
                            title: "Success",
                            message: `${this.label.allRemovedSuccess} `,
                            variant: "success"
                        });
                }
                fireEvent(this.pageRef, "CALCULATE_TAX", "");
                const attributeChangeEvent = new FlowAttributeChangeEvent(
                    "selectedTax",
                    JSON.stringify(this._selectedTax)
                );
                this.dispatchEvent(attributeChangeEvent);
            })
            .catch((error) => {
                this.showToast({ title: "Error", message: JSON.stringify(error), variant: "error" });
            })
            .finally(() => {
                this.isLoading = false;
                this.removedPill = null;
                this.createPill = false;
            });
    }
}
