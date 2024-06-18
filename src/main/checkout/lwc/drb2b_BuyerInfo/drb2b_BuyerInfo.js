import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getAddresses from "@salesforce/apex/DRB2B_BuyerInfoController.getAddresses";
import updateCart from "@salesforce/apex/DRB2B_BuyerInfoController.updateCart";
import updateCartDeliveryGroup from "@salesforce/apex/DRB2B_BuyerInfoController.updateCartDeliveryGroup";
import { fireEvent } from "c/pubsub";

//WEBCART FIELD
import CART_CUSTOMER_TYPE from "@salesforce/schema/Webcart.DR_Customer_Type__c";
import CART_ID_FIELD from "@salesforce/schema/Webcart.Id";
import CART_BILL_STREET_FIELD from "@salesforce/schema/Webcart.BillingStreet";
import CART_BILL_CITY_FIELD from "@salesforce/schema/Webcart.BillingCity";
import CART_BILL_COUNTRY_FIELD from "@salesforce/schema/Webcart.BillingCountry";
import CART_BILL_STATE_FIELD from "@salesforce/schema/Webcart.BillingState";
import CART_BILL_CODE_FIELD from "@salesforce/schema/Webcart.BillingPostalCode";
import CDG_CART_ID_FIELD from "@salesforce/schema/CartDeliveryGroup.CartId";
import CDG_SHIP_STREET_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToStreet";
import CDG_SHIP_CITY_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToCity";
import CDG_SHIP_COUNTRY_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToCountry";
import CDG_SHIP_STATE_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToState";
import CDG_SHIP_CODE_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToPostalCode";
import BUYER_EMAIL_FIELD from "@salesforce/schema/Webcart.Buyer_Email__c";
import BUYER_NAME_FIELD from "@salesforce/schema/Webcart.Buyer_Name__c";
import BUYER_PHONE_FIELD from "@salesforce/schema/Webcart.Buyer_Phone__c";
import DR_ORGANIZATION_NAME from "@salesforce/schema/Webcart.Buyer_OrganizationName__c";

//USER FIELD
import USER_NAME_FIELD from "@salesforce/schema/User.Name";
import USER_EMAIL_FIELD from "@salesforce/schema/User.Email";
import USER_PHONE_FIELD from "@salesforce/schema/User.Phone";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import USER_ID from "@salesforce/user/Id";
// Import custom labels
import updateCartError from "@salesforce/label/c.DR_Error_Update_Cart";
import fieldMissError from "@salesforce/label/c.DR_Genric_Req_Field_Miss_Error";
import businessValue from "@salesforce/label/c.DR_Business_Val";
import individualValue from "@salesforce/label/c.DR_Individual_Val";
import nameLabel from "@salesforce/label/c.DR_Name_Label";
import emailLabel from "@salesforce/label/c.DR_Email_Label";
import phoneLabel from "@salesforce/label/c.DR_Phone_Label";
import billtoLabel from "@salesforce/label/c.DR_Bill_TO_Label";
import shiptoLabel from "@salesforce/label/c.DR_Ship_To_Label";
import taxCertificatesLink from "@salesforce/label/c.DR_TAX_CERTIFICATES_LINK";

import { publish, MessageContext, subscribe,unsubscribe } from "lightning/messageService";
import toggleShowTC from "@salesforce/messageChannel/TaxCertificateMessageChannel__c";
import drMessageChannel from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";

const US = "UNITED STATES";
const PURCHASE_TYPE = "DIGITAL";
const BILLING_TYPE = "BILLING";
const SHIPPING_TYPE = "SHIPPING";
const BIllTO_FIELD = "BILLTO";
const POST_ADDRESS = "postAddress";
const BUSINESS_VAL = "business";
const INDIVIDUAL_VAL = "individual";
const CART_TYPE = "Digital";
export default class Drb2b_BuyerInfo extends LightningElement {
    @api webcartId;
    @api contactPointAddressId;
    @api enableTaxcertificates;
    @track billingAddresses;
    @track shippingAddresses;
    @api showShippingAddress;
    currentUser;
    cartType;
    selectedShippingValue;
    selectedBillingValue;
    selectedPurchaseType = "";
    isRendered = false;
    isLoading = true;
    isShow = true;
    subscription = null;
    isVisibleOrganizationName = false;
    organizationName;
    @track showLink;

    labels = {
        updateCartError,
        fieldMissError,
        businessValue,
        individualValue,
        nameLabel,
        emailLabel,
        phoneLabel,
        billtoLabel,
        shiptoLabel,
        taxCertificatesLink
    };

    //get contact point addresses and cart type
    getAddresses() {
        getAddresses({ CartId: this.webcartId })
            .then((result) => {
                let response = JSON.parse(result);
                this.cartType = response.cartType;
                this.organizationName = response.organizationName;
                this.filterArray(JSON.parse(response.contactPointAddress));
            })
            .catch((error) => {
                console.log("error " + error);
            })
            .finally(() => (this.isLoading = false));
    }

    renderedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
        this.getAddresses();
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, drMessageChannel, (message) =>
                this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        switch (message.purpose) {
            case "toggleShowBIComponent":
                this.toggleShowCSComponent(message.payload);
                break;
            case "saveBuyerInfo":
                this.validate();
                break;
        }
    }

    //method will be used to show/hide component
    toggleShowCSComponent(data) {
        let dataobj = JSON.parse(data);
        this.isShow = dataobj?.isShow;
    }

    @wire(CurrentPageReference)
    pageRef;

    //get Logged in user info
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USER_NAME_FIELD, USER_EMAIL_FIELD, USER_PHONE_FIELD]
    })
    wireuser({ error, data }) {
        if (error) {
            this.showToast({ message: JSON.stringify(error), variant: "error" });
        } else if (data) {
            this.currentUser = data.fields;
        }
    }

    @wire(MessageContext)
    messageContext;

    //set purchase type based on selected address
    setDefaultPurchaseType(country) {
        if (country == US) {
            this.selectedPurchaseType = INDIVIDUAL_VAL;
            this.isVisibleOrganizationName = false;
        } else {
            this.selectedPurchaseType = BUSINESS_VAL;
            this.isVisibleOrganizationName = true;
        }
    }

    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }

    get purchaseTypeOption() {
        return [
            { label: this.labels.businessValue, value: BUSINESS_VAL },
            { label: this.labels.individualValue, value: INDIVIDUAL_VAL }
        ];
    }

    filterArray(data) {
        let addresses = [];
        let address = data.map((ele) => ({
            ...ele,
            label:
                ele.Address.street +
                "," +
                ele.Address.city +
                "," +
                ele.Address.state +
                " " +
                ele.Address.postalCode +
                " " +
                ele.Address.country,
            value: ele.Id
        }));

        for (let ele of address) {
            ele.label = ele.label.replaceAll("null", "");
            ele.label = ele.label.replaceAll("null,", "");
            addresses.push(ele);
        }

        this.shippingAddresses = addresses.filter((ele) => ele.AddressType.toUpperCase() == SHIPPING_TYPE);
        this.billingAddresses = addresses.filter((ele) => ele.AddressType.toUpperCase() == BILLING_TYPE);

        let selectedShippingAddress = addresses.filter(
            (ele) => ele.AddressType.toUpperCase() == SHIPPING_TYPE && ele.IsDefault
        )[0];
        let selectedBillingAddress = addresses.filter(
            (ele) => ele.AddressType.toUpperCase() == BILLING_TYPE && ele.IsDefault
        )[0];

        this.selectedShippingValue = selectedShippingAddress.Id;
        this.selectedBillingValue = selectedBillingAddress.Id;

        this.cartType && this.cartType.toUpperCase() == PURCHASE_TYPE
            ? this.setDefaultPurchaseType(selectedBillingAddress.Address.country.toUpperCase())
            : this.setDefaultPurchaseType(selectedShippingAddress.Address.country.toUpperCase());
    }

    fireAddressEvent() {
        let countries = {
            shipTo: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].label,
            billTo: this.billingAddresses.filter((ele) => ele.Id == this.selectedBillingValue)[0].label,
            cartType: this.cartType
        };
        fireEvent(this.pageRef, POST_ADDRESS, countries);
    }

    updateCart() {
        const fields = {};
        fields[CART_ID_FIELD.fieldApiName] = this.webcartId;
        fields[CART_CUSTOMER_TYPE.fieldApiName] = this.selectedPurchaseType;
        fields[CART_BILL_STREET_FIELD.fieldApiName] = this.billingAddresses.filter(
            (ele) => ele.Id == this.selectedBillingValue
        )[0].Address.street;
        fields[CART_BILL_CITY_FIELD.fieldApiName] = this.billingAddresses.filter(
            (ele) => ele.Id == this.selectedBillingValue
        )[0].Address.city;
        fields[CART_BILL_COUNTRY_FIELD.fieldApiName] = this.billingAddresses.filter(
            (ele) => ele.Id == this.selectedBillingValue
        )[0].Address.country;
        fields[CART_BILL_STATE_FIELD.fieldApiName] = this.billingAddresses.filter(
            (ele) => ele.Id == this.selectedBillingValue
        )[0].Address.state;
        fields[CART_BILL_CODE_FIELD.fieldApiName] = this.billingAddresses.filter(
            (ele) => ele.Id == this.selectedBillingValue
        )[0].Address.postalCode;
        fields[BUYER_NAME_FIELD.fieldApiName] = this.template.querySelector("[data-id=buyerName]").value;
        fields[BUYER_PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-id=buyerPhone]").value;
        fields[BUYER_EMAIL_FIELD.fieldApiName] = this.template.querySelector("[data-id=buyerEmail]").value;
        if(this.isVisibleOrganizationName){
            fields[DR_ORGANIZATION_NAME.fieldApiName] = this.template.querySelector("[data-id=organizationName]").value;   
        }

        updateCart({ cart: JSON.stringify(fields) })
            .then((result) => {})
            .catch((error) => {
                this.showToast({ message: JSON.stringify(error), variant: "error" });
            });
    }


    updateCartDeliveryGroup() {
         const fields = {};
         fields[CDG_CART_ID_FIELD.fieldApiName] = this.webcartId;
         fields[CDG_SHIP_STREET_FIELD.fieldApiName] = this.shippingAddresses.filter(
            (ele) => ele.Id == this.selectedShippingValue
        )[0].Address.street;
        fields[CDG_SHIP_CITY_FIELD.fieldApiName] = this.shippingAddresses.filter(
            (ele) => ele.Id == this.selectedShippingValue
        )[0].Address.city;
        fields[CDG_SHIP_COUNTRY_FIELD.fieldApiName] = this.shippingAddresses.filter(
            (ele) => ele.Id == this.selectedShippingValue
        )[0].Address.country;
        fields[CDG_SHIP_STATE_FIELD.fieldApiName] = this.shippingAddresses.filter(
            (ele) => ele.Id == this.selectedShippingValue
        )[0].Address.state;
        fields[CDG_SHIP_CODE_FIELD.fieldApiName] = this.shippingAddresses.filter(
            (ele) => ele.Id == this.selectedShippingValue
        )[0].Address.postalCode;
     
        updateCartDeliveryGroup({ cartdelivery: JSON.stringify(fields) })
            .then((result) => {})
            .catch((error) => {
                this.showToast({ message: JSON.stringify(error), variant: "error" });
            });
    }

    handleAddressChange(event) {
        if (event.target.name.toUpperCase() == BIllTO_FIELD) {
            this.selectedBillingValue = event.target.value;
        } else {
            this.selectedShippingValue = event.target.value;
        }
        let selectedCountry = {
            shipTo: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].Address.country,
            billTo: this.billingAddresses.filter((ele) => ele.Id == this.selectedBillingValue)[0].Address.country,
            cartType: this.cartType,
            purchaseType: this.selectedPurchaseType
        };
        if (!this.showShippingAddress) {
            selectedCountry.shipTo = this.billingAddresses.filter(
                (ele) => ele.Id == this.selectedBillingValue
            )[0].Address.country;
        }

        if (
            selectedCountry.cartType == CART_TYPE &&
            selectedCountry.purchaseType == BUSINESS_VAL &&
            selectedCountry.billTo == "United States"
        ) {
            this.showLink = true;
        } else if (
            selectedCountry.cartType != CART_TYPE &&
            selectedCountry.purchaseType == BUSINESS_VAL &&
            selectedCountry.shipTo == "United States"
        ) {
            this.showLink = true;
        } else {
            this.showLink = false;
        }
        publish(this.messageContext, toggleShowTC, {
            showLink: this.showLink
        });
    }

    @api
    validate() {
        this.checkValidity();
        // Event is published to send contact point address Id
        if (this.showShippingAddress) {
            publish(this.messageContext, drMessageChannel, {
                purpose: 'contactPointAddressId',
                payload: this.selectedShippingValue
            });
        }else{
            publish(this.messageContext, drMessageChannel, {
                purpose: 'contactPointAddressId',
                payload: this.selectedBillingValue
            });
        }
        return this.handleNextClick();
    }

    valiateFields() {
        this.checkValidity();
        return this.handleNextClick();
    }

    handleNextClick() {
        if (this.cartType && this.allValid) {
            this.fireAddressEvent();
            this.updateCart();
            if (this.showShippingAddress) {
                this.updateCartDeliveryGroup();
                const attributeChangeEvent = new FlowAttributeChangeEvent(
                    "contactPointAddressId",
                    this.selectedShippingValue
                );
                this.dispatchEvent(attributeChangeEvent);
                return { isValid: true };
            } else {
                const attributeChangeEvent = new FlowAttributeChangeEvent(
                    "contactPointAddressId",
                    this.selectedBillingValue
                );
                this.dispatchEvent(attributeChangeEvent);
                return { isValid: true };
            }
        } else if (!this.cartType) {
            this.showToast({ message: this.labels.updateCartError, variant: "error" });
        } else if (!this.allValid) {
            this.showToast({ message: this.labels.fieldMissError, variant: "error" });
        }
        return { isValid: false, errorMessage: "" };
    }

    handlePurchaseTypeChange(event) {
        this.selectedPurchaseType = event.target.value;
        if(this.selectedPurchaseType == BUSINESS_VAL){
            this.isVisibleOrganizationName = true;
        }else{
            this.isVisibleOrganizationName = false;
        }
        let selectedCountry = {
            shipTo: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].Address.country,
            billTo: this.billingAddresses.filter((ele) => ele.Id == this.selectedBillingValue)[0].Address.country,
            cartType: this.cartType
        };
        if (!this.showShippingAddress) {
            selectedCountry.shipTo = this.billingAddresses.filter(
                (ele) => ele.Id == this.selectedBillingValue
            )[0].Address.country;
        }
        if (
            this.selectedPurchaseType == BUSINESS_VAL &&
            selectedCountry.cartType == CART_TYPE &&
            selectedCountry.billTo == "United States"
        ) {
            this.showLink = true;
        } else if (
            this.selectedPurchaseType == BUSINESS_VAL &&
            selectedCountry.cartType != CART_TYPE &&
            selectedCountry.shipTo == "United States"
        ) {
            this.showLink = true;
        } else {
            this.showLink = false;
        }

        publish(this.messageContext, toggleShowTC, {
            showLink: this.showLink
        });
    }

    handleTaxCertificates() {
        this.template.querySelector("c-drb2b-modal").open();
    }

    
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    allValid = false;
    checkValidity() {
        this.allValid = [...this.template.querySelectorAll(".input")].reduce((validSoFar, inputCmp) => {
            return validSoFar && inputCmp.checkValidity();
        }, true);
    }
}
