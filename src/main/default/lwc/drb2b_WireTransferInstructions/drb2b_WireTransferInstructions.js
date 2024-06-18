import { LightningElement, api } from 'lwc';
import getSourceInfo from "@salesforce/apex/DRB2B_WireTransferInstructions.getSourceInfo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import communityPath from "@salesforce/community/basePath";
import { getNamespacePrefix } from "c/commons";
import communityId from '@salesforce/community/Id';

import wiretransferInformation from "@salesforce/label/c.DR_Delayed_Payment_Information";
import genericErrorMessage from "@salesforce/label/c.WireTranfer_Generic_Error_Message";

export default class Drb2b_WireTransferInstructions extends LightningElement {
    initilized = false;
    isLoading = false;
    sourceId;
    sourceClientSecret;
    displayPaymentInstructions;
    @api recordId;
    label = {
        wiretransferInformation,
        genericErrorMessage
    };

    connectedCallback() {
        if (this.initilized) return;
        this.initilized = true;
        this.isLoading = true;
        this.getSourceInfo();
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
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath.slice(0, communityPath.lastIndexOf("/s"));
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    getSourceInfo() {
        getSourceInfo({ orderSummaryId : this.recordId })
            .then((result) => {
                let sourceDetail = JSON.parse(result);
                if (sourceDetail.isSuccess) {
                    this.displayPaymentInstructions = sourceDetail.displayPaymentInstructions;
                    if(sourceDetail.displayPaymentInstructions){
                        this.sourceId = sourceDetail.sourceId;
                        this.sourceClientSecret = sourceDetail.clientSecret;
                        //this.fireEventLWC();
                    }
                } else {
                    this.isLoading = false;
                    this.showToast({ message: this.label.genericErrorMessage, variant: "error" });
                }
            })
            .catch((error) => {
                console.log(error);
                this.isLoading = false;
                this.showToast({ message: this.label.genericErrorMessage, variant: "error" });
            })
            .finally(() => (this.isLoading = false));
    }

    fireEventLWC() {
        let component = this;
        let jsonData = {
            sourceId : this.sourceId,
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

    iframeLoaded(){
        if(this.displayPaymentInstructions){
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