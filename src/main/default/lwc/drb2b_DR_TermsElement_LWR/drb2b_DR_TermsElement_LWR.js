import { track, api, wire } from "lwc";
import communityPath from "@salesforce/community/basePath";
import { getNamespacePrefix } from "c/commons";
import getCartEntity from "@salesforce/apex/DRB2B_DrElementController.getCartEntity";
import getComplianceAddress from "@salesforce/apex/DRB2B_DrElementController.getComplianceAddress";
import updateTerms from "@salesforce/apex/DRB2B_TermsController.updateCheckoutWithTerms";
import drTermsError from "@salesforce/label/c.DR_Terms_ERROR";
import Toast from "lightning/toast";
import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";
import communityId from "@salesforce/community/Id";

import { publish, subscribe, unsubscribe, MessageContext } from "lightning/messageService";
import toggleCheckboxMS from "@salesforce/messageChannel/DRTermsMessageChannel__c";

//WEBCART FIELD
import SELLING_ENTITY_FIELD from "@salesforce/schema/WebCart.DR_Selling_Entity__c";
import RECURRING_FIELD from "@salesforce/schema/WebCart.Recurring_Line_Item_Count__c";
const US_LOCALE = "EN_US";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import showPlaceOrderButton from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";

import getCartIdWithCommunityId from "@salesforce/apex/DRB2B_CartHelper.getCartIdWithCommunityId";
import ToastContainer from "lightning/toastContainer";
import { CheckoutComponentBase } from "commerce/checkoutApi";
import { CartSummaryAdapter } from "commerce/cartApi";

const CheckoutStage = {
    CHECK_VALIDITY_UPDATE: "CHECK_VALIDITY_UPDATE",
    REPORT_VALIDITY_SAVE: "REPORT_VALIDITY_SAVE",
    BEFORE_PAYMENT: "BEFORE_PAYMENT",
    PAYMENT: "PAYMENT",
    BEFORE_PLACE_ORDER: "BEFORE_PLACE_ORDER",
    PLACE_ORDER: "PLACE_ORDER"
};

export default class dRB2B_DrTermsElement_LWR extends CheckoutComponentBase {
    @track drDisclosure;
    showTermsCheckbox = false;
    isInitialized = false;
    isRendered = false;
    isConnectedCallback = false;
    isLoading = false;
    locale;
    acceptedDisclosureAsString = "";
    showAutoRenewalForSubs = false;
    @api header;
    @api recordId;
    @api objectApiName;
    @api webcartId;
    @api bypassValidation;
    @api hideTermsUI;
    @api autoInitialize;
    isError = false;
    isFireFromPlaceOrder = false;
    termsString;
    acceptedTerms;
    isSubscriptionProduct = false;
    summary;
    _checkoutMode = 1;
    isExecuted = false;

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath + "vforcesite";
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }
    labels = {
        drTermsError
    };

    @wire(MessageContext)
    messageContext;

    //-------------------------------
    _checkedByDefault;
    checked;
    showError = false;
    _checkoutMode = 1;
    isDisabled = false;
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

    set checkoutMode(value) {
        this.setCheckoutMode(value);
    }
    /**
     * @type {CheckoutMode}
     */
    @api get checkoutMode() {
        return this._checkoutMode;
    }
    setCheckoutMode(value) {
        switch (value) {
            case 1:
                this.isLoading = true;
                this.hideTermsUI = false;
                this.cart = null;
                this.showTermElement();
                this.isDisabled = false;
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

    connectedCallback() {
        if (this.isInitialized) return;
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.isLoading = true;
        this.isInitialized = true;
        this.hideTermsUI = false;
        this.subscribeToMessageChannel();
        let component = this;
        window.addEventListener("message", function (event) {
            let url = window.location.protocol + "//" + window.location.hostname;
            if (event.origin != url) {
                return false;
            }
            component.handleVFResponse(event.data);
        });
    }

    renderedCallback() {
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        registerListener("SHOW_TERMS_ELEMENT", this.showTermElement, this);
    }
    showTermElement() {
        this.hideTermsUI = false;
        this.autoInitialize = true;
    }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.webcartId = data.cartId;
            this.recordId = data.cartId;
            this.isLoading = false;
        } else if (error) {
            console.error(error);
        }
    }

    handlePreviousButton() {
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    isInSitePreview = () =>
        ["sitepreview", "livepreview", "live-preview", "live.", ".builder."].some((substring) =>
            document.URL.includes(substring)
        );

    async getCartEntityJs() {
        if (this.webcartId == undefined || this.webcartId == null) {
            this.isPreview = this.isInSitePreview();
        }
        getCartEntity({ cartId: this.webcartId })
            .then((result) => {
                if (result) {
                    let cart = JSON.parse(result);
                    this.isSubscriptionProduct = cart[RECURRING_FIELD.fieldApiName] > 0;
                    this.cartEntity = { entity: cart[SELLING_ENTITY_FIELD.fieldApiName] };
                }
                this.getComplianceData();
            })
            .catch((error) => {
                console.log("DRB2BTermsElement error:", error);
            });
    }

    cartShippingCountry;
    cartBillingCountry;
    cartLanguage;
    cartType;

    async getComplianceData() {
        await getComplianceAddress({ CartId: this.webcartId })
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
                console.log("DRB2BTermsElement error", error);
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
            event: "terms",
            data: arrayVar
        };

        this.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
        this.isLoading = false;
    }

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        this.locale = msg.locale;
        switch (msg.event) {
            case "DRterms":
                this.constructDrTerms(msg.obj);
                break;
        }
    }

    iframeLoaded() {
        this.getCartEntityJs();
    }

    constructDrTerms(msg) {
        if (!this.isExecuted) {
            this.isExecuted = true;
            this.drDisclosure = msg.disclosure;
            this.termsString = msg.disclosure.autorenewalPlanTerms.localizedText;
            this.showTermsCheckbox = true;
            this.acceptedTerms = `${this.drDisclosure.confirmDisclosure.localizedText}`;
            if (this.isSubscriptionProduct) this.acceptedTerms = `${this.acceptedTerms} ${this.termsString}`;

            publish(this.messageContext, toggleCheckboxMS, {
                isSelected: false,
                termsString: this.acceptedTerms
            });
        }
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, dr_lms, (message) => this.validateCheckBox(message));
        }
    }

    validateCheckBox(message) {
        if (message.purpose == "checkTermsAndConditions") {
            let checkValidation = this.validate();
            this.isFireFromPlaceOrder = true;
            if (checkValidation.isValid) {
                this.isError = false;
                if (this.bypassValidation && this.isSubscriptionProduct) {
                    this.updateTerms();
                }
                fireEvent(this.pageRef, "PLACE_ORDER", "");
                this.handlePreviousButton();
            } else {
                this.isError = true;
                console.log("DRB2BTermsElement Error Select Terms Element");
            }
        } else if (message.purpose == "updateCheckoutWithTermsString") {
            if (this.isSubscriptionProduct) {
                this.updateTerms();
            }
            fireEvent(this.pageRef, "PLACE_ORDER", "");
        } else if (message.purpose == "toggleShowTermsComponent") {
            this.toggleShowTermsComponent(message.payload);
        }
    }

    toggleShowTermsComponent(data) {
        let dataobj = JSON.parse(data);
        this.hideTermsUI = !dataobj?.isShow; //dataobj;
        this.autoInitialize = dataobj?.isShow;
    }
    @api
    validate() {
        this.checkValidity();
        return this.handleNextClick();
    }

    allValid = false;
    checkValidity() {
        this.allValid = [...this.template.querySelectorAll(".input")].reduce((validSoFar, inputCmp) => {
            return validSoFar && inputCmp.checkValidity();
        }, true);
    }

    handleNextClick() {
        if (this.isSubscriptionProduct) {
            if (!this.isFireFromPlaceOrder) {
                this.updateTerms();
            }
        }
        if (this.bypassValidation) {
            return { isValid: true };
        } else {
            if (this.allValid) {
                return { isValid: true };
            } else if (!this.allValid) {
                this.showToast({ title: "Error", message: this.labels.drTermsError, variant: "error" });
            }
            return { isValid: false, errorMessage: "" };
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

    disconnectedCallback() {
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    updateTerms() {
        updateTerms({ cartId: this.webcartId, terms: this.termsString })
            .then((result) => {})
            .catch((error) => {
                console.log("DRB2BTermsElement updateTerms error:", error);
            });
    }

    handleCheckBoxChange(event) {
        this.isError = false;
        publish(this.messageContext, toggleCheckboxMS, {
            isSelected: event.target.checked,
            termsString: this.acceptedTerms
        });
        if (!this.bypassValidation) {
            let data = {
                isShow: event.target.checked
            };
            publish(this.messageContext, showPlaceOrderButton, {
                purpose: "toggleShowPOComponent",
                payload: JSON.stringify(data)
            });
        }
    }
}