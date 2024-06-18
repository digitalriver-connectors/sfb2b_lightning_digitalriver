import { LightningElement, wire } from "lwc";
import { fireEvent } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";

export default class Drb2b_DRUtil extends LightningElement {
    isRendered = false;

    @wire(CurrentPageReference)
    pageRef;

    connectedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
        fireEvent(this.pageRef, "CALCULATE_TAX", "");
    }
}