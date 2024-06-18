public with sharing class DRB2B_CheckoutSummaryController {
    private static final Set<String> CART_FIELDS = new Set<String>{
        'Id',
        'BillingStreet',
        'BillingCity',
        'BillingState',
        'BillingCountry',
        'BillingPostalCode',
        'Buyer_Email__c',
        'Buyer_Name__c',
        'Buyer_Phone__c',
        'DR_Source_Id__c'
    };

    @TestVisible
    private static DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

    @TestVisible
    private static DRB2B_CartService cartService = new DRB2B_CartService();
    private static DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();

    @AuraEnabled
    public static DRB2B_CartModel getTaxAndFee(Id cartId) {
        DRB2B_CartModel result;

        try {
            result = cartService.getCartTaxAndFee(cartId);
            logger.info('Get tax and Fee' + JSON.serialize(result));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return result;
    }

    @AuraEnabled
    public static DRB2B_CartModel getCartByOrderSummaryId(Id recordId) {
        DRB2B_CartModel cart = new DRB2B_CartModel();

        try {
            cart.wrap(cartSelector.getByOrderSummaryId(recordId, CART_FIELDS));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return cart;
    }

    @AuraEnabled(Cacheable=true)
    public static DRB2B_CartModel getCartById(Id recordId) {
        DRB2B_CartModel cart = new DRB2B_CartModel();

        try {
            cart.wrap(cartSelector.getById(recordId, CART_FIELDS));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return cart;
    }

    @AuraEnabled
    public static void CancelOrder(Id cartId) {

        try {
             cartService.cancelCartSession(cartId);
             logger.debug('cancelOrder calling cancelCartSession' +cartId);
        } catch (Exception e) {
            logger.error('cancelOrder error' +e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }
}
