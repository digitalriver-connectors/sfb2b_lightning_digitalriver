global without sharing class DRB2B_CustomerCreditService {
    @TestVisible
    private class CustomerCreditException extends Exception {
    }
    @TestVisible
    private static DRB2B_TransactionPaymentService transactionPaymentService = new DRB2B_TransactionPaymentService();
    @TestVisible
    private static DRB2B_CheckoutServiceImpl checkoutServiceImpl = new DRB2B_CheckoutServiceImpl();
    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();

    global DRB2B_CustomerCreditService() {
    }

    private static final Set<String> CART_FIELDS = new Set<String>{
        'digitalriverv3__DR_Payment_Session_Id__c',
        'digitalriverv3__DR_Checkout_Id__c',
        'digitalriverv3__DR_Amount_Contributed__c',
        'digitalriverv3__DR_Amount_Remaining_to_be_Contributed__c',
        'digitalriverv3__Recurring_Line_Item_Count__c'
    };

    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.Customer_Credit);

    //method will be responsible for create customer credit source and attach to checkout
    @AuraEnabled
    global static Map<String, object> addCustomerCreditSourceToCheckout(string inputData) {
        //missing/invalid parameters  validation
        //amount invalid: “Invalid amount specified
        //If amount specified by client is greater that amountRemainingToBeContributed it will throw error.
        Map<String, object> resultMap = new Map<String, object>();
        try {
            Map<String, Object> data = (Map<String, Object>) json.deserializeUntyped(inputData);

            if (String.isBlank((String) data.get('cartId')) || String.isBlank((String) data.get('amount'))) {
                resultMap.put('isSuccess', false);
                resultMap.put('errorMessage', System.Label.Missing_Invalid_Input_Parameters);
                logger.error(System.Label.Missing_Invalid_Input_Parameters);
                return resultMap;
            }
            if (Decimal.valueOf((String) data.get('amount')) < 0) {
                resultMap.put('isSuccess', false);
                resultMap.put('errorMessage', System.Label.Invalid_Amount);
                logger.error(System.Label.Invalid_Amount);
                return resultMap;
            }

            Id cartId = (Id) data.get('cartId');
            Decimal amount = Decimal.valueOf((String) data.get('amount'));
            String paymentName = (String) data.get('paymentName');

            DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
            WebCart cart = cartSelector.getById(cartId, CART_FIELDS);

            if (amount > cart.digitalriverv3__DR_Amount_Remaining_to_be_Contributed__c) {
                system.debug('amount is greater than required');
                resultMap.put('isSuccess', false);
                resultMap.put('errorMessage', System.Label.Invalid_Amount);
                logger.error(System.Label.Invalid_Amount);
                return resultMap;
            }
            DRB2B_CreateCustomerCreditModel.Request req = new DRB2B_CreateCustomerCreditModel.Request();
            req.amount = amount;
            req.currency1 = DCM_BaseUtilities.getSObjectCurrency(cart);
            req.paymentSessionId = cart.digitalriverv3__DR_Payment_Session_Id__c;
            req.type = 'customerCredit';
            req.customerCredit = new DRB2B_CreateCustomerCreditModel.customerCredit();
            string a = JSON.serialize(req, true).replace('"currency1":', '"currency":');

            logger.debug('Prepared Secondary source request:' + req);

            DCM_HttpClient.Response response = createSecondaryPaymentsource(req, cartId);

            if (response.getStatusCode() == 201) {
                logger.debug('Created Secondary source response:' + response.getBody());
                DRB2B_CreateCustomerCreditModel.Response createCustomerCreditSourceResponse = (DRB2B_CreateCustomerCreditModel.Response) response.asType(
                    DRB2B_CreateCustomerCreditModel.Response.class
                );
                DRB2B_CreateCheckoutResponseModel.Source sourceModelResponse = (DRB2B_CreateCheckoutResponseModel.Source) response.asType(
                    DRB2B_CreateCheckoutResponseModel.Source.class
                );
                String sourceId = createCustomerCreditSourceResponse.id;
                String checkoutId = cart.digitalriverv3__DR_Checkout_Id__c;
                response = attachPaymentToCheckout(checkoutId, sourceId, String.valueOf(cartId));
                //create new firlds on cart for remaining amount and contribbuted amount and populate them
                //Digital River transaction payment
                if (response.getStatusCode() == 200) {
                    resultMap.put('isSuccess', true);
                    resultMap.put('sourceId', sourceId);
                    logger.debug('Attach Source to Checkout response:' + response.getBody());
                    getAmountRemainingforCheckout(inputData);
                    Order sfOrder = checkoutServiceImpl.getOrderWithLines(cartId);
                    List<Sobject> payload = new List<Sobject>();
                    updateSourceIdToCartObject(cartId, sourceId);
                    DR_Transaction_Payment__c transactionPaymentObj = transactionPaymentService.createTrasactionPaymentRecord(
                        sfOrder,
                        sourceModelResponse,
                        cartId
                    );
                    transactionPaymentObj.Display_Name__c = paymentName;
                    DmlManager.insertAsSystem(transactionPaymentObj);
                } else {
                    DRB2B_ErrorResponse errorMessages = (DRB2B_ErrorResponse) response.asType(
                        DRB2B_ErrorResponse.class
                    );
                    resultMap.put('isSuccess', false);
                    resultMap.put('errorMessage', System.Label.DR_API_Error + errorMessages.Errors[0].message);
                    logger.error(System.Label.DR_API_Error + errorMessages.Errors[0].message);
                }
            } else {
                DRB2B_ErrorResponse errorMessages = (DRB2B_ErrorResponse) response.asType(DRB2B_ErrorResponse.class);
                resultMap.put('isSuccess', false);
                resultMap.put('errorMessage', System.Label.DR_API_Error + errorMessages.Errors[0].message);
                logger.error(System.Label.DR_API_Error + errorMessages.Errors[0].message);
            }
        } catch (Exception e) {
            logger.error(e);
            throw new CustomerCreditException(e.getMessage() + ' ' + e.getStackTraceString());
        } finally {
            logger.flush();
        }
        return resultMap;
    }

    //method will be responsible for create customer credit source
    private static DCM_HttpClient.Response createSecondaryPaymentsource(
        DRB2B_CreateCustomerCreditModel.Request req,
        String cartId
    ) {
        DRB2B_RequestService requestService = new DRB2B_RequestService();
        return requestService.createCustomercredit(req, cartId).fetch();
    }

    //method will be responsible for attaching customer credit source ti checkout
    private static DCM_HttpClient.Response attachPaymentToCheckout(String checkoutId, String sourceId, String cartId) {
        DRB2B_RequestService requestService = new DRB2B_RequestService();
        return requestService.attachSourceToCheckout(checkoutId, sourceId, cartId).fetch();
    }

    private static void updateSourceIdToCartObject(Id cartId, String sourceId) {
        logger.info('customerCredit  updateSourceIdToCartObject' + sourceId);
        List<Sobject> payload = new List<Sobject>();
        webcart cart = new webcart();
        cart.Id = cartId;
        cart.digitalriverv3__DR_Source_Id__c = sourceId;
        payload.add(cart);
        logger.info('customerCredit  payload' + payload);
        DMLManager.updateAsSystem(payload);
    }

    // method will be responsible for deattaching source to checkout
    @AuraEnabled
    global static Map<String, object> deattachPaymentToCheckout(String inputData) {
        Map<String, object> resultMap = new Map<String, object>();
        try {
            Map<String, Object> data = (Map<String, Object>) json.deserializeUntyped(inputData);

            String sourceId = (String) data.get('sourceId');

            DRB2B_RequestService requestService = new DRB2B_RequestService();

            if (String.isBlank((String) data.get('cartId')) || String.isBlank(sourceId)) {
                resultMap.put('errorMessage', System.Label.Missing_Invalid_Input_Parameters);
                resultMap.put('isSuccess', false);
                logger.error(System.Label.Missing_Invalid_Input_Parameters);
            } else {
                Id cartId = (Id) data.get('cartId');
                DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
                WebCart cart = cartSelector.getById(cartId, CART_FIELDS);
                String checkoutId = cart.digitalriverv3__DR_Checkout_Id__c;

                DCM_HttpClient.Response response = requestService.deletePaymentSourceFromCheckout(
                        checkoutId,
                        sourceId,
                        cartId
                    )
                    .fetch();

                if (response.getStatusCode() == 204) {
                    resultMap.put('isSuccess', true);
                    //Delete DRpayment transaction record
                    //clear/reset out two field on cart 1)amount contributed and amount remaining to be contributed
                    getAmountRemainingforCheckout(inputData);
                    Boolean isDeleted = transactionPaymentService.deleteDRTransactionPayment(sourceId);
                } else {
                    DRB2B_ErrorResponse errorMessages = (DRB2B_ErrorResponse) response.asType(
                        DRB2B_ErrorResponse.class
                    );
                    resultMap.put('isSuccess', false);
                    resultMap.put('errorMessage', System.Label.DR_API_Error + errorMessages.Errors[0].message);
                    logger.error(System.Label.DR_API_Error + errorMessages.Errors[0].message);
                }
            }
        } catch (exception e) {
            logger.error(e);
            throw new CustomerCreditException(e.getMessage() + ' ' + e.getStackTraceString());
        } finally {
            logger.flush();
        }

        return resultMap;
    }

    // method will be responsible for getting remaining amount Contributed
    @AuraEnabled
    global static Map<String, Object> getAmountRemainingforCheckout(String inputData) {
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Map<String, Object> data = (Map<String, Object>) json.deserializeUntyped(inputData);
            if (String.isBlank((String) data.get('cartId'))) {
                responseMap.put('isSuccess', false);
                responseMap.put('errorMessage', System.Label.Missing_Invalid_Input_Parameters);
                logger.error(System.Label.Missing_Invalid_Input_Parameters);
                return responseMap;
            }
            Id cartId = (Id) data.get('cartId');
            DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
            WebCart cart = cartSelector.getById(cartId, CART_FIELDS);
            logger.info('CustomerCreditservice cart' + json.serialize(cart));
            String checkoutId = cart.digitalriverv3__DR_Checkout_Id__c;
            //String checkoutId = 'e7ff2d1a-cf11-416d-9a54-53d58fd8c3f4';

            DRB2B_CreateCheckoutResponseModel response = DRB2B_CreateCheckoutResponseModel.deserializeCheckout(
                getAmountRemaining(checkoutId, String.valueOf(cartId)).getBody()
            );
            logger.info(
                'CustomerCreditservice cart DRB2B_CreateCheckoutResponseModel response' + json.serialize(response)
            );
            if (response.errors != null) {
                responseMap.put('isSuccess', false);
                responseMap.put(
                    'errorMessage',
                    System.Label.Unable_To_Retrieve_Remaining_Amount + response.Errors[0].message
                );
                logger.error(System.Label.DR_API_Error + response.Errors[0].message);
            } else {
                //stamp amount remaining to be coontributed  and amount contributed on cart
                cart.DR_Amount_Contributed__c = response?.Payment?.session?.amountContributed;
                cart.DR_Amount_Remaining_to_be_Contributed__c = response
                    ?.Payment
                    ?.session
                    ?.amountRemainingToBeContributed;
                if (!isGuestUser) {
                    DmlManager.updateAsUser(cart);
                } else {
                    DmlManager.updateAsSystem(cart);
                }
                responseMap.put('isSuccess', true);
                responseMap.put(
                    'amountRemainingToBeContributed',
                    response.Payment.session.amountRemainingToBeContributed
                );
                responseMap.put('currencyCode', response.drCurrency);
            }
        } catch (exception e) {
            logger.error(e);
            throw new CustomerCreditException(e.getMessage() + ' ' + e.getStackTraceString());
        } finally {
            logger.flush();
        }

        return responseMap;
    }

    private static DCM_HttpClient.Response getAmountRemaining(String checkoutId, String cartId) {
        DRB2B_RequestService requestService = new DRB2B_RequestService();
        return requestService.getCheckoutRequest(checkoutId, cartId).fetch();
    }

    @AuraEnabled
    global static Boolean getCartDetailsById(Id cartId) {
        Boolean isSubscription = false;
        try {
            DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
            WebCart cart = cartSelector.getById(cartId, CART_FIELDS);
            if (cart.digitalriverv3__Recurring_Line_Item_Count__c > 0) {
                isSubscription = true;
            }
        } catch (Exception e) {
            LOGGER.error(e);
            throw new CustomerCreditException(e.getMessage() + ' ' + e.getStackTraceString());
        } finally {
            LOGGER.flush();
        }
        return isSubscription;
    }
}
