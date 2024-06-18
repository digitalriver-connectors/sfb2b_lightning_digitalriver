global without sharing class DRB2B_TaxCalculationService {
    public DRB2B_TaxCalculationService() {
    }

    private static final String DELIVERY_CHARGE_ITEM = 'DELIVERY_CHARGE_ITEM';

    private static final List<String> CART_FIELDS = new List<String>{
        'DR_Checkout_Type__c',
        'Buyer_Name__c',
        'Buyer_Email__c',
        'Buyer_Phone__c',
        'BillingCountry',
        'BillingState',
        'BillingPostalCode',
        'BillingCity',
        'BillingStreet',
        'DR_Customer_Type__c',
        'Buyer_OrganizationName__c',
        'DR_Guest_IpAddress__c'
    };
    private static final List<String> CART_ITEMS_FIELDS = new List<String>{
        'Id',
        'Sku',
        'Product2Id',
        'TotalPrice',
        'Quantity',
        'Type',
        'Name',
        'CartId',
        'CartDeliveryGroup.DeliverToCountry',
        'CartDeliveryGroup.DeliverToState',
        'CartDeliveryGroup.DeliverToPostalCode',
        'CartDeliveryGroup.DeliverToCity',
        'CartDeliveryGroup.DeliverToStreet',
        'Recurring_Line_Item__c',
        'Subscription_Id__c',
        'Subscription_End_Time__c',
        'Subscription_Start_Time__c',
        'Free_Subscription_Trial__c',
        'TotalPriceAfterAllAdjustments',
        'digitalriverv3__ShipFrom_Country__c',
        'digitalriverv3__ShipFrom_State__c',
        'digitalriverv3__ShipFrom_Postal_code__c',
        'digitalriverv3__ShipFrom_City__c',
        'digitalriverv3__ShipFrom_Street__c',
        'DR_Item_TaxType__c'
    };

    private DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

    @TestVisible
    private DRB2B_CheckoutService checkoutService = new DRB2B_CheckoutServiceImpl();
    private DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
    private static DRB2B_UserSelector userSelector = new DRB2B_UserSelector();
    private static DRB2B_CustomerService customerService = new DRB2B_CustomerService();

    global static ResponseModel startCartProcessAsync(Id cartId, sfdc_checkout.IntegrationInfo jobInfo) {
        DRB2B_CheckoutService checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
        DRB2B_UserSelector userSelector = new DRB2B_UserSelector();
        DRB2B_CustomerService customerService = new DRB2B_CustomerService();
        DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
        String status;
        String errorMessage;
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        String previousCheckoutItemsObj;

        try {
            previousCheckoutItemsObj = [SELECT DR_CartItemStructure__c FROM webCart WHERE id = :cartId]
            .DR_CartItemStructure__c;

            if (!isGuestUser) {
                DRB2B_CreateCustomerResponseModel customerResponse = customerService.getById(
                    UserInfo.getUserId(),
                    cartId
                );
                if (customerResponse.id == null) {
                    customerResponse = customerService.createCustomer(UserInfo.getUserId(), cartId);
                }
            }

            Boolean isCountryPickListEnabled = DRB2B_Utility.isCountryStateEnabled();
            //Adding state and code country field if country picklist is enabled
            if (isCountryPickListEnabled) {
                CART_FIELDS.addAll(new List<String>{ 'BillingCountryCode', 'BillingStateCode' });
                CART_ITEMS_FIELDS.addAll(
                    new List<String>{ 'CartDeliveryGroup.DeliverToStateCode', 'CartDeliveryGroup.DeliverToCountryCode' }
                );
            }
            User runningUser;
            if (!isGuestUser) {
                runningUser = userSelector.getById(UserInfo.getUserId(), new Set<String>{ 'Id', 'Name', 'ContactId' });
            }
            WebCart cart = cartSelector.getCartWithItemsById(cartId, CART_FIELDS, CART_ITEMS_FIELDS);
            CartDeliveryGroup deliveryGroup = getDeliveryGroup(cart);
            logger.debug(cartId, 'Starting tax calculation process: \n\n' + JSON.serializePretty(cart));

            // Setup Checkout Context
            DRB2B_CheckoutContext context = new DRB2B_CheckoutContext();
            context.cartId = cartId;

            DRB2B_CreateCheckoutRequestModel createCheckoutRequest = new DRB2B_CreateCheckoutRequestModel();
            List<DRB2B_CreateCheckoutRequestModel.TaxIdentifiers> taxIdentifiersList = new List<DRB2B_CreateCheckoutRequestModel.TaxIdentifiers>();
            List<DRB2B_CreateCheckoutRequestModel.Item> checkoutItems = new List<DRB2B_CreateCheckoutRequestModel.Item>();
            DRB2B_CheckoutAddressService addressService = new DRB2B_CheckoutAddressService();

            DRB2B_updateCheckoutRequestModel updateCheckoutRequest = new DRB2B_updateCheckoutRequestModel();
            createCheckoutRequest.items = checkoutItems;

            Map<String, CartItem> cartItemsBySkuIds = new Map<String, CartItem>();
            for (CartItem cartItem : cart.CartItems) {
                if (isProductType(cartItem)) {
                    if (isInvalidSku(cartItem)) {
                        errorMessage = 'The SKUs for all products in your cart must be defined.';
                        saveCartValidationOutputError(errorMessage, jobInfo, cartId);
                        status = 'Error';
                    } else {
                        checkoutItemStructure(
                            cartItem,
                            configurationSelector,
                            cartId,
                            checkoutItems,
                            cartItemsBySkuIds
                        );
                    }
                } else if (isChargeType(cartItem)) {
                    if (
                        cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_DIGITAL &&
                        cartItem.TotalPrice > 0 &&
                        !Test.isRunningTest()
                    ) {
                        errorMessage = 'Digital cart (Cart with only Digital Products) cannot have a Shipping Amount greater than $0';
                        saveCartValidationOutputError(errorMessage, jobInfo, cartId);
                        status = 'Error';
                        logger.error(errorMessage);
                    } else if (cart.DR_Checkout_Type__c != DRB2B_Constants.WebCart.TYPE_DIGITAL) {
                        DRB2B_CheckoutShippingChoiceService shippingChoiceInfo = new DRB2B_CheckoutShippingChoiceService();
                        DRB2B_ShippingChoiceInfo shippingChoiceDetails = shippingChoiceInfo.getShippingChoiceInfo(
                            context
                        );
                        DRB2B_CreateCheckoutRequestModel.ShippingChoice shippingChoice = new DRB2B_CreateCheckoutRequestModel.ShippingChoice();
                        DRB2B_CheckoutShippingChoiceService updateShippingChoiceInfo = new DRB2B_CheckoutShippingChoiceService();

                        DRB2B_updateCheckoutRequestModel.ShippingChoice updateShippingChoice = new DRB2B_updateCheckoutRequestModel.ShippingChoice();
                        shippingChoice.amount = cartItem.TotalPrice;
                        updateShippingChoice.amount = cartItem.TotalPrice;
                        if (String.isNotBlank(shippingChoiceDetails.description)) {
                            shippingChoice.description = shippingChoiceDetails.description;
                            updateShippingChoice.description = shippingChoiceDetails.description;
                        }
                        if (String.isNotBlank(shippingChoiceDetails.serviceLevel)) {
                            shippingChoice.serviceLevel = shippingChoiceDetails.serviceLevel;
                            updateShippingChoice.serviceLevel = shippingChoiceDetails.serviceLevel;
                        }
                        createCheckoutRequest.shippingChoice = shippingChoice;
                        updateCheckoutRequest.shippingChoice = updateShippingChoice;
                        cartItemsBySkuIds.put(DELIVERY_CHARGE_ITEM, cartItem);
                    }
                }
            }
            logger.debug(cartId, 'Collected the map of Cart Items per SKU Ids: \n\n' + cartItemsBySkuIds);
            logger.debug('cart validation about the digital item--------->' + errorMessage);
            logger.debug('cart type about the digital item--------->' + cart.DR_Checkout_Type__c);

            if (status != 'Error') {
                String currentCheckoutItemsObj = JSON.Serialize(checkoutItems);
                if (
                    (previousCheckoutItemsObj != null) &&
                    (previousCheckoutItemsObj == (String.valueOf(System.hashCode(currentCheckoutItemsObj))))
                ) {
                    List<DRB2B_updateCheckoutRequestModel.TaxIdentifiers> updateTaxIdentifiersList = new List<DRB2B_updateCheckoutRequestModel.TaxIdentifiers>();
                    updateCheckoutRequest.sourceId = '';
                    if (!isGuestUser) {
                        updateCheckoutRequest.customerId = runningUser.ContactId;
                        updateCheckoutRequest.browserIp = getUserIpAddress();
                    } else {
                        if (cart.DR_Guest_IpAddress__c != null) {
                            updateCheckoutRequest.browserIp = cart.DR_Guest_IpAddress__c;
                        }
                    }
                    updateCheckoutRequest.locale = UserInfo.getLocale();
                    updateCheckoutRequest.drCurrency = DCM_BaseUtilities.getSObjectCurrency(cart);
                    updateCheckoutRequest.upstreamId = cartId;
                    updateCheckoutRequest.email = cart.Buyer_Email__c;
                    updateCheckoutRequest.customerType = cart.DR_Customer_Type__c;
                    updateCheckoutRequest.taxIdentifiers = updateTaxIdentifiersList;
                    if (cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL) {
                        if (configurationSelector.getDRShipFromAddressConfiguration() != 'Item-level') {
                            updateCheckoutRequest.shipFrom = new DRB2B_updateCheckoutRequestModel.ShipFrom(
                                addressService.getFromAddress(context)
                            );
                        }
                        DRB2B_updateCheckoutRequestModel.Address updatShipToAddress = new DRB2B_updateCheckoutRequestModel.Address();
                        updatShipToAddress.country = isCountryPickListEnabled
                            ? (String) deliveryGroup.get('DeliverToCountryCode')
                            : new DRB2B_CountryPicklist().getEntry(deliveryGroup.DeliverToCountry).value;
                        updatShipToAddress.state = isCountryPickListEnabled
                            ? (String) deliveryGroup.get('DeliverToStateCode')
                            : deliveryGroup.DeliverToState;
                        updatShipToAddress.postalCode = deliveryGroup.DeliverToPostalCode;
                        updatShipToAddress.city = deliveryGroup.DeliverToCity;
                        updatShipToAddress.line1 = deliveryGroup.DeliverToStreet;

                        DRB2B_updateCheckoutRequestModel.ShipTo updateShipTo = new DRB2B_updateCheckoutRequestModel.ShipTo();
                        updateShipTo.name = cart.Buyer_Name__c;
                        updateShipTo.address = updatShipToAddress;
                        updateCheckoutRequest.shipTo = updateShipTo;

                        DRB2B_updateCheckoutRequestModel.Address updateBillToAddress = new DRB2B_updateCheckoutRequestModel.Address();
                        updateBillToAddress.country = isCountryPickListEnabled
                            ? (String) cart.get('BillingCountryCode')
                            : new DRB2B_CountryPicklist().getEntry(cart.BillingCountry).value;
                        updateBillToAddress.state = isCountryPickListEnabled
                            ? (String) cart.get('BillingStateCode')
                            : cart.BillingState;
                        updateBillToAddress.postalCode = cart.BillingPostalCode;
                        updateBillToAddress.city = cart.BillingCity;
                        updateBillToAddress.line1 = cart.BillingStreet;

                        DRB2B_updateCheckoutRequestModel.BillTo updateBillTo = new DRB2B_updateCheckoutRequestModel.BillTo();

                        updateBillTo.name = cart.Buyer_Name__c;
                        updateBillTo.email = cart.Buyer_Email__c;
                        updateBillTo.phone = cart.Buyer_Phone__c;
                        updateBillTo.address = updateBillToAddress;

                        if (updateBillTo.address.country != null) {
                            updateCheckoutRequest.billTo = updateBillTo;
                        }
                    } else if (cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_DIGITAL) {
                        DRB2B_updateCheckoutRequestModel.Address updateBillToAddress = new DRB2B_updateCheckoutRequestModel.Address();
                        updateBillToAddress.country = isCountryPickListEnabled
                            ? (String) cart.get('BillingCountryCode')
                            : new DRB2B_CountryPicklist().getEntry(cart.BillingCountry).value;
                        updateBillToAddress.state = isCountryPickListEnabled
                            ? (String) cart.get('BillingStateCode')
                            : cart.BillingState;
                        updateBillToAddress.postalCode = cart.BillingPostalCode;
                        updateBillToAddress.city = cart.BillingCity;
                        updateBillToAddress.line1 = cart.BillingStreet;

                        DRB2B_updateCheckoutRequestModel.BillTo updateBillTo = new DRB2B_updateCheckoutRequestModel.BillTo();
                        updateBillTo.name = cart.Buyer_Name__c;
                        updateBillTo.email = cart.Buyer_Email__c;
                        updateBillTo.phone = cart.Buyer_Phone__c;
                        updateBillTo.address = updateBillToAddress;
                        if (updateBillTo.address.country != null) {
                            updateCheckoutRequest.billTo = updateBillTo;
                        }
                    }

                    if (
                        cart.DR_Customer_Type__c == System.Label.DR_Business_Val &&
                        cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_DIGITAL
                    ) {
                        updateCheckoutRequest.billTo.organization = cart.Buyer_OrganizationName__c;
                    } else {
                        if (
                            cart.DR_Customer_Type__c == System.Label.DR_Business_Val &&
                            cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL
                        ) {
                            updateCheckoutRequest.billTo.organization = cart.Buyer_OrganizationName__c;
                        }
                    }

                    string currentCheckoutId = [SELECT DR_Checkout_Id__c FROM WebCart WHERE Id = :cartId LIMIT 1]
                    .DR_Checkout_Id__c;

                    DRB2B_CreateCheckoutResponseModel updateResponseModel = checkoutService.updateCheckoutReqwithoutItems(
                        currentCheckoutId,
                        updateCheckoutRequest
                    );
                    if (DRB2B_Constants.Checkout.CREATE_CHECKOUT_BAD_RESPONSES.contains(updateResponseModel.type)) {
                        String msgPrefix = 'An issue occurred during Digital River Checkout updation:';
                        List<String> messages = new List<String>();
                        for (DRB2B_ErrorResponseModel error : updateResponseModel.errors) {
                            messages.add(error.message);
                            logger.error(cartId, msgPrefix + error.message);
                        }

                        saveCartValidationOutputError(msgPrefix + '\n' + String.join(messages, ','), jobInfo, cartId);
                        errorMessage = msgPrefix + '\n' + String.join(messages, ',');
                        status = 'Error';
                    } else {
                        checkoutService.recalculateTaxesAndFees(cart, cartItemsBySkuIds, updateResponseModel);
                        status = 'Success';
                    }
                } else {
                    createCheckoutRequest.sourceId = '';
                    if (!isGuestUser) {
                        createCheckoutRequest.customerId = runningUser.ContactId;
                        createCheckoutRequest.browserIp = getUserIpAddress();
                    } else {
                        if (cart.DR_Guest_IpAddress__c != null) {
                            createCheckoutRequest.browserIp = cart.DR_Guest_IpAddress__c;
                        }
                    }
                    createCheckoutRequest.locale = UserInfo.getLocale();

                    if (cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL) {
                        if (configurationSelector.getDRShipFromAddressConfiguration() != 'Item-level') {
                            createCheckoutRequest.shipFrom = new DRB2B_CreateCheckoutRequestModel.ShipFrom(
                                addressService.getFromAddress(context)
                            );
                        }

                        DRB2B_CreateCheckoutRequestModel.Address shipToAddress = new DRB2B_CreateCheckoutRequestModel.Address();
                        shipToAddress.country = isCountryPickListEnabled
                            ? (String) deliveryGroup.get('DeliverToCountryCode')
                            : new DRB2B_CountryPicklist().getEntry(deliveryGroup.DeliverToCountry).value;
                        shipToAddress.state = isCountryPickListEnabled
                            ? (String) deliveryGroup.get('DeliverToStateCode')
                            : deliveryGroup.DeliverToState;
                        shipToAddress.postalCode = deliveryGroup.DeliverToPostalCode;
                        shipToAddress.city = deliveryGroup.DeliverToCity;
                        shipToAddress.line1 = deliveryGroup.DeliverToStreet;

                        DRB2B_CreateCheckoutRequestModel.ShipTo shipTo = new DRB2B_CreateCheckoutRequestModel.ShipTo();
                        shipTo.name = cart.Buyer_Name__c;
                        shipTo.address = shipToAddress;

                        createCheckoutRequest.shipTo = shipTo;

                        DRB2B_CreateCheckoutRequestModel.Address billToAddress = new DRB2B_CreateCheckoutRequestModel.Address();
                        billToAddress.country = isCountryPickListEnabled
                            ? (String) cart.get('BillingCountryCode')
                            : new DRB2B_CountryPicklist().getEntry(cart.BillingCountry).value;
                        billToAddress.state = isCountryPickListEnabled
                            ? (String) cart.get('BillingStateCode')
                            : cart.BillingState;
                        billToAddress.postalCode = cart.BillingPostalCode;
                        billToAddress.city = cart.BillingCity;
                        billToAddress.line1 = cart.BillingStreet;

                        DRB2B_CreateCheckoutRequestModel.BillTo billTo = new DRB2B_CreateCheckoutRequestModel.BillTo();
                        billTo.name = cart.Buyer_Name__c;
                        billTo.email = cart.Buyer_Email__c;
                        billTo.phone = cart.Buyer_Phone__c;
                        billTo.address = billToAddress;

                        if (billTo.address.country != null) {
                            createCheckoutRequest.billTo = billTo;
                        }

                        logger.debug(
                            cartId,
                            'Prepared Non-Digital checkout request:' + JSON.serializePretty(createCheckoutRequest)
                        );
                    } else if (cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_DIGITAL) {
                        DRB2B_CreateCheckoutRequestModel.Address billToAddress = new DRB2B_CreateCheckoutRequestModel.Address();
                        billToAddress.country = isCountryPickListEnabled
                            ? (String) cart.get('BillingCountryCode')
                            : new DRB2B_CountryPicklist().getEntry(cart.BillingCountry).value;
                        billToAddress.state = isCountryPickListEnabled
                            ? (String) cart.get('BillingStateCode')
                            : cart.BillingState;
                        billToAddress.postalCode = cart.BillingPostalCode;
                        billToAddress.city = cart.BillingCity;
                        billToAddress.line1 = cart.BillingStreet;

                        DRB2B_CreateCheckoutRequestModel.BillTo billTo = new DRB2B_CreateCheckoutRequestModel.BillTo();
                        billTo.name = cart.Buyer_Name__c;
                        billTo.email = cart.Buyer_Email__c;
                        billTo.phone = cart.Buyer_Phone__c;
                        billTo.address = billToAddress;

                        if (billTo.address.country != null) {
                            createCheckoutRequest.billTo = billTo;
                        }

                        logger.debug(
                            cartId,
                            'Prepared Digital checkout request:' + JSON.serializePretty(createCheckoutRequest)
                        );
                    }
                    if (
                        cart.DR_Customer_Type__c == System.Label.DR_Business_Val &&
                        cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_DIGITAL
                    ) {
                        createCheckoutRequest.billTo.organization = cart.Buyer_OrganizationName__c;
                    } else {
                        if (
                            cart.DR_Customer_Type__c == System.Label.DR_Business_Val &&
                            cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL
                        ) {
                            createCheckoutRequest.shipTo.organization = cart.Buyer_OrganizationName__c;
                        }
                    }
                    createCheckoutRequest.drCurrency = DCM_BaseUtilities.getSObjectCurrency(cart);
                    createCheckoutRequest.upstreamId = cartId;
                    createCheckoutRequest.email = cart.Buyer_Email__c;
                    createCheckoutRequest.customerType = cart.DR_Customer_Type__c;
                    createCheckoutRequest.taxIdentifiers = taxIdentifiersList;
                    // As we are not supporting subscriptions in lightnining version charge type will always be customer initiated
                    createCheckoutRequest.chargeType = DRB2B_Constants.Checkout.CHARGE_TYPE_CUSTOMER_INITIATED;
                    DRB2B_CreateCheckoutResponseModel createCheckoutResponse = checkoutService.createCheckout(
                        createCheckoutRequest
                    );

                    if (DRB2B_Constants.Checkout.CREATE_CHECKOUT_BAD_RESPONSES.contains(createCheckoutResponse.type)) {
                        String msgPrefix = 'An issue occurred during Digital River Checkout creation:';
                        List<String> messages = new List<String>();
                        for (DRB2B_ErrorResponseModel error : createCheckoutResponse.errors) {
                            messages.add(error.message);
                            logger.error(cartId, msgPrefix + error.message);
                        }

                        saveCartValidationOutputError(msgPrefix + '\n' + String.join(messages, ','), jobInfo, cartId);
                        errorMessage = msgPrefix + '\n' + String.join(messages, ',');
                        status = 'Error';
                    } else {
                        checkoutService.recalculateTaxesAndFees(cart, cartItemsBySkuIds, createCheckoutResponse);
                        status = 'Success';
                    }
                    updateCartWithItemStructure(CartId, currentCheckoutItemsObj);
                }
            }
        } catch (Exception e) {
            logger.error(cartId, e);
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.

            errorMessage = 'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage();
            saveCartValidationOutputError(errorMessage, jobInfo, cartId);
            status = 'Error';
        } finally {
            logger.flush();
        }
        if (status == 'Error') {
            ResponseModel model = new ResponseModel();
            model.status = status;
            model.message = errorMessage;
            return model;
        } else if (status == 'Success') {
            ResponseModel model = new ResponseModel();
            model.status = status;
            model.message = 'Tax Calculation Success';
            return model;
        } else {
            return null;
        }
    }

    // update the cart item structure with the latest once
    public static void updateCartWithItemStructure(Id CartId, String currentCheckoutItemsObj) {
        WebCart wcart = [SELECT id, DR_CartItemStructure__c, DR_SF_CartId__c FROM WebCart WHERE id = :cartId];
        wCart.DR_CartItemStructure__c = String.valueOf(System.hashCode(currentCheckoutItemsObj));
        wCart.DR_SF_CartId__c = cartId;
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        if (!isGuestUser) {
            DmlManager.updateAsUser(wCart);
        } else {
            DmlManager.updateAsSystem(wCart);
        }
    }

    // create checkout items structure
    private static List<DRB2B_CreateCheckoutRequestModel.Item> checkoutItemStructure(
        CartItem cartItem,
        DRB2B_ConnectorConfigurationSelector configurationSelector,
        Id cartId,
        List<DRB2B_CreateCheckoutRequestModel.Item> checkoutItems,
        Map<String, CartItem> cartItemsBySkuIds
    ) {
        DRB2B_CreateCheckoutRequestModel.Item checkoutItem = new DRB2B_CreateCheckoutRequestModel.Item(
            cartItem.Product2Id,
            cartItem.Quantity,
            cartItem.TotalPriceAfterAllAdjustments
        );

        if (configurationSelector.getDRShipFromAddressConfiguration() == 'Item-level') {
            if (cartItem.DR_Item_TaxType__c != DRB2B_Constants.WebCart.TYPE_DIGITAL) {
                DRB2B_Address addressForItem = new DRB2B_Address();
                addressForItem.line1 = cartItem.digitalriverv3__ShipFrom_Street__c;
                addressForItem.postalCode = cartItem.digitalriverv3__ShipFrom_Postal_code__c;
                addressForItem.country = cartItem.digitalriverv3__ShipFrom_Country__c;
                addressForItem.city = cartItem.digitalriverv3__ShipFrom_City__c;
                addressForItem.state = cartItem.digitalriverv3__ShipFrom_State__c;
                checkoutItem.shipFrom = new DRB2B_CreateCheckoutRequestModel.ShipFrom(addressForItem);
            }
        }
        checkoutItem.metadata = new DRB2B_CreateCheckoutRequestModel.Metadata();
        checkoutItem.metadata.cartItemId = cartItem.id;
        checkoutItem.metadata.cartId = cartId;

        // Add Subscription Info element for Subscription Line Items
        if (isSubscriptionLineItem(cartItem)) {
            checkoutItem.subscriptionInfo = getLineItemSubscriptionInfo(cartItem);
        }
        checkoutItems.add(checkoutItem);
        cartItemsBySkuIds.put(cartItem.Product2Id, cartItem);
        return checkoutItems;
    }

    private static String getUserIpAddress() {
        String ip = '';

        try {
            if (
                AuthSession.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.AuthSession.fields.Id.isAccessible()
            ) {
                AuthSession session = [
                    SELECT Id, SourceIp
                    FROM AuthSession
                    WHERE UsersId = :UserInfo.getUserId()
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                ip = session.SourceIp == '::' ? '' : session.SourceIp;
            }
        } catch (Exception e) {
            logger.error('DRB2B_TaxCalculationservice getUserIpAddress Exception' + e);
        }

        return ip;
    }

    private static Boolean isChargeType(CartItem cartItem) {
        return cartItem.Type == 'Charge';
    }

    private static Boolean isProductType(CartItem cartItem) {
        return cartItem.Type == 'Product';
    }

    private static Boolean isSubscriptionLineItem(CartItem cartItem) {
        return cartItem.Recurring_Line_Item__c;
    }

    private static Boolean isInvalidSku(CartItem cartItem) {
        return String.isBlank(cartItem.Sku);
    }

    private static DRB2B_CreateCheckoutRequestModel.SubscriptionInfo getLineItemSubscriptionInfo(CartItem cartItem) {
        DRB2B_CreateCheckoutRequestModel.SubscriptionInfo itemSubscriptionInfo = new DRB2B_CreateCheckoutRequestModel.SubscriptionInfo();
        itemSubscriptionInfo.terms = DRB2B_Constants.Subscription.DR_AUTO_RENEWAL_TERMS;
        itemSubscriptionInfo.autoRenewal = true;
        itemSubscriptionInfo.subscriptionId = cartItem.Subscription_Id__c;
        itemSubscriptionInfo.freeTrial = CartItem.Free_Subscription_Trial__c;
        //As per DR request
        //if enddate is null ,we will not pass startime and endtime to checkout request
        if (null != CartItem.Subscription_End_Time__c) {
            itemSubscriptionInfo.startTime = CartItem.Subscription_Start_Time__c;
            itemSubscriptionInfo.endTime = CartItem.Subscription_End_Time__c;
        }
        return itemSubscriptionInfo;
    }

    private static CartDeliveryGroup getDeliveryGroup(WebCart cart) {
        // In the Spring '20 release, there should be one delivery group per cart.
        // In the future, when multiple delivery groups can be created,
        // this sample should be updated to loop through all delivery groups.
        return (CartDeliveryGroup) cart.CartItems.get(0).getSObject(CartItem.CartDeliveryGroupId);
    }

    private static void saveCartValidationOutputError(
        String errorMessage,
        sfdc_checkout.IntegrationInfo jobInfo,
        Id cartId
    ) {
        // For the error to be propagated to the user, we need to add a new CartValidationOutput record.
        // The following fields must be populated:
        // BackgroundOperationId: Foreign Key to the BackgroundOperation
        // CartId: Foreign key to the WebCart that this validation line is for
        // Level (required): One of the following - Info, Error, or Warning
        // Message (optional): Message displayed to the user (maximum 255 characters)
        // Name (required): The name of this CartValidationOutput record. For example CartId
        // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
        // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
        CartValidationOutput cartValidationError = new CartValidationOutput(
            CartId = cartId,
            Level = 'Error',
            Message = errorMessage.left(255),
            //   Name = (String)cartId,
            RelatedEntityId = cartId,
            Type = 'Taxes'
        );
        cartValidationError.BackgroundOperationId = jobInfo != null ? jobInfo.jobId : null;
        cartValidationError.Name = jobInfo != null ? (String) cartId + ':' + jobInfo : (String) cartId;
        insert (cartValidationError);
    }

    global class ResponseModel {
        global String status { get; set; }
        global String message { get; set; }
    }
}
