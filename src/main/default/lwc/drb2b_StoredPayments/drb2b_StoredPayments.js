//new Changes

import { LightningElement, wire, track } from "lwc";

import getLabel from "@salesforce/apex/DRB2B_StoredPayments.getLabel";
import getAllSavedPayments from "@salesforce/apex/DRB2B_StoredPayments.getAllSavedPayments";
import deleteSavedSource from "@salesforce/apex/DRB2B_StoredPayments.deleteSavedPayment";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import CONTACT_ID from "@salesforce/schema/User.ContactId";
import confirmDeletion from "@salesforce/label/c.DR_Confirm_Source_Delete";
import deleteSuccess from "@salesforce/label/c.Saved_Payment_delete_Success_message";
import deleteError from "@salesforce/label/c.DR_Saved_Payment_Delete_Error_Msg";
import cancelBtn from "@salesforce/label/c.DR_Global_Btn_Cancel";
import confirmBtn from "@salesforce/label/c.DR_Global_Confirm_Button";
import drPaymentMethodPrefix from "@salesforce/label/c.DR_PaymentMethod";


const columns = [
    { label: "Payment Type", fieldName: "paymentType", type: "text" },
    { label: "Card Type ", fieldName: "cardType", type: "text" },
    { label: "Card Number", fieldName: "cardNumber", type: "text" },
    {
        label: "Action",
        type: "button",
        typeAttributes: {
            iconName: "action:delete",
            title: "Delete",
            variant: "destructive",
            name: "delete",
            label: "Delete"
        },
        initialWidth: 150
    }
];

export default class Drb2b_StoredPayments extends LightningElement {
    @track data;
    @track _columns = columns;
    ContactId;
    UserId = USER_ID;
    initialized = false;
    isLoading = false;
    savedcardList = [];
    sourceIdForDeletion;
    showConfirmationModal = false;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID]
    })
    user;

    label = {
        confirmDeletion,
        deleteError,
        deleteSuccess,
        cancelBtn,
        confirmBtn
    };

    get contactInfo() {
        this.ContactId = getFieldValue(this.user.data, CONTACT_ID);
        return getFieldValue(this.user.data, [CONTACT_ID]);
    }

    connectedCallback() {
        if (this.initialized) return;
        this.initialized = true;
        this.isLoading = true;
        this.getAllStoredPayments();
    }
    //get all Stored Payments
    creditCardValue;
    mapOfPaymentMethod =[];
    dataSetFromLabelServer;
    async getAllStoredPayments() {
       await getAllSavedPayments({ jsonString: JSON.stringify({ contactId: this.ContactId, userId: this.UserId, cartId : ''}) })
            .then((result) => {
                let resultData = JSON.parse(result);
                let tempdatad = [];
                if (resultData.isSuccess) {
                    this.savedcardList = resultData.attachedSources;
                    this.savedcardList.forEach((savedCard) => {
                        resultData.storedPayments.forEach((storedPayment) => {
                            if (savedCard.state != "cancelled") {
                                if(storedPayment === savedCard.type){
                                    this.creditCardValue=undefined;
                                    let label = drPaymentMethodPrefix+savedCard.type;
                                    //let label = drPaymentMethodPrefix+'newMethod';
                                    let boolFlag = false;
                                  this.mapOfPaymentMethod.map(resData => {
                                        if(resData.key==label)
                                        {
                                            boolFlag = true;
                                            this.creditCardValue = resData.value;
                                        }
                                    });
                                    if(!boolFlag){
                                        this.dataSetFromLabelServer =false;
                                        this.labelValue(label);
                                     
                                    }
                                    if(savedCard.type === 'creditCard'){
                                        var creditCardValues = savedCard.creditCard;
                                        let brandValue;
                                        let boolFlag = false;
                                        label = drPaymentMethodPrefix + creditCardValues.brand;
                                        
                                        this.mapOfPaymentMethod.map(resData => {
                                            if(resData.key==label)
                                            {
                                                boolFlag = true;
                                                brandValue = resData.value;
                                            }
                                        });
                                        if(!boolFlag){
                                            this.dataSetFromLabelServer =false;
                                            this.labelValue(label);
                                        }
                                        let tempArray = {
                                            //paymentType: savedCard.type,
                                            paymentType: this.creditCardValue ,
                                            cardType:brandValue,//creditCardValues.brand,//brandValue,
                                            cardNumber: creditCardValues.lastFourDigits,
                                            id: savedCard.id
                                        };
                                        tempdatad.push(tempArray);
                                    }else{
                                        let tempArray = {
                                            paymentType: this.creditCardValue,
                                            cardType: '',
                                            cardNumber: '',
                                            id: savedCard.id
                                        };
                                        tempdatad.push(tempArray);
                                    }
                                    
                                }
                            }
                        });
                    });
                   
                    if(this.dataSetFromLabelServer || this.savedcardList.length===0) {
                        this.data = tempdatad;
                        this.isLoading = false;
                    }
                } else {
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                this.isLoading = false;
                console.log("\n\n error => " + JSON.stringify(error, null, 2));
                this.showToast({ message: error.body.message, variant: "error" });
            });
    }
    handleRowAction(event) {
        this.sourceIdForDeletion = event.detail.row.id;
        this.handleShowConfirmationModal();
    }
    handleShowConfirmationModal() {
        this.showConfirmationModal = true;
        this.template.querySelector("c-drb2b-modal").open();
    }
    handleCancel() {
        this.template.querySelector("c-drb2b-modal").close();
    }
    //common method to show toast
    showToast(obj) {
        const event = new ShowToastEvent(obj);
        this.dispatchEvent(event);
    }
    handleConfirm() {
        this.deleteSavedSource();
    }

    deleteSavedSource() {
        this.isLoading = true;
        deleteSavedSource({ jsonString: JSON.stringify({ sourceId: this.sourceIdForDeletion, userId: this.UserId }) })
            .then((result) => {
                if (result) {
                    this.getAllStoredPayments();
                    this.handleCancel();
                    this.isLoading = false;
                    this.showToast({ message: this.label.deleteSuccess, variant: "success" });
                } else {
                    this.showToast({ message: this.label.deleteError, variant: "error" });
                }
            })
            .catch((error) => {
                this.showToast({ message: this.label.deleteError, variant: "error" });
                console.log(error);
            });
        }
    
    async labelValue(labelStr) {
       
                let valueD = await getLabel({label:labelStr});
                let value = JSON.parse(valueD).value;
                let temp={}
                temp.key=labelStr;
                temp.value = value;
                let boolFlag = false;
                this.mapOfPaymentMethod.map(res=>{
                    if(res.key == labelStr){
                        boolFlag = true;
                    }
                })
                if(!boolFlag){
                    this.mapOfPaymentMethod.push(temp);
                }
               
                this.dataSetFromLabelServer = true;
                if(this.isLoading && this.dataSetFromLabelServer){
                    this.getAllStoredPayments();
                }
           
    }

}
