import { LightningElement, wire, api } from "lwc";
import { fireEvent } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";
export default class DRB2B_HideCheckoutSummary extends LightningElement {
    isRendered = false;
    @api hideCheckoutSummary;

    @wire(CurrentPageReference)
    pageRef;

    connectedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
        fireEvent(this.pageRef, "HIDE_CHECKOUT_SUMMARY_COMPONENT",this.hideCheckoutSummary);
    }
}