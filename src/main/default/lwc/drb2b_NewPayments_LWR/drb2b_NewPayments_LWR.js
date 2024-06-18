import { LightningElement, track, wire, api } from "lwc";

import getBillingContactPointAddress from "@salesforce/apex/DRB2B_NewPayments.getBillingContactPointAddress";
import attachSourceWithCustomer from "@salesforce/apex/DRB2B_NewPayments.attachSourceWithCustomer";
import communityPath from "@salesforce/community/basePath";
import { getNamespacePrefix } from "c/commons";
import { NavigationMixin } from "lightning/navigation";

import { getRecord } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_FIRSTNAME from "@salesforce/schema/User.FirstName";
import USER_LASTNAME from "@salesforce/schema/User.LastName";
import USER_EMAIL from "@salesforce/schema/User.Email";
import USER_PHONE from "@salesforce/schema/User.Phone";
import Toast from 'lightning/toast';
import ToastContainer from 'lightning/toastContainer';
import USER_ID from "@salesforce/user/Id";
import myWalletSourceNotSaved from "@salesforce/label/c.MyWallet_DR_Source_Not_Saved";
import attachSourceFailed from "@salesforce/label/c.My_Wallet_DR_Attach_Source_Customer_Failed";
import newPaymentAddedtoWallet from "@salesforce/label/c.DR_New_Payment_Add_to_Wallet";
import contactAddressFieldsMissing from "@salesforce/label/c.DR_Contact_Address_Fields_Missing_Errors";
import emptyDropIn from "@salesforce/label/c.DR_Empty_DropIN_Error";
import addNewPaymentMethods from "@salesforce/label/c.DR_Add_new_Payment_methods";
import selectBillingAddress from "@salesforce/label/c.DR_Select_Billing_Address";
import noBillingAddressFound from "@salesforce/label/c.DR_No_Billing_address_found";
import clickToAdd from "@salesforce/label/c.DR_Click_to_Add";
import selectPaymentMethod from "@salesforce/label/c.DR_Select_Payment_Method";
import userFieldsMissing from "@salesforce/label/c.DR_User_Fields_Missing_Error";
import unableToSavePayment from "@salesforce/label/c.My_Wallet_Generic_Error_Message";
import communityId from '@salesforce/community/Id';

import drSuccess from "@salesforce/label/c.DR_Success";

export default class drb2b_NewPayments_LWR extends NavigationMixin(LightningElement) {
    isNewPayment = true;
    isStepOne = true;
    isStepTwo = false;
    isStepThree = false;
    noBillingAddress = false;
    isConnectedCallback = false;
    contactPointAddresses;
    contactPointAddressesList = [];
    @track contactPointAddressMap = [];
    @track selectedConPointAddress;
    @track currentStep = "step1";
    error;
    ContactId;
    UserId = USER_ID;
    currentUser;
    isLoading = false;
    @api hideNewPayment = false;
    @api dropinConfig;

    label = {
        myWalletSourceNotSaved,
        attachSourceFailed,
        newPaymentAddedtoWallet,
        contactAddressFieldsMissing,
        emptyDropIn,
        addNewPaymentMethods,
        selectBillingAddress,
        noBillingAddressFound,
        clickToAdd,
        selectPaymentMethod,
        drSuccess,
        userFieldsMissing,
        unableToSavePayment
    };
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE]
    })
    wireuser({ error, data }) {
        if (error) {
            console.log("drb2b_NewpaymentLWR wireuser error ", error);
        } else if (data) {
            this.currentUser = data.fields;
        }
    }

    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.isLoading = true;
        this.getContactPointAddress();
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);
    }
    callResponseHandler(msg) {
        let url = window.location.protocol+'//'+window.location.hostname;
        if(msg.origin != url)
            {
                return false;
            }
        let component = this;
        component.handleVFResponse(msg.data);
    }

    disconnectedCallback() {
        window.removeEventListener("message", this._listenForMessage);
    }
    //common method to show toast

    showToast(obj) {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';
        Toast.show({
            label: obj.title,
            message: obj.message,
            mode: 'dismissible',
            variant: obj.variant,
                    }, this);
    }

    //get all Contact Point Address
    getContactPointAddress() {
        getBillingContactPointAddress()
            .then((result) => {
                this.contactPointAddresses = JSON.parse(result);
                this.contactPointAddressesList = this.contactPointAddresses;
                this.contactPointAddressesList.forEach((conPoint) => {
                    this.contactPointAddressMap[conPoint.Id] = conPoint;
                    if (conPoint.IsDefault) {
                        this.selectedConPointAddress = conPoint;
                    }
                });
                this.isLoading = false;
                if (this.contactPointAddresses.length !== 0) {
                    this.noBillingAddress = false;
                } else {
                    this.noBillingAddress = true;
                }
            })
            .catch((error) => {
                this.isLoading = false;
                this.showToast({title: "Error" , message: error.body.message, variant: "error" });
            });
    }
    handleRedirect(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "comm-my-account"
            }
        });
    }
    get isEnableNext() {
        if (this.currentStep != "step2" && this.currentStep != "step3") {
            return true;
        } else {
            return false;
        }
    }

    get isEnablePrev() {
        if (this.currentStep != "step1" && this.currentStep != "step3") {
            return true;
        } else {
            return false;
        }
    }

    handleNext(event) {
        let getselectedStep = this.currentStep;
        this.isLoading = true;
        if (getselectedStep === "step1") {
            this.currentStep = "step2";
            this.isStepOne = false;
            this.isStepTwo = true;
            this.isStepThree = false;
            this.fireEventLWC();
            this.template.querySelector(".iframe-Class").classList.remove("slds-hide");
        } else if (getselectedStep === "step2") {
            this.currentStep = "step3";
            this.isStepOne = false;
            this.isStepTwo = false;
            this.isStepThree = true;
            this.template.querySelector(".iframe-Class").classList.add("slds-hide");
        }
        this.template.querySelector('[data-id="' + this.currentStep + '"]').className = "slds-is-active";
    }

    handlePrev() {
        if (this.currentStep == "step3") {
            this.currentStep = "step2";
            this.isStepOne = false;
            this.isStepTwo = true;
            this.isStepThree = false;
        } else if ((this.currentStep = "step2")) {
            this.currentStep = "step1";
            this.isStepOne = true;
            this.isStepTwo = false;
            this.isStepThree = false;
            this.template.querySelector(".iframe-Class").classList.add("slds-hide");
        }
    }

    handleOnStepClick(event) {
        this.currentStep = event.target.value;
    }
    handleRadioChange(event) {
        let selEleVal = event.currentTarget.dataset.value;
        this.selectedConPointAddress = this.contactPointAddressMap[selEleVal];
    }
     get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath + 'vforcesite';
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    fireEventLWC() {
        let component = this;
        let errorData;
        if (this.currentUser.FirstName.value == "" || this.currentUser.FirstName.value == null) {
            errorData = {
                event: "userError",
                data: JSON.stringify({ label: this.label.userFieldsMissing, message: "First Name" })
            };
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(errorData), "/");
            return;
        }
        if (this.currentUser.LastName.value == "" || this.currentUser.LastName.value == null) {
            errorData = {
                event: "userError",
                data: JSON.stringify({ label: this.label.userFieldsMissing, message: "Last Name" })
            };
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(errorData), "/");
            return;
        }
        if (this.currentUser.Email.value == "" || this.currentUser.Email.value == null) {
            errorData = {
                event: "userError",
                data: JSON.stringify({ label: this.label.userFieldsMissing, message: "Email Name" })
            };
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(errorData), "/");
            return;
        }
        if (this.currentUser.Phone.value == "" || this.currentUser.Phone.value == null) {
            errorData = {
                event: "userError",
                data: JSON.stringify({ label: this.label.userFieldsMissing, message: "Phone Number" })
            };
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(errorData), "/");
            return;
        }
        if (this.selectedConPointAddress.Street == "" || this.selectedConPointAddress.Street == null) {
            errorData = {
                event: "error",
                data: JSON.stringify({ label: this.label.contactAddressFieldsMissing, message: "Address Line" })
            };
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(errorData), "/");
            return;
        }
        if (this.selectedConPointAddress.PostalCode == "" || this.selectedConPointAddress.PostalCode == null) {
            errorData = {
                event: "error",
                data: JSON.stringify({ label: this.label.contactAddressFieldsMissing, message: "Postal Code" })
            };
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(errorData), "/");
            return;
        }
        if (this.selectedConPointAddress.Country == "" || this.selectedConPointAddress.Country == null) {
            errorData = {
                event: "error",
                data: JSON.stringify({ label: this.label.contactAddressFieldsMissing, message: "Country" })
            };
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(errorData), "/");
            return;
        }
        let jsonData = {
            contactaddress: this.selectedConPointAddress,
            firstName: this.currentUser.FirstName.value,
            lastName: this.currentUser.LastName.value,
            email: this.currentUser.Email.value,
            phone: this.currentUser.Phone.value,
            userId: this.UserId,
            countryIsoCode: this.selectedConPointAddress.Country.toUpperCase()
        };
        let pMessage = {
            event: "mywallet",
            data: JSON.stringify(jsonData)
        };
        component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
    }

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        switch (msg.event) {
            case "myWalletSuccess":
                this.handleSuccess(msg.obj);
                break;
            case "myWalletCancel":
                this.handleCancel(msg.obj);
                break;
            case "myWalletError":
                this.handleError(msg.obj);
                break;
            case "myWalletOnReady":
                this.handleOnReady(msg.obj);
                break;
            case "ErrorMessage":
                this.handleErrorMessage(msg.obj);
                break;
            case "UserErrorMessage":
                this.handleErrorMessage(msg.obj);
                break;
        }
    }
    handleErrorMessage(data) {
        this.isLoading = false;
        this.showToast({title: "Error" , message: data, variant: "error" });
    }
    handleError(data) {
        this.isLoading = false;
        this.showToast({title: "Error" , message: this.label.unableToSavePayment, variant: "error" });
    }
    handleOnReady(data) {
        this.isLoading = false;
        if (typeof data.paymentMethodTypes === "undefined" || data.paymentMethodTypes.length == 0) {
            this.showToast({title: "Error" , message: this.label.emptyDropIn, variant: "error" });
        }
    }
    handleSuccess(data) {
        this.isLoading = false;
        let component = this;
        if (!data.readyForStorage) {
            this.showToast({title: "Error" , message: this.label.myWalletSourceNotSaved, variant: "error" });
            return;
        }
        attachSourceWithCustomer({
            jsonString: JSON.stringify({
                sourceId: data.source.id,
                paymentType: data.source.type,
                contactId: this.currentUser.ContactId.value,
                userId: this.UserId
            })
        })
            .then((result) => {
                let resultData = JSON.parse(result);
                if (resultData.isSuccess) {
                    this.currentStep = "step3";
                    this.isStepOne = false;
                    this.isStepTwo = false;
                    this.isStepThree = true;
                    this.hideNewPayment = true;
                    this.template.querySelector(".iframe-Class").classList.add("slds-hide");
                    this.template.querySelector('[data-id="' + this.currentStep + '"]').className = "slds-is-active";
                    setTimeout(() => {
                        // Creates the event with the data.
                        const selectedEvent = new CustomEvent("hidenewpayment", {
                            detail: this.hideNewPayment
                        });

                        // Dispatches the event.
                        component.dispatchEvent(selectedEvent);
                        // component.isLoading = false;
                    }, 1500);
                } else {
                    this.showToast({title: "Error" , message: this.label.attachSourceFailed, variant: "error" });
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log("\n\n drb2b_NewpaymentLWR attachSourceWithCustomer error => " + JSON.stringify(error, null, 2));
                this.showToast({title: "Error" , message: error.body.message, variant: "error" });
            });
    }
}
