import {LightningElement, api, wire} from 'lwc';
import {getRecord} from "lightning/uiRecordApi";
import {destructWiredRecord} from "c/commons";

import BUYER_NAME_FIELD from "@salesforce/schema/WebCart.Buyer_Name__c";
import BUYER_EMAIL_FIELD from "@salesforce/schema/WebCart.Buyer_Email__c";
import BUYER_PHONE_FIELD from "@salesforce/schema/WebCart.Buyer_Phone__c";
import BILLING_COUNTRY_FIELD from "@salesforce/schema/WebCart.BillingCountry";
import BILLING_STATE_FIELD from "@salesforce/schema/WebCart.BillingState";
import BILLING_POSTAL_CODE_FIELD from "@salesforce/schema/WebCart.BillingPostalCode";
import BILLING_CITY_FIELD from "@salesforce/schema/WebCart.BillingCity";
import BILLING_STREET_FIELD from "@salesforce/schema/WebCart.BillingStreet";

export default class Drb2BCheckoutAddressSummary extends LightningElement {
    @api cartId

    cart

    @wire(getRecord, {
        recordId: '$cartId',
        fields: [
            BUYER_NAME_FIELD, BUYER_EMAIL_FIELD, BUYER_PHONE_FIELD,
            BILLING_COUNTRY_FIELD, BILLING_STATE_FIELD, BILLING_POSTAL_CODE_FIELD,
            BILLING_STREET_FIELD, BILLING_CITY_FIELD]
    })
    wireCart({ error, data }) {
        if (error) {
            console.error("error", error);
        } else if (data) {
            this.cart = destructWiredRecord(data);
        }
    }
}