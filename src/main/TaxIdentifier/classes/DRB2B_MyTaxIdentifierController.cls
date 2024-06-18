public with sharing class DRB2B_MyTaxIdentifierController {
    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.APP_CONFIG);

    @TestVisible
    private static final DRB2B_TaxIdentifierService taxIdentifier = new DRB2B_TaxIdentifierService();

    @TestVisible
    private static final DRB2B_CustomerService customerService = new DRB2B_CustomerService();

    @TestVisible
    private static final DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();

    @TestVisible
    private static final DRB2B_CartService cartService = new DRB2B_CartService();

    @TestVisible
    private static DRB2B_CheckoutService checkoutService = new DRB2B_CheckoutServiceImpl();

    //save tax id and link to customer
    @AuraEnabled
    public static String createTaxIdentifier(String jsonString, String cartId) {
        String result;
        try {
            result = JSON.serialize(taxIdentifier.saveTaxIdentifier(jsonString, cartId));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    //save tax id to DR without linking to customer
    @AuraEnabled
    public static String saveTaxIdentifier(String jsonString, String cartId) {
        String result;
        try {
            result = JSON.serialize(taxIdentifier.createTaxIdentifier(jsonString, cartId));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static String getTaxIdentifier(String cartId) {
        String result;
        try {
            result = JSON.serialize(customerService.getById(UserInfo.getUserId(), cartId));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static Boolean deleteTaxIdentifier(string taxId, String cartId) {
        Boolean result = false;
        try {
            result = taxIdentifier.deleteTaxIdentifier(taxId, cartId);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static String applyTaxIdenifier(String checkoutId, List<String> taxIds, String cartId) {
        String result;
        try {
            result = JSON.serialize(taxIdentifier.attachTaxId(checkoutId, taxIds, cartId));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
    @AuraEnabled
    public static String updateDRRemainingField(String cartId) {
        String result;
        try {
            
                DRB2B_RequestService requestService = new DRB2B_RequestService();
                DRB2B_CheckoutService checkoutService = new DRB2B_CheckoutServiceImpl();
                DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
                WebCart cart = cartSelector.getCartWithItemsById(
                    cartId,
                    new List<String>{ 'Id', 'DR_Checkout_Id__c', 'DR_Checkout_Type__c' },
                    new List<String>{ 'Id', 'Name', 'Product2Id', 'Type' }
                );
            
                DCM_HttpClient.Response getCheckoutResponse = requestService.getCheckoutRequest(cart.DR_Checkout_Id__c, String.valueOf(cartId)).fetch();
        
                if (isValidStatusCode(getCheckoutResponse)) {
                    DRB2B_CreateCheckoutResponseModel checkout = DRB2B_CreateCheckoutResponseModel.parse(
                        getCheckoutResponse.getBody()
                    );
                    Map<String, CartItem> cartItemsBySkuIds = (Map<String, CartItem>) Collection.of(cart.CartItems)
                    .mapBy('Product2Id', String.class);
                    checkoutService.recalculateTaxesAndFees(cart, cartItemsBySkuIds, checkout);
                }else {
                    throw new CheckoutServiceException(
                        'There is an issue while getting Digital River Checkout record. Please, contact your System Administrator.'
                    );
                }
            result = 'SUCCESS';
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    public inherited sharing class CheckoutServiceException extends Exception {
    }

    static Boolean isValidStatusCode(DCM_HttpClient.Response createOrderResponse) {
        return createOrderResponse.getStatusCode() >= 200 && createOrderResponse.getStatusCode() < 300;
    }

    @AuraEnabled
    public static DRB2B_CartModel getCart(Id cartId) {

        DRB2B_CartModel result;
        try {
            Webcart cart = cartSelector.getById(
                cartId,
                new Set<String>{
                    'DR_Payment_Session_Id__c',
                    'DR_Checkout_Id__c',
                    'DR_Checkout_Type__c',
                    'BillingAddress',
                    'DR_Customer_Type__c'
                }
            );
            result = cartService.getCartAsWrapper(cart);
            result.shipCountry = [SELECT DeliverToCountry, Id FROM CartDeliveryGroup WHERE CartId = :cartId]
            ?.DeliverToCountry; //TODO :need to replace with selector class and queryframework
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return result;
    }
}