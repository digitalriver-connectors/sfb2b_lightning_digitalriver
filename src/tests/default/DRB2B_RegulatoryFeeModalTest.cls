@ISTest
private class DRB2B_RegulatoryFeeModalTest {
    private static final String DR_CHECKOUT_ID = 'f2cd50e5-355d-42d3-8bb7-0c14d8b777e4';
    private static final String DR_PAYMENT_SESSION_ID = '897eeaa3-ac2d-411f-9211-b7686b51a18d';
    private static final String DR_REG_FEE_BATTERY_TYPE = 'battery';
    private static final String DR_REG_FEE_ID = 'asdkj1h239lkj123j9123';
    private static final String CREATED = 'Created';
    private static final String SOURCE_ID = 'Source_Id';
    @TestSetup
    static void setup() {
        DRB2B_TestEnvironment.prepareStoreWithNonDigitalCart();
    }

    @IsTest
    static void createCheckout_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
                .field(WebCart.DR_Checkout_Id__c)
                .repeat(DR_CHECKOUT_ID)
                .field(WebCart.DR_Payment_Session_Id__c)
                .repeat(DR_PAYMENT_SESSION_ID)
                .withChildren(CartItem.SObjectType, CartItem.CartId, 2)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .also()
                .withChildren(CartItem.SObjectType, CartItem.CartId, 1)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.Type)
                .repeat('Charge')
                .field(CartItem.Sku)
                .repeat('Charge {0000}')
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .withChildren(CartTax.SObjectType, CartTax.CartItemId, 2)
                .build(EntityBuilderFactory.cartTaxBuilder)
                .field(CartTax.Amount)
                .repeat(5.00)
                .field(CartTax.TaxRate)
                .repeat(1.00)
                .field(CartTax.DR_Regulatory_Fee__c)
                .repeat(5.00)
                .field(CartTax.DR_IOR_Tax__c)
                .repeat(5.00)
                .field(CartTax.DR_Duty__c)
                .repeat(5.00)
                .save();
            CartItem cartItem = [SELECT Id FROM CartItem LIMIT 1];
            ATK.SaveResult result = ATK.prepare(DR_Regulatory_Fee__c.SObjectType, 2)
                .build(EntityBuilderFactory.regulatoryFeeBuilder)
                .save(false);

            DR_Regulatory_Fee__c drRegulatoryFee = (DR_Regulatory_Fee__c) result.get(
                DR_Regulatory_Fee__c.SobjectType
            )[0];
            drRegulatoryFee.Amount__c = 5.00;
            drRegulatoryFee.Per_Unit_Amount__c = 5.00;
            drRegulatoryFee.Fee_Type__c = 'battery';
            drRegulatoryFee.Fee_Id__c = 'asdkj1h239lkj123j9123';
            drRegulatoryFee.Cart_Item_Id__c = cartItem.Id;
            insert drRegulatoryFee;
            // When
            Test.startTest();
            DRB2B_RegulatoryFeeModal regulatoryFees = new DRB2B_RegulatoryFeeModal();
            DRB2B_RegulatoryFeeModal regulatoryFee = new DRB2B_RegulatoryFeeModal(drRegulatoryFee);
            regulatoryFee.wrap(drRegulatoryFee);
            DRB2B_RegulatoryFeeModal.DRB2B_RegulatoryFeeModalFactory regulatoryFeeFactory = new DRB2B_RegulatoryFeeModal.DRB2B_RegulatoryFeeModalFactory();
            regulatoryFeeFactory.wrap(drRegulatoryFee);
            System.assertEquals(drRegulatoryFee.Amount__c, regulatoryFee.amount);
            Test.stopTest();
        }
    }
}
