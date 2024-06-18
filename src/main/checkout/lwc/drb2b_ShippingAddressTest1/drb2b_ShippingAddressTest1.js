import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";

//WEBCART FIELD

//USER FIELD

import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from "lightning/flowSupport";

// Import custom labels

const shiptoLabel = "Ship To Test";
const PURCHASE_TYPE = "DIGITAL";
const BILLING_TYPE = "BILLING";
const SHIPPING_TYPE = "SHIPPING";
const POST_ADDRESS = "postAddress";

export default class Drb2b_ShippingAddressTest1 extends LightningElement {
    @api webcartId;
    @api contactPointAddressId;
    @track shippingAddresses;
    currentUser;
    selectedShippingValue;

    labels = {
        shiptoLabel
    };

    renderedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
        //this.getAddresses();
    }

    @wire(CurrentPageReference)
    pageRef;

    @api
    validate() {
        return this.handleNextClick();
    }

    handleNextClick() {
        this.selectedShippingValue = this.template.querySelector("[data-id=shipTo]").value;
        const attributeChangeEvent = new FlowAttributeChangeEvent("contactPointAddressId", this.selectedShippingValue);
        this.dispatchEvent(attributeChangeEvent);
        return { isValid: true };
    }
}
