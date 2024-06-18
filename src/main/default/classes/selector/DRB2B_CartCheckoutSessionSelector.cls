public with sharing class DRB2B_CartCheckoutSessionSelector {
 

    public CartCheckoutSession getActiveSessionForCart(String cartID,Set<String> fields) {
        return (CartCheckoutSession) new DCM_Query('CartCheckoutSession')
            .selectFields(new List<String>(fields))
            .addConditionEq('IsArchived', false)
            .addConditionEq('webCartId', cartID)
            .run()[0];
    }

    public List<CartCheckoutSession> getListOfActiveSessionForCart(List<String> cartIDs,Set<String> fields) {
        return (List<CartCheckoutSession>) new DCM_Query('CartCheckoutSession')
            .selectFields(new List<String>(fields))
            .addConditionEq('IsArchived', false)
            .addConditionIn('webCartId', cartIDs)
            .run();
    }


    

}


