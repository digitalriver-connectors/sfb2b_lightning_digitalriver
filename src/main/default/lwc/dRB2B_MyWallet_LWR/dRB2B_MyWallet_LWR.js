import { LightningElement, api } from "lwc";

export default class dRB2B_MyWallet_LWR extends LightningElement {
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
