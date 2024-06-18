import { LightningElement, api, track, wire } from "lwc";
import addCustomerCreditSourceToCheckout from "@salesforce/apex/digitalriverv3.DRB2B_CustomerCreditService.addCustomerCreditSourceToCheckout";
import deattachPaymentToCheckout from "@salesforce/apex/digitalriverv3.DRB2B_CustomerCreditService.deattachPaymentToCheckout";
import getCartDetailsById from "@salesforce/apex/digitalriverv3.DRB2B_CustomerCreditService.getCartDetailsById";
import Toast from "lightning/toast";
import ToastContainer from "lightning/toastContainer";
import { publish, MessageContext } from "lightning/messageService";
import dr_lms from "@salesforce/messageChannel/digitalriverv3__DigitalRiverMessageChannel__c";
import currencyCode from "@salesforce/i18n/number.currencySymbol";
import { CartSummaryAdapter } from "commerce/cartApi";

export default class Drb2b_CustomerCredit_LWR extends LightningElement {
    initilized = false;
    isLoading = false;
    @api webcartId;
    @track amount;
    createPill = false;
    pillValue;
    pillId;
    @track showCustomerCreditMocker = false;
    @track pillData = [];

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

    set checkoutMode(value) {
        switch (value) {
            case 3:
                this.pillData = [];
        }
        this._checkoutMode = value;
    }
    connectedCallback() {
        if (this.initilized) return;
        this.initilized = true;
        this.startLoading();
    }

    startLoading() {
        this.isLoading = true;
        publish(this.messageContext, dr_lms, {
            purpose: "customerCreditIsProcessing",
            payload: true
        });
    }

    stopLoading() {
        this.isLoading = false;
        publish(this.messageContext, dr_lms, {
            purpose: "customerCreditIsProcessing",
            payload: false
        });
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

    @wire(MessageContext)
    messageContext;

    handleReloadDropin() {
        publish(this.messageContext, dr_lms, {
            purpose: "reloadDropin"
        });
    }

    handleReloadPaymentBasedOnCustomerCredit() {
        publish(this.messageContext, dr_lms, {
            purpose: "reloadPaymentCC"
        });
    }

    handleReloadCheckoutSummary() {
        publish(this.messageContext, dr_lms, {
            purpose: "reloadCheckoutSummary"
        });
    }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.webcartId = data.cartId;
            if (this.webcartId != null && this.webcartId != undefined) {
                this.getCartDetails();
            }
        } else if (error) {
            console.error(error);
        }
    }

    getCartDetails() {
        getCartDetailsById({ cartId: this.webcartId })
            .then((result) => {
                this.showCustomerCreditMocker = !result;
            })
            .catch((error) => {
                console.log("error " + error);
            })
            .finally(() => {
                this.stopLoading();
            });
    }

    handleAddCustomerCredit(event) {
        this.startLoading();
        var ccAmount = this.template.querySelector("[data-id=amount]").value;
        addCustomerCreditSourceToCheckout({
            inputData: JSON.stringify({
                cartId: this.webcartId,
                amount: ccAmount
            })
        })
            .then((result) => {
                this.template.querySelector("[data-id=amount]").value = "";
                if (result.isSuccess) {
                    this.createPill = true;
                    this.pillValue = "Customer Credit " + currencyCode + ccAmount;
                    this.pillId = result.sourceId;
                    let pillData = { id: this.pillId, value: this.pillValue };
                    this.pillData.push(pillData);
                    this.handleReloadCheckoutSummary();
                    this.handleReloadPaymentBasedOnCustomerCredit();
                    this.handleReloadDropin();
                } else {
                    this.showToast({ title: "Error", message: result.errorMessage, variant: "error" });
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log("\n\n DRB2B CustomerCreditLWR error => " + JSON.stringify(error, null, 2));
                this.showToast({ title: "Error", message: error.body.message, variant: "error" });
            });
        this.stopLoading();
    }

    handleRemoveCustomerCredit(event) {
        this.startLoading();
        var sourceId = event.target.name;
        deattachPaymentToCheckout({
            inputData: JSON.stringify({
                cartId: this.webcartId,
                sourceId: sourceId
            })
        })
            .then((result) => {
                if (result.isSuccess) {
                    this.fireEvent(this.pageRef, "Remove_Customer_Credit");
                    this.pillData = this.pillData.filter((elem) => elem.id != sourceId);
                    this.createPill = true;
                    this.showToast({ title: "Success", message: "Successfully removed", variant: "success" });
                    this.handleReloadDropin();
                    this.handleReloadCheckoutSummary();
                } else {
                    this.showToast({ title: "Error", message: result.errorMessage, variant: "error" });
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log(
                    "\n\nDRB2B_CustomerCreditLWR deattachPaymentToCheckout error => " + JSON.stringify(error, null, 2)
                );
                this.showToast({ title: "Error", message: error.body.message, variant: "error" });
            });
        this.stopLoading();
    }

    /**
     * Fires an event to listeners.
     * @param {object} pageRef - Reference of the page that represents the event scope.
     * @param {string} eventName - Name of the event to fire.
     * @param {*} payload - Payload of the event to fire.
     */
    fireEvent(pageRef, eventName, payload) {
        if (events[eventName]) {
            const listeners = events[eventName];
            listeners.forEach((listener) => {
                try {
                    listener.callback.call(listener.thisArg, payload);
                } catch (error) {
                    // fail silently
                }
            });
        }
    }
}
