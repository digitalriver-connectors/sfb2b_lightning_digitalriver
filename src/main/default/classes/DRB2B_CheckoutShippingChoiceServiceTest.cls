@IsTest
public with sharing class DRB2B_CheckoutShippingChoiceServiceTest {
    @TestSetup
    static void setupData() {
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
        ATK.SaveResult result = ATK.prepare(Account.SObjectType, 1)
            .build(EntityBuilderFactory.accountBuilder)
            .save(false);
        Account acc = (Account) result.get(Account.SObjectType)[0];
        insert acc;

        result = ATK.prepare(Contact.SObjectType, 1).build(EntityBuilderFactory.contactBuilder).save(false);
        Contact con = (Contact) result.get(Contact.SObjectType)[0];
        con.AccountId = acc.Id;
        insert con;

        result = ATK.prepare(User.SObjectType, 1).build(EntityBuilderFactory.userBuilder).save(false);
        User shopper = (User) result.get(User.SObjectType)[0];
        Profile shopperProfile = [SELECT Id FROM Profile WHERE Name = :DRB2B_Constants.Profile.DR_SHOPPER LIMIT 1];
        shopper.ProfileId = shopperProfile.Id;
        shopper.ContactId = con.Id;
        insert shopper;

        result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);
        WebStore store = (WebStore) result.get(WebStore.SObjectType)[0];
        insert store;

        result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
        WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
        cart.WebStoreId = store.Id;
        cart.AccountId = acc.Id;
        insert cart;

        result = ATK.prepare(CartDeliveryGroup.SObjectType, 1)
            .build(EntityBuilderFactory.cartDeliveryGroupBuilder)
            .save(false);
        CartDeliveryGroup deliveryGroup = (CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
        deliveryGroup.CartId = cart.Id;
        insert deliveryGroup;
        }
    }

    @isTest
    static void getShippingChoiceInfo_Test() {
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(shopper) {
            WebCart cart = [SELECT Id from WebCart LIMIT 1];
            CartDeliveryGroup cartDeliveryGroup = [SELECT id FROM CartDeliveryGroup LIMIT 1];
            DRB2B_CheckoutShippingChoiceService checkoutShippingChoiceService = new DRB2B_CheckoutShippingChoiceService();
            DRB2B_CheckoutContext checkoutContext = new DRB2B_CheckoutContext();
            checkoutContext.cartId = cart.Id;
            DRB2B_ShippingChoiceInfo shippingData = checkoutShippingChoiceService.getShippingChoiceInfo(checkoutContext);
            System.assertNotEquals(null, shippingData);
        }

    }
}
