@IsTest
private class DRB2B_CartItemSelectorTest {
    @TestSetup
    static void setupData() {
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult resultAccount = ATK.prepare(Account.SObjectType, 1)
                .build(EntityBuilderFactory.accountBuilder)
                .save(false);
            Account acc = (Account) resultAccount.get(Account.SObjectType)[0];
            insert acc;

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

            result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);

            WebStore webStore = (WebStore) result.get(WebStore.SObjectType)[0];
            insert webStore;

            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            insert priceBook;

            result = ATK.prepare(ContactPointAddress.SObjectType, 1)
                .build(EntityBuilderFactory.contactPointAddressBuilder)
                .save(false);

            ContactPointAddress conPointAddress = (ContactPointAddress) result.get(ContactPointAddress.SObjectType)[0];
            insert conPointAddress;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            insert product;

            result = ATK.prepare(PricebookEntry.SObjectType, 1)
                .build(EntityBuilderFactory.pricebookEntryBuilder)
                .save(false);

            PricebookEntry standardPriceBookEntry = (PricebookEntry) result.get(PricebookEntry.SObjectType)[0];
            standardPriceBookEntry.Pricebook2Id = Test.getStandardPricebookId();
            standardPriceBookEntry.Product2Id = product.Id;
            standardPriceBookEntry.UnitPrice = 20;
            insert standardPriceBookEntry;

            ATK.SaveResult resultP = ATK.prepare(PricebookEntry.SObjectType, 1)
                .build(EntityBuilderFactory.pricebookEntryBuilder)
                .save(false);

            PricebookEntry priceBookEntry = (PricebookEntry) resultP.get(PricebookEntry.SObjectType)[0];
            priceBookEntry.Pricebook2Id = priceBook.Id;
            priceBookEntry.Product2Id = product.Id;
            priceBookEntry.UnitPrice = 20.99;
            insert priceBookEntry;

            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);

            WebCart webCart = (WebCart) result.get(WebCart.SObjectType)[0];
            webCart.AccountId = acc.Id;
            webcart.webStoreId = webStore.Id;
            insert WebCart;

            result = ATK.prepare(CartDeliveryGroup.SObjectType, 1)
                .build(EntityBuilderFactory.cartDeliveryGroupBuilder)
                .save(false);
            CartDeliveryGroup deliveryGroup = (CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
            deliveryGroup.CartId = webCart.Id;
            insert deliveryGroup;

            result = ATK.prepare(CartItem.SObjectType, 1).build(EntityBuilderFactory.cartItemBuilder).save(false);

            CartItem carItem = (CartItem) result.get(CartItem.SObjectType)[0];
            carItem.CartId = webCart.Id;
            carItem.Product2Id = product.Id;
            carItem.CartDeliveryGroupId = deliveryGroup.Id;
            insert carItem;
        }
    }

    @isTest
    static void getById_Test() {
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        CartItem cartItem = [SELECT Id, cartId FROM CartItem WHERE cartId = :cart.id];
        Test.startTest();
            CartItem cartItemReturned = new DRB2B_CartItemSelector().getById(cartItem.Id, new Set<String>{ 'Id,CartId' });
            System.assertEquals(cart.Id, cartItemReturned.CartId, 'Cart Id dose not match');
        Test.stopTest();
    }

    @isTest
    static void getByForeignKey_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        CartItem cartItem = [SELECT Id, cartId FROM CartItem WHERE cartId = :cart.id];
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
                List<CartItem> cartItemReturned = new DRB2B_CartItemSelector()
                    .getByForeignKey(
                        'CartId',
                        new Set<String>{
                            'Product2.DR_TAXGROUP__c',
                            'Product2.DR_TAXTYPE__c',
                            'CartId',
                            'Cart.DR_Checkout_Type__c'
                        },
                        new Set<id>{ cart.id }
                    );
                System.assertEquals(cart.Id, cartItemReturned.get(0).CartId, 'Cart Id should match');
            Test.stopTest();
        }
    }

}