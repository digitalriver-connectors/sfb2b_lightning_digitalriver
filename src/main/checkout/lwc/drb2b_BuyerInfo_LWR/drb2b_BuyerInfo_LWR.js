import { api, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getAddresses from "@salesforce/apex/DRB2B_BuyerInfoController.getAddresses";
import updateCart from "@salesforce/apex/DRB2B_BuyerInfoController.updateCart";
import updateCartDeliveryGroup from "@salesforce/apex/DRB2B_BuyerInfoController.updateCartDeliveryGroup";
import { fireEvent } from "c/pubsub";

//WEBCART FIELD
import CART_CUSTOMER_TYPE from "@salesforce/schema/WebCart.DR_Customer_Type__c";
import CART_ID_FIELD from "@salesforce/schema/WebCart.Id";
import CART_BILL_STREET_FIELD from "@salesforce/schema/WebCart.BillingStreet";
import CART_BILL_CITY_FIELD from "@salesforce/schema/WebCart.BillingCity";
import CART_BILL_COUNTRY_FIELD from "@salesforce/schema/WebCart.BillingCountry";
import CART_BILL_STATE_FIELD from "@salesforce/schema/WebCart.BillingState";
import CART_BILL_CODE_FIELD from "@salesforce/schema/WebCart.BillingPostalCode";
import CDG_CART_ID_FIELD from "@salesforce/schema/CartDeliveryGroup.CartId";
import CDG_SHIP_FIRSTNAME_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToFirstName";
import CDG_SHIP_LASTNAME_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToLastName";
import CDG_SHIP_NAME_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToName";
import CDG_SHIP_STREET_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToStreet";
import CDG_SHIP_CITY_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToCity";
import CDG_SHIP_COUNTRY_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToCountry";
import CDG_SHIP_STATE_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToState";
import CDG_SHIP_CODE_FIELD from "@salesforce/schema/CartDeliveryGroup.DeliverToPostalCode";
import CDG_ORDERDELIVERYMETHODID from "@salesforce/schema/CartDeliveryGroup.DeliveryMethodId";

import BUYER_EMAIL_FIELD from "@salesforce/schema/WebCart.Buyer_Email__c";
import BUYER_NAME_FIELD from "@salesforce/schema/WebCart.Buyer_Name__c";
import BUYER_PHONE_FIELD from "@salesforce/schema/WebCart.Buyer_Phone__c";
import DR_ORGANIZATION_NAME from "@salesforce/schema/WebCart.Buyer_OrganizationName__c";
import GUEST_EMAIL_FIELD from "@salesforce/schema/WebCart.GuestEmailAddress";
import GUEST_FIRSTNAME_FIELD from "@salesforce/schema/WebCart.GuestFirstName";
import GUEST_LASTNAME_FIELD from "@salesforce/schema/WebCart.GuestLastName";
import GUEST_PHONE_FIELD from "@salesforce/schema/WebCart.GuestPhoneNumber";

//USER FIELD
import USER_NAME_FIELD from "@salesforce/schema/User.Name";
import USER_EMAIL_FIELD from "@salesforce/schema/User.Email";
import USER_PHONE_FIELD from "@salesforce/schema/User.Phone";
import { getRecord } from "lightning/uiRecordApi";
import ToastContainer from "lightning/toastContainer";
import Toast from "lightning/toast";

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

import { publish, MessageContext, subscribe, unsubscribe } from "lightning/messageService";
import toggleShowTC from "@salesforce/messageChannel/TaxCertificateMessageChannel__c";
import drMessageChannel from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import getCartIdWithCommunityId from "@salesforce/apex/DRB2B_CartHelper.getCartIdWithCommunityId";
import communityId from "@salesforce/community/Id";
import {
    CheckoutComponentBase,
    CheckoutInformationAdapter,
    updateContactInformation,
    updateShippingAddress,
    waitForCheckout,
    loadCheckout
} from "commerce/checkoutApi";
import { CartSummaryAdapter } from "commerce/cartApi";
import { getPicklistValuesByRecordType, getObjectInfo } from "lightning/uiObjectInfoApi";
import CPA_OBJECT from "@salesforce/schema/ContactPointAddress";
import getcountryPicklistIsEnabled from "@salesforce/apex/DRB2B_BuyerInfoController.getcountryPicklistIsEnabled";
import { AppContextAdapter } from "commerce/contextApi";

const US = "UNITED STATES";
const PURCHASE_TYPE = "DIGITAL";
const BILLING_TYPE = "BILLING";
const SHIPPING_TYPE = "SHIPPING";
const BIllTO_FIELD = "BILLTO";
const POST_ADDRESS = "postAddress";
const RELOAD_ADDRESS = "reloadAddress";
const BUSINESS_VAL = "business";
const INDIVIDUAL_VAL = "individual";
const CART_TYPE = "Digital";

const CheckoutStage = {
    CHECK_VALIDITY_UPDATE: "CHECK_VALIDITY_UPDATE",
    REPORT_VALIDITY_SAVE: "REPORT_VALIDITY_SAVE",
    BEFORE_PAYMENT: "BEFORE_PAYMENT",
    PAYMENT: "PAYMENT",
    BEFORE_PLACE_ORDER: "BEFORE_PLACE_ORDER",
    PLACE_ORDER: "PLACE_ORDER"
};
export default class Drb2b_BuyerInfo_LWR extends CheckoutComponentBase {
    @api webcartId;
    @api contactPointAddressId;
    @api enableTaxcertificates;
    @track billingAddresses;
    @track shippingAddresses;
    @api showShippingAddress;
    @api recordId;
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
    @api guestUser = false;
    @track showLink;
    supportedshippingCountryCode;
    supportedshippingCountryList;
    isRenderedAddress = false;

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

    @wire(CheckoutInformationAdapter, { recordId: "$recordId" })
    wiredRecord(result) {
        this.record = result;
        if (result.data && result.data.checkoutStatus == 200) {
            {
                this.checkoutId = result.data.checkoutId;
            }
        }
    }

    @wire(AppContextAdapter)
    wiredRecord(result) {
        if (result) {
            this.supportedshippingCountryCode = result.data.shippingCountries;
        } else if (error) {
            console.error('Drb2b_Buyer supportedshippingCountryCode not loaded from SF adapter AppContextAdapter' , error);
        }
    }

    //------------------------------------------------------326 START
    @wire(getObjectInfo, { objectApiName: CPA_OBJECT })
    objectInfo;

    guestUserSelectedBillingCountry = "";
    guestUserSelectedBillingState = "";
    guestUserSelectedShippingCountry = "";
    guestUserSelectedShippingState = "";
    isCountryStateEnabled = false;

    countryOptions;
    controllerValues;
    billingStateOptions;
    shippingStateOptions;
    countryPicklistData;
    countryNameWithISOCode = new Map();
    stateNameWithISO = new Map();

    @wire(getcountryPicklistIsEnabled)
    setupCountryPicklist({ data, error }) {
        if (data) {
            this.isCountryStateEnabled = data.isCountryStateEnabled;
        }
        if (error) {
            console.log("DRB2B_BuyerinfoLWR setupCountryPicklist Error::>>", error);
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: CPA_OBJECT,
        recordTypeId: "$objectInfo.data.defaultRecordTypeId"
    })
    async wiredPropertyOrFunction({ data, error }) {
        if (this.isCountryStateEnabled == false) {
            await getcountryPicklistIsEnabled().then((result) => {
                this.isCountryStateEnable = result.isCountryStateEnabled;
            });
        }
        if (data) {
            if (this.isCountryStateEnabled) {
                this.countryPicklistData = data;
                this.controllerValues = data.picklistFieldValues.StateCode.controllerValues;
                let filterPicklistValue = this.getPicklistValuesArray(
                    data.picklistFieldValues.CountryCode,
                    "label",
                    "value"
                );
                this.countryOptions = filterPicklistValue.picklistValues;
                this.supportedshippingCountryList = filterPicklistValue.supportedShipToCountryList;
                this.countryNameWithISOCode = filterPicklistValue.countryWithISOCode;
                this.getStatesByCountry(data.picklistFieldValues.StateCode);
            }
        }
        if (error) {
            console.log("error=> " + JSON.stringify(error));
        }
    }

    statesByCountry = new Map();
    getStatesByCountry = (states) => {
        states.values.forEach((item) => {
            let listOfItems = [];
            if (this.statesByCountry[item.validFor[0]]) {
                listOfItems = this.statesByCountry[item.validFor[0]];
            }
            listOfItems.push(item);
            this.statesByCountry[item.validFor[0]] = listOfItems;
        });
    };

    getPicklistValuesArray = (picklistValue, labelField, valueField) => {
        let picklistValues = [];
        let i;
        let picklistData = picklistValue;
        let countryWithISOCode = new Map();
        let shipToCountry = [];
        if (picklistData) {
            for (i = 0; i < picklistData.values.length; i++) {
                let picklistValue = {};
                picklistValue.label = picklistData.values[i][labelField];
                picklistValue.value = picklistData.values[i][valueField];
                picklistValues.push(picklistValue);
                countryWithISOCode[picklistData.values[i][valueField]] = picklistData.values[i][labelField];
                if (this.supportedshippingCountryCode.includes(picklistData.values[i][valueField])) {
                    shipToCountry.push(picklistValue);
                }
            }
            return {
                picklistValues: picklistValues,
                countryWithISOCode: countryWithISOCode,
                supportedShipToCountryList: shipToCountry
            };
        }
    };
    stateNameWithISO = new Map();
    handleBillingOptions(event) {
        this.guestUserSelectedBillingCountry = event.detail.country;
        if (this.isCountryStateEnabled && event.detail.country) {
            this.billingStateOptions = this.statesByCountry[this.controllerValues[event.detail.country]];
            if (this.billingStateOptions != undefined) {
                this.billingStateOptions.forEach((item) => {
                    this.stateNameWithISO[item.value] = item.label;
                });
            }
        }
        this.guestUserSelectedBillingState = event.detail.province;
    }

    stateNameWithISOforShipping = new Map();
    handleShippingOptions(event) {
        this.guestUserSelectedShippingCountry = event.detail.country;
        if (this.isCountryStateEnabled && event.detail.country) {
            this.shippingStateOptions = this.statesByCountry[this.controllerValues[event.detail.country]];
            if (this.shippingStateOptions != undefined) {
                this.shippingStateOptions.forEach((item) => {
                    this.stateNameWithISOforShipping[item.value] = item.label;
                });
            }
        }
        this.guestUserSelectedShippingState = event.detail.province;
    }
    //------------------------------------------------------326 END

    summary;
    _checkoutMode = 1;
    stageAction(checkoutStage /*CheckoutStage*/) {
        switch (checkoutStage) {
            case CheckoutStage.CHECK_VALIDITY_UPDATE:
                return Promise.resolve(this.checkValidity());
            case CheckoutStage.REPORT_VALIDITY_SAVE:
                return Promise.resolve(this.reportValidity());
            default:
                return Promise.resolve(true);
        }
    }

    reportValidity() {
        return this.validateFields();
    }

    checkValidity() {
        return this.validateFields();
    }

    @api
    checkoutSave() {
        if (!this.checkValidity) {
            throw new Error("Mandatory fields are missing");
        }
    }

    //Changes for story - LIGHTNING-234
    setAspect(newAspect /*CheckoutContainerAspect*/) {
        if (this.summary == newAspect.summary) {
            return;
        }
        this.summary = newAspect.summary;
        if (this.summary && this.allValid) {
            this.setCheckoutMode(2);
        } else {
            this.setCheckoutMode(1);
        }
    }

    setCheckoutMode(value) {
        var inputs;
        switch (value) {
            case 1:
                inputs = this.template.querySelectorAll("lightning-input");
                inputs.forEach((input) => {
                    input.readOnly = false;
                });
                inputs = this.template.querySelectorAll("lightning-combobox");
                inputs.forEach((input) => {
                    input.readOnly = false;
                });
                inputs = this.template.querySelectorAll("lightning-radio-group");
                inputs.forEach((input) => {
                    input.disabled = false;
                });
                inputs = this.template.querySelectorAll("lightning-input-address");
                inputs.forEach((input) => {
                    input.readOnly = false;
                    input.disabled = false;
                });
                waitForCheckout();
                loadCheckout();
                if (!this.guestUser) {
                    this.getAddresses();
                }
                break;
            case 2:
                inputs = this.template.querySelectorAll("lightning-input");
                inputs.forEach((input) => {
                    input.readOnly = true;
                });

                inputs = this.template.querySelectorAll("lightning-combobox");
                inputs.forEach((input) => {
                    input.readOnly = true;
                });

                inputs = this.template.querySelectorAll("lightning-radio-group");
                inputs.forEach((input) => {
                    input.disabled = true;
                });

                inputs = this.template.querySelectorAll("lightning-input-address");
                inputs.forEach((input) => {
                    input.readOnly = true;
                    input.disabled = true;
                });
                waitForCheckout();
                loadCheckout();
                break;
        }
        this._checkoutMode = value;
    }
    //End of Changes for story - LIGHTNING-234

    //get contact point addresses and cart type
    async getAddresses() {
        this.isLoading = true;
        if (this.webcartId == undefined && !this.guestUser) {
            this.getCartIdAutheticatedUser();
        }
        await getAddresses({ CartId: this.webcartId })
            .then((result) => {
                let response = JSON.parse(result);
                this.cartType = response.cartType;
                if (!this.guestUser) {
                    this.organizationName = response.organizationName;
                    this.filterArray(JSON.parse(response.contactPointAddress));
                }
            })
            .catch((error) => {
                console.log("Drb2b_BuyerInfo_LWR getAddress error::>>" + error);
            })
            .finally(() => (this.isLoading = false));
    }

    async getCartIdAutheticatedUser() {
        await getCartIdWithCommunityId({ communityId: communityId })
            .then((result) => {
                this.webcartId = result;
            })
            .catch((error) => {
                console.log("Drb2b_BuyerInfo_LWR getCartIdAutheticatedUser error ", error);
            });
    }

    connectedCallback() {
        this.isLoading = true;
    }

    renderedCallback() {
        if (this.isRendered) return;
        this.isRendered = true;
        if (this.isCountryStateEnabled == false) {
            this.getcountrypicklistfirst();
        }
        if (this.webcartId != undefined) {
            this.getAddresses();
        }
        this.subscribeToMessageChannel();
    }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.webcartId = data.cartId;
            if (this.isRenderedAddress) return;
            if (this.webcartId != undefined) {
                this.getAddresses();
                this.isRenderedAddress = true;
            }
        } else if (error) {
            console.error(error);
        }
    }

    async getcountrypicklistfirst() {
        if (this.isCountryStateEnabled == false) {
            await getcountryPicklistIsEnabled().then((result) => {
                this.isCountryStateEnable = result.isCountryStateEnabled;
            });
        }
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
            this.showToast({ title: "Error", message: JSON.stringify(error), variant: "error" });
        } else if (data) {
            this.currentUser = data.fields;
            this.guestUser = false;
        } else {
            this.guestUser = true;
        }
    }

    @wire(MessageContext)
    messageContext;

    //set purchase type based on selected address
    setDefaultPurchaseType(country) {
        if (country == US || country == "United States") {
            this.selectedPurchaseType = INDIVIDUAL_VAL;
            this.isVisibleOrganizationName = false;
        } else {
            this.selectedPurchaseType = BUSINESS_VAL;
            this.isVisibleOrganizationName = true;
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

    get purchaseTypeOption() {
        return [
            { label: this.labels.businessValue, value: BUSINESS_VAL },
            { label: this.labels.individualValue, value: INDIVIDUAL_VAL }
        ];
    }

    filterArray(data) {
        //  let addresses = [];
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
        let selectedShippingAddress;
        let selectedBillingAddress;
        let billingAddressList = [];
        let shippingAddressList = [];
        for (let ele of address) {
            ele.label = ele.label.replaceAll("null", "");
            ele.label = ele.label.replaceAll("null,", "");
            //   addresses.push(ele);
            if (ele.AddressType == "Shipping" || ele.AddressType.toUpperCase() == SHIPPING_TYPE) {
                shippingAddressList.push(ele);
                if (ele.IsDefault) {
                    selectedShippingAddress = ele;
                }
            } else if (ele.AddressType == "Billing" || ele.AddressType.toUpperCase() == BILLING_TYPE) {
                billingAddressList.push(ele);
                if (ele.IsDefault) {
                    selectedBillingAddress = ele;
                }
            }
        }
        this.billingAddresses = JSON.parse(JSON.stringify(billingAddressList));
        this.shippingAddresses = JSON.parse(JSON.stringify(shippingAddressList));

        this.selectedShippingValue = selectedShippingAddress.Id;
        this.selectedBillingValue = selectedBillingAddress.Id;

        this.cartType && this.cartType.toUpperCase() == PURCHASE_TYPE
            ? this.setDefaultPurchaseType(selectedBillingAddress.Address.country.toUpperCase())
            : this.setDefaultPurchaseType(selectedShippingAddress.Address.country.toUpperCase());
    }

    fireAddressEvent() {
        //to we need to handle this for guest user.. by getting guest ship to and bill to address
        if (!this.guestUser) {
            let countries = {
                shipTo: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].label,
                billTo: this.billingAddresses.filter((ele) => ele.Id == this.selectedBillingValue)[0].label,
                cartType: this.cartType
            };
            fireEvent(this.pageRef, POST_ADDRESS, countries);
        }
    }

    guestShippingAddress;
    guestBillingAddress;

    async updateCart() {
        this.isLoading = true;
        const fields = {};
        fields[CART_ID_FIELD.fieldApiName] = this.webcartId;
        fields[CART_CUSTOMER_TYPE.fieldApiName] = this.selectedPurchaseType;
        if (this.guestUser) {
            fields[BUYER_NAME_FIELD.fieldApiName] =
                this.template.querySelector("[data-id=GuestFirstName]").value +
                " " +
                this.template.querySelector("[data-id=GuestLastName]").value;
            fields[GUEST_FIRSTNAME_FIELD.fieldApiName] = this.template.querySelector("[data-id=GuestFirstName]").value;
            fields[GUEST_LASTNAME_FIELD.fieldApiName] = this.template.querySelector("[data-id=GuestLastName]").value;
            fields[GUEST_PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-id=buyerPhone]").value;
            fields[GUEST_EMAIL_FIELD.fieldApiName] = this.template.querySelector("[data-id=buyerEmail]").value;
            this.guestbillingAddress = this.template.querySelector("[data-id=guestBillingAddress]");
            this.guestShippingAddress = this.template.querySelector("[data-id=guestShippingAddress]");

            if (this.isCountryStateEnabled) {
                fields[CART_BILL_COUNTRY_FIELD.fieldApiName] = this.countryNameWithISOCode[
                    this.guestUserSelectedBillingCountry
                ];
                fields[CART_BILL_STATE_FIELD.fieldApiName] = this.stateNameWithISO[this.guestUserSelectedBillingState];
            } else {
                fields[CART_BILL_COUNTRY_FIELD.fieldApiName] = this.guestbillingAddress.country;
                fields[CART_BILL_STATE_FIELD.fieldApiName] = this.guestbillingAddress.province;
            }
        } else {
            fields[CART_BILL_COUNTRY_FIELD.fieldApiName] = this.billingAddresses.filter(
                (ele) => ele.Id == this.selectedBillingValue
            )[0].Address.country;

            fields[CART_BILL_STATE_FIELD.fieldApiName] = this.billingAddresses.filter(
                (ele) => ele.Id == this.selectedBillingValue
            )[0].Address.state;
        }
        fields[CART_BILL_STREET_FIELD.fieldApiName] = this.guestUser
            ? this.guestbillingAddress.street
            : this.billingAddresses.filter((ele) => ele.Id == this.selectedBillingValue)[0].Address.street;
        fields[CART_BILL_CITY_FIELD.fieldApiName] = this.guestUser
            ? this.guestbillingAddress.city
            : this.billingAddresses.filter((ele) => ele.Id == this.selectedBillingValue)[0].Address.city;
        fields[CART_BILL_CODE_FIELD.fieldApiName] = this.guestUser
            ? this.guestbillingAddress.postalCode
            : this.billingAddresses.filter((ele) => ele.Id == this.selectedBillingValue)[0].Address.postalCode;
        if (!this.guestUser) {
            fields[BUYER_NAME_FIELD.fieldApiName] = this.template.querySelector("[data-id=buyerName]").value;
        }
        fields[BUYER_PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-id=buyerPhone]").value;
        fields[BUYER_EMAIL_FIELD.fieldApiName] = this.template.querySelector("[data-id=buyerEmail]").value;
        if (this.isVisibleOrganizationName) {
            fields[DR_ORGANIZATION_NAME.fieldApiName] = this.organizationName;
        }

        await updateCart({ cart: JSON.stringify(fields) }).catch((error) => {
            console.log("Drb2b_BuyerInfo_LWR UpdateCart error", error);
            this.showToast({ title: "Error", message: JSON.stringify(error), variant: "error" });
        });
        this.isLoading = false;
        this.fireAddressEvent();
        fireEvent(this.pageRef, "RELOAD_ADDRESS", "reloadaddress");
    }

    async updateCartDeliveryGroup() {
        this.isLoading = true;
        const fields = {};
        if (this.guestUser) {
            this.guestShippingAddress = this.template.querySelector("[data-id=guestShippingAddress]");
            let deliveryGroupdetailsGuest = {
                deliveryAddress: {
                    name:
                        this.template.querySelector("[data-id=GuestFirstName]").value +
                        " " +
                        this.template.querySelector("[data-id=GuestLastName]").value,
                    firstName: this.template.querySelector("[data-id=GuestFirstName]").value,
                    lastName: this.template.querySelector("[data-id=GuestLastName]").value,
                    region: this.guestShippingAddress.province,
                    country: this.guestShippingAddress.country,
                    city: this.guestShippingAddress.city,
                    street: this.guestShippingAddress.street,
                    postalCode: this.guestShippingAddress.postalCode
                }
            };
            await updateShippingAddress(deliveryGroupdetailsGuest).catch((error) => {
                console.log("Drb2b_BuyerInfo_LWR UpdateContact info failed", error);
                this.showToast({ title: "Error", message: JSON.stringify(error), variant: "error" });
            });
        } else {
            let deliveryGroupdetailsUser = {
                deliveryAddress: {
                    name: this.template.querySelector("[data-id=buyerName]").value,
                    firstName: this.template.querySelector("[data-id=buyerName]").value,
                    lastName: this.template.querySelector("[data-id=buyerName]").value,
                    region: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].Address
                        .stateCode,
                    country: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].Address
                        .countryCode,
                    city: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].Address.city,
                    street: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].Address
                        .street,
                    postalCode: this.shippingAddresses.filter((ele) => ele.Id == this.selectedShippingValue)[0].Address
                        .postalCode
                }
            };
            await updateShippingAddress(deliveryGroupdetailsUser);
        }

        this.isLoading = false;
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
                purpose: "contactPointAddressId",
                payload: this.selectedShippingValue
            });
        } else {
            publish(this.messageContext, drMessageChannel, {
                purpose: "contactPointAddressId",
                payload: this.selectedBillingValue
            });
        }
        return this.handleNextClick();
    }

    async validateFields() {
        this.checkValidity();
        if (this.allValid == true) {
            return this.handleNextClick();
        } else {
            this.showToast({ title: "Error", message: this.labels.fieldMissError, variant: "error" });
            return false;
        }
    }

    async handleNextClick() {
        this.updateCart();
        if (this.cartType && this.allValid) {
            this.fireAddressEvent();
            if (this.guestUser) {
                let contactdetails = {
                    firstName: this.template.querySelector("[data-id=GuestFirstName]").value,
                    lastName: this.template.querySelector("[data-id=GuestLastName]").value,
                    email: this.guestUserEmail,
                    phoneNumber: this.guestUserPhone
                };
                await updateContactInformation(contactdetails).catch((error) => {
                    console.log("Drb2b_BuyerInfo_LWR UpdateContact info failed", error);
                    this.showToast({ title: "Error", message: JSON.stringify(error), variant: "error" });
                });
            }
            if (this.showShippingAddress) {
                await this.updateCartDeliveryGroup();
            }
            publish(this.messageContext, dr_lms, {
                purpose: "calculateTaxRefresh"
            });
            return { isValid: true };
        } else if (!this.cartType) {
            this.showToast({ title: "Error", message: this.labels.updateCartError, variant: "error" });
            return { isValid: false };
        } else if (!this.allValid) {
            this.showToast({ title: "Error", message: this.labels.fieldMissError, variant: "error" });
            return { isValid: false };
        }
    }

    handleOrganizationChange() {
        this.organizationName = event.target.value;
    }

    handlePurchaseTypeChange(event) {
        this.selectedPurchaseType = event.target.value;
        if (this.selectedPurchaseType == BUSINESS_VAL) {
            this.isVisibleOrganizationName = true;
        } else {
            this.isVisibleOrganizationName = false;
        }

        if (!this.guestUser) {
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

    guestUserFirstName = "";
    guestUserLastName = "";
    guestUserEmail = "";
    guestUserPhone = "";
    handleGuestUserDetails(event) {
        switch (event.target.dataset.id) {
            case "GuestFirstName":
                {
                    this.guestUserFirstName = event.target.value;
                }
                break;
            case "GuestLastName":
                {
                    this.guestUserLastName = event.target.value;
                }
                break;
            case "buyerEmail":
                {
                    this.guestUserEmail = event.target.value;
                }
                break;
            case "buyerPhone":
                {
                    this.guestUserPhone = event.target.value;
                }
                break;
        }
    }
}
