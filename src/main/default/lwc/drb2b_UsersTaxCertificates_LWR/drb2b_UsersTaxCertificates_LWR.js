import { LightningElement } from "lwc";
import Toast from 'lightning/toast';
import userDoesntHasTaxCertificatesMsg from '@salesforce/label/c.DR_TaxCertificates_UserDoesntHasTaxCertificates';
import myTaxCertificatesTtl from '@salesforce/label/c.DR_TaxCertificates_MyTaxCertificates';
import manageTaxExemptionLbl from '@salesforce/label/c.DR_TaxCertificates_ManageTaxExemption';
import companyNameLbl from '@salesforce/label/c.DR_TaxCertificates_CompanyName';
import certTaxAuthLbl from '@salesforce/label/c.DR_TaxCertificates_ExemptionCertTaxAuth';
import startDateLbl from '@salesforce/label/c.DR_TaxCertificates_ExemptionStartDate';
import endDateLbl from '@salesforce/label/c.DR_TaxCertificates_ExemptionEndDate';

import getCustomer from "@salesforce/apex/DRB2B_UsersTaxCertificatesController.getCustomer";
import getCartIdWithCommunityId from "@salesforce/apex/DRB2B_CartHelper.getCartIdWithCommunityId";
import communityId from '@salesforce/community/Id';
import ToastContainer from 'lightning/toastContainer';

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


export default class drb2b_UsersTaxCertificates_LWR extends LightningElement {
    customer;
    data;
    columns = [
        { label: companyNameLbl, fieldName: "companyName" },
        { label: certTaxAuthLbl, fieldName: "taxAuthority" },
        { label: startDateLbl, fieldName: "startDate", type: "date-local" },
        { label: endDateLbl, fieldName: "endDate", type: "date-local" }
    ];
    
    showSpinner = false;
    componentInitiated = false;
    isConnectedCallback = false;

    labels = {
        userDoesntHasTaxCertificatesMsg,
        myTaxCertificatesTtl,
        manageTaxExemptionLbl
    };

    get hasCertificates() {
        return this.componentInitiated && this.customer.taxCertificates && this.customer.taxCertificates.length > 0;
    }

    get doesNotHaveCertificates() {
        return this.componentInitiated && this.customer.taxCertificates && this.customer.taxCertificates.length === 0;
    }
    
    showNewCertificateTaxModal() {
        this.showModal = true;
        this.template.querySelector("c-drb2b-add-tax-certificate_-l-w-r").open();
    }
    
    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;    
        console.log('updated');
        this.getCustomerInfo();
    }
    
  

    getCustomerInfo() {
        const self = this;
         
         getCustomer({cartId : ''})
            .then(result => {
                if (result.isSuccess) {
                    this.customer = JSON.parse(JSON.stringify(result));
                    this.data = this.prepareCertificatesForView(this.customer.taxCertificates);
                    self.componentInitiated = true;
                } else if (!result.isSuccess && result.errors) {
                    result.errors.forEach(error => {
                    this.showToast({title: "Error" , message: error.message, variant: "error" });
                    });
                }
            })
            .catch(error => {
                    this.showToast({title: "Error" , message: error.body.message, variant: "error" });
                    console.log("\n\n drb2b_UsersTaxCertificates_LWR getCustomerInfo error => " + JSON.stringify(error, null, 2));
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
}