public with sharing class DRB2B_CancelCheckoutSessionTrigHdlr implements TriggerHandler.Logic {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

    @TestVisible
    private DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();

    @TestVisible
    private DRB2B_RegulatoryFeeSelector feeSelector = new DRB2B_RegulatoryFeeSelector();

    @TestVisible
    private static DRB2B_CartService cartService = new DRB2B_CartService();

    public void execute(List<SObject> records, TriggerContext ctx) {
        LOGGER.info('DRB2B_CancelCheckoutSessionTrigHdlr Cancel Trigger');
        try {
            Set<Id> checkoutCancelledCartIds = new Set<Id>();
            for (CartCheckoutSession cartCheckoutSess : (List<CartCheckoutSession>) records) {
                if (
                    cartCheckoutSess.IsArchived &&
                    ctx.isChangedTo(cartCheckoutSess, CartCheckoutSession.IsArchived, true)
                ) {
                    checkoutCancelledCartIds.add(cartCheckoutSess.WebCartId);
                }
            }

            if (!checkoutCancelledCartIds.isEmpty()) {
                //Update Total Price on Cart Items to remove Landed Costs and Regulatory Fees
                cartItemService.removeLandedCostsAndRegulatoryFeesFromTotalPrice(checkoutCancelledCartIds);
                Set<String> cartIds = (Set<String>) JSON.deserialize(
                    JSON.serialize(checkoutCancelledCartIds),
                    Set<String>.class
                );
                cartService.clearAddress(cartIds);
                /**
                 * Whenever a Shopper cancels an existing checkout, then we need to remove data related to DR from cart
                 */
                cartService.clearDataRelatedToDr(cartIds);
                //Delete transaction payment details
                List<DR_Transaction_Payment__c> transactionDetails = [
                    SELECT Id
                    FROM DR_Transaction_Payment__c
                    WHERE Cart__c IN :cartIds
                ];
                if (!transactionDetails.isEmpty()) {
                    DmlManager.deleteAsUser(transactionDetails);
                }
            }
            Set<Id> cartItemIds = cartItemService.getCartItemIdByCart(checkoutCancelledCartIds);
            // Delete Taxes and fee
            List<CartTax> taxes = [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds];
            if (!taxes.isEmpty()) {
                DmlManager.deleteAsUser(taxes);
            }
            list<DR_Regulatory_Fee__c> fee = feeSelector.getByCartItemId(new Set<String>{ 'Id' }, cartItemIds);

            if (!fee.isEmpty()) {
                LOGGER.info('DRB2B_CancelCheckoutSessionTrigHdlr Delete Fee' + JSON.serialize(fee));
                DmlManager.deleteAsUser(fee);
            }
        } catch (exception e) {
            LOGGER.error(e);
        } finally {
            LOGGER.flush();
        }
    }
}
