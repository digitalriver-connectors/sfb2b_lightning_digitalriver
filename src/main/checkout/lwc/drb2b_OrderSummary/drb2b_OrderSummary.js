import { LightningElement, api ,wire} from "lwc";
import getCartByOrderSummaryId from "@salesforce/apex/DRB2B_CheckoutSummaryController.getCartByOrderSummaryId";
import getTaxAndFee from "@salesforce/apex/DRB2B_CheckoutSummaryController.getTaxAndFee";
import cancelOrder from "@salesforce/apex/DRB2B_CheckoutSummaryController.CancelOrder";
import convertToOrder from "@salesforce/apex/DRB2B_CheckoutController.convertToOrder";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { FlowNavigationNextEvent, FlowAttributeChangeEvent } from "lightning/flowSupport";
import orderFailure from "@salesforce/label/c.DR_Order_Creation_Error";
import { NavigationMixin } from 'lightning/navigation';

//labels
import placeOrderBtnLbl from "@salesforce/label/c.DR_Place_Order_Button";
import {publish, subscribe,unsubscribe, MessageContext } from 'lightning/messageService';


import returnTocart from "@salesforce/label/c.Return_To_Cart";
import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";
import  dr_lms from '@salesforce/messageChannel/DigitalRiverMessageChannel__c';


const FLOW_ATTRIBUTE = "paymentType";
const FLOW_VALUE = "DigitalRiver";
export default class Drb2b_OrderSummary extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isDutyEnabled = false;
    @api isShippingEnabled = false;
    @api isFeeEnabled = false;
    @api isIOREnabled = false;
    @api isTaxEnabled = false;
    @api isGrandTotalEnabled = false ;
    @api isSubTotalEnabled = false;
    @api isPlaceOrderEnabled = false;
    @api isShowAll;
    @api bypassValidation;
    @api placeOrder;
    @api autoInitialize;
    showOrderSummaryComp = true;
    @api showPromotion;
    showOrderSummaryComponent;
    cartId;
    cart;
    isLoading = false;
    disablePO =  false;
    isLoaded = false;
    labels = {
        placeOrderBtnLbl,
        orderFailure,
        returnTocart
    };
    
    @wire(MessageContext)
    messageContext;
    isRenderd = false;

    connectedCallback() {
        if (this.isLoaded) return;
        this.isLoaded = true;
        this.startLoading();
        this.initCart(this.recordId).finally(this.stopLoading.bind(this));
        this.subscribeToMessageChannel();
        fireEvent(this.pageRef, "SHOW_PLACE_ORDER_BUTTON", "");
    }


    renderedCallback() {
        if (this.isRenderd) return;
        this.isRenderd = true;
        registerListener("DISABLE_PLACE_ORDER_BUTTON", this.disablePlaceOrderButtonfunc, this);
        if(this.placeOrder){
            registerListener("PLACE_ORDER", this.placeOrderFunc, this);
        }
    }
    
    get isCartReady() {
        return !!this.cart;
    }

    get isFullLayout() {
        return true;
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                dr_lms,
                (message) => this.showPlaceOrderFunct(message),
            );
        }
    }


    handlePreviousButton(){
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    showPlaceOrderFunct(message){
        switch (message.purpose) {
            case "placeOrder":
                this.validateAndPlaceOrder();
                break;
            case "toggleShowOSComponent":
                this.toggleShowOSComponent(message.payload);
                break;
            case "onPrevious":
                this.handlePreviousButton();
                break;
        }
    }

    toggleShowOSComponent(data){
        let dataobj = JSON.parse(data);
        this.showOrderSummaryComponent = dataobj?.isShow; //dataobj; 
        this.autoInitialize = dataobj?.isShow;
    }

    get showOrderSummaryComp(){
        return this.showOrderSummaryComponent && this.autoInitialize;
    }

    async initCart(recordId) {
        if (!recordId) return;
        var cartId = recordId;
        try {
            if (isOrderSummary(recordId)) {
                this.cart = await getCartByOrderSummaryId({ recordId });
            } else {
                this.cart = await getTaxAndFee({ cartId });
                this.isIOREnabled = this.isIOREnabled && this.cart.hasLandedCost;
                this.isDutyEnabled =  this.isDutyEnabled && this.cart.hasLandedCost;
                this.isFeeEnabled = this.cart.totaFee > 0 && this.isFeeEnabled;
                // if (this.cart.hasLandedCost) {
                //     this.isIOREnabled = true;
                //     this.isDutyEnabled = true;
                // }
                // if (this.cart.totaFee > 0) {
                //     this.isFeeEnabled = true;
                // }
                // this.isShippingEnabled = true;
                // this.isTaxEnabled = true;
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    mode: "sticky",
                    variant: "error"
                })
            );
        }
    }

    get displayPlaceOrderButton() {
        return this.cart != null && !isOrderSummary(this.recordId);
    }

   /*function to place order and disable place order button*/
   placeOrderFunc(){
        fireEvent(this.pageRef, "DISABLE_PLACE_ORDER_BUTTON", "");
        this.startLoading();
        this.handlePreviousButton();
        convertToOrder({ cartId: this.recordId })
            .then(() => {
                this.dispatchEvent(new FlowAttributeChangeEvent(FLOW_ATTRIBUTE, FLOW_VALUE));
                this.dispatchEvent(new FlowNavigationNextEvent());
            })
            .catch((error) => {
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'WebCart',
                        actionName: 'view'
                    },
                }).then(url => {
                    const event = new ShowToastEvent({
                        "title":  "Error",
                        "message": JSON.stringify(error.body.message),
                        "variant": "error",
                        "mode" : "sticky",
                        "messageData": [
                                                        {
                                url:url,
                                label: this.labels.returnTocart
                            }
                        ]
                    });
                    this.dispatchEvent(event);
                    this.cancelOrder();
                });
                console.error("Order Placement Process Error", JSON.stringify(error));
            })
            .finally(this.stopLoading.bind(this));
    }
    handlePlaceOrderBtnClick(){
        publish(this.messageContext, dr_lms, {
            purpose: 'placeOrder' 
        });
    }
    validateAndPlaceOrder() {
        /* condition to check whether to by pass validation or not based on designer attribute value configured*/
        try{
        if(this.placeOrder){
            if(!this.bypassValidation){
                publish(this.messageContext, dr_lms, {
                    purpose: 'checkTermsAndCondtions' 
                });
            }else{
                this.placeOrderFunc();
            }
        }   }catch(e){console.log('eeeee000000---'+e);}      
    }

    cancelOrder(){
        cancelOrder({ cartId: this.recordId })
        .then(() => {
            console.log('session cancelled')
        })
        .catch((error) => {
            console.log(error);
        })
        .finally(this.disablePO = true);
    }

    startLoading() {
        this.isLoading = true;
    }

    stopLoading() {
        this.isLoading = false;
    }

    disablePlaceOrderButtonfunc(){
        this.disablePO = true;
    }
    
    disconnectedCallback() {
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}

function isOrderSummary(recordId = "") {
    const orderSummaryIdPrefix = "1Os";
    return recordId.startsWith(orderSummaryIdPrefix);
}


