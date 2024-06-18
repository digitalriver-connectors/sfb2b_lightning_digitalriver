public with sharing class DRB2B_AddressDetailsController {

    @TestVisible
    private static final DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();

    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance();

    private static final List<String> CART_FIELDS = new List<String>{
        'DR_Checkout_Type__c'
    };

    private static final List<String> CART_ITEMS_FIELDS = new List<String>{
        'CartDeliveryGroup.DeliverToCountry',
        'CartDeliveryGroup.DeliverToState',
        'CartDeliveryGroup.DeliverToPostalCode',
        'CartDeliveryGroup.DeliverToCity',
        'CartDeliveryGroup.DeliverToStreet'
    };

    @AuraEnabled
    public static String getAddressesDetails(Id CartId) {
        String result;
        
        try {
            Map<String, object> response = new Map<String, object>();
            WebCart cart = cartSelector.getCartWithItemsById(cartId, CART_FIELDS, CART_ITEMS_FIELDS);
            CartDeliveryGroup deliveryGroup = (CartDeliveryGroup) cart.CartItems.get(0).getSObject(CartItem.CartDeliveryGroupId);
            response.put(
                'billingAddress', cartSelector.getById(CartId, new Set<String>{ 'BillingAddress' })?.BillingAddress
            );
            response.put(
                'shippingAddress', deliveryGroup
            );

            result = JSON.serialize(response);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
}
