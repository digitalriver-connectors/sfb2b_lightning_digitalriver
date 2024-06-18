public without sharing class DRB2B_CartTaxService {
    @TestVisible
    private DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.APP_CONFIG); //TODO:UPDATE MODULE

    @TestVisible
    private static final String ITEM_TYPE = 'CHARGE';

    public static Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();

    public DRB2B_CartTaxService() {
    }

    public void updateCartTax(DRB2B_CreateCheckoutResponseModel response) {
        
        Map<String, DRB2B_CreateCheckoutResponseModel.Item> itemMap = new Map<String, DRB2B_CreateCheckoutResponseModel.Item>();
        for (DRB2B_CreateCheckoutResponseModel.Item item : response.items) {
            itemMap.put(item.skuId, item);
        }
        List<CartTax> cartTaxList = new List<CartTax>();
        for (cartTax tax : [
            SELECT Id, Amount, DR_Duty__c, DR_IOR_Tax__c, DR_Regulatory_Fee__c, CartItem.product2Id, CartItem.Type
            FROM CartTax
            WHERE CartId = :response.upstreamId
        ]) {
            if (!tax.CartItem.Type.equalsIgnoreCase(ITEM_TYPE)) {
                logger.debug('DRB2B_CartTaxService In updateCartTax' + tax.CartItem.Type);
                tax.Amount =
                    itemMap.get(tax.CartItem.product2Id).tax.amount +
                    itemMap.get(tax.CartItem.product2Id).fees.taxAmount;
                tax.DR_Duty__c = itemMap.get(tax.CartItem.product2Id).duties.amount;
                tax.DR_IOR_Tax__c = itemMap.get(tax.CartItem.product2Id).importerTax.amount;
                tax.DR_Regulatory_Fee__c = itemMap.get(tax.CartItem.product2Id).fees.amount;
                cartTaxList.add(tax);
            } else {
                logger.debug('DRB2B_CartTaxService In updateCartTax' + tax.CartItem.Type);
                if (response.shippingChoice != null) {
                    tax.Amount = response.shippingChoice.taxAmount;
                    cartTaxList.add(tax);
                }
            }
        }
        logger.info('DRB2B_CartTaxService updated cartItems with new tax ' + JSON.serialize(cartTaxList));
        if (!isGuestUser) {
            DMLManager.updateAsUser(cartTaxList);
        } else {
            DmlManager.updateAsSystem(cartTaxList);
        }
    }
}
