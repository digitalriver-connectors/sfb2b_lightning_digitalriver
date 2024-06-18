import { LightningElement, api,wire} from "lwc";
import getSourceInfo from "@salesforce/apex/DRB2B_WireTransferInstructions.getSourceInfo";
import getSummaryId from "@salesforce/apex/DRB2B_WireTransferInstructions.getSummaryId";
import ToastContainer from "lightning/toastContainer";
import Toast from "lightning/toast";
import communityPath from "@salesforce/community/basePath";
import { getNamespacePrefix } from "c/commons";
import communityId from "@salesforce/community/Id";

import wiretransferInformation from "@salesforce/label/c.DR_Delayed_Payment_Information";
import genericErrorMessage from "@salesforce/label/c.WireTranfer_Generic_Error_Message";
import isGuestUser from "@salesforce/user/isGuest";
import { CurrentPageReference } from "lightning/navigation";

export default class drb2b_delayedPaymentInstructions_LWR extends LightningElement {
    isConnectedCallback = false;
    loggedinuser=false;
    isLoading = false;
    sourceId;
    sourceClientSecret;
    displayPaymentInstructions;
    @api recordId;
    @api orderNumber;
    @api  orderID;
    label = {
        wiretransferInformation,
        genericErrorMessage
    };

    @wire(CurrentPageReference)
    getUrlParameters(currentPageReference) {
       if (currentPageReference) {
        if(currentPageReference.attributes?.objectApiName=="OrderSummary")
        {
            if(isGuestUser)
            {
                this.orderNumber = currentPageReference.attributes?.recordId;  
            } 
            else  
            { 
                this.orderID = currentPageReference.attributes?.recordId;  
            }
        }
        else
        {
            this.orderNumber = currentPageReference.state?.orderNumber;
            if(!isGuestUser)  { this.loggedinuser=true;}
                 
        }
       }
    }

    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        this.isLoading = true;
        this.getSourceInfo();
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);
    }
    callResponseHandler(msg) {
        let url = window.location.protocol + "//" + window.location.hostname;
        if (msg.origin != url) {
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

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath + "vforcesite";
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    async getSourceInfo() {
        if(isGuestUser || this.loggedinuser)
        {
        if(this.orderNumber)
        {
        await getSummaryId({ orderNumber: this.orderNumber })
                .then((result) => {
                    this.orderID = result;
                })
                .catch((error) => {
                    console.log("GetsummaryId Error ", error);
                                   });
            }
        }
      
           await getSourceInfo({ orderSummaryId: this.orderID })
            .then((result) => {
                let sourceDetail = JSON.parse(result);
                if (sourceDetail.isSuccess) {
                    this.displayPaymentInstructions = sourceDetail.displayPaymentInstructions;
                    if (sourceDetail.displayPaymentInstructions) {
                        this.sourceId = sourceDetail.sourceId;
                        this.sourceClientSecret = sourceDetail.clientSecret;
                        //this.fireEventLWC();
                    }
                } else {
                    this.isLoading = false;
                    this.showToast({ title: "Error", message: this.label.genericErrorMessage, variant: "error" });
                }
            })
            .catch((error) => {
                console.log("Drb2b_WireTransferInstructions_LWR getSourceInfo", +error);
                this.isLoading = false;
                this.showToast({ title: "Error", message: this.label.genericErrorMessage, variant: "error" });
            })
            .finally(() => (this.isLoading = false));
    }

    fireEventLWC() {
        let component = this;
        let jsonData = {
            sourceId: this.sourceId,
            sourceClientSecret: this.sourceClientSecret
        };
        let pMessage = {
            event: "wireTransfer",
            data: JSON.stringify(jsonData)
        };
       // setTimeout(() => {
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
            // component.isLoading = false;
      //  }, 1500);
    }

    iframeLoaded() {
        if (this.displayPaymentInstructions) {
            this.fireEventLWC();
        }  
    }

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        switch (msg.event) {
            case "wireTransferInstru":
                this.handleOnReady(msg.obj);
                break;
        }
    }
    handleOnReady(data) {
        this.isLoading = false;
        this.template.querySelector(".iframe-Class").classList.remove("slds-hide");
    }
}
