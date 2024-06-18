public without sharing class DRB2B_CartSelector {
    public WebCart getById(Id cartId, Set<String> fields) {
        return (WebCart) new DCM_Query('WebCart')
            .selectFields(new List<String>(fields))
            .addConditionEq('Id', cartId)
            .run()[0];
    }

    public list<WebCart> getByForeignKey(String foreignKey, Set<String> fields, String foreignValue) {
        return (list<WebCart>) new DCM_Query('WebCart')
            .selectFields(new List<String>(fields))
            .addConditionEq(foreignKey, foreignValue)
            .run();
    }

    public WebCart getCartWithItemsById(String cartId, List<String> cartFields, List<String> cartItemFields) {
        return getCartWithItemsByIds(new Set<String>{ cartId }, cartFields, cartItemFields).get(0);
    }

    public List<WebCart> getCartWithItemsByIds(
        Set<String> cartId,
        List<String> cartFields,
        List<String> cartItemFields
    ) {
        return (List<WebCart>) new DCM_Query('WebCart')
            .selectFields(cartFields)
            .addSubquery('CartItems', cartItemFields)
            .addConditionEq('Id', cartId)
            .debug()
            .setLimit(2000)
            .run();
    }

    public List<WebCart> getCartItemWithDefaultFieldsById(String cartId) {
        return getCartWithItemsByIds(
            new Set<String>{ cartId },
            new List<String>{
                'DR_Total_IOR_Tax__c',
                'DR_Total_Duty__c',
                'DR_Total_Fees__c',
                'GrandTotalAmount',
                'TotalAmount'
            },
            new List<String>{ 'Sku', 'TotalAmount' }
        );
    }

    public WebCart getByCheckoutId(String checkoutId) {
        return (WebCart) new DCM_Query('WebCart')
            .selectField(WebCart.BillingStreet)
            .selectField(WebCart.BillingCity)
            .selectField(WebCart.BillingPostalCode)
            .selectField(WebCart.BillingCountry)
            .selectField(WebCart.BillingState)
            .addConditionEq(WebCart.DR_Checkout_Id__c, checkoutId)
            .run()[0];
    }

    public WebCart getByOrderSummaryId(Id orderSummaryId, Set<String> fields) {
        OrderSummary orderSummary = [
            SELECT Id, OriginalOrderId
            FROM OrderSummary
            WHERE Id = :orderSummaryId
            WITH SECURITY_ENFORCED
        ];

        CartCheckoutSession cartCheckoutSession = [
            SELECT Id, WebCartId
            FROM CartCheckoutSession
            WHERE OrderId = :orderSummary.OriginalOrderId AND IsArchived = FALSE
            WITH SECURITY_ENFORCED
        ];

        return (WebCart) new DCM_Query('WebCart')
            .selectFields(fields)
            .addConditionEq('Id', cartCheckoutSession.WebCartId)
            .run()
            .get(0);
    }
    public String getBySfOrderId(String sfOrderId) {
        String webCartId = [SELECT WebCartId FROM CartCheckoutSession WHERE OrderId = :sfOrderId AND IsArchived = FALSE]
        .WebCartId;

        return webCartId;
    }
}
