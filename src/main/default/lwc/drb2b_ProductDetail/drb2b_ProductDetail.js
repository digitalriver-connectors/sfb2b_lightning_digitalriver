import { LightningElement, api, track } from "lwc";

import getProductDetail from "@salesforce/apex/DRB2B_ProductDetail.getProductDetail";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import productCode from "@salesforce/label/c.DR_Product_Code";
import productSku from "@salesforce/label/c.DR_Product_Sku";
import quantity from "@salesforce/label/c.DR_Quantity";
import price from "@salesforce/label/c.DR_Price";
export default class Drb2b_ProductDetail extends LightningElement {
    initilized = false;
    isLoading = false;
    @track orderItemList = [];
    @api recordId;
    connectedCallback() {
        if (this.initilized) return;
        this.initilized = true;
        this.isLoading = true;
        this.getProductDetail();
    }
    label = {
        productCode,
        productSku,
        quantity,
        price
    };
    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }
    getProductDetail() {
        getProductDetail({ orderSummaryId: this.recordId })
            .then((result) => {
                let orderItemDetail = JSON.parse(result);
                if (orderItemDetail.isSuccess) {
                    this.orderItemList = orderItemDetail.OrderItemList;
                } else {
                    this.isLoading = false;
                    this.showToast({ message: "Error", variant: "error" });
                }
            })
            .catch((error) => {
                console.log(error);
                this.isLoading = false;
                this.showToast({ message: error.body.message, variant: "error" });
            })
            .finally(() => (this.isLoading = false));
    }
}
