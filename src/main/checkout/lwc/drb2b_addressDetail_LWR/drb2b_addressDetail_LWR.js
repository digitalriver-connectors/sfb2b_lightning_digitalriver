import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { registerListener, unregisterAllListeners } from "c/pubsub";
const POST_ADDRESS = "postAddress";
const RELOAD_ADDRESS = "reloadAddress";
import billtoLabel from "@salesforce/label/c.DR_Bill_TO_Label";
import shiptoLabel from "@salesforce/label/c.DR_Ship_To_Label";
import getAddressesDetails from "@salesforce/apex/DRB2B_AddressDetailsController.getAddressesDetails";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import { subscribe, MessageContext } from "lightning/messageService";
import getCartIdWithCommunityId from "@salesforce/apex/DRB2B_CartHelper.getCartIdWithCommunityId";
import communityId from "@salesforce/community/Id";
import { CartSummaryAdapter } from "commerce/cartApi";

export default class drb2b_addressDetail_LWR extends LightningElement {
    @track addresses;
    @api recordId;
    @api showShippingAddress;
    @api showBillingAddress;
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
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        this.getAddressesDetails();
        this.isLoading = false;
        registerListener("RELOAD_ADDRESS", this.getAddressesDetails, this);
        registerListener("CALCULATE_TAX", this.getAddressesDetails, this);
        this.subscribeToMessageChannel();
    }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.recordId = data.cartId;
            if (this.recordId) {
                this.getAddressesDetails();
                this.isLoading = false;
            }
        } else if (error) {
            console.error(error);
        }
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
        if (this.recordId != null || this.recordId != undefined) {
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
    }

    //listen to CALCULATE_TAX event and get updated address
    getUpdatedAddress() {
        this.getAddressesDetails();
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}
