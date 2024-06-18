import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { registerListener, unregisterAllListeners } from "c/pubsub";
const POST_ADDRESS = "postAddress";
import billtoLabel from "@salesforce/label/c.DR_Bill_TO_Label";
import shiptoLabel from "@salesforce/label/c.DR_Ship_To_Label";
import getAddressesDetails from "@salesforce/apex/DRB2B_AddressDetailsController.getAddressesDetails";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { subscribe, MessageContext } from "lightning/messageService";

export default class DRB2B_AddressDetails extends LightningElement {
    @track addresses;
    @api recordId;
    @api showShippingAddress;
    isRendered = false;
    @track billingAddress = [];
    @track shippingAddress = [];

    @wire(CurrentPageReference)
    pageRef;

    @wire(MessageContext) messageContext;

    labels = {
        billtoLabel,
        shiptoLabel
    };

    renderedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
        this.getAddressesDetails();
        registerListener("CALCULATE_TAX", this.getUpdatedAddress, this);
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, dr_lms, (message) => this.handleMessage(message));
        }
    }

    handleMessage(message) {
        switch (message.purpose) {
            case "reloadAddressDetails":
                this.getAddressesDetails();
                break;
        }
    }

    //get address details
    getAddressesDetails() {
        getAddressesDetails({ CartId: this.recordId })
            .then((result) => {
                let response = JSON.parse(result);
                this.billingAddress = response.billingAddress;
                if ("DeliverToCountry" in response.shippingAddress) {
                    this.shippingAddress = response.shippingAddress;
                } else {
                    this.shippingAddress = null;
                }
            })
            .catch((error) => {
                console.log("error " + error);
            });
    }

    //listen to CALCULATE_TAX event and get updated address
    getUpdatedAddress() {
        this.getAddressesDetails();
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}
