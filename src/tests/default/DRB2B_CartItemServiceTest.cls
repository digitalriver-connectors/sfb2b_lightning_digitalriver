@isTest
private class DRB2B_CartItemServiceTest {

    @TestSetup
    static void setupData() {
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult resultAccount = ATK.prepare(Account.SObjectType, 1)
                .build(EntityBuilderFactory.accountBuilder)
                .save(false);
            Account acc = (Account) resultAccount.get(Account.SObjectType)[0];
            insert acc;

            ATK.SaveResult resultWebStore = ATK.prepare(WebStore.SObjectType, 1)
                .build(EntityBuilderFactory.webStoreBuilder)
                .save(false);
            WebStore store = (WebStore) resultWebStore.get(WebStore.SObjectType)[0];
            insert store;

            ATK.SaveResult resultContact = ATK.prepare(Contact.SObjectType, 1)
                .build(EntityBuilderFactory.contactBuilder)
                .save(false);
            Contact con = (Contact) resultContact.get(Contact.SObjectType)[0];
            con.AccountId = acc.Id;
            insert con;

            ATK.SaveResult result = ATK.prepare(User.SObjectType, 1).build(EntityBuilderFactory.userBuilder).save(false);
            User shopper = (User) result.get(User.SObjectType)[0];
            Profile shopperProfile = [SELECT Id FROM Profile WHERE Name = :DRB2B_Constants.Profile.DR_SHOPPER LIMIT 1];
            shopper.ProfileId = shopperProfile.Id;
            shopper.ContactId = con.Id;
            insert shopper;

            ATK.SaveResult resultCart = ATK.prepare(WebCart.SObjectType, 1)
                .build(EntityBuilderFactory.webCartBuilder)
                .save(false);
            WebCart cart = (WebCart) resultCart.get(WebCart.SObjectType)[0];
            cart.WebStoreId = store.Id;
            cart.AccountId = acc.Id;
            cart.Name = 'Test Cart';
            insert cart;

            ATK.SaveResult resultCartDeliveryGroup = ATK.prepare(CartDeliveryGroup.SObjectType, 1)
                .build(EntityBuilderFactory.cartDeliveryGroupBuilder)
                .save(false);
            CartDeliveryGroup cartDeliveryGroup = (CartDeliveryGroup) resultCartDeliveryGroup.get(
                CartDeliveryGroup.SObjectType
            )[0];
            cartDeliveryGroup.CartId = cart.Id;
            insert cartDeliveryGroup;

            // Create Cart Item
            ATK.SaveResult resultCartItem = ATK.prepare(CartItem.SObjectType, 1)
                .build(EntityBuilderFactory.cartItemBuilder)
                .save(false);
            CartItem cartItemRec = (CartItem) resultCartItem.get(CartItem.SObjectType)[0];
            cartItemRec.CartId = cart.Id;
            cartItemRec.CartDeliveryGroupId = cartDeliveryGroup.Id;
            cartItemRec.Price_Includes_DR_Surcharge__c = true;
            insert cartItemRec;
        }
    }

    @isTest
    static void setTotalPriceExcludingDrSurcharge_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            List<CartItem> cartItemRecs = [
                SELECT Id, TotalPrice, Total_Price_Excluding_DR_Surcharge__c
                    FROM CartItem
                    LIMIT 1
            ];
            DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();
            Test.startTest();
            cartItemRecs.get(0).TotalPrice = 150.00;
            cartItemService.setTotalPriceExcludingDrSurchargeToTotalPrice(cartItemRecs);
            System.assertEquals(
                true,
                cartItemRecs.get(0).TotalPrice == cartItemRecs.get(0).Total_Price_Excluding_DR_Surcharge__c,
                'Total Price Excluding DR Surcharge should match Total Price of Cart Item'
            );
            Test.stopTest();
        }
    }
    
    @isTest
    static void removeLandedCostsAndRegulatoryFeesFromTotalPriceLWR_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            List<CartItem> cartItemRecs = [
                SELECT Id, TotalPrice, Total_Price_Excluding_DR_Surcharge__c
                    FROM CartItem
                    LIMIT 1
            ];
            DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();
            Test.startTest();
            cartItemRecs.get(0).TotalPrice = 150.00;
            webCart cart =[SELECT Id FROM WebCart LIMIT 1];
            set<Id>cartIdSet=new set<Id>();
            cartIdSet.add(cart.Id);
            cartItemService.removeLandedCostsAndRegulatoryFeesFromTotalPriceLWR(cartIdSet);
            System.assertEquals(
                false,
                cartItemRecs.get(0).TotalPrice == cartItemRecs.get(0).Total_Price_Excluding_DR_Surcharge__c,
                'Total Price Excluding DR Surcharge should match Total Price of Cart Item'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void removeLandedCostsAndRegulatoryFeesFromTotalPrice_CartItemDoesNotIncludeSurcharge_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();
            Id cartId = [SELECT id FROM WebCart LIMIT 1][0].Id;
            Test.startTest();
                cartItemService.removeLandedCostsAndRegulatoryFeesFromTotalPrice(new Set<Id>{ cartId });
            Test.stopTest();
            List<CartItem> cartItemRecs = [SELECT Id, Price_Includes_DR_Surcharge__c FROM CartItem LIMIT 1];
            System.assertEquals(
                false,
                cartItemRecs.get(0).Price_Includes_DR_Surcharge__c,
                'Total Price on Cart Item should not include DR Surcharge'
            );
        }
    }

    @isTest
    static void removeLandedCostsAndRegulatoryFeesFromTotalPrice_CartItemIncludesSurcharge_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();
            Id cartId = [SELECT id FROM WebCart LIMIT 1][0].Id;
            List<CartItem> cartItems = [SELECT Id, Price_Includes_DR_Surcharge__c FROM CartItem WHERE CartId = :cartId];
            for (CartItem cartItemRec : cartItems) {
                cartItemRec.Price_Includes_DR_Surcharge__c = true;
            }
            update cartItems;
            Test.startTest();
                cartItemService.removeLandedCostsAndRegulatoryFeesFromTotalPrice(new Set<Id>{ cartId });
            Test.stopTest();

            List<CartItem> cartItemUpdatedRecs = [
                SELECT Id, TotalPrice, Total_Price_Excluding_DR_Surcharge__c, Price_Includes_DR_Surcharge__c
                    FROM CartItem
                    LIMIT 1
            ];
            System.assertEquals(
                false,
                cartItemUpdatedRecs.get(0).Price_Includes_DR_Surcharge__c,
                'Total Price on Cart Item should not include DR Surcharge'
            );
            System.assertEquals(
                true,
                cartItemUpdatedRecs.get(0).TotalPrice == cartItemUpdatedRecs.get(0).Total_Price_Excluding_DR_Surcharge__c,
                'Total Price Excluding DR Surcharge should match Total Price of Cart Item'
            );
        }
    }

}