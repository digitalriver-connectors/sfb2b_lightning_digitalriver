import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFileLink from "@salesforce/apex/DRB2B_VatAndCreditMemoController.getFileLink";
import getInvoiceAndCreditMemo from "@salesforce/apex/DRB2B_VatAndCreditMemoController.getInvoiceAndCreditMemo";
import ORDER_ID from "@salesforce/schema/OrderSummary.OriginalOrderId";
// Import custom labels
import linkGenrationError from "@salesforce/label/c.File_link_generation_error_msg";

const INVOICE = "Invoices";
const CREDIT_MEMO = "Credit Memos";
export default class DRB2B_VatCreditMemo extends LightningElement {
    @api recordId;
    @api type;
    orderFiles;
    haveFiles = false;
    isIntilized = false;
    label = {
        linkGenrationError
    };

    @wire(getRecord, { recordId: "$recordId", fields: [ORDER_ID] })
    orderFileIds({ error, data }) {
        if (data) {
            let orderId = getFieldValue(data, ORDER_ID);
            this.getInvoiceAndCreditMemo(orderId.trim());
        } else if (error) {
            console.log('in vat credit error orderFileIds',error);
        }
    }
    connectedCallback() {
        if (this.isIntilized) return;
        this.isIntilized = true;
        }

    getInvoiceAndCreditMemo(orderId) {
        getInvoiceAndCreditMemo({ sfOrderId: orderId })
            .then((result) => {
                this.orderFiles = JSON.parse(result);
                this.haveFiles =
                    this.type == INVOICE
                        ? this.orderFiles["Invoice"].length > 0
                        : this.orderFiles["Credit Memo"].length > 0;
            })
            .catch((error) => console.log('line 52',error));
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
        getFileLink({ fileId: fileId, orderId: ORDER_ID})
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