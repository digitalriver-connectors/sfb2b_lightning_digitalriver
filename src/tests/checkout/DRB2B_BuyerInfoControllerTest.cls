@isTest
private with sharing class DRB2B_BuyerInfoControllerTest {

    @TestSetup
    static void setupData() {
        ATK.SaveResult result;
        Account acc;
        WebStore store;
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            result = ATK.prepare(Account.SObjectType, 1)
                                        .build(EntityBuilderFactory.accountBuilder)
                                        .save(false);
            acc = (Account) result.get(Account.SObjectType)[0];
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
            store = (WebStore) result.get(WebStore.SObjectType)[0];
            insert store;

            
        }
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
            cart.WebStoreId = store.Id;
            cart.AccountId = acc.Id;
            cart.Name = 'Cart';
            insert cart;
        }
        
    }

    @isTest
    static void getAddressTest() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            //create cart as community user context
            ATK.SaveResult cartResult = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) cartResult.get(WebCart.SObjectType)[0];
            cart.WebStoreId = [SELECT id FROM WebStore]?.Id;
            cart.AccountId = [SELECT id FROM Account]?.Id;
            cart.Id = [SELECT Id FROm webCart LIMIT 1].Id;

            Map<String, String> addressMap = (Map<String, String>) JSON.deserialize(
                DRB2B_BuyerInfoController.getAddresses(cart.Id),
                Map<String, String>.class
            );
            system.assert(addressMap.get('contactPointAddress') != null);
        }
    }

    @isTest
    static void updateCartTest() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            WebCart cart = [SELECT Id FROM Webcart LIMIT 1];
            cart.DR_Checkout_Type__c = 'Digital';
            DRB2B_BuyerInfoController.updateCart(JSON.serialize(cart));
            system.assertEquals('Digital', [SELECT Id, DR_Checkout_Type__c FROM webCart LIMIT 1]?.DR_Checkout_Type__c);
        }
    }
    
        
    @isTest
    static void getCartTest() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
           String cartId = DRB2B_BuyerInfoController.getCartId();
           Assert.isNotNull(cartId, 'CartId Should Not Null');
        }
    }
    
    @isTest
    static void updateCartDeliveryGroupTestPositive() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
           String cartId = DRB2B_BuyerInfoController.getCartId();
           CartDeliveryGroup cartDeliveryGroupRecord = new CartDeliveryGroup();
            cartDeliveryGroupRecord.CartId = cartId;
            cartDeliveryGroupRecord.Name = 'Cart Delivery Group';
            cartDeliveryGroupRecord.DeliverToCountry = 'US';
            cartDeliveryGroupRecord.DeliverToState = 'CA';
            cartDeliveryGroupRecord.DeliverToCity = 'Goleta';
            if(DRB2B_Utility.isCountryStateEnabled() == true){
                cartDeliveryGroupRecord.DeliverToCountry = 'United States';
                cartDeliveryGroupRecord.DeliverToState = 'California';
            }
            Insert cartDeliveryGroupRecord;
           Assert.isNotNull(cartId, 'CartId Should Not Null');
           String updateCartDeliveryGroup = JSON.serialize(cartDeliveryGroupRecord);
           DRB2B_BuyerInfoController.updateCartDeliveryGroup(updateCartDeliveryGroup);
        }
    }
    
    @isTest
    static void updateCartDeliveryGroupTestNegative() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
           String cartId = DRB2B_BuyerInfoController.getCartId();
           CartDeliveryGroup cartDeliveryGroupRecord = new CartDeliveryGroup();
           cartDeliveryGroupRecord.CartId = cartId;
           cartDeliveryGroupRecord.Name = 'Cart Delivery Group';
            cartDeliveryGroupRecord.DeliverToCountry = 'US';
                cartDeliveryGroupRecord.DeliverToState = 'CA';
             if(DRB2B_Utility.isCountryStateEnabled() == true){
                cartDeliveryGroupRecord.DeliverToCountry = 'United States';
                cartDeliveryGroupRecord.DeliverToState = 'California';
            }
            Insert cartDeliveryGroupRecord;
           Assert.isNotNull(cartId, 'CartId Should Not Null');
           String updateCartDeliveryGroup = JSON.serialize(cartDeliveryGroupRecord);
           DRB2B_BuyerInfoController.updateCartDeliveryGroup(updateCartDeliveryGroup);
        }
    }

@isTest
    static void startTaxCalcTest() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        String cartId = DRB2B_BuyerInfoController.getCartId();
        DRB2B_BuyerInfoController.getcountryPicklistIsEnabled();
        DRB2B_BuyerInfoController.startTaxCalc(cartId); 
        }

    }

}