import { LightningElement, api, wire } from "lwc";
import getSummaryAndSfOrderId from "@salesforce/apex/DRB2B_VatAndCreditMemoController.getSummaryAndSfOrderId";
import getOriginalOrderID from "@salesforce/apex/DRB2B_VatAndCreditMemoController.getOriginalOrderID";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFileLink from "@salesforce/apex/DRB2B_VatAndCreditMemoController.getFileLink";
import getInvoiceAndCreditMemo from "@salesforce/apex/DRB2B_VatAndCreditMemoController.getInvoiceAndCreditMemo";
import ORDER_ID from "@salesforce/schema/OrderSummary.OriginalOrderId";

import isGuestUser from "@salesforce/user/isGuest";
import { CurrentPageReference } from 'lightning/navigation';
// Import custom labels
import linkGenrationError from "@salesforce/label/c.File_link_generation_error_msg";

const INVOICE = "Invoices";
const CREDIT_MEMO = "Credit Memos";
export default class DRB2B_VatCreditMemo_LWR extends LightningElement {
    @api recordId;
    @api type;
    @api summaryId;
    orderFiles;
    haveFiles = false;
    isIntilized = false;
    label = {
        linkGenrationError
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
                this.summaryId = currentPageReference.attributes?.recordId;  
            }
           
        }
        
       }
    }

    connectedCallback() {
        if(isGuestUser)
        {
            this.getSFOrderId(this.orderNumber);
        }
        else
        {
            this.getOriginalOrderID(this.summaryId); 
        }
        if (this.isIntilized) return;
        this.isIntilized = true;
    }

    async getSFOrderId(orderNumber) {
        await getSummaryAndSfOrderId({ orderNumber: this.orderNumber })
            .then((result) => {
                result= JSON.parse(result);
                this.recordId = result.summaryId;
                this.orderId = result.sfOrderId;
            })
            .catch((error) => {
                console.log("Error " + error);
            })
            .finally(() => (this.isLoading = false));
        this.getInvoiceAndCreditMemo(this.orderId.trim());
    }

    async getOriginalOrderID(orderNumber) {
        await getOriginalOrderID({ summaryID:this.summaryId })
            .then((result) => {
                result = JSON.parse(result);                
                this.orderId = result.sfOrderId;
            })
            .catch((error) => {
                console.log("Error " + error);
            })
            .finally(() => (this.isLoading = false));
        this.getInvoiceAndCreditMemo(this.orderId.trim());
    }

    async getInvoiceAndCreditMemo(orderId) {
        getInvoiceAndCreditMemo({ sfOrderId: orderId })
            .then((result) => {
                this.orderFiles = JSON.parse(result);
                this.haveFiles =
                    this.type == INVOICE
                        ? this.orderFiles["Invoice"].length > 0
                        : this.orderFiles["Credit Memo"].length > 0;
            })
            .catch((error) => console.log("line 52", error));
    }

    get fileIdLink() {
        let ids = this.type == INVOICE ? this.orderFiles["Invoice"] : this.orderFiles["Credit Memo"];
        let idsArray = ids.toString().split(",");
        if (this.type == INVOICE) {
            idsArray = idsArray.map((fid) => `Invoice ${fid}`); //TODO : Use label For Invoice string
        } else if (this.type == CREDIT_MEMO) {
            idsArray = idsArray.map((fid) => `Credit Memo ${fid}`); //TODO : Use label For Credit Memo string
        }
        return idsArray;
    }

    handleGenrateLink(event) {
        let fileId = event.currentTarget.dataset.id;
        fileId = fileId.trim().split(" ").pop();
        getFileLink({ fileId: fileId, orderId: ORDER_ID })
            .then((result) => {
                let respone = JSON.parse(result);
                if (respone.errors) {
                    this.showToast({ message: this.label.linkGenrationError, variant: "error" });
                } else {
                    window.open(respone.url);
                }
            })
            .catch((error) => {
                console.log("error:", error);
                this.showToast({ message: this.label.linkGenrationError, variant: "error" });
            });
    }

    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }
}
