import { LightningElement, api, wire } from "lwc";
import getCartByOrderSummaryId from "@salesforce/apex/DRB2B_CheckoutSummaryController.getCartByOrderSummaryId";
import getTaxAndFee from "@salesforce/apex/DRB2B_CheckoutSummaryController.getTaxAndFee";
import clearCartItemStructure from "@salesforce/apex/DRB2B_CartService.clearCartItemStructure";
import convertToOrderLWR from "@salesforce/apex/DRB2B_CheckoutController.convertToOrderLWR";
import orderFailure from "@salesforce/label/c.DR_Order_Creation_Error";
import { NavigationMixin } from "lightning/navigation";
import ToastContainer from "lightning/toastContainer";
import Toast from "lightning/toast";
import getCart from "@salesforce/apex/DRB2B_DropinController.getCart";
import sfFailedCancelOrder from "@salesforce/apex/DRB2B_CheckoutController.sfFailedCancelOrder";

//labels
import placeOrderBtnLbl from "@salesforce/label/c.DR_Place_Order_Button";
import { publish, subscribe, unsubscribe, MessageContext } from "lightning/messageService";
import returnTocart from "@salesforce/label/c.Return_To_Cart";
import { fireEvent, registerListener, unregisterAllListeners } from "c/pubsub";
import dr_lms from "@salesforce/messageChannel/DigitalRiverMessageChannel__c";
import getOrderDetail from "@salesforce/apex/DRB2B_CheckoutController.getOrderDetail";
import {
    CheckoutComponentBase,
    CheckoutInformationAdapter,
    placeOrder,
    authorizePayment,
    postAuthorizePayment
} from "commerce/checkoutApi";
import { CartSummaryAdapter } from "commerce/cartApi";
import { CurrentPageReference } from "lightning/navigation";

const CheckoutStage = {
    CHECK_VALIDITY_UPDATE: "CHECK_VALIDITY_UPDATE",
    REPORT_VALIDITY_SAVE: "REPORT_VALIDITY_SAVE",
    BEFORE_PAYMENT: "BEFORE_PAYMENT",
    PAYMENT: "PAYMENT",
    BEFORE_PLACE_ORDER: "BEFORE_PLACE_ORDER",
    PLACE_ORDER: "PLACE_ORDER"
};

export default class drb2b_order_Summary_LWR extends NavigationMixin(CheckoutComponentBase) {
    @api recordId;
    @api orderNumber;
    @api isDutyEnabled = false;
    @api isShippingEnabled = false;
    @api isFeeEnabled = false;
    @api isIOREnabled = false;
    @api isTaxEnabled = false;
    @api isGrandTotalEnabled = false;
    @api isSubTotalEnabled = false;
    @api isPlaceOrderEnabled = false;
    @api isShowAll;
    @api bypassValidation = false;
    @api placeOrder;
    @api autoInitialize;
    showOrderSummryComp = true;
    @api showPromotion;
    @api sfOrderId;
    @api orderSummaryId;
    @api webCartId;
    @api checkoutId;
    @api billingDetails;
    @api buyerName;

    showOrderSummaryComponent;
    cartId;
    cart;
    isLoading = false;
    disablePO = false;
    isLoaded = false;
    isPlaceOrderFlag = false;
    isRendered = false;
    isConnectedCallback = false;
    labels = {
        placeOrderBtnLbl,
        orderFailure,
        returnTocart
    };

    @wire(CurrentPageReference)
    getUrlParameters(currentPageReference) {
        if (currentPageReference) {
            if (currentPageReference.attributes?.objectApiName == "OrderSummary") {
                this.recordId = this.orderNumber = currentPageReference.attributes?.recordId;
            } else if (currentPageReference.state?.orderNumber != undefined) {
                this.recordId = this.orderNumber = currentPageReference.state?.orderNumber;
            }
        }
    }

    @wire(MessageContext)
    messageContext;

    summary;
    _checkoutMode = 1;

    setAspect(newAspect /*CheckoutContainerAspect*/) {
        if (this.summary == newAspect.summary) {
            return;
        }
        this.summary = newAspect.summary;
        if (this.summary) {
            this.setCheckoutMode(3);
        } else {
            this.setCheckoutMode(4);
        }
    }

    //-------------------------------
    _checkedByDefault;
    checked;
    showError = false;
    _checkoutMode = 1;
    isDisabled = false;
    /**
     * @type {CheckoutMode}
     */
    @api get checkoutMode() {
        return this._checkoutMode;
    }

    /**
     * Handles the checkout mode and puts the component in the right state
     * If the component is not currently being edited it'll go into disbaled state
     */
    set checkoutMode(value) {
        this.setCheckoutMode(value);
    }

    setCheckoutMode(value) {
        switch (value) {
            case 1:
                break;
            case 2:
                break;
            case 3:
                break;
            case 4:
                break;
        }
        this._checkoutMode = value;
    }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {

            this.recordId = data.cartId;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(CheckoutInformationAdapter, { recordId: "$recordId" })
    wiredRecord(result) {
        this.record = result;
        if (result.data && result.data.checkoutStatus == 200) {
            {
                this.checkoutId = result.data.checkoutId;
            }
        }
    }

    //-------------------------------
    connectedCallback() {
        if (this.isConnectedCallback || !this.isConnected) return;
        this.isConnectedCallback = true;
        if (this.isLoaded) return;
        this.isLoaded = true;
        this.isPlaceOrderEnabled = true;
        this.startLoading();
        if (this.orderNumber) {
            this.initCart(this.orderNumber).finally(this.stopLoading.bind(this));
        } else {
            this.getCartIdRecord();
        }
        this.subscribeToMessageChannel();
        fireEvent(this.pageRef, "SHOW_PLACE_ORDER_BUTTON", "");
    }

    renderedCallback() {
        if (this.isRendered || !this.isConnected) return;
        this.isRendered = true;
        registerListener("DISABLE_PLACE_ORDER_BUTTON", this.disablePlaceOrderButtonfunc, this);
        if (this.placeOrder) {
            registerListener("PLACE_ORDER", this.placeOrderFunc, this);
            this.hideOrderSummarySection();
        }
    }

    hideOrderSummarySection() {
        if (this.template.querySelector(".orderSummary") !== null) {
            this.template.querySelector(".orderSummary").classList.add("slds-hide");
        }
    }

    getCartIdRecord() {
        this.initCart(this.recordId).finally(this.stopLoading.bind(this));
        this.getOrderDetailFromServer(this.recordId).finally(this.stopLoading.bind(this));
        this.isLoading = false;
    }

    get isCartReady() {
        return !!this.cart;
    }

    get isFullLayout() {
        return true;
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, dr_lms, (message) => this.showPlaceOrderFunct(message));
        }
    }

    handlePreviousButton() {
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    showPlaceOrderFunct(message) {
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

    toggleShowOSComponent(data) {
        let dataobj = JSON.parse(data);
        this.showOrderSummaryComponent = dataobj?.isShow; //dataobj;
        this.autoInitialize = dataobj?.isShow;
    }

    get showOrderSummaryComp() {
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
                this.isDutyEnabled = this.isDutyEnabled && this.cart.hasLandedCost;
                this.isFeeEnabled = this.cart.totaFee > 0 && this.isFeeEnabled;
            }
        } catch (error) {
            this.showToastwithOutLink({
                title: "Error",
                message: JSON.stringify(error.body.message),
                variant: "error"
            });
        }
    }

    get displayPlaceOrderButton() {
        return this.cart != null && !isOrderSummary(this.recordId);
    }

    /*function to place order and disable place order button*/
    async placeOrderFunc() {
        let drOrderId;
        if (!this.isPlaceOrderFlag) {
            fireEvent(this.pageRef, "DISABLE_PLACE_ORDER_BUTTON", "");
            this.isPlaceOrderFlag = true;
            publish(this.messageContext, dr_lms, {
                purpose: "isPlacingOrder",
                payload: true
            });
            this.startLoading();
            this.handlePreviousButton();
            try {
                // dr order creation
                await convertToOrderLWR({ cartId: this.recordId })
                    .then((result) => {
                        this.drOrderId = result;
                    })
                    .catch((error) => {
                        console.log("drb2b_ordersummary DR order creation failure " + error);
                        clearCartItemStructure({ cartId: this.recordId });
                        this.showToastbacktoCart(error);
                    });
                // sf order creation
                await placeOrder().then((result1) => {
                    if (result1.orderReferenceNumber) {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                name: "Order"
                            },
                            state: { orderNumber: result1.orderReferenceNumber }
                        });
                    } else {
                        sfFailedCancelOrder({drOrderId:this.drOrderId});
                        throw new Error("handlePlaceOrderBtn Required orderReferenceNumber is missing");
                    }
                });
            } catch (error) {
                this[NavigationMixin.GenerateUrl]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Current_Cart"
                    }
                }).then((url) => {
                    this.isPlaceOrderFlag = false;
                    publish(this.messageContext, dr_lms, {
                        purpose: "isPlacingOrder",
                        payload: false
                    });
                    let messageData = ["Salesforce", { url: url, label: this.labels.returnTocart }];
                    this.showToast({
                        title: "Error",
                        message: JSON.stringify(error.body.message),
                        messageData: messageData,
                        variant: "error"
                    });
                    console.error("Order Placement Process Error", JSON.stringify(error));
                });
                throw e;
            } finally {
                this.stopLoading.bind(this);
            }
        }
    }

    handlePlaceOrderBtnClick() {
        publish(this.messageContext, dr_lms, {
            purpose: "placeOrder"
        });
    }

    async validateAndPlaceOrder() {
        /* condition to check whether to by pass validation or not based on designer attribute value configured*/
        try {
            await this.postAuthorizePayment(this.recordId);
            if (this.placeOrder) {
                if (!this.bypassValidation) {
                    publish(this.messageContext, dr_lms, {
                        purpose: "checkTermsAndConditions"
                    });
                } else {
                    this.placeOrderFunc();
                }
            }
        } catch (e) {
            console.log("validateAndPlaceOrder" + e);
        }
    }

    startLoading() {
        this.isLoading = true;
    }

    stopLoading() {
        this.isLoading = false;
    }

    disablePlaceOrderButtonfunc() {
        this.disablePO = true;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    showToast(obj) {
        const toastContainer = ToastContainer.instance();
        let salesforceLink;
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = "top-center";
        Toast.show(
            {
                label: obj.title,
                messageLinks: [
                    {
                        url: obj.messageData[1].url,
                        label: obj.messageData[1].label
                    }
                ],
                message: obj.message,
                mode: "dismissible",
                variant: obj.variant
            },
            this
        );
    }

    showToastwithOutLink(obj) {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = "top-center";
        Toast.show(
            {
                label: obj.title,
                message: obj.message,
                mode: "dismissible",
                variant: obj.variant
            },
            this
        );
    }

    async postAuthorizePayment(webCartId) {
        let token, paymentResult;
        try {
            await getCart({ cartId: webCartId }).then((result) => {
                this.billingDetails = result.cart.billingAddress;
                this.buyerName = result.cart.buyerName;
                this.paymentSourceId = result.cart.sourceId;
                this.grandTotal = result.cart.grandTotalAmount;
            });
            let billingAddress = {
                name: this.buyerName,
                street: this.billingDetails.street,
                city: this.billingDetails.city,
                region: this.billingDetails.stateCode,
                country: this.billingDetails.countryCode,
                postalCode: this.billingDetails.postalCode
            };
            //zero dollar check before creating token
            if (this.grandTotal > 0) {
                token = this.paymentSourceId + "_" + webCartId;
            } else {
                token = "_" + webCartId;
            }
            paymentResult = await postAuthorizePayment(this.checkoutId, token, billingAddress);
        } catch (error) {
            //Add show toast error...
            console.log("handlePostAuthorizePaymentBtn error: " + error.errors[0].detail);
            this.showToastbacktoCart(error.errors[0]);
        }
    }

    showToastbacktoCart(error) {
        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                name: "Current_Cart"
            }
        }).then((url) => {
            this.isPlaceOrderFlag = false;
            publish(this.messageContext, dr_lms, {
                purpose: "isPlacingOrder",
                payload: false
            });
            let messageData = ["Salesforce", { url: url, label: this.labels.returnTocart }];
            this.showToast({
                title: "Error",
                message: JSON.stringify(error.body.message),
                messageData: messageData,
                variant: "error"
            });
            console.error("Order Placement Process Error", JSON.stringify(error));
        });
        throw e;
    }

    orderDetail = {};
    async getOrderDetailFromServer(recordId) {
        getOrderDetail({ cartId: recordId })
            .then((resp) => {
                let data = JSON.parse(resp);
                this.orderDetail = data[0] ? data[0] : undefined;
            })
            .catch((error) => {
                this.showToastwithOutLink({
                    title: "Error",
                    message: JSON.stringify(error.body.message),
                    variant: "error"
                });
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}

function isOrderSummary(recordId = "") {
    const orderSummaryIdPrefix = "1Os";
    return recordId.startsWith(orderSummaryIdPrefix);
}
