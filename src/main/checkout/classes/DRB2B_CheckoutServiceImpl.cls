public without sharing class DRB2B_CheckoutServiceImpl implements DRB2B_CheckoutService {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

    private static final String TAX_TYPE_ACTUAL = 'Actual';
    private static final String TAX_TYPE_ESTIMATED = 'Estimated';
    private static final String DELIVERY_CHARGE_ITEM = 'DELIVERY_CHARGE_ITEM';
    public static Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();

    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();
    @TestVisible
    private static DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();

    private DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
    private DRB2B_TaxIdentifierService taxIdentifierService = new DRB2B_TaxIdentifierService();
    private DRB2B_CartItemSelector cartItemSelector = new DRB2B_CartItemSelector();
    @TestVisible
    private static DRB2B_TransactionPaymentService transactionPaymentService = new DRB2B_TransactionPaymentService();

    public DRB2B_CreateCheckoutResponseModel createCheckout(DRB2B_CreateCheckoutRequestModel request) {
        DRB2B_CreateCheckoutResponseModel response = (DRB2B_CreateCheckoutResponseModel) requestService.getBasicRequest()
            .through(new DRB2B_CreateCheckoutErrorWire())
            .path(DRB2B_DRApiConstants.CHECKOUT_PATH)
            .headers(requestService.getUpstreamSessionId(request.upstreamId))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(reconcileCheckoutRequestModel(request)))
            .fetch()
            .asType(DRB2B_CreateCheckoutResponseModel.class);

        if (response.taxIdentifiers == null) {
            response.taxIdentifiers = new List<DRB2B_CreateCheckoutResponseModel.TaxIdentifier>();
        }

        return response;
    }

    public DRB2B_CreateCheckoutResponseModel updateCheckoutReqwithoutItems (String checkoutId, DRB2B_updateCheckoutRequestModel req) {
            DRB2B_CreateCheckoutResponseModel updateResponse = (DRB2B_CreateCheckoutResponseModel)requestService.getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CHECKOUT_PATH)
            .path(checkoutId)
            .headers(requestService.getUpstreamSessionId(String.valueOf(req.upstreamId)))
            .headers(requestService.getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(reconcileUpdateRequestModel(req)))
            .fetch()
            .asType(DRB2B_CreateCheckoutResponseModel.class);
        return updateResponse;
    }
    private Object reconcileUpdateRequestModel(DRB2B_updateCheckoutRequestModel updateCheckoutRequest) {
        Map<String, Object> updateCheckoutRequestMap = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serialize(updateCheckoutRequest, true)
        );

        Object drCurrency = updateCheckoutRequestMap.remove('drCurrency');
        updateCheckoutRequestMap.put('currency', drCurrency);
        return updateCheckoutRequestMap;
    }

    // TODO: Add logging
    public void attachSource(Id cartId, DRB2B_CreateCheckoutResponseModel.Source source) {
        logger.debug(cartId, 'DRB2B_CheckoutServiceImpl: The start of the authorization process: \n ' + JSON.serializePretty(source));
        ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();

        Set<String> cartFields = getCartFields();
        WebCart cart = cartSelector.getById(cartId, cartFields);

        authRequest.amount = cart.GrandTotalAmount;
        authRequest.accountId = cart.AccountId;
        authRequest.effectiveDate = Datetime.now();
        authRequest.currencyIsoCode = DCM_BaseUtilities.getSObjectCurrency(cart);

        // Cannot proceed if paymentGatewayId does not exist
        String paymentGatewayId = getPaymentGatewayId(cart.WebStoreId);
        if (String.isBlank(paymentGatewayId)) {
            throw new PaymentAuthorizationException(
                'This store is not authorized to process payments. Please, contact your System Administrator.'
            );
        }
        authRequest.paymentGatewayId = paymentGatewayId;
        authRequest.paymentMethod = getPaymentMethod();
        logger.debug('DRB2B_CheckoutServiceImpl checking getPaymentGroup method is calling with cart object' + cart);
        authRequest.paymentGroup = getPaymentGroup(cart);
        authRequest.additionalData = new Map<String, String>{
            'checkoutId' => cart.DR_Checkout_Id__c,
            'sourceId' => source.id,
            'cartId' => String.valueOf(cartId)
        };
        ConnectApi.AuthorizationResponse authResponse;
        ConnectApi.AuthorizationGatewayResponse authGatewayResponse;
        if (!Test.isRunningTest()) {
            // Authorize Payment with Payments API
            logger.debug(cartId, 'Authorize Payment Request: \n' + authRequest);
            authResponse = ConnectApi.Payments.authorize(authRequest);
            logger.debug(cartId, 'Authorize Payment Response: \n' + authResponse);
            authGatewayResponse = authResponse.gatewayResponse;
        } else {
            authResponse = new ConnectApi.AuthorizationResponse();
            authGatewayResponse = new ConnectApi.AuthorizationGatewayResponse();
            authResponse.error = null;
        }

        if (authResponse.error != null) {
            updatePaymentFailureStateOnOrder(authResponse.error.message, cartId);
            throw new PaymentAuthorizationException(authResponse.error.message);
        } else {
            List<SObject> payload = new List<SObject>();
            //actual dependency on sf order during payment authorization..
            Order sfOrder = getOrderWithLines(cartId);
            cart.DR_Source_Id__c = source.id;
            if (isBillingAddressDifferent(source, cart)) {
                setBillingAddress(cart, source);
                setBillingAddress(sfOrder, source);
            }
            payload.add(sfOrder);
            payload.add(cart);
            DmlManager.updateAsSystem(payload);
            logger.debug(cartId, authResponse + '');
        }
    }

    @TestVisible
    private Boolean isBillingAddressDifferent(DRB2B_CreateCheckoutResponseModel.Source source, WebCart cart) {
        return source.owner != null &&
            source.owner.address != null &&
            (source.owner.address.country != cart.BillingCountry ||
            source.owner.address.state != cart.BillingState ||
            source.owner.address.postalCode != cart.BillingPostalCode ||
            source.owner.address.city != cart.BillingCity ||
            source.owner.address.line1 != cart.BillingStreet);
    }
    @TestVisible
    private void setBillingAddress(SObject record, DRB2B_CreateCheckoutResponseModel.Source source) {
        Boolean isCountryStateEnabled = DRB2B_Utility.isCountryStateEnabled();
        if (isCountryStateEnabled) {
            record.put('BillingCountryCode', source.owner.address.country);
        } else {
            record.put('BillingCountry', new DRB2B_CountryPicklist().getEntry(source.owner.address.country).label);
        }
        if (String.isNotBlank(source.owner.address.state)) {
            if (isCountryStateEnabled) {
                record.put('BillingStateCode', source.owner.address.state);
            } else {
                record.put('BillingState', source.owner.address.state);
            }
        } else {
            record.put('BillingState', '');
        }
        record.put('BillingPostalCode', source.owner.address.postalCode);
        if (String.isNotBlank(source.owner.address.city)) {
            record.put('BillingCity', source.owner.address.city);
        } else {
            record.put('BillingCity', '');
        }
        record.put('BillingStreet', source.owner.address.line1);
    }
    @TestVisible
    private Set<String> getCartFields() {
        Set<String> cartFields = new Set<String>{
            'WebStoreId',
            'GrandTotalAmount',
            'AccountId',
            'DR_Checkout_Id__c',
            'BillingCountry',
            'BillingState',
            'BillingCity',
            'BillingPostalCode',
            'BillingStreet'
        };
        if (DCM_BaseUtilities.hasCurrencyField(WebCart.SObjectType)) {
            cartFields.add('CurrencyIsoCode');
        }
        return cartFields;
    }
    @TestVisible
    private Object reconcileCheckoutRequestModel(DRB2B_CreateCheckoutRequestModel createCheckoutRequest) {
        Map<String, Object> createCheckoutRequestMap = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serialize(createCheckoutRequest, true)
        );

        Object drCurrency = createCheckoutRequestMap.remove('drCurrency');
        createCheckoutRequestMap.put('currency', drCurrency);

        return createCheckoutRequestMap;
    }
    @TestVisible
    private static String getPaymentGatewayId(String webStoreId) {
        return [
            SELECT Integration
            FROM StoreIntegratedService
            WHERE ServiceProviderType = 'Payment' AND StoreId = :webStoreId
        ]
        ?.Integration;
    }
    @TestVisible
    private static ConnectApi.AuthApiPaymentMethodRequest getPaymentMethod() {
        ConnectApi.AuthApiPaymentMethodRequest authApiMethod = new ConnectApi.AuthApiPaymentMethodRequest();
        ConnectApi.CardPaymentMethodRequest paymentMethod = new ConnectApi.CardPaymentMethodRequest();

        paymentMethod.cardCategory = ConnectApi.CardCategory.CreditCard;
        paymentMethod.cardHolderName = 'cardHolderName';
        paymentMethod.cardNumber = '4111111111111111'; //Dummy Card Number value to bypass required field
        paymentMethod.cardType = 'Visa'; //Dummy Card Type value to bypass required field
        paymentMethod.cvv = '123'; //Dummy Card CVV value to bypass required field
        paymentMethod.expiryMonth = 12; //Dummy Card Expiry Month value to bypass required field
        paymentMethod.expiryYear = 2030; //Dummy Card Expiry Year value to bypass required field
        authApiMethod.cardPaymentMethod = paymentMethod;

        ConnectApi.AddressRequest address = new ConnectApi.AddressRequest();
        address.street = 'street';
        address.city = 'city';
        address.state = 'Alabama';
        address.country = 'United States';
        address.postalCode = 'postalCode';

        authApiMethod.address = address;
        authApiMethod.saveForFuture = false;

        return authApiMethod;
    }
    @TestVisible
    private static ConnectApi.PaymentGroupRequest getPaymentGroup(WebCart cart) {
        ConnectApi.PaymentGroupRequest paymentGroup = new ConnectApi.PaymentGroupRequest();
        logger.debug('verifying getPaymentGroup  is having cart object- check the id field' + cart);
        paymentGroup.createPaymentGroup = true;
        paymentGroup.sourceObjectId = getOrderId(cart.Id);
        paymentGroup.currencyIsoCode = DCM_BaseUtilities.getSObjectCurrency(cart);
        return paymentGroup;
    }
    @TestVisible
    private static String getOrderId(String cartId) {
        return [SELECT OrderId FROM CartCheckoutSession WHERE WebCartId = :cartId AND IsArchived = FALSE]?.OrderId;
    }

    @TestVisible
    private static CartCheckoutSession getOrderNumber(String cartId) {
        if (!isGuestUser && !Test.isRunningTest()) {
            return [
                SELECT order.OrderNumber, OrderId
                FROM CartCheckoutSession
                WHERE WebCartId = :cartId AND IsArchived = FALSE
                WITH SECURITY_ENFORCED
            ];
        } else {
            return [
                SELECT order.OrderNumber, OrderId
                FROM CartCheckoutSession
                WHERE WebCartId = :cartId AND IsArchived = FALSE
            ];
        }
    }

    public void convertToOrder(Id cartId) {
        if (
            !test.isRunningTest() //TODO : Remove this and handle this in testclass
        )
            updateCheckoutWithSfOrderId(cartId);
        WebCart cart = cartSelector.getById(
            cartId,
            new Set<String>{
                'DR_Checkout_Id__c',
                'Has_Landed_Cost__c',
                'DR_Tax_Identifiers__c',
                'DR_Customer_Type__c',
                'DR_Selling_Entity__c'
            }
        );

        DCM_HttpClient.Response createOrderResponse = requestService
            .getConvertCheckoutToOrderRequest(cart.DR_Checkout_Id__c, String.valueOf(cartId))
            .fetch();

        if (isValidStatusCode(createOrderResponse)) {
            DRB2B_OrderResponseModel drOrder = DRB2B_OrderResponseModel.deserializeOrder(createOrderResponse.getBody());
            logger.debug(cartId, 'The DR Order successfully created: \n' + JSON.serializePretty(drOrder));

            DCM_HttpClient.Response getOrderResponse = requestService.getOrderRequest(
                    drOrder.id,
                    String.valueOf(cartId)
                )
                .fetch();
            logger.debug(cartId, 'Get complete DR Order info: \n' + JSON.serializePretty(drOrder));

            drOrder = DRB2B_OrderResponseModel.deserializeOrder(getOrderResponse.getBody());
            Map<String, DRB2B_OrderResponseModel.Items> drItemsBySku = new Map<String, DRB2B_OrderResponseModel.Items>();
            if(drOrder != null && drOrder.Items != null){
                for (DRB2B_OrderResponseModel.Items items : drOrder.items) {
                	drItemsBySku.put(items.skuId, items);
            	}
            }

            Order sfOrder = getOrderWithLines(cartId);
            deleteOutdatedOrderTaxes(sfOrder);

            logger.debug(cartId, 'Get order with lines: \n' + JSON.serializePretty(sfOrder));

            sfOrder.DR_Order_Id__c = drOrder.id;
            sfOrder.DR_Order_State__c = drOrder.state;
            sfOrder.DR_Fraud_State__c = drOrder.fraudState;
            sfOrder.Has_Landed_Cost__c = cart.Has_Landed_Cost__c;
            sfOrder.DR_Customer_Type__c = cart.DR_Customer_Type__c;
            sfOrder.DR_Tax_Identifiers__c = cart.DR_Tax_Identifiers__c;
            sfOrder.DR_Payment_Status__c = 'Successful';
            sfOrder.DR_Selling_Entity__c = cart.DR_Selling_Entity__c;
            sfOrder.DR_SF_CartId__c = cartId;

            List<OrderItemTaxLineItem> newOrderItemTaxLineItems = new List<OrderItemTaxLineItem>();
            for (OrderItem sfItem : sfOrder.OrderItems) {
                DRB2B_OrderResponseModel.Items drItem = drItemsBySku.get(sfItem.Product2Id);
                if (drItem != null) {
                    // Capture Billing Agreement Id and other Subscription info
                    sfItem.DR_Billing_Agreement_Id__c = drItem?.subscriptionInfo?.billingAgreementId;
                    sfItem.Subscription_Id__c = drItem?.subscriptionInfo?.subscriptionId;
                    sfItem.Recurring_Line_Item__c = (null != drItem.subscriptionInfo) ? true : false;

                    sfItem.DR_Order_Item_Id__c = drItem.id;
                    sfItem.DR_Order_Item_State__c = drItem.state;
                    sfItem.DR_Regulatory_Fee__c = drItem?.fees?.amount;
                    sfItem.DR_Duty__c = drItem?.duties?.amount;
                    sfItem.DR_IOR_Tax__c = drItem?.importerTax?.amount;
                    sfItem.DR_Open_Quantity__c = sfItem.Quantity;
                    sfItem.TotalLineAmount =
                        sfItem.TotalLineAmount +
                        sfItem?.DR_Duty__c +
                        sfItem?.DR_IOR_Tax__c +
                        sfItem?.DR_Regulatory_Fee__c;

                    newOrderItemTaxLineItems.add(
                        new OrderItemTaxLineItem(
                            Name = sfItem.Product2.Name + ' Tax',
                            TaxEffectiveDate = Date.today(),
                            OrderItemId = sfItem.Id,
                            Amount = drItem?.tax?.amount + drItem?.fees?.taxAmount,
                            Type = TAX_TYPE_ACTUAL
                        )
                    );
                }
            }

            if (drOrder.shippingChoice != null && drOrder.shippingChoice.taxAmount > 0) {
                List<OrderItem> chargeItems = (List<OrderItem>) Collection.of(sfOrder.OrderItems)
                    .filter(OrderItem.Type)
                    .equals('Delivery Charge')
                    .get();

                if (Collection.of(chargeItems).isNotEmpty()) {
                    OrderItem deliveryChargeItem = chargeItems.get(0);

                    newOrderItemTaxLineItems.add(
                        new OrderItemTaxLineItem(
                            Name = 'Delivery Charge Tax',
                            TaxEffectiveDate = Date.today(),
                            OrderItemId = deliveryChargeItem.Id,
                            Amount = drOrder.shippingChoice.taxAmount,
                            Type = TAX_TYPE_ACTUAL
                        )
                    );
                }
            }
            List<SObject> payload = new List<SObject>();
            payload.add(sfOrder);
            payload.addAll(sfOrder.OrderItems);
            payload.addAll(newOrderItemTaxLineItems);
            Boolean isOrderAndOrderItemUpdationDone = handleOrderandOrderItemUpdation(payload, drOrder);
        } else {
            handleOrderCreationIssue(createOrderResponse, cartId);
        }

        logger.flush();
    }

    public string convertToOrderLWR(Id cartId) {
        List<Sobject> payload = new List<Sobject>();
        String drOrderId;
        if (!test.isRunningTest()) {
            WebCart cart = cartSelector.getById(
                cartId,
                new Set<String>{
                    'DR_Checkout_Id__c',
                    'Has_Landed_Cost__c',
                    'DR_Tax_Identifiers__c',
                    'DR_Customer_Type__c',
                    'DR_Selling_Entity__c'
                }
            );
            DCM_HttpClient.Response createOrderResponse = requestService
                .getConvertCheckoutToOrderRequest(cart.DR_Checkout_Id__c, String.valueOf(cartId))
                .fetch();

            if (isValidStatusCode(createOrderResponse)) {
                DRB2B_OrderResponseModel drOrder = DRB2B_OrderResponseModel.deserializeOrder(
                    createOrderResponse.getBody()
                );
                logger.debug(cartId, 'The DR Order successfully created: \n' + JSON.serializePretty(drOrder));

                DCM_HttpClient.Response getOrderResponse = requestService.getOrderRequest(
                        drOrder.id,
                        String.valueOf(cartId)
                    )
                    .fetch();
                logger.debug(cartId, 'Get complete DR Order info: \n' + JSON.serializePretty(drOrder));

                drOrder = DRB2B_OrderResponseModel.deserializeOrder(getOrderResponse.getBody());
                drOrderId = drOrder.id;
                //new change update drorderid to cart using cartid
                cart.Id = cartId;
                cart.digitalriverv3__DR_Order_Id__c = drOrderId;
                payload.add(cart);
                DMLManager.updateAsSystem(payload);

                Map<String, DRB2B_OrderResponseModel.Items> drItemsBySku = new Map<String, DRB2B_OrderResponseModel.Items>();
                for (DRB2B_OrderResponseModel.Items items : drOrder.items) {
                    drItemsBySku.put(items.skuId, items);
                }
            } else {
                DRB2B_ErrorsResponseModel errorResponse = DRB2B_ErrorsResponseModel.parse(
                    createOrderResponse.getBody()
                );

                List<String> codes = new List<String>();
                List<String> messages = new List<String>();
                for (DRB2B_ErrorResponseModel e : errorResponse.errors) {
                    codes.add(e.code);
                    messages.add(e.message);
                }

                logger.error(cartId, JSON.serializePretty(errorResponse));
                throw new CheckoutServiceException(System.Label.DR_Order_Creation_Error);
            }
        }
        return drOrderId;
    }

    @TestVisible
    private Boolean handleOrderandOrderItemUpdation(List<SObject> payLoad, DRB2B_OrderResponseModel drOrder) {
        Boolean isOrderAndOrderItemUpdationDone = false;
        try {
            DmlManager.upsertAsSystem(payload); //insertAsUser
            isOrderAndOrderItemUpdationDone = true;
        } catch (Exception e) {
            cancelDROrder(JSON.serialize(drOrder), e.getMessage());
            throw new DmlManager.DmlManagerException(System.Label.SF_Order_Updation_Error);
        }
        return isOrderAndOrderItemUpdationDone;
    }

    public void cancelDROrder(String responseJson, String errorMessage) {
        logger.error(errorMessage);
        List<DigitalRiverOrderCancellation__e> drOrderCancellationEvents = new List<DigitalRiverOrderCancellation__e>();
        drOrderCancellationEvents.add(
            new DigitalRiverOrderCancellation__e(errorMessage__c = errorMessage, orderResponse__c = responseJson)
        );
        EventBus.publish(drOrderCancellationEvents);
    }

    @future(callout=true)
    public static void cancelDRFailedOrder(String responseJson) {
        DRB2B_OrderResponseModel drOrder = DRB2B_OrderResponseModel.deserializeOrder(responseJson);
        DRB2B_CreateFulfillmentRequestModel fulfillmentRequestModel = new DRB2B_CreateFulfillmentRequestModel();
        fulfillmentRequestModel.orderId = drOrder.id;

        // Add Line Item Fulfillment Request
        List<DRB2B_CreateFulfillmentRequestModel.Items> fulfillmentLineItemList = new List<DRB2B_CreateFulfillmentRequestModel.Items>();
        for (DRB2B_OrderResponseModel.Items drLineItem : drOrder.items) {
            DRB2B_CreateFulfillmentRequestModel.Items fulfillmentLineItem = new DRB2B_CreateFulfillmentRequestModel.Items();
            fulfillmentLineItem.itemId = drLineItem.id;
            fulfillmentLineItem.cancelQuantity = Integer.valueOf(drLineItem.quantity);
            fulfillmentLineItemList.add(fulfillmentLineItem);
        }
        fulfillmentRequestModel.items = fulfillmentLineItemList;

        // Serialize the Fulfillment request
        String cancellationRequestJson = DRB2B_CreateFulfillmentRequestModel.serialize(fulfillmentRequestModel);
        logger.info('Order Cancellation Request to be submitted to DR: ' + cancellationRequestJson);
        DCM_HttpClient.Request request = requestService.getFulfillmentRequest(cancellationRequestJson);
        DCM_HttpClient.Response response = request.fetch();
        logger.info('Order Cancellation response ' + response);
        if (response.getStatusCode() == DRB2B_Constants.Base.FULFILLMENT_SUCCESS_RESPONSE_CODE) {
            logger.info('Order Cancellation done successfully with Status Code :' + response.getStatusCode());
        } else if (response.getStatusCode() == DRB2B_Constants.Base.CONFLICT_RESPONSE_CODE) {
            logger.info('Conflicts In Order Cancellation with Status Code :' + response.getStatusCode());
        } else {
            logger.info('Order Cancellation failed with Status Code :' + response.getStatusCode());
        }
        logger.flush();
    }

    @TestVisible
    private void deleteOutdatedOrderTaxes(Order sfOrder) {
       
        List<OrderItemTaxLineItem> oldOrderItemTaxLineItems = [
            SELECT Id
            FROM OrderItemTaxLineItem
            WHERE OrderItem.OrderId = :sfOrder.Id
            WITH SECURITY_ENFORCED
        ];
        DmlManager.deleteAsSystem(oldOrderItemTaxLineItems);
    }
    @TestVisible
    // TODO: Rewrite using Query library
    public Order getOrderWithLines(Id cartId) {
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        Order order = null;
        List<Order> orderList;
        if (!isGuestUser) {
        orderList = [
            SELECT
                Id,
                AccountId,
                CreatedById,
                CreatedBy.ContactId,
                (SELECT Id, Quantity, Product2Id, Product2.Name, type, TotalLineAmount FROM OrderItems)
            FROM Order
            WHERE Id IN (SELECT OrderId FROM CartCheckoutSession WHERE WebCartId = :cartId AND IsArchived = FALSE)
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        }
        else
        {
        orderList = [
                SELECT
                    Id,
                    AccountId,
                    CreatedById,
                    CreatedBy.ContactId,
                    (SELECT Id, Quantity, Product2Id, Product2.Name, type, TotalLineAmount FROM OrderItems)
                FROM Order
                WHERE Id IN (SELECT OrderId FROM CartCheckoutSession WHERE WebCartId = :cartId AND IsArchived = FALSE)
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];  
        }
        if (orderList.isEmpty()) {
            logger.debug('DRBRB_CheckoutServiceImpl getOrderWithLines OrderList LWR null ');
            return null;
        } else {
            order = orderList[0];
            logger.debug('DRBRB_CheckoutServiceImpl getOrderWithLines after order creation AURA' + order);
            return order;
        }
    }

    @AuraEnabled
    public static string getcheckoutSessionId(String cartId) {
        Id checkoutId = [
            SELECT Id, OrderId
            FROM CartCheckoutSession
            WHERE WebCartId = :cartId AND IsArchived = FALSE
        ][0]
        .Id;
        return checkoutId;
    }
    
    @TestVisible
    private void handleOrderCreationIssue(DCM_HttpClient.Response createOrderResponse, Id cartId) {
        DRB2B_ErrorsResponseModel errorResponse = DRB2B_ErrorsResponseModel.parse(createOrderResponse.getBody());

        List<String> codes = new List<String>();
        List<String> messages = new List<String>();
        for (DRB2B_ErrorResponseModel e : errorResponse.errors) {
            codes.add(e.code);
            messages.add(e.message);
        }
        updatePaymentFailureStateOnOrder(errorResponse.errors[0].message, cartId);

        logger.error(cartId, JSON.serializePretty(errorResponse));
        throw new CheckoutServiceException(System.Label.DR_Order_Creation_Error);
    }
    @TestVisible
    private static Boolean isValidStatusCode(DCM_HttpClient.Response createOrderResponse) {
        return createOrderResponse.getStatusCode() >= 200 && createOrderResponse.getStatusCode() < 300;
    }

    public class DRB2B_CreateCheckoutErrorWire extends DCM_HttpClient.Wire {
        public override DCM_HttpClient.Response send(HttpRequest request, Map<String, Object> parameters) {
            DCM_HttpClient.Response originResponse = this.getOrigin().send(request, parameters);

            Integer statusCode = originResponse.getStatusCode();
            if ((Integer) statusCode != 201) {
                logger.debugErrorEvent('DRB2B_CreateCheckoutErrorWire  Error in response: '+ originResponse.getBody());
            }

            return originResponse;
        }
    }

    /**
     * Update SF Order with Payment Failure State and Reason
     */
    public void updatePaymentFailureStateOnOrder(String errorMessage, Id cartId) {
        Order sfOrder = getOrderWithLines(cartId);
        sfOrder.DR_Payment_Status__c = 'Declined';
        sfOrder.DR_Payment_Failure_Reason__c = errorMessage;
        List<DmlOperation__e> dmlOperationEvents = new List<DmlOperation__e>();
        dmlOperationEvents.add(new DmlOperation__e(Operation__c = 'MODIFY', Payload__c = JSON.serialize(sfOrder)));
        EventBus.publish(dmlOperationEvents);
    }

    public void refreshCartBasedOnDrRecord(Id cartId) {
        logger.debug('refreshCartBasedOnDrRecord method in checkoutservice impl cartid ' + cartId);
        WebCart cart = cartSelector.getCartWithItemsById(
            cartId,
            new List<String>{ 'Id', 'DR_Checkout_Id__c', 'DR_Checkout_Type__c' },
            new List<String>{ 'Id', 'Name', 'Product2Id', 'Type' }
        );
        logger.debug('refreshCartBasedOnDrRecord in CheckoutServiceImpl1');
        DCM_HttpClient.Response getCheckoutResponse = requestService.getCheckoutRequest(
                cart.DR_Checkout_Id__c,
                String.valueOf(cartId)
            )
            .fetch();

        if (isValidStatusCode(getCheckoutResponse)) {
            logger.debug('refreshCartBasedOnDrRecord in isValidStatusCode');
            DRB2B_CreateCheckoutResponseModel checkout = DRB2B_CreateCheckoutResponseModel.parse(
                getCheckoutResponse.getBody()
            );
            //Passing Response Body to validate digital river payment instruction detail.
            DRB2B_TransactionPaymentService.responseBody = getCheckoutResponse.getBody();
            logger.debug('refreshCartBasedOnDrRecord in responseBody');

            for (DRB2B_CreateCheckoutResponseModel.Source source : checkout.Payment.sources) {
                if (source.type != 'customerCredit') {
                    logger.debug('refreshCartBasedOnDrRecord in before getOrderWithLines');
                    Order sfOrder = null;
                    sfOrder = getOrderWithLines(cartId);
                    logger.debug('refreshCartBasedOnDrRecord after getOrderWithLines');
                    DR_Transaction_Payment__c transactionPaymentObj = transactionPaymentService.createTrasactionPaymentRecord(
                        sfOrder,
                        source,
                        cartId
                    );
                    if (!isGuestUser) {
                        DmlManager.insertAsUser(transactionPaymentObj);
                    } else {
                        DmlManager.insertAsSystem(transactionPaymentObj);
                    }
                }
            }

            Map<String, CartItem> cartItemsBySkuIds = (Map<String, CartItem>) Collection.of(cart.CartItems)
                .mapBy('Product2Id', String.class);

            this.recalculateTaxesAndFees(cart, cartItemsBySkuIds, checkout);
        } else {
            throw new CheckoutServiceException(
                'There is an issue while getting Digital River Checkout record. Please, contact your System Administrator.'
            );
        }
    }

    public void recalculateTaxesAndFees(
        WebCart cart,
        Map<String, CartItem> cartItemsBySkuIds,
        DRB2B_CreateCheckoutResponseModel createCheckoutResponse
    ) {
        try {
            List<CartTax> cartTaxes = new List<CartTax>();
            list<CartItem> cItems = new List<CartItem>();
            List<DR_Regulatory_Fee__c> regulatoryFees = new List<DR_Regulatory_Fee__c>();
            logger.debug(
                'Drb2bcheckoutServiceImpl recalculateTaxesAndFees method cartItemsBySkuIds ' + cartItemsBySkuIds
            );
            logger.debug('Drb2bcheckoutServiceImpl recalculateTaxesAndFees method cart ' + cart);
            logger.debug(
                'Drb2bcheckoutServiceImpl recalculateTaxesAndFees method createCheckoutResponse ' +
                createCheckoutResponse
            );
            deleteOutdatedTaxesAndFees(cartItemsBySkuIds, cart, createCheckoutResponse);

            for (DRB2B_CreateCheckoutResponseModel.Item item : createCheckoutResponse.items) {
                CartItem cartItem = cartItemsBySkuIds.get(item.skuId);
                if (hasAnyTax(item)) {
                    CartTax cartTax = new CartTax(
                        Name = cartItem.Name + ' Tax',
                        Amount = item.tax.amount + item.fees.taxAmount,
                        CartItemId = cartItem.Id,
                        TaxRate = item.tax.rate,
                        TaxType = TAX_TYPE_ACTUAL,
                        TaxCalculationDate = Date.today(),
                        DR_Regulatory_Fee__c = item.fees.amount,
                        DR_Duty__c = item.duties.amount,
                        DR_IOR_Tax__c = item.importerTax.amount
                    );
                    cartTaxes.add(cartTax);

                    if (Collection.of(item.fees.details).isNotEmpty()) {
                        for (DRB2B_CreateCheckoutResponseModel.Details details : item.fees.details) {
                            DR_Regulatory_Fee__c regulatoryFee = new DR_Regulatory_Fee__c(
                                Cart_Item_Id__c = cartItem.Id,
                                Amount__c = details.amount,
                                Per_Unit_Amount__c = details.perUnitAmount,
                                Fee_Type__c = details.type,
                                Fee_Id__c = details.id
                            );

                            regulatoryFees.add(regulatoryFee);
                        }
                    }
                }
                //DRLB2B-336 saving cartItem Id to salesforce to support subscription terms updation
                CartItem cItem = new CartItem(id = cartItem.Id, DR_Cart_Item_Id__c = item.id);
                cItems.add(cItem);
            }

            // Capture Shipping Tax Amount
            List<CartItem> chargeItems = (List<CartItem>) Collection.of(cart.CartItems)
                .filter(CartItem.Type)
                .equals('Charge')
                .get();

            if (Collection.of(chargeItems).isNotEmpty()) {
                CartItem deliveryChargeItem = chargeItems.get(0);
                Decimal shippingTaxAmount = 0;
                if (
                    createCheckoutResponse.shippingChoice != null &&
                    createCheckoutResponse.shippingChoice.taxAmount > 0
                ) {
                    shippingTaxAmount = createCheckoutResponse.shippingChoice.taxAmount;
                }

                CartTax cartTax = new CartTax(
                    Name = deliveryChargeItem.Name + ' Tax',
                    Amount = shippingTaxAmount,
                    CartItemId = deliveryChargeItem.Id,
                    TaxCalculationDate = Date.today(),
                    TaxType = TAX_TYPE_ACTUAL
                );
                cartTaxes.add(cartTax);
            }

            if (null == createCheckoutResponse.importerOfRecordTax) {
                createCheckoutResponse.importerOfRecordTax = false;
            }

            if (null == createCheckoutResponse.sellingEntity || null == createCheckoutResponse.sellingEntity.id) {
                createCheckoutResponse.sellingEntity.id = null;
            }

            List<SObject> payload = new List<SObject>();
            payload.addAll(cartTaxes);
            payload.addAll(cItems);
            payload.addAll(regulatoryFees);
            payload.add(
                new WebCart(
                    Id = cart.Id,
                    DR_Checkout_Id__c = createCheckoutResponse.id,
                    DR_Payment_Session_Id__c = createCheckoutResponse.payment?.session?.id,
                    Has_Landed_Cost__c = createCheckoutResponse.importerOfRecordTax,
                    DR_Selling_Entity__c = createCheckoutResponse.sellingEntity.id,
                    DR_Tax_Identifiers__c = createCheckoutResponse.taxIdentifiers == null
                        ? ''
                        : taxIdentifierService.appliedTaxIds(createCheckoutResponse.taxIdentifiers), //DRLB2B-324 Populate tax id on cart and order
                    DR_Amount_Contributed__c = createCheckoutResponse?.Payment?.session?.amountContributed,
                    DR_Amount_Remaining_to_be_Contributed__c = createCheckoutResponse
                        ?.Payment
                        ?.session
                        ?.amountRemainingToBeContributed
                )
            );
            DmlManager.upsertAsSystem(payload);
            logger.debug('Drb2bcheckoutServiceImpl payload after update webcart ' + payload);
        } catch (exception e) {
            logger.error('Drb2bcheckoutServiceImpl recalculateTaxesAndFees method' + e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }
    @TestVisible
    private void deleteOutdatedTaxesAndFees(
        Map<String, CartItem> cartItemsBySkuIds,
        WebCart cart,
        DRB2B_CreateCheckoutResponseModel createCheckoutResponse
    ) {
        Set<String> cartItemIds = (Set<String>) Collection.of(cartItemsBySkuIds.values()).setOf('Id', String.class);
        List<SObject> payload = new List<SObject>();

        for (DRB2B_CreateCheckoutResponseModel.Item item : createCheckoutResponse.items) {
            CartItem cartItemRecord = cartItemsBySkuIds.get(item.skuId);
            logger.debug('Drb2bcheckoutServiceImpl deleteOutdatedTaxesAndFees method cartItemRecord' + cartItemRecord);
        }
        //  Map<Id, cartTax> cartTaxMap = new Map<Id, cartTax>();
        List<CartTax> cartTaxList = new List<CartTax>(
            [
                SELECT Id, CartItemId, CartItem.cartId
                FROM CartTax
                WHERE CartItemId IN (SELECT Id FROM CartItem WHERE CartId = :cart.Id)
            ]
        );
        try {
            if (cartTaxList != null && cartTaxList.size() > 0) {
                logger.debug('Drb2bcheckoutServiceImpl deleteOutdatedTaxesAndFees cartTaxList ' + cartTaxList);
                payload.addAll(cartTaxList);
            }
        } catch (exception ex) {
            logger.error('CART_TAX_ERROR::>>' + ex.getLineNumber() + ' | ' + ex.getMessage());
        }
        List<DR_Regulatory_Fee__c> fees = [SELECT Id FROM DR_Regulatory_Fee__c WHERE Cart_Item_Id__c IN :cartItemIds];
        payload.addAll(fees);

        if (!payload.isEmpty()) {
            DmlManager.deleteAsSystem(payload);
        }
    }

    //DRLB2B-336
    //Update checkout request with subscription terms and orderid as upstream id
    public DCM_HttpClient.Response updateCheckoutReq(Id cartId, string terms) {
        list<cartItem> recurringCartItems = cartItemSelector.getRecurringItemByForeignKey(
            'CartId',
            new Set<String>{
                'Id',
                'DR_Cart_Item_Id__c',
                'Cart.DR_Checkout_Id__c',
                'Subscription_Id__c',
                'Free_Subscription_Trial__c',
                'Subscription_Start_Time__c',
                'Subscription_End_Time__c'
            },
            new Set<Id>{ cartId }
        );
        String drCheckoutId = recurringCartItems[0].Cart.DR_Checkout_Id__c;
        DRB2B_updateCheckoutRequestModel req = new DRB2B_updateCheckoutRequestModel();
        List<DRB2B_updateCheckoutRequestModel.item> reqItemList = new List<DRB2B_updateCheckoutRequestModel.item>();
        for (cartItem item : recurringCartItems) {
            DRB2B_updateCheckoutRequestModel.item reqItem = new DRB2B_updateCheckoutRequestModel.item();
            reqItem.Id = item.DR_Cart_Item_Id__c;
            reqItem.subscriptionInfo = new DRB2B_updateCheckoutRequestModel.subscriptionInfo();
            reqItem.subscriptionInfo.terms = terms;
            reqItem.subscriptionInfo.autoRenewal = true;
            reqItem.subscriptionInfo.subscriptionId = item.Subscription_Id__c;
            reqItem.subscriptionInfo.freeTrial = item.Free_Subscription_Trial__c;
            //As per DR request
            //if enddate is null ,we will not pass startime and endtime to checkout request
            if (null != item.Subscription_End_Time__c) {
                reqItem.subscriptionInfo.startTime = item.Subscription_Start_Time__c;
                reqItem.subscriptionInfo.endTime = item.Subscription_End_Time__c;
            }
            reqItemList.add(reqItem);
        }
        req.items = reqItemList;
        logger.info('update checkout request' + req);
        DCM_HttpClient.Response updateResponse = requestService.updateCheckout(
                req,
                drCheckoutId,
                String.valueOf(cartId)
            )
            .fetch();
        return updateResponse;
    }

    public void updateCheckoutWithSfOrderId(Id cartId) {
        CartCheckoutSession sfOrder = getOrderNumber(cartId);
        Set<String> cartFields = getCartFields();
        WebCart cart = cartSelector.getById(cartId, cartFields);
        DRB2B_updateCheckoutRequestModel req = new DRB2B_updateCheckoutRequestModel(sfOrder?.order?.OrderNumber);
        DRB2B_updateCheckoutRequestModel.Metadata metadata = new DRB2B_updateCheckoutRequestModel.Metadata();
        metadata.sfOrderId = sfOrder?.OrderId;
        req.metadata = metadata;
        DCM_HttpClient.Response updateUpstreamIdResponse = requestService.updateCheckout(
                req,
                cart.DR_Checkout_Id__c,
                String.valueOf(cartId)
            )
            .fetch();
    }

    @TestVisible
    private List<CartTax> getOutdatedTaxFromCancelledCheckout(List<CartItem> cartItems) {
        return [SELECT Id FROM CartTax WHERE CartItemId IN :cartItems WITH SECURITY_ENFORCED];
    }
    @TestVisible
    private Boolean isChargeType(CartItem cartItem) {
        return cartItem.Type == 'Charge';
    }
    @TestVisible
    private Boolean hasAnyTax(DRB2B_CreateCheckoutResponseModel.Item item) {
        return item.tax.amount > 0 || item.fees.amount > 0 || item.duties.amount > 0 || item.importerTax.amount > 0;
    }

    public class PaymentAuthorizationException extends Exception {
    }

    public inherited sharing class CheckoutServiceException extends Exception {
    }

    // TODO: Add logging
    public boolean attachSourceLWR(Id cartId, DRB2B_CreateCheckoutResponseModel.Source source) {
        Boolean responsePayment;
        try {
            ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();
            Set<String> cartFields = getCartFields();
            WebCart cart = cartSelector.getById(cartId, cartFields);
            authRequest.amount = cart.GrandTotalAmount;
            authRequest.accountId = cart.AccountId;
            authRequest.effectiveDate = Datetime.now();
            authRequest.currencyIsoCode = DCM_BaseUtilities.getSObjectCurrency(cart);
            authRequest.paymentMethod = getPaymentMethod();
            authRequest.additionalData = new Map<String, String>{
                'checkoutId' => cart.DR_Checkout_Id__c,
                'sourceId' => source.id,
                'cartId' => String.valueOf(cartId)
            };
            if (!Test.isRunningTest()) {
                String checkoutId = authRequest.additionalData.get('checkoutId');
                String sourceId = authRequest.additionalData.get('sourceId');
                cartId = authRequest.additionalData.get('cartId');
                responsePayment= attachPaymentToCheckout(checkoutId, sourceId, cartId);
            }
            List<SObject> payload = new List<SObject>();
            cart.DR_Source_Id__c = source.id;
            if (isBillingAddressDifferent(source, cart)) {
                setBillingAddress(cart, source);
                //        setBillingAddress(sfOrder, source);
            }
            system.debug('c' + payload);
            system.debug('checkoutserviceimpl payload cart' + cart);
            payload.add(cart);
            DmlManager.updateAsSystem(payload);
        } 
        catch (Exception e) {
            system.debug('checkoutserviceimpl attachSourceLWR failure' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return responsePayment;
    }
    
    public Boolean attachPaymentToCheckout(String checkoutId, String sourceId, String cartId) {
        boolean returnValue;
        try {
            DRB2B_RequestService requestService = new DRB2B_RequestService();
            DCM_HttpClient.Response response = requestService.attachSourceToCheckout(checkoutId, sourceId, cartId)
                .fetch();
            DRB2B_SourceModel sourceModelResponse;
            if (response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS) {
                sourceModelResponse = (DRB2B_SourceModel) response.asType(DRB2B_SourceModel.class);
                returnValue = true;
             }
             else{
                 returnValue = false;
              }
            }
           catch (Exception e) {
                system.debug('checkservimpl4 attachPaymentToCheckout' + e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
            return returnValue;
    }

    public void recalculateTaxesAndFeesCartCalculate(CartExtension.Cart cart, Map<String, CartExtension.CartItem> cartItemsBySkuIds, DRB2B_CreateCheckoutResponseModel createCheckoutResponse) {
        try {
            CartExtension.CartTaxList cartTaxCollection;
            deleteOutdatedTaxesAndFeesCartCalculate(cart);
            for (DRB2B_CreateCheckoutResponseModel.Item item : createCheckoutResponse.items) {
                CartExtension.CartItem cartItem = cartItemsBySkuIds.get(item.skuId);
                cartTaxCollection= cartItem.getCartTaxes();
                if (hasAnyTax(item)) {
                    CartExtension.TaxTypeEnum taxType = CartExtension.TaxTypeEnum.ACTUAL;
                    Decimal amount = item.tax.amount + item.fees.taxAmount;
                    String name = cartItem.getname().toString() + ' Tax';

                    CartExtension.CartTax cartTax = new CartExtension.CartTax(taxType, amount, name);

                    if(item.tax.rate!= null){
                        cartTax.setTaxRate(String.valueOf(item.tax.rate));
                    }
                    cartTax.setCustomField('digitalriverv3__DR_Duty__c', item.duties.amount);
                    cartTax.setCustomField('digitalriverv3__DR_IOR_Tax__c', item.importerTax.amount);
                    cartTax.setCustomField('digitalriverv3__DR_Regulatory_Fee__c', item.fees.amount);
                    cartTaxCollection.add(cartTax);
                }
                //DRLB2B-336 saving cartItem Id to salesforce to support subscription terms updation
                CartItem.setCustomField('digitalriverv3__DR_Cart_Item_Id__c', item.id);
            }

            CartExtension.CartItemList cartItemCollection = cart.getCartItems();
            for (Integer i = (cartItemCollection.size() - 1); i >= 0; i--) {
                if (cartItemCollection.get(i).getType() == CartExtension.SalesItemTypeEnum.CHARGE) {
                    Decimal shippingTaxAmount = 0;
                    if ( createCheckoutResponse.shippingChoice != null && createCheckoutResponse.shippingChoice.taxAmount > 0 ) {
                        shippingTaxAmount = createCheckoutResponse.shippingChoice.taxAmount;
                    }
                    CartExtension.CartTax cartTax2 = new CartExtension.CartTax(CartExtension.TaxTypeEnum.ACTUAL, shippingTaxAmount, cartItemCollection.get(i).getname().toString() + ' Tax');
                    cartTaxCollection.add(cartTax2);
                }
            }

            if (null == createCheckoutResponse.importerOfRecordTax) {
                createCheckoutResponse.importerOfRecordTax = false;
            }

            if (null == createCheckoutResponse.sellingEntity || null == createCheckoutResponse.sellingEntity.id) {
                createCheckoutResponse.sellingEntity.id = null;
            }
            cart.setCustomField('digitalriverv3__DR_Checkout_Id__c', createCheckoutResponse.id);
            cart.setCustomField('digitalriverv3__DR_Payment_Session_Id__c', createCheckoutResponse.payment?.session?.id);
            cart.setCustomField('digitalriverv3__Has_Landed_Cost__c', createCheckoutResponse.importerOfRecordTax);
            cart.setCustomField('digitalriverv3__DR_Selling_Entity__c', createCheckoutResponse.sellingEntity.id);
            cart.setCustomField('digitalriverv3__DR_Tax_Identifiers__c', createCheckoutResponse.taxIdentifiers == null ? '' : taxIdentifierService.appliedTaxIds(createCheckoutResponse.taxIdentifiers));
            cart.setCustomField('digitalriverv3__DR_Amount_Contributed__c', createCheckoutResponse?.Payment?.session?.amountContributed);
            cart.setCustomField('digitalriverv3__DR_Amount_Remaining_to_be_Contributed__c', createCheckoutResponse ?.Payment ?.session ?.amountRemainingToBeContributed);
            
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @TestVisible
    private void deleteOutdatedTaxesAndFeesCartCalculate( CartExtension.Cart cart) 
    {
        CartExtension.CartItemList cartItemCollection = cart.getCartItems();
        Map<String, CartExtension.CartItem> cartItemById = new Map<String, CartExtension.CartItem>();
        for (Integer i = (cartItemCollection.size() - 1); i >= 0; i--) {
            for (Integer j = (cartItemCollection.get(i).getCartTaxes().size() - 1); j >= 0; j--) {
                cartItemCollection.get(i).getCartTaxes().remove(cartItemCollection.get(i).getCartTaxes().get(j));
            }
        }
    }

    @TestVisible
    public void sfFailedcancelDROrder(String drOrderId) {
        try {        
        DCM_HttpClient.Response getOrderResponse = requestService.getOrderRequest(drOrderId).fetch();        
        DRB2B_OrderResponseModel  drOrder = DRB2B_OrderResponseModel.deserializeOrder(getOrderResponse.getBody());       
        cancelDRFailedOrder( JSON.serialize(drOrder));    
        } catch (Exception e) {
            logger.error('sfFailedcancelDROrder::>>' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }


}
