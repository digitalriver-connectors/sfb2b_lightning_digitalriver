import { LightningElement, api, track, wire } from "lwc";
import getTaxAndFee from "@salesforce/apex/DRB2B_CheckoutSummaryController.getTaxAndFee";
import { registerListener, unregisterAllListeners } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";
// Import custom labels
import totalDuty from "@salesforce/label/c.DR_Total_Duty";
import totalFee from "@salesforce/label/c.DR_Total_Fee";
import shipping from "@salesforce/label/c.DR_Shipping";
import grandTotal from "@salesforce/label/c.DR_Grand_Total";
import tax from "@salesforce/label/c.DR_Generic_Tax";
import total from "@salesforce/label/c.DR_Generic_Total";
import IOR from "@salesforce/label/c.DR_IOR";
import amountContributed from "@salesforce/label/c.DR_Amount_Contributed";
import remainingAmount from "@salesforce/label/c.DR_Remaining_Amount";

import promotion from "@salesforce/label/c.DR_Promotions";
import reloadCheckoutSummary from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { subscribe, MessageContext } from "lightning/messageService";
import { CheckoutInformationAdapter } from "commerce/checkoutApi";
import { CartSummaryAdapter } from "commerce/cartApi";
import communityId from "@salesforce/community/Id";

export default class drb2b_checkOut_Summary_LWR extends LightningElement {
    @api recordId;
    @track cart;
    isRendered = false;
    adapterFlag = false;
    @api isFullLayout = false;
    @api isDutyEnabled;
    @api isShippingEnabled;
    @api isFeeEnabled;
    @api isIOREnabled;
    @api isTaxEnabled;
    @api isGrandTotalEnabled;
    @api isSubtotalEnabled;
    @api isShowAll;
    @api showAmountContributed;
    @api showRemainingAmount;
    @api showPromotion;
    subscription = null;
    newCheckoutId = null;
    prevCheckoutId = null;

    @wire(CurrentPageReference)
    pageRef;

    labels = {
        totalDuty,
        totalFee,
        shipping,
        grandTotal,
        tax,
        total,
        IOR,
        amountContributed,
        remainingAmount,
        promotion
    };

    @wire(CheckoutInformationAdapter, { recordId: "$recordId" })
    wiredRecord(result) {
        this.record = result;
        if (result.data && result.data.checkoutStatus == 200) {
            {
                this.refreshData();
            }
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

    refreshData() {
        this.getUpdatedTaxFromAdapter();
    }

    @wire(MessageContext) messageContext;

    renderedCallback() {
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        registerListener("CALCULATE_TAX", this.getUpdatedTaxFromListener, this);
        registerListener("HIDE_CHECKOUT_SUMMARY_COMPONENT", this.toggleDisplayCheckoutSummary, this);
        this.getTaxAndFee();
        this.isLoading = false;
        this.subscribeToMessageChannel();
    }

    //this method will show/hide checkout summary component as per HIDE_CHECKOUT_SUMMARY_COMPONENT event
    toggleDisplayCheckoutSummary(evt) {
        this.isShowAll = !evt;
    }

    getUpdatedTaxFromAdapter() {
        this.cart = null;
        this.adapterFlag = true;
        this.getTaxAndFee();
    }

    getUpdatedTaxFromListener() {
        this.cart = null;
        this.adapterFlag = false;
        this.getTaxAndFee();
    }

    getTaxAndFee() {
        if (this.recordId != null || this.recordId != undefined) {
        getTaxAndFee({ cartId: this.recordId })
            .then((result) => {
                if (this.adapterFlag) {
                    this.newCheckoutId = result.drcheckoutId;
                    if (this.newCheckoutId != null && this.prevCheckoutId != this.newCheckoutId) {
                        this.cart = result;
                    }
                    if (this.cart == null && result != null) {
                        this.cart = result;
                    }
                    this.prevCheckoutId = this.newCheckoutId;
                } else {
                    this.cart = result;
                }
            })
            .catch((error) => {
                console.log("drb2b_checkOut_Summary_LWR error from getTaxAndFee", error);
            });
        }
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, reloadCheckoutSummary, (message) =>
                this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        switch (message.purpose) {
            case "reloadCheckoutSummary":
                this.getUpdatedTaxFromListener();
                break;
            case "toggleShowCSComponent":
                this.toggleShowCSComponent(message.payload);
                break;
        }
    }

    toggleShowCSComponent(data) {
        let dataobj = JSON.parse(data);
        this.isShowAll = dataobj?.isShow; //dataobj;
    }

    get showDuty() {
        return this.cart.hasLandedCost && this.isDutyEnabled;
    }

    get showFee() {
        return this.isFeeEnabled && this.cart.totaFee != 0;
    }

    get showIOR() {
        return this.cart.hasLandedCost && this.isIOREnabled;
    }

    get showTax() {
        return this.isTaxEnabled;
    }

    get showGrandTotal() {
        return this.isGrandTotalEnabled;
    }

    get showAmountContributedToCheckout() {
        if (this.cart.amountContributed != this.cart.grandTotalAmount) {
            return this.cart.amountContributed && this.showAmountContributed;
        } else {
            return false;
        }
    }

    get showPromotions() {
        if (this.cart.totalAdjustmentAmount) {
            return this.cart.totalAdjustmentAmount && this.showPromotion;
        } else {
            return false;
        }
    }

    get showRemainingAmountToBeContributed() {
        if (this.cart.amountContributed != this.cart.grandTotalAmount) {
            return this.cart.remainingAmount && this.showRemainingAmount;
        } else {
            return false;
        }
    }

    get hideCustomerCreditFields() {
        if (this.cart.grandTotalAmount == this.cart.remainingAmount) {
            return false;
        } else {
            return true;
        }
    }

    get showShipping() {
        return this.isShippingEnabled;
    }

    get ShowSubtotal() {
        return this.isSubtotalEnabled;
    }

    get subtotal() {
        return this.cart.totalAmount - this.cart.totaFee - this.cart.IOR - this.cart.totalDuty;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}
