global without sharing class DRB2B_TaxCalculationServiceCartCalculate extends CartExtension.TaxCartCalculator {
    public DRB2B_TaxCalculationServiceCartCalculate() {

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
    String  status;
    private static boolean isCvoPresent = false;

    public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request) {
        DRB2B_CheckoutService checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
        DRB2B_UserSelector userSelector = new DRB2B_UserSelector();
        DRB2B_CustomerService customerService = new DRB2B_CustomerService();
        DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
        String errorMessage;
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        String previousCheckoutItemsObj = null;
        CartExtension.CartValidationOutputList cartValidationOutputCollection;
        
        try {
            CartExtension.Cart cart = request.getCart();
            cartValidationOutputCollection = cart.getCartValidationOutputs();
            Boolean isCountryPickListEnabled = DRB2B_Utility.isCountryStateEnabled();
            User runningUser;
            Integer cvoSize = cartValidationOutputCollection.size();

            for (Integer i = (cvoSize - 1); i >= 0; i--) {
                CartExtension.CartValidationOutput cvo = cartValidationOutputCollection.get(i);
                if (cvo.getType() == CartExtension.CartValidationOutputTypeEnum.TAXES) {
                  cartValidationOutputCollection.remove(cvo);
                }
            }
            Id cartId = cart.getId();
            logger.debugEvent('DRB2B_TaxCalculationServiceCartCalculate Start');

            String email = (cart.getCustomField('digitalriverv3__Buyer_Email__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Email__c').toString() : '';
            if(email == '')
                {
                logger.debugEvent('DRB2B_TaxCalculationServiceCartCalculate email is empty');
                return;
            }
            if(cart.getCustomField('digitalriverv3__DR_CartItemStructure__c') != null) {
                previousCheckoutItemsObj = cart.getCustomField('digitalriverv3__DR_CartItemStructure__c').toString();
            }
            //logger.debugEvent('DRB2B_TaxCalculationServiceCartCalculate previousCheckoutItemsObj: '+previousCheckoutItemsObj);
            if(!isGuestUser)
            {
                if (!Test.isRunningTest()) {
                    DRB2B_CreateCustomerResponseModel customerResponse = customerService.getById(UserInfo.getUserId(), cartId);
                    if (customerResponse.id == null) {
                    customerResponse = customerService.createCustomer(UserInfo.getUserId(), cartId);
                    }
                }
                runningUser = userSelector.getById(UserInfo.getUserId(), new Set<String>{ 'Id', 'Name', 'ContactId' });
            }
            
            //Adding state and code country field if country picklist is enabled
            if(isCountryPickListEnabled){
                CART_FIELDS.addAll(new List<String>{'BillingCountryCode','BillingStateCode'});  
                CART_ITEMS_FIELDS.addAll(new List<String>{'CartDeliveryGroup.DeliverToStateCode','CartDeliveryGroup.DeliverToCountryCode'});
            }

            WebCart webcart = cartSelector.getCartWithItemsById(cartId, CART_FIELDS, CART_ITEMS_FIELDS);
            CartDeliveryGroup deliveryGroup = getDeliveryGroup(webcart);
            CartExtension.CartDeliveryGroupList deliveryGroupList = cart.getCartDeliveryGroups();
            CartExtension.CartDeliveryGroup deliveryGroup2 = deliveryGroupList.get(0);
            // Setup Checkout Context
            DRB2B_CheckoutContext context = new DRB2B_CheckoutContext();
            context.cartId = cartId;

            DRB2B_CreateCheckoutRequestModel createCheckoutRequest = new DRB2B_CreateCheckoutRequestModel();
            List<DRB2B_CreateCheckoutRequestModel.TaxIdentifiers> taxIdentifiersList = new List<DRB2B_CreateCheckoutRequestModel.TaxIdentifiers>();
            List<DRB2B_CreateCheckoutRequestModel.Item> checkoutItems = new List<DRB2B_CreateCheckoutRequestModel.Item>();
            DRB2B_CheckoutAddressService addressService = new DRB2B_CheckoutAddressService();

            DRB2B_updateCheckoutRequestModel updateCheckoutRequest = new DRB2B_updateCheckoutRequestModel();
            createCheckoutRequest.items = checkoutItems;

            Map<String, CartExtension.CartItem> cartItemsBySkuIds = new Map<String, CartExtension.CartItem>();

            CartExtension.CartItemList cartItemsList = cart.getCartItems();
            Integer cartItemSize = cartItemsList.size();
            for (Integer i = (cartItemSize - 1); i >= 0; i--) {
                if (isProductType(cartItemsList.get(i))) {
                    if (isInvalidSku(cartItemsList.get(i))) {
                        errorMessage = 'The SKUs for all products in your cart must be defined.';
                        saveCartValidationOutputError(errorMessage,cartValidationOutputCollection);
                        status = 'Error';
                    }
                    else {
                        checkoutItemStructure(cartItemsList.get(i), configurationSelector,cartId, checkoutItems,cartItemsBySkuIds);
                    }
                } else if (isChargeType(cartItemsList.get(i))) {
                    if (
                        cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_DIGITAL &&
                        cartItemsList.get(i).getTotalPrice() > 0 &&
                        !Test.isRunningTest()
                    ) {
                        errorMessage = 'Digital cart (Cart with only Digital Products) cannot have a Shipping Amount greater than $0';
                        saveCartValidationOutputError(errorMessage,cartValidationOutputCollection);
                        status = 'Error';
                        system.debug(errorMessage);
                    } else if (cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') != DRB2B_Constants.WebCart.TYPE_DIGITAL) {
                        DRB2B_CheckoutShippingChoiceService shippingChoiceInfo = new DRB2B_CheckoutShippingChoiceService();
                        DRB2B_ShippingChoiceInfo shippingChoiceDetails = shippingChoiceInfo.getShippingChoiceInfo(context);
                        DRB2B_CreateCheckoutRequestModel.ShippingChoice shippingChoice = new DRB2B_CreateCheckoutRequestModel.ShippingChoice();
                        DRB2B_CheckoutShippingChoiceService updateShippingChoiceInfo = new DRB2B_CheckoutShippingChoiceService();

                        DRB2B_updateCheckoutRequestModel.ShippingChoice updateShippingChoice = new DRB2B_updateCheckoutRequestModel.ShippingChoice();
                        shippingChoice.amount = cartItemsList.get(i).getTotalPrice();
                        updateShippingChoice.amount = cartItemsList.get(i).getTotalPrice();
                        if(String.isNotBlank(shippingChoiceDetails.description)){
                            shippingChoice.description = shippingChoiceDetails.description;
                            updateShippingChoice.description = shippingChoiceDetails.description;
                        }
                        if( String.isNotBlank(shippingChoiceDetails.serviceLevel)){
                            shippingChoice.serviceLevel = shippingChoiceDetails.serviceLevel;
                            updateShippingChoice.serviceLevel = shippingChoiceDetails.serviceLevel;
                        }
                        createCheckoutRequest.shippingChoice = shippingChoice;
                        updateCheckoutRequest.shippingChoice = updateShippingChoice;
                        cartItemsBySkuIds.put(DELIVERY_CHARGE_ITEM, cartItemsList.get(i));
                    }
                }
            }
            if ( status != 'Error') { 
            String currentCheckoutItemsObj =JSON.Serialize(checkoutItems);
            if ((previousCheckoutItemsObj != null) && (previousCheckoutItemsObj==(String.valueOf(System.hashCode(currentCheckoutItemsObj)))))
            {
                List<DRB2B_updateCheckoutRequestModel.TaxIdentifiers> updateTaxIdentifiersList = new List<DRB2B_updateCheckoutRequestModel.TaxIdentifiers>();
                updateCheckoutRequest.sourceId = '';
                if (!isGuestUser) {
                    updateCheckoutRequest.customerId = runningUser.ContactId;
                    updateCheckoutRequest.browserIp = getUserIpAddress();
                }else {
                    if (cart.getCustomField('digitalriverv3__DR_Guest_IpAddress__c') != null) {
                        updateCheckoutRequest.browserIp = cart.getCustomField('digitalriverv3__DR_Guest_IpAddress__c').toString();
                    }
                }
                updateCheckoutRequest.locale = UserInfo.getLocale();
                updateCheckoutRequest.drCurrency = DCM_BaseUtilities.getSObjectCurrency(webcart);
                updateCheckoutRequest.upstreamId = cartId;
                updateCheckoutRequest.email = (cart.getCustomField('digitalriverv3__Buyer_Email__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Email__c').toString() : null;
                updateCheckoutRequest.customerType = (cart.getCustomField('digitalriverv3__DR_Customer_Type__c')!=null) ? cart.getCustomField('digitalriverv3__DR_Customer_Type__c').toString() : null;
                updateCheckoutRequest.taxIdentifiers = updateTaxIdentifiersList;
                if (cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL) {
                    if(configurationSelector.getDRShipFromAddressConfiguration()!='Item-level')
                    {
                        updateCheckoutRequest.shipFrom = new DRB2B_updateCheckoutRequestModel.ShipFrom(
                        addressService.getFromAddress(context)
                        );
                    }
                    DRB2B_updateCheckoutRequestModel.Address updateShipToAddress = new DRB2B_updateCheckoutRequestModel.Address();
                    updateShipToAddress.country = isCountryPickListEnabled ? (String) deliveryGroup.get('DeliverToCountryCode') : new DRB2B_CountryPicklist().getEntry(deliveryGroup.DeliverToCountry).value;
                    updateShipToAddress.state = isCountryPickListEnabled ? (String) deliveryGroup.get('DeliverToStateCode') : deliveryGroup.DeliverToState;
                    updateShipToAddress.postalCode = deliveryGroup2.getDeliverToAddress().getPostalCode();
                    updateShipToAddress.city = deliveryGroup2.getDeliverToAddress().getCity();
                    updateShipToAddress.line1 = deliveryGroup2.getDeliverToAddress().getStreet();

                    DRB2B_updateCheckoutRequestModel.ShipTo updateShipTo = new DRB2B_updateCheckoutRequestModel.ShipTo();
                    updateShipTo.name = (cart.getCustomField('digitalriverv3__Buyer_Name__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Name__c').toString() : null;
                    updateShipTo.address = updateShipToAddress;
                    updateCheckoutRequest.shipTo = updateShipTo;

                    DRB2B_updateCheckoutRequestModel.Address updateBillToAddress = new DRB2B_updateCheckoutRequestModel.Address();
                    updateBillToAddress.country = isCountryPickListEnabled ? (String) webcart.get('BillingCountryCode') : new DRB2B_CountryPicklist().getEntry(webcart.BillingCountry).value;
                    updateBillToAddress.state = isCountryPickListEnabled ? (String) webcart.get('BillingStateCode') : webcart.BillingState;
                    updateBillToAddress.postalCode = deliveryGroup2.getDeliverToAddress().getPostalCode();
                    updateBillToAddress.city = deliveryGroup2.getDeliverToAddress().getCity();
                    updateBillToAddress.line1 = deliveryGroup2.getDeliverToAddress().getStreet();

                    DRB2B_updateCheckoutRequestModel.BillTo updateBillTo = new DRB2B_updateCheckoutRequestModel.BillTo();

                    updateBillTo.name = (cart.getCustomField('digitalriverv3__Buyer_Name__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Name__c').toString() : null;
                    updateBillTo.email = (cart.getCustomField('digitalriverv3__Buyer_Email__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Email__c').toString() : null;
                    updateBillTo.phone = (cart.getCustomField('digitalriverv3__Buyer_Phone__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Phone__c').toString() : null;
                    updateBillTo.address = updateBillToAddress;

                    if(updateBillTo.address.country != null) {
                        updateCheckoutRequest.billTo = updateBillTo;
                    }
                } else if (cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_DIGITAL) {

                    DRB2B_updateCheckoutRequestModel.Address updateBillToAddress = new DRB2B_updateCheckoutRequestModel.Address();
                    updateBillToAddress.country = isCountryPickListEnabled ? (String) webcart.get('BillingCountryCode') : new DRB2B_CountryPicklist().getEntry(webcart.BillingCountry).value;
                    updateBillToAddress.state = isCountryPickListEnabled ? (String) webcart.get('BillingStateCode') : webcart.BillingState;
                    updateBillToAddress.postalCode = deliveryGroup2.getDeliverToAddress().getPostalCode();
                    updateBillToAddress.city = deliveryGroup2.getDeliverToAddress().getCity();
                    updateBillToAddress.line1 = deliveryGroup2.getDeliverToAddress().getStreet();
                                    
                    DRB2B_updateCheckoutRequestModel.BillTo updateBillTo = new DRB2B_updateCheckoutRequestModel.BillTo();
                    updateBillTo.name = (cart.getCustomField('digitalriverv3__Buyer_Name__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Name__c').toString() : null;
                    updateBillTo.email = (cart.getCustomField('digitalriverv3__Buyer_Email__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Email__c').toString() : null;
                    updateBillTo.phone = (cart.getCustomField('digitalriverv3__Buyer_Phone__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Phone__c').toString() : null;
                    updateBillTo.address = updateBillToAddress;
                    if(updateBillTo.address.country != null) {
                    updateCheckoutRequest.billTo = updateBillTo;
                    }
                }

                if(cart.getCustomField('digitalriverv3__DR_Customer_Type__c') == System.Label.DR_Business_Val && cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_DIGITAL)
                {
                    updateCheckoutRequest.billTo.organization = cart.getCustomField('digitalriverv3__Buyer_OrganizationName__c').toString(); 
                }
                else 
                {
                    if(cart.getCustomField('digitalriverv3__DR_Customer_Type__c') == System.Label.DR_Business_Val &&  cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL)
                    {
                        updateCheckoutRequest.billTo.organization = cart.getCustomField('digitalriverv3__Buyer_OrganizationName__c').toString(); 
                    }
                }
                
                string currentCheckoutId = (cart.getCustomField('digitalriverv3__DR_Checkout_Id__c')!=null) ? cart.getCustomField('digitalriverv3__DR_Checkout_Id__c').toString() : null;
                logger.debugEvent('DRB2B_TaxCalculationServiceCartCalculate updateCheckoutRequest: '+ updateCheckoutRequest);
                DRB2B_CreateCheckoutResponseModel updateResponseModel = checkoutService.updateCheckoutReqwithoutItems(currentCheckoutId, updateCheckoutRequest);

                if (DRB2B_Constants.Checkout.CREATE_CHECKOUT_BAD_RESPONSES.contains(updateResponseModel.type)) {
                    String msgPrefix = 'An issue occurred during Digital River Checkout updation:';
                    List<String> messages = new List<String>();
                    for (DRB2B_ErrorResponseModel error : updateResponseModel.errors) {
                        messages.add(error.message);
                    }
                    errorMessage = msgPrefix + '\n' + String.join(messages, ',');
                    saveCartValidationOutputError( errorMessage,cartValidationOutputCollection );
                } else {
                    checkoutService.recalculateTaxesAndFeesCartCalculate(cart, cartItemsBySkuIds, updateResponseModel);
                    status = 'Success';
                }
            } 
            else 
            {
                createCheckoutRequest.sourceId = '';
                if(!isGuestUser) {
                    createCheckoutRequest.customerId = runningUser.ContactId;
                    if (!Test.isRunningTest()) {
                    createCheckoutRequest.browserIp = getUserIpAddress();
                    }
                }
                else {
                    if (cart.getCustomField('digitalriverv3__DR_Guest_IpAddress__c') != null) {
                        createCheckoutRequest.browserIp = cart.getCustomField('digitalriverv3__DR_Guest_IpAddress__c').toString();
                    }
                }
                createCheckoutRequest.locale = UserInfo.getLocale();
                if (cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL) {
                    if(configurationSelector.getDRShipFromAddressConfiguration()!='Item-level')
                    {
                        createCheckoutRequest.shipFrom = new DRB2B_CreateCheckoutRequestModel.ShipFrom(
                            addressService.getFromAddress(context)
                        );
                    }
                    
                    DRB2B_CreateCheckoutRequestModel.Address shipToAddress = new DRB2B_CreateCheckoutRequestModel.Address();
                    shipToAddress.country = isCountryPickListEnabled ? (String) deliveryGroup.get('DeliverToCountryCode') : new DRB2B_CountryPicklist().getEntry(deliveryGroup.DeliverToCountry).value;
                    shipToAddress.state = isCountryPickListEnabled ? (String) deliveryGroup.get('DeliverToStateCode') : deliveryGroup.DeliverToState;
                    shipToAddress.postalCode = deliveryGroup2.getDeliverToAddress().getPostalCode();
                    shipToAddress.city = deliveryGroup2.getDeliverToAddress().getCity();
                    shipToAddress.line1 = deliveryGroup2.getDeliverToAddress().getStreet();

                    DRB2B_CreateCheckoutRequestModel.ShipTo shipTo = new DRB2B_CreateCheckoutRequestModel.ShipTo();
                    shipTo.name = (cart.getCustomField('digitalriverv3__Buyer_Name__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Name__c').toString() : null;
                    shipTo.address = shipToAddress;

                    createCheckoutRequest.shipTo = shipTo;

                    DRB2B_CreateCheckoutRequestModel.Address billToAddress = new DRB2B_CreateCheckoutRequestModel.Address();
                    billToAddress.country = isCountryPickListEnabled ? (String) webcart.get('BillingCountryCode') : new DRB2B_CountryPicklist().getEntry(webcart.BillingCountry).value;
                    billToAddress.state = isCountryPickListEnabled ? (String) webcart.get('BillingStateCode') : webcart.BillingState;
                    billToAddress.postalCode = deliveryGroup2.getDeliverToAddress().getPostalCode();
                    billToAddress.city = deliveryGroup2.getDeliverToAddress().getCity();
                    billToAddress.line1 = deliveryGroup2.getDeliverToAddress().getStreet();

                    DRB2B_CreateCheckoutRequestModel.BillTo billTo = new DRB2B_CreateCheckoutRequestModel.BillTo();
                    billTo.name = (cart.getCustomField('digitalriverv3__Buyer_Name__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Name__c').toString() : null;
                    billTo.email = (cart.getCustomField('digitalriverv3__Buyer_Email__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Email__c').toString() : null;
                    billTo.phone = (cart.getCustomField('digitalriverv3__Buyer_Phone__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Phone__c').toString() : null;
                    billTo.address = billToAddress;

                    if(billTo.address.country != null) {
                        createCheckoutRequest.billTo = billTo;
                    }
                } else if (cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_DIGITAL) {
                    DRB2B_CreateCheckoutRequestModel.Address billToAddress = new DRB2B_CreateCheckoutRequestModel.Address();
                    billToAddress.country = isCountryPickListEnabled ? (String) webcart.get('BillingCountryCode') : new DRB2B_CountryPicklist().getEntry(webcart.BillingCountry).value;
                    billToAddress.state = isCountryPickListEnabled ? (String) webcart.get('BillingStateCode') : webcart.BillingState;
                    billToAddress.postalCode = deliveryGroup2.getDeliverToAddress().getPostalCode();
                    billToAddress.city = deliveryGroup2.getDeliverToAddress().getCity();
                    billToAddress.line1 = deliveryGroup2.getDeliverToAddress().getStreet();

                    DRB2B_CreateCheckoutRequestModel.BillTo billTo = new DRB2B_CreateCheckoutRequestModel.BillTo();
                    billTo.name = (cart.getCustomField('digitalriverv3__Buyer_Name__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Name__c').toString() : null;
                    billTo.email = (cart.getCustomField('digitalriverv3__Buyer_Email__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Email__c').toString() : null;
                    billTo.phone = (cart.getCustomField('digitalriverv3__Buyer_Phone__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Phone__c').toString() : null;
                    billTo.address = billToAddress;

                    if(billTo.address.country != null) {
                        createCheckoutRequest.billTo = billTo;
                    }
                }
                if(cart.getCustomField('digitalriverv3__DR_Customer_Type__c') == System.Label.DR_Business_Val && cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_DIGITAL){
                    createCheckoutRequest.billTo.organization = cart.getCustomField('digitalriverv3__Buyer_OrganizationName__c').toString(); 
                }
                else 
                {
                    if(cart.getCustomField('digitalriverv3__DR_Customer_Type__c') == System.Label.DR_Business_Val &&  cart.getCustomField('digitalriverv3__DR_Checkout_Type__c') == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL){
                    createCheckoutRequest.shipTo.organization = cart.getCustomField('digitalriverv3__Buyer_OrganizationName__c').toString();
                 }
               }
                
                createCheckoutRequest.drCurrency = DCM_BaseUtilities.getSObjectCurrency(webcart);
                createCheckoutRequest.upstreamId = cartId;
                createCheckoutRequest.email = (cart.getCustomField('digitalriverv3__Buyer_Email__c')!=null) ? cart.getCustomField('digitalriverv3__Buyer_Email__c').toString() : null;
                createCheckoutRequest.customerType = (cart.getCustomField('digitalriverv3__DR_Customer_Type__c')!=null) ? cart.getCustomField('digitalriverv3__DR_Customer_Type__c').toString() : null;
                createCheckoutRequest.taxIdentifiers = taxIdentifiersList;
                logger.debugEvent('DRB2B_TaxCalculationServiceCartCalculate createCheckoutRequest 370: '+ createCheckoutRequest);
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
                    }
                    errorMessage = msgPrefix + '\n' + String.join(messages, ',');
                    saveCartValidationOutputError( errorMessage,cartValidationOutputCollection );
                } else {
                    checkoutService.recalculateTaxesAndFeesCartCalculate(cart, cartItemsBySkuIds, createCheckoutResponse);
                    status = 'Success';
                }
                updateCartWithItemStructure(cart, currentCheckoutItemsObj);
                }
            }
        } catch (Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            //errorMessage = 'Sorry!! An issue occurred during Digital River Checkout creation';//'An exception of type ' +e.getTypeName() + ' has occurred: ' + e.getMessage();
            errorMessage = 'An exception of type ' +e.getTypeName() + ' has occurred: ' + e.getMessage();
            logger.debugErrorEvent('DRB2B_TaxCalculationServiceCartCalculate exception : '+ errorMessage);
            isCvoPresent = true;
            if (isCvoPresent)
            {
                return;
            }
        }
        return;
    }

    // update the cart item structure with the latest once
    public static void updateCartWithItemStructure(CartExtension.Cart cart, String currentCheckoutItemsObj) {
        String itemStructureHash = String.valueOf(System.hashCode(currentCheckoutItemsObj));
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        Id cartId = cart.getId();
        if(!isGuestUser){
            cart.setCustomField('digitalriverv3__DR_CartItemStructure__c', itemStructureHash);
            cart.setCustomField('digitalriverv3__DR_SF_CartId__c', cartId);
        }
        else {
            cart.setCustomField('digitalriverv3__DR_CartItemStructure__c', itemStructureHash);
            cart.setCustomField('digitalriverv3__DR_SF_CartId__c', cartId);
        }
    }

    // create checkout items structure
    private static List<DRB2B_CreateCheckoutRequestModel.Item> checkoutItemStructure (CartExtension.CartItem cartItem, DRB2B_ConnectorConfigurationSelector configurationSelector, Id cartId, List<DRB2B_CreateCheckoutRequestModel.Item> checkoutItems,  Map<String, CartExtension.CartItem> cartItemsBySkuIds){
        DRB2B_CreateCheckoutRequestModel.Item checkoutItem = new DRB2B_CreateCheckoutRequestModel.Item(
            cartItem.getProduct2Id(),
            cartItem.getQuantity(),
            cartItem.getTotalPriceAfterAllAdjustments() 
        );

        if(configurationSelector.getDRShipFromAddressConfiguration()=='Item-level' )
        {   
            if(cartItem.getCustomField('digitalriverv3__DR_Item_TaxType__c') != DRB2B_Constants.WebCart.TYPE_DIGITAL )
            {
                DRB2B_Address addressForItem= new DRB2B_Address();
                addressForItem.line1 = cartItem.getCustomField('digitalriverv3__ShipFrom_Street__c').toString();
                addressForItem.postalCode = cartItem.getCustomField('digitalriverv3__ShipFrom_Postal_code__c').toString();
                addressForItem.country = cartItem.getCustomField('digitalriverv3__ShipFrom_Country__c').toString();
                addressForItem.city = cartItem.getCustomField('digitalriverv3__ShipFrom_City__c').toString();
                addressForItem.state = cartItem.getCustomField('digitalriverv3__ShipFrom_State__c').toString();
                checkoutItem.shipFrom =
                new DRB2B_CreateCheckoutRequestModel.ShipFrom(
                    addressForItem
                );
            }
           
        }
        checkoutItem.metadata = new DRB2B_CreateCheckoutRequestModel.Metadata();
        checkoutItem.metadata.cartItemId = cartItem.getId();
        checkoutItem.metadata.cartId = cartId;
        
        // Add Subscription Info element for Subscription Line Items
        if(isSubscriptionLineItem(cartItem)) {
            checkoutItem.subscriptionInfo = getLineItemSubscriptionInfo(cartItem);
        }
        checkoutItems.add(checkoutItem);
        cartItemsBySkuIds.put(cartItem.getProduct2Id(), cartItem);
        return checkoutItems;
    }

    private static String getUserIpAddress() {
        String ip = '';

        try {
            AuthSession session = [
                SELECT Id, SourceIp
                FROM AuthSession
                WHERE UsersId = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            ip = session.SourceIp == '::' ? '' : session.SourceIp;
        } catch (Exception e) {
            system.debug(e);
        }

        return ip;
    }

    private static Boolean isChargeType(CartExtension.CartItem cartItem) {
        if(cartItem.getType() == CartExtension.SalesItemTypeEnum.CHARGE){
            return true;
        }
        else {
            return false;
        }
    }

    private static Boolean isProductType(CartExtension.CartItem cartItem) {
        if(cartItem.getType() == CartExtension.SalesItemTypeEnum.PRODUCT){
            return true;
        }
        else {
            return false;
        }
    }

    private static Boolean isSubscriptionLineItem(CartExtension.CartItem cartItem) {
        if((Boolean) cartItem.getCustomField('digitalriverv3__Recurring_Line_Item__c')){
            return true;
        }
        else {
            return false;
        }
    }

    private static  Boolean isInvalidSku(CartExtension.CartItem cartItem) {
        if(String.isBlank(cartItem.getSku())){
            return true;
        }
        else {
            return false;
        }
    }

    private static  DRB2B_CreateCheckoutRequestModel.SubscriptionInfo getLineItemSubscriptionInfo(CartExtension.CartItem cartItem) {
        DRB2B_CreateCheckoutRequestModel.SubscriptionInfo itemSubscriptionInfo = new DRB2B_CreateCheckoutRequestModel.SubscriptionInfo();
        itemSubscriptionInfo.terms = DRB2B_Constants.Subscription.DR_AUTO_RENEWAL_TERMS;
        itemSubscriptionInfo.autoRenewal = true;
        itemSubscriptionInfo.subscriptionId = cartItem.getCustomField('digitalriverv3__Subscription_Id__c').toString();
        itemSubscriptionInfo.freeTrial = (Boolean) CartItem.getCustomField('digitalriverv3__Free_Subscription_Trial__c');
        //As per DR request
            //if enddate is null ,we will not pass startime and endtime to checkout request
        if(null != CartItem.getCustomField('digitalriverv3__Subscription_End_Time__c')){
            itemSubscriptionInfo.startTime = (DateTime) CartItem.getCustomField('digitalriverv3__Subscription_Start_Time__c');
            itemSubscriptionInfo.endTime = (DateTime) CartItem.getCustomField('digitalriverv3__Subscription_End_Time__c');
        }
        return itemSubscriptionInfo;
    }

    private static CartDeliveryGroup getDeliveryGroup(WebCart cart) {
        // In the Spring '20 release, there should be one delivery group per cart.
        // In the future, when multiple delivery groups can be created,
        // this sample should be updated to loop through all delivery groups.
        return (CartDeliveryGroup) cart.CartItems.get(0).getSObject(CartItem.CartDeliveryGroupId);
    }

    private static void saveCartValidationOutputError( String errorMessage,CartExtension.CartValidationOutputList cartValidationOutputCollection ) {
        logger.debugEvent('DRB2B_TaxCalculationServiceCartCalculate in saveCartValidationOutputError ');
            CartExtension.CartValidationOutput cvo = new CartExtension.CartValidationOutput(
              CartExtension.CartValidationOutputTypeEnum.TAXES,
              CartExtension.CartValidationOutputLevelEnum.ERROR
            );
            cvo.setMessage(errorMessage);
            cartValidationOutputCollection.add(cvo);
            isCvoPresent = true;
            logger.debugErrorEvent('DRB2B_TaxCalculationServiceCartCalculate saveCartValidationOutputError : '+ JSON.serialize(cvo));
            }
}