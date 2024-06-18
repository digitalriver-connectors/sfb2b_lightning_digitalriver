import { api, LightningElement } from "lwc";
import Toast from 'lightning/toast';
import ToastContainer from 'lightning/toastContainer';
import { isNotEmpty } from "c/commons";

import taxCertificateCreatedMsg from "@salesforce/label/c.DR_TaxCertificates_TaxCertificatedCreated";
import startDateBeforeEndDateMsg from "@salesforce/label/c.DR_TaxCertificates_StartDateBeforeEndDate";
import endDateAfterStartDateMsg from "@salesforce/label/c.DR_TaxCertificates_EndDateAfterStartDate";
import startDateBeforeTodayMsg from "@salesforce/label/c.DR_TaxCertificates_StartDateBeforeToday";
import endDateAfterTodayMsg from "@salesforce/label/c.DR_TaxCertificates_EndDateAfterToday";
import invalidFileMsg from "@salesforce/label/c.DR_TaxCertificates_InvalidFile";
import selectMissingFileMsg from "@salesforce/label/c.DR_TaxCertificates_SelectMissingFile";
import companyNameLbl from "@salesforce/label/c.DR_TaxCertificates_CompanyName";
import countryNameLbl from "@salesforce/label/c.DR_TaxCertificates_CountryName";
import certTaxAuthLbl from "@salesforce/label/c.DR_TaxCertificates_ExemptionCertTaxAuth";
import startDateLbl from "@salesforce/label/c.DR_TaxCertificates_ExemptionStartDate";
import endDateLbl from "@salesforce/label/c.DR_TaxCertificates_ExemptionEndDate";
import uploadFileLbl from "@salesforce/label/c.DR_TaxCertificates_UploadYourCertificate";
import exemptionDetailsTtl from "@salesforce/label/c.DR_TaxCertificates_SubmitYourExemptionDetails";
import submitBtnLbl from "@salesforce/label/c.DR_Global_Btn_Submit";
import cancelBtnLbl from "@salesforce/label/c.DR_Global_Btn_Cancel";

import getCountriesAndStates from "@salesforce/apex/DRB2B_UsersTaxCertificatesController.getCountriesAndStates";
import updateCustomerWithTaxCertificate from "@salesforce/apex/DRB2B_UsersTaxCertificatesController.updateCustomerWithTaxCertificate";
import uploadTaxCertificate from "@salesforce/apex/DRB2B_UsersTaxCertificatesController.uploadTaxCertificate";

export default class Drb2BAddTaxCertificate_LWR extends LightningElement {
    taxCertificate = {};
    countryOptions;
    stateOptions;
    country = "US";
    acceptedFormats = [".jpg", ".jpeg", ".pdf", ".png"];
    fileData;
    showSpinner;
    isFormOpen = false;

    labels = {
        selectMissingFileMsg,
        companyNameLbl,
        countryNameLbl,
        certTaxAuthLbl,
        startDateLbl,
        endDateLbl,
        uploadFileLbl,
        exemptionDetailsTtl,
        submitBtnLbl,
        cancelBtnLbl
    };

    connectedCallback() {
        this.initComponent();
    }

    initComponent() {
        getCountriesAndStates({})
            .then((result) => {
                this.countryOptions = Object.keys(result.countries).map((key) => {
                    return {
                        label: result.countries[key],
                        value: key
                    };
                });

                this.stateOptions = Object.keys(result.states).map((key) => {
                    return {
                        label: result.states[key],
                        value: key
                    };
                });
            })
            .catch((error) => {
                console.log("\n\n error => " + JSON.stringify(error, null, 2));
                this.showToast({title: "Error" , message: error.body.message, variant: "error" });
            });
    }

    @api
    open() {
        this.isFormOpen = true;
        this.removeValues();
        this.template.querySelector("c-drb2b-modal").open();
        this.template.querySelector("c-drb2b-modal").overflowFix();
    }

    updateCustomerWithTaxCertificate(drFile) {
        this.taxCertificate.fileid = drFile.id;
        updateCustomerWithTaxCertificate({ taxCertificate: this.taxCertificate, cartId :  ''})
            .then((result) => {
                       
                    if (result.isSuccess) {
                        this.dispatchEvent(new CustomEvent("success"));
                        this.closeModal();
                        this.showToast({title: "Success" , message: taxCertificateCreatedMsg, variant: "success" });
                    }      
                 
                    else if (!result.isSuccess && result.errors) {
                    result.errors.forEach((error) => {
                        console.log('Error Cause', error);
                        this.showToast({title: "Error" , message: error.message, variant: "error" });
                        });
                }
            })
            .catch((error) => {
                this.showToast({title: "Error" , message: error.body.message, variant: "error" });
                console.log("\n\n error => " + JSON.stringify(error, null, 2));
            })
            .finally(() => {
                this.showSpinner = false;
            });
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

    submitCertificate() {
        if (this.isInputValid() && this.fileData.base64File) {
            this.showSpinner = true;

            let currentURl = window.location.href.split('/');
            let indexOfCheckout = currentURl.indexOf('checkout')
            let currentCartId;
            if(indexOfCheckout != -1){
                currentCartId = currentURl[indexOfCheckout + 1];
            }

            let currentDate = new Date();
            //link expiry date + 1 year
            let desiredDate = new Date(currentDate.getFullYear() + 1, currentDate.getMonth(), currentDate.getDate());
            let filedata={
                file:this.fileData.base64File,
                fileName:this.fileData.filename,
                title:this.fileData.filename.substring(0, this.fileData.filename.lastIndexOf('.')) ,
                purpose:'tax_document_customer_upload',
                linkExpiresTime: desiredDate
            }
            uploadTaxCertificate({taxCertificateObject : JSON.stringify(filedata), cartId : currentCartId})
                .then((result) => {
                    this.updateCustomerWithTaxCertificate(result);
                })
                .catch((error) => {
                    this.showSpinner = false;

                    console.log("\n\n Error: " + JSON.stringify(error, null, 2));
                    this.showToast({title: "Error" , message: error.body.message, variant: "error" });
                    })
        } else if (isNotEmpty(this.fileData) && !this.fileData.base64File) {
            this.showToast({title: "Error" , message: this.labels.selectMissingFileMsg, variant: "error" });
        }
    }

    closeModal() {
        this.template.querySelector("c-drb2b-modal").close();
        this.isFormOpen = false;
    }

    handleCountryChange(event) {
        this.country = event.detail.value;
    }

    handleStateChange(event) {
        this.taxCertificate.taxAuthority = event.detail.value;
    }

    handleCompanyNameChange(event) {
        this.taxCertificate.companyName = event.detail.value;
    }

    handleStartDateChange(event) {
        this.taxCertificate.startDate = event.detail.value;
        this.validateStartEndDates();
    }

    handleEndDateChange(event) {
        this.taxCertificate.endDate = event.detail.value;
        this.validateStartEndDates();
    }

    validateStartEndDates() {
        const today = new Date();
        const startDateInput = this.template.querySelector(".start-date");
        const endDateInput = this.template.querySelector(".end-date");

        startDateInput.setCustomValidity("");
        endDateInput.setCustomValidity("");

        if (this.taxCertificate.endDate && this.taxCertificate.startDate) {
            if (new Date(this.taxCertificate.startDate) >= new Date(this.taxCertificate.endDate)) {
                startDateInput.setCustomValidity(startDateBeforeEndDateMsg);
                endDateInput.setCustomValidity(endDateAfterStartDateMsg);
            }
        }

        if (this.taxCertificate.startDate && new Date(this.taxCertificate.startDate) > today) {
            startDateInput.setCustomValidity(startDateBeforeTodayMsg);
        }

        if (this.taxCertificate.endDate)
            if(new Date(this.taxCertificate.endDate).setHours(0, 0, 0, 0)
                    < today.setHours(0, 0, 0, 0)) {
            endDateInput.setCustomValidity(endDateAfterTodayMsg);
        }
    }

    handleUpload(event) {

        const input = this.template.querySelector(".dcm-file-input");
        const uploadedFiles = event.detail.files;

        const file = uploadedFiles[0];
        console.log('file type', file);
        


        if (isLessThan10Mb(file) && isValidType(file)) {
            input.setCustomValidity("");

            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(",")[1];
                this.fileData = {
                    filename: file.name,
                    base64File: base64
                };
            };

            reader.readAsDataURL(file);
        } else {
            input.setCustomValidity(invalidFileMsg);
            input.value = 0;
            input.files = [];

            this.fileData = { filename: file.name };
        }
    }

    get isFileSelected() {
        return this.fileData && this.fileData.filename;
    }

    isInputValid() {
        const inputFields = this.template.querySelectorAll("lightning-input");
        const picklists = this.template.querySelectorAll("lightning-combobox");

        let inputs = [...inputFields];
        inputs = inputs.concat([...picklists]);

        return inputs.reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
    }

    removeValues() {
        this.fileData = {};
        const inputFields = this.template.querySelectorAll("lightning-input");
        const picklists = this.template.querySelectorAll("lightning-combobox");
        let inputs = [...inputFields];
        inputs = inputs.concat([...picklists]);

        inputs.forEach((input) => {
            if (input.value !== "US") {
                input.value = "";
            }
        });
    }
}

function isLessThan10Mb(file) {
    return file.size / 1024 / 1024 <= 10;
}

function isValidType(file) {
    const validTypes = new Set(["application/pdf", "image/jpeg", "image/jpg", "image/png"]);

    return validTypes.has(file.type);
}
