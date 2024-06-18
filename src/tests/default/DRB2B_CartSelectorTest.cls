@IsTest
private class DRB2B_CartSelectorTest {
    private static final String DR_CHECKOUT_ID = 'f2cd50e5-355d-42d3-8bb7-0c14d8b777e4';
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
            webCart.BillingCountry = 'US';
            if(DRB2B_Utility.isCountryStateEnabled() == true){
                webCart.BillingCountry = 'United States';
            }
            
            webCart.DR_Checkout_Id__c = DR_CHECKOUT_ID;
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
        WebCart cart = [SELECT Id, AccountId FROM WebCart LIMIT 1];
        Test.startTest();
        WebCart retrunedcart = new DRB2B_CartSelector().getById(cart.Id, new Set<String>{ 'Id,AccountId' });
        System.assertEquals(cart.AccountId, retrunedcart.AccountId, 'Account Id dose not match');
        Test.stopTest();
    }

    @isTest
    static void getByForeignKey_Test() {
        WebCart cart = [SELECT Id, AccountId FROM WebCart LIMIT 1];
        Test.startTest();
        List<WebCart> retrunedcart = new DRB2B_CartSelector()
            .getByForeignKey('Id', new Set<String>{ 'Id,AccountId' }, cart.Id);
        System.assertEquals(cart.AccountId, retrunedcart.get(0).AccountId, 'Account Id dose not match');
        Test.stopTest();
    }

    @isTest
    static void getCartWithItemsById_Test() {
        WebCart cart = [SELECT Id, AccountId FROM WebCart LIMIT 1];
        Test.startTest();
        WebCart retrunedcart = new DRB2B_CartSelector()
            .getCartWithItemsById(cart.Id, new List<String>{ 'Id,AccountId' }, new List<String>{ 'Id,CartId' });
        System.assertEquals(cart.AccountId, retrunedcart.AccountId, 'Account Id dose not match');
        Test.stopTest();
    }

    @isTest
    static void getCartItemWithDefaultFieldsById_Test() {
        // Assign DR Admin Permission Set to Portal Account Owner user
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            WebCart cart = [SELECT Id, AccountId, DR_Total_IOR_Tax__c FROM WebCart LIMIT 1];
            Test.startTest();
                List<WebCart> retrunedcart = new DRB2B_CartSelector().getCartItemWithDefaultFieldsById(cart.Id);
                System.assertEquals(cart.Id, retrunedcart.get(0).Id, 'Account Id dose not match');
            Test.stopTest();
        }
    }

    @isTest
    static void getByCheckoutId_Test() {
        WebCart cart = [SELECT Id, AccountId, BillingCountry FROM WebCart LIMIT 1];
        Test.startTest();
        WebCart retrunedcart = new DRB2B_CartSelector().getByCheckoutId(DR_CHECKOUT_ID);
        System.assertEquals(cart.BillingCountry, retrunedcart.BillingCountry, 'Account Id dose not match');
        Test.stopTest();
    }

}