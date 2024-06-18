public without sharing class DRB2B_UpdateCheckoutTypeTrigHdlr implements TriggerHandler.Logic {
    public static Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
    DCM_Logger logger = DCM_Logger.getInstance();
    DRB2B_CartService cartService = new DRB2B_CartService();

    // public List<SObject> filter(List<SObject> records, TriggerContext ctx) {
    //     return records;
    // }

    public void execute(List<SObject> records, TriggerContext ctx) {
        DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
        try {
            updateType((list<cartItem>) records);
        } catch (exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
    }

    // public void execute(List<SObject> records, QueueableContext ctx) {
    //     try {
    //         updateType((list<CartItem>) records);
    //     } catch (exception e) {
    //         logger.error(e);
    //     } finally {
    //         logger.flush();
    //     }
    // }

    private void updateType(List<cartItem> records) {
        Set<Id> CartIds = (Set<Id>) Collection.of(records).setOf('cartId');
        Map<String, String> checkoutTypesByCartIds = cartService.getCheckoutType(CartIds);
        Set<WebCart> cartSet = new Set<WebCart>();
        for (cartItem item : records) {
            WebCart wCart = new WebCart(
                DR_Checkout_Type__c = checkoutTypesByCartIds.get(item.CartId),
                Id = item.CartId
            );
            cartSet.add(wCart);
        }
        logger.info('wCart ' + cartSet);
        if(!isGuestUser) {
            DmlManager.updateAsUser(new List<WebCart>(cartSet));
        }
        else {
            DmlManager.updateAsSystem(new List<WebCart>(cartSet));
        }
    }
}
