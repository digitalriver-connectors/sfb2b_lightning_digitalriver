@isTest
private class DRB2B_CustomCartToOrder_Test {
    private static final String DR_ORDER_ID = '190296100336';

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

            result = ATK.prepare(Digital_River_Tax_Mapping__c.SObjectType, 1)
                .build(EntityBuilderFactory.drTaxMappingBuilder)
                .save(false);
            Digital_River_Tax_Mapping__c digitalRiverTaxMapping = (Digital_River_Tax_Mapping__c) result.get(
                Digital_River_Tax_Mapping__c.SObjectType
            )[0];
            insert digitalRiverTaxMapping;

            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
            cart.WebStoreId = [SELECT id FROM WebStore]?.Id;
            cart.AccountId = [SELECT id FROM Account]?.Id;
            cart.DR_Checkout_Type__c = 'Non-Digital';
            cart.DR_Source_Id__c = '123231132232321232';
            cart.Has_Landed_Cost__c = true;
            insert cart;

            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            priceBook.Name = 'PriceBook-Name';
            insert priceBook;

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = cart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            sfOrder.Name = 'OrderRecord';
            sfOrder.OrderReferenceNumber = DR_ORDER_ID;
            insert sfOrder;

            CartCheckoutSession cartCheckOutSession = new CartCheckoutSession();
            cartCheckOutSession.WebCartId = cart.Id;
            cartCheckOutSession.OrderId = sfOrder.Id;
            cartCheckOutSession.State = 'Cancel Session';
            cartCheckOutSession.Name = 'Test';
            insert cartCheckOutSession;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);
            Product2 Product = (Product2) result.get(Product2.SObjectType)[0];
            Product.Name = 'Sort Material';
            Product.DR_TAXGROUP__c = 'Downloadable Goods (Non-Software)';
            Product.DR_TAXTYPE__c = 'Digital Image';
            insert Product;

            result = ATK.prepare(CartDeliveryGroup.SObjectType, 1)
                .build(EntityBuilderFactory.cartDeliveryGroupBuilder)
                .save(false);
            CartDeliveryGroup cartDeliveryGroup = (CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
            cartDeliveryGroup.CartId = cart.Id;
            cartDeliveryGroup.DesiredDeliveryDate = System.now() + 1;
            cartDeliveryGroup.DeliverToName = 'Deliver To Customer';
            cartDeliveryGroup.ShippingInstructions = 'Nothing';
            cartDeliveryGroup.DeliverToStreet = 'xyz street';
            cartDeliveryGroup.DeliverToCity = 'Eagan';
            cartDeliveryGroup.DeliverToState = 'MN';
            cartDeliveryGroup.DeliverToPostalCode = '55344';
            cartDeliveryGroup.DeliverToCountry = 'US';
            //cartDeliveryGroup.DeliveryMethodI = dm.Id;

            if (DRB2B_Utility.isCountryStateEnabled() == true) {
                cartDeliveryGroup.DeliverToCountry = 'United States';
                cartDeliveryGroup.DeliverToState = 'Minnesota';
            }
            insert cartDeliveryGroup;

            orderDeliveryGroup oDG = new orderDeliveryGroup();
            //oDG.CartId = cart.Id;
            //oDG. = System.now()+1;
            oDG.DeliverToName = 'Deliver To Customer';
            oDG.DeliveryInstructions = 'Nothing';
            oDG.DeliverToStreet = 'xyz street';
            oDG.DeliverToCity = 'Eagan';
            oDG.DeliverToState = 'MN';
            oDG.DeliverToPostalCode = '55344';
            oDG.DeliverToCountry = 'US';
            oDG.OrderId = sfOrder.Id;
            if (DRB2B_Utility.isCountryStateEnabled() == true) {
                oDG.DeliverToCountry = 'United States';
                oDG.DeliverToState = 'Minnesota';
            }
            insert oDG;

            result = ATK.prepare(CartItem.SObjectType, 1).build(EntityBuilderFactory.cartItemBuilder).save(false);
            CartItem cartItem = (CartItem) result.get(CartItem.SObjectType)[0];
            cartItem.CartId = cart.Id;
            cartItem.Product2Id = Product.Id;
            cartItem.CartDeliveryGroupId = cartDeliveryGroup.Id;
            insert cartItem;

            result = ATK.prepare(CartTax.SObjectType, 1).build(EntityBuilderFactory.cartTaxBuilder).save(false);
            CartTax cartTax = (CartTax) result.get(CartTax.SObjectType)[0];
            cartTax.CartItemId = cartItem.Id;
            cartTax.DR_IOR_Tax__c = 5.00;
            cartTax.DR_Duty__c = 2.00;
            cartTax.TaxType = 'Actual';
            cartTax.TaxRate = 7.00;
            cartTax.TaxCalculationDate = Date.today();
            cartTax.DR_Regulatory_Fee__c = 2.00;
            insert cartTax;
        }
    }

    /*  @isTest
    public static void customCreatCartToOrderTest() {
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        
        System.runAs(shopper) {
            String cartId = [SELECT Id FROM WebCart]?.Id;
            CartCheckoutSession session = [Select ID, OrderId FROM CartCheckoutSession WHERE WebCartId =: cartId ];
            
            Test.startTest();
            CartCheckoutSession checkoutSession = DRB2B_CustomCartToOrder.getOrderIdFromCheckoutSession(cartId);
            
            system.assertEquals(checkoutSession.OrderId, session.OrderId);
            Test.stopTest();
        }
    }

    */

    @isTest
    public static void updateCheckoutSessionTest() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ID checkoutSessionID = [SELECT ID FROM CartCheckoutSession][0].Id;
            ID orderID = [SELECT ID FROM Order][0].Id;
            Test.startTest();
            DRB2B_CustomCartToOrder.updateCheckoutSession(checkoutSessionID, orderID);
            Test.stopTest();
        }
    }
}
