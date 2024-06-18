@isTest
public with sharing class DRB2B_UpdateCheckoutTypeTrigHdlrTest {
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

            result = ATK.prepare(ContactPointAddress.SObjectType, 1)
                .build(EntityBuilderFactory.contactPointAddressBuilder)
                .save(false);
            ContactPointAddress conPointAddress = (ContactPointAddress) result.get(ContactPointAddress.SObjectType)[0];
            conPointAddress.ParentId = acc.id;
            insert conPointAddress;

            result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);
            WebStore store = (WebStore) result.get(WebStore.SObjectType)[0];
            insert store;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);
            Product2 product1 = (Product2) result.get(Product2.SObjectType)[0];
            insert product1;

            result = ATK.prepare(Digital_River_Tax_Mapping__c.SObjectType, 1)
                .build(EntityBuilderFactory.drTaxMappingBuilder)
                .save(false);
            Digital_River_Tax_Mapping__c drTaxMapping = (Digital_River_Tax_Mapping__c) result.get(
                Digital_River_Tax_Mapping__c.SObjectType
            )[0];
            insert drTaxMapping;
        }
    }

    @IsTest
    static void updateCheckoutType() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.SaveResult result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
            cart.WebStoreId = [SELECT id FROM WebStore]?.Id;
            cart.AccountId = [SELECT id FROM Account]?.Id;
            insert cart;

            result = ATK.prepare(CartDeliveryGroup.SObjectType, 1).build(EntityBuilderFactory.cartDeliveryGroupBuilder).save(false);
            CartDeliveryGroup cartDeliveryGroup  = (CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
            cartDeliveryGroup.CartId = cart.Id;
            insert cartDeliveryGroup;

            Product2 product1 = [Select Id from Product2 Limit 1][0];

            Test.startTest();
                result = ATK.prepare(CartItem.SObjectType, 1).build(EntityBuilderFactory.cartItemBuilder).save(false);
                CartItem cartItem  = (CartItem) result.get(CartItem.SObjectType)[0];
                cartItem.CartId = cart.Id;
                cartItem.Product2Id = product1.Id;
                cartItem.CartDeliveryGroupId = cartDeliveryGroup.Id;
                insert cartItem;
            Test.stopTest();
       
            WebCart updatedCart = [Select Id,DR_Checkout_Type__c from WebCart where Id = :cart.Id];
            system.assertEquals('Digital', updatedCart.DR_Checkout_Type__c);
        }
    }

}
