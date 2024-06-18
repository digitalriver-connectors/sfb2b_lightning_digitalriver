import { LightningElement, track, api } from "lwc";
import { getCountries } from "c/countries";
import { getNamespacePrefix } from "c/commons";
import communityPath from "@salesforce/community/basePath";
import saveTaxId from "@salesforce/apex/DRB2B_MyTaxIdentifierController.createTaxIdentifier";
import getTaxIds from "@salesforce/apex/DRB2B_MyTaxIdentifierController.getTaxIdentifier";
import deleteTaxId from "@salesforce/apex/DRB2B_MyTaxIdentifierController.deleteTaxIdentifier";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// Import custom labels
import confirmDeletion from "@salesforce/label/c.DR_Confirm_Delete_Msg";
import deleteSuccess from "@salesforce/label/c.DR_TaxId_Delete_Success_Msg";
import deleteError from "@salesforce/label/c.DR_TaxId_Delete_Error_Msg";
import addSuccess from "@salesforce/label/c.DR_TaxId_Add_Success_Msg";
import alreadyExistError from "@salesforce/label/c.DR_TaxId_Already_Exist";
import addError from "@salesforce/label/c.DR_TaxId_Add_Error_Msg";
import notApplicableError from "@salesforce/label/c.DR_TaxId_Not_Applicable";
import taxIdDisclaimer from "@salesforce/label/c.DR_TaxId_Disclaimer";
import noSavedTaxId from "@salesforce/label/c.DR_No_Saved_Tax";
import DR_Confirm from "@salesforce/label/c.DR_Confirm";
import DR_Cancel from "@salesforce/label/c.DR_Cancel";
import DR_Delete from "@salesforce/label/c.DR_Delete";
import DR_Tax_Identifiers from "@salesforce/label/c.DR_Tax_Identifiers";
import DR_Country from "@salesforce/label/c.DR_Country";
import DR_TaxId_Type from "@salesforce/label/c.DR_TaxId_Type";
import DR_TaxId_Id from "@salesforce/label/c.DR_TaxId_Id";
import DR_TaxId_State from "@salesforce/label/c.DR_TaxId_State";
import DR_Select_Country_placeholder from "@salesforce/label/c.DR_Select_Country_placeholder";
import DR_New_Tax_ID_Label from "@salesforce/label/c.DR_New_Tax_ID_Label";
import communityId from '@salesforce/community/Id';

const eventType = "taxId";
const tableColumns = [
    {
        label: DR_TaxId_Type,
        fieldName: "type",
        hideDefaultActions: true
    },
    {
        label: DR_TaxId_Id,
        fieldName: "value",
        hideDefaultActions: true
    },
    {
        label: DR_TaxId_State,
        fieldName: "state",
        hideDefaultActions: true
    },
    {
        label: "",
        type: "button",
        hideDefaultActions: true,
        initialWidth: 120,
        typeAttributes: {
            iconName: "action:delete",
            title: DR_Delete,
            variant: "destructive",
            alternativeText: "View",
            label: DR_Delete
        }
    }
];
export default class Drb2b_MyTaxIdentifier extends LightningElement {
    @api webcartId; // DEPRECATED
    taxIdForDeletion;
    isLoading = false;
    initilized = false;
    showTaxSection = false;
    showTable;
    @track taxData = [];
    tableColumns = tableColumns;
    showConfirmationModal = false;
    label = {
        noSavedTaxId,
        confirmDeletion,
        taxIdDisclaimer,
        notApplicableError,
        addError,
        alreadyExistError,
        addSuccess,
        deleteError,
        deleteSuccess,
        DR_Confirm,
        DR_Cancel,
        DR_Delete,
        DR_Tax_Identifiers,
        DR_Country,
        DR_Select_Country_placeholder,
        DR_New_Tax_ID_Label
    };

    get options() {
        return getCountries();
    }

    get communityURL() {
        let nameSpace = getNamespacePrefix();
        let cURL = communityPath.slice(0, communityPath.lastIndexOf("/s"));
        return `${cURL}/apex/${nameSpace}DRB2B_drjsElement?communityId=${communityId}`;
    }

    connectedCallback() {
        if (this.isInitilized) return;
        this.isInitilized = true;
        this.showLoader();
        this._listenForMessage = this.callResponseHandler.bind(this);
        window.addEventListener("message", this._listenForMessage);
        this.getTaxIds();
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

    handleVFResponse(message) {
        let msg = JSON.parse(message);
        switch (msg.event) {
            case "taxid":
                this.initilizeSave(msg.obj);
                break;
            case "notApplicable":
                this.showToast({ message: notApplicableError, variant: "error" });
                this.hideLoader();
                break;
            case "hideLoader":
                this.hideLoader();
                break;
        }
    }

    initilizeSave(evt) {
        this.showLoader();
        for (let taxid in evt) {
            let ajaxTaxID = {
                type: evt[taxid].type,
                value: evt[taxid].value
            };
            this.saveTaxIdentifier(ajaxTaxID);
        }
    }

    saveTaxIdentifier(data) {
        let currentURl = window.location.href.split('/');
        let indexOfCheckout = currentURl.indexOf('checkout')
        let currentCartId;
        if(indexOfCheckout != -1){
            currentCartId = currentURl[indexOfCheckout + 1];
        }
        saveTaxId({ jsonString: JSON.stringify(data),  cartId: currentCartId })
            .then((result) => {
                let response = JSON.parse(result);
                if (response.errors) {
                    this.showToast({ message: response.errors[0].message, variant: "error" });
                } else {
                    this.getTaxIds();
                    this.handleCloseTaxSection();
                    this.showToast({ message: this.label.addSuccess + ":" + data.value, variant: "success" });
                }
            })
            .catch((error) => {
                this.showToast({ message: this.label.addError + ":" + data.value, variant: "error" });
                console.log(error);
            })
            .finally(() => this.hideLoader());
    }

    fireEventLWC(evt) {
        let component = this;
        let pMessage = {
            event: eventType,
            data: {
                code: evt
            }
        };
        //setTimeout(() => {
            component.template.querySelector(".iframe-Class").contentWindow.postMessage(JSON.stringify(pMessage), "/");
      //  }, 1000);
    }

    handleCountryChange(event) {
        this.fireEventLWC(event.detail.detail.value);
        this.showLoader();
    }

    handleAddNewTaxId() {
        this.showTaxSection = true;
    }

    getTaxIds() {
        getTaxIds()
            .then((result) => {
                this.taxData = JSON.parse(result).taxIdentifiers;
                this.showTable = true;
            })
            .catch((error) => {
                console.log(error);
            })
            .finally(() => this.hideLoader());
    }

    handleRowAction(event) {
        this.taxIdForDeletion = event.detail.row.id;
        this.handleShowConfirmationModal();
    }

    handleCloseTaxSection() {
        this.showTaxSection = false;
    }

    handleShowConfirmationModal() {
        this.showConfirmationModal = true;
        this.template.querySelector("c-drb2b-modal").open();
    }

    handleCancel() {
        this.template.querySelector("c-drb2b-modal").close();
    }

    handleConfirm() {
        this.showLoader();
        this.deleteTaxId();
    }

    deleteTaxId() {
        let currentURl = window.location.href.split('/');
        let indexOfCheckout = currentURl.indexOf('checkout')
        let currentCartId;
        if(indexOfCheckout != -1){
            currentCartId = currentURl[indexOfCheckout + 1];
        }
        deleteTaxId({ taxId: this.taxIdForDeletion, cartId: currentCartId  })
            .then((result) => {
                if (result) {
                    this.getTaxIds();
                    this.handleCancel();
                    this.showToast({ message: this.label.deleteSuccess, variant: "success" });
                } else {
                    this.showToast({ message: this.label.deleteError, variant: "error" });
                }
            })
            .catch((error) => {
                this.showToast({ message: this.label.deleteError, variant: "error" });
                console.log(error);
            });
        //.finally(() => this.hideLoader());
    }

    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }

    showLoader() {
        this.isLoading = true;
    }

    hideLoader() {
        this.isLoading = false;
    }
}
