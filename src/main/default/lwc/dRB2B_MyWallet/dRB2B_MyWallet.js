import { LightningElement, api } from "lwc";

export default class DRB2B_MyWallet extends LightningElement {
    isSavedPayments = true;
    @api dropinConfig;

    handlePaymentMethodChange(event) {
        if (this.isSavedPayments) {
            this.isSavedPayments = false;
        } else {
            this.isSavedPayments = true;
        }
    }
    @api
    renderSavedPaymentComponent() {
        this.isSavedPayments = true;
    }
}
