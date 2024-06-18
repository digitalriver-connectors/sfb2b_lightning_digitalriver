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

export default class Drb2b_CheckoutSummary extends LightningElement {
    @api recordId;
    @track cart;
    isRendered = false;
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

    @wire(MessageContext) messageContext;

    renderedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
        registerListener("CALCULATE_TAX", this.getUpdatedTax, this);
        registerListener("HIDE_CHECKOUT_SUMMARY_COMPONENT", this.toggleDisplayCheckoutSummary, this);
        this.getTaxAndFee();
        this.subscribeToMessageChannel();
    }

    //this method will show/hide checkout summary component as per HIDE_CHECKOUT_SUMMARY_COMPONENT event
    toggleDisplayCheckoutSummary(evt) {
        this.isShowAll = !evt;
    }

    getUpdatedTax() {
        // this.isFullLayout = true;
        this.cart = null;
        this.getTaxAndFee();
    }

    getTaxAndFee() {
        getTaxAndFee({ cartId: this.recordId })
            .then((result) => {
                this.cart = result;
            })
            .catch((error) => {
                console.log(error);
            });
        //.finally(() => (this.isLoading = false));
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
                this.getTaxAndFee();
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
        //return this.isFullLayout && this.isShippingEnabled;
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
