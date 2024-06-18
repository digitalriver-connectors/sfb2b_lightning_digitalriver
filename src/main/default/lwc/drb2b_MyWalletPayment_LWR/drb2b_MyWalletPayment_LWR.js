import { LightningElement, api } from "lwc";

import getAllSavedPayments from "@salesforce/apex/DRB2B_StoredPayments.getAllSavedPayments";
import getCheckoutAndSourceInfoForSCA from "@salesforce/apex/DRB2B_MyWalletPayment.getCheckoutAndSourceInfoForSCA";

import communityPath from "@salesforce/community/basePath";
import { getNamespacePrefix } from "c/commons";
import USER_ID from "@salesforce/user/Id";
import ToastContainer from 'lightning/toastContainer';
import Toast from 'lightning/toast';
import communityId from '@salesforce/community/Id';
//labels
import useSavePayment from "@salesforce/label/c.DR_My_Wallet_Use_Save_Payments";
import cardEndingWith from "@salesforce/label/c.DR_Card_Ending_with";
import useStoredPaymentBtn from "@salesforce/label/c.DR_User_Store_Payment";
import sourceAuthenticationFailed from "@salesforce/label/c.DR_Source_Authentication_Failed";
import noSavedPayment from "@salesforce/label/c.DR_No_Saved_Payment_Found";
export default class Drb2b_MyWalletPayment_LWR extends LightningElement {
    isConnectedCallback = false;
    isLoading = false;
    UserId = USER_ID;
    @api cart;
    value = "";
    options = [];
    sourceId;
    source = {};
    checkoutId;
    paymentsToDisplay = [];
    label = {
        useSavePayment,
        cardEndingWith,
        useStoredPaymentBtn,
        sourceAuthenticationFailed,
        noSavedPayment
    };

    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.isLoading = true;
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);
    }

    disconnectedCallback() {
        window.removeEventListener("message", this._listenForMessage);
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

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath + 'vforcesite';
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
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

    //get all Stored Payments
    getAllStoredPayments() {
        getAllSavedPayments({ jsonString: JSON.stringify({ userId: this.UserId, cartId : this.cart.id}) })
            .then((result) => {
                let resultData = JSON.parse(result);
                
                if (resultData.isSuccess) {
                    this.savedcardList = resultData.attachedSources;
                    this.paymentsToDisplay = resultData.storedPayments;
                    this.fireEventLWC();
                    this.isLoading = false;
                } else {
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log("\n\n MyWalletPayment error => " + JSON.stringify(error, null, 2));
                this.showToast({title: "Error" , message: error.body.message, variant: "error" });
            });
    }
    fireEventLWC() {
        let component = this;
        let jsonData = {
            savedcardList: this.savedcardList,
            radioOptions: this.options,
            paymentsToDisplay : this.paymentsToDisplay
        };
        let pMessage = {
            event: "savedCard",
            data: JSON.stringify(jsonData)
        };
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
    }
    
    iframeLoaded(){
        this.getAllStoredPayments();
    }

    handleUseStorePayment(data) {
        this.isLoading = true;
        this.sourceId = data;
        getCheckoutAndSourceInfoForSCA({ jsonString: JSON.stringify({ userId: this.UserId, sourceId: this.sourceId, cartId : this.cart.id}) })
            .then((result) => {
                let resultData = JSON.parse(result);
                if (resultData.isSuccess) {
                    let component = this;
                    resultData.sourceInformation.amount = this.cart.grandTotalAmount;
                    this.source.source = resultData.sourceInformation;
                    let jsonData = {
                        sourceInfo: resultData.sourceInformation,
                        paymentSessionId: this.cart.paymentSession
                    };
                    let pMessage = {
                        event: "verifySCAEvent",
                        data: JSON.stringify(jsonData)
                    };
                    setTimeout(() => {
                        component.template
                            .querySelector(".iframe-Class")
                            .contentWindow.postMessage(JSON.stringify(pMessage), "/");
                    }, 1500);
                } else {
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log("\n\n Drb2bMyWallet handleUseStorePayment error => " + JSON.stringify(error, null, 2));
                this.showToast({title: "Error" , message: error.body.message, variant: "error" });
            });
    }

    handleVFResponse(message) {
        let msg = JSON.parse(message);

        switch (msg.event) {
            case "proceedToPayment":
                this.proceedToPayment();
                break;
            case "sourceAuthError":
                this.handleAuthError(msg.obj);
                break;
            case "savedCardDetails":
                this.handleUseStorePayment(msg.obj);
                break;
        }
    }

    proceedToPayment() {
        const selectedEvent = new CustomEvent("getsource", { detail: this.source });
        this.dispatchEvent(selectedEvent);
        this.isLoading = false;
    }

    handleAuthError(data) {
        this.isLoading = false;
        this.showToast({title: "Error" , message: this.label.sourceAuthenticationFailed, variant: "error" });
    }
}
