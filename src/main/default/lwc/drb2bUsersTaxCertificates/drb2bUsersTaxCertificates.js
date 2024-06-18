import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import userDoesntHasTaxCertificatesMsg from '@salesforce/label/c.DR_TaxCertificates_UserDoesntHasTaxCertificates';
import myTaxCertificatesTtl from '@salesforce/label/c.DR_TaxCertificates_MyTaxCertificates';
import manageTaxExemptionLbl from '@salesforce/label/c.DR_TaxCertificates_ManageTaxExemption';
import companyNameLbl from '@salesforce/label/c.DR_TaxCertificates_CompanyName';
import certTaxAuthLbl from '@salesforce/label/c.DR_TaxCertificates_ExemptionCertTaxAuth';
import startDateLbl from '@salesforce/label/c.DR_TaxCertificates_ExemptionStartDate';
import endDateLbl from '@salesforce/label/c.DR_TaxCertificates_ExemptionEndDate';

import getCustomer from "@salesforce/apex/DRB2B_UsersTaxCertificatesController.getCustomer";

const STATES = {
    "AL": "Alabama",
    "AK": "Alaska",
    "AZ": "Arizona",
    "AR": "Arkansas",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DE": "Delaware",
    "DC": "District Of Columbia",
    "FL": "Florida",
    "GA": "Georgia",
    "HI": "Hawaii",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "IA": "Iowa",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "ME": "Maine",
    "MD": "Maryland",
    "MA": "Massachusetts",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MS": "Mississippi",
    "MO": "Missouri",
    "MT": "Montana",
    "NE": "Nebraska",
    "NV": "Nevada",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NY": "New York",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VT": "Vermont",
    "VA": "Virginia",
    "WA": "Washington",
    "WV": "West Virginia",
    "WI": "Wisconsin",
    "WY": "Wyoming"
};


export default class Drb2BUsersTaxCertificates extends LightningElement {
    customer;
    data;
    columns = [
        { label: companyNameLbl, fieldName: "companyName" },
        { label: certTaxAuthLbl, fieldName: "taxAuthority" },
        { label: startDateLbl, fieldName: "startDate", type: "date-local" },
        { label: endDateLbl, fieldName: "endDate", type: "date-local" }
    ];
    
    showSpinner = false;
    componentInited = false;

    labels = {
        userDoesntHasTaxCertificatesMsg,
        myTaxCertificatesTtl,
        manageTaxExemptionLbl
    };

    get hasCertificates() {
        return this.componentInited && this.customer.taxCertificates && this.customer.taxCertificates.length > 0;
    }

    get doesNotHaveCertificates() {
        return this.componentInited && this.customer.taxCertificates && this.customer.taxCertificates.length === 0;
    }
    
    showNewCertificateTaxModal() {
        this.showModal = true;
        this.template.querySelector("c-drb2b-add-tax-certificate").open();
    }
    
    connectedCallback() {
        this.getCustomerInfo();
    }
    
    getCustomerInfo() {
        const self = this;
        this.showSpinner = true;
        let currentURl = window.location.href.split('/');
        let indexOfCheckout = currentURl.indexOf('checkout')
        let currentCartId;
        if(indexOfCheckout != -1){
            currentCartId = currentURl[indexOfCheckout + 1];
        }
        getCustomer({cartId : currentCartId})
            .then(result => {
                if (result.isSuccess) {
                    this.customer = JSON.parse(JSON.stringify(result));
                    this.data = this.prepareCertificatesForView(this.customer.taxCertificates);
                    self.componentInited = true;
                } else if (!result.isSuccess && result.errors) {
                    result.errors.forEach(error => {
                        self.dispatchEvent(new ShowToastEvent({
                            title: "Error",
                            message: error.message,
                            variant: "error"
                        }));
                    });
                }
            })
            .catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error"
                    }));
                    console.log("\n\n error => " + JSON.stringify(error, null, 2));
                }
            )
            .finally(() => {
                this.showSpinner = false;
            });
    }
    
    prepareCertificatesForView(certificates) {
        let i = 0;
        certificates.forEach(certificate => {
            certificate.id = i;
            i++;
            certificate.taxAuthority = STATES[certificate.taxAuthority];
        });
        return certificates;
    }
    
    refresh() {
        this.getCustomerInfo();
    }
}