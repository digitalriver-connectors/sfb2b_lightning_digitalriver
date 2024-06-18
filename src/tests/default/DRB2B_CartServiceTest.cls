@IsTest
public with sharing class DRB2B_CartServiceTest {
	private static final String TEST_SOURCE_ID = '0052123230007BcYFCC0';
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

            result = ATK.prepare(Digital_River_Tax_Mapping__c.SObjectType, 1).build(EntityBuilderFactory.drTaxMappingBuilder).save(false);
            Digital_River_Tax_Mapping__c digitalRiverTaxMapping = (Digital_River_Tax_Mapping__c) result.get(Digital_River_Tax_Mapping__c.SObjectType)[0];
            insert digitalRiverTaxMapping;

            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
            cart.WebStoreId = [SELECT id FROM WebStore]?.Id;
            cart.AccountId = [SELECT id FROM Account]?.Id;
            cart.DR_Checkout_Type__c = 'Non-Digital';
            cart.DR_Source_Id__c = '123231132232321232';
            cart.Has_Landed_Cost__c = true;
            insert cart;
            
            CartCheckoutSession cartCheckOutSession = new CartCheckoutSession();
            cartCheckOutSession.WebCartId = cart.Id;
            //cartCheckOutSession.OrderId = sfOrder.Id;
            cartCheckOutSession.State = 'Cancel Session';
            cartCheckOutSession.Name = 'Test';
            insert cartCheckOutSession;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);
            Product2 Product = (Product2) result.get(Product2.SObjectType)[0];
            Product.Name = 'Sort Material';
            Product.DR_TAXGROUP__c = 'Downloadable Goods (Non-Software)';
            Product.DR_TAXTYPE__c = 'Digital Image';
            insert Product;

            result = ATK.prepare(CartDeliveryGroup.SObjectType, 1).build(EntityBuilderFactory.cartDeliveryGroupBuilder).save(false);
            CartDeliveryGroup cartDeliveryGroup  = (CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
            cartDeliveryGroup.CartId = cart.Id;
            insert cartDeliveryGroup;

            result = ATK.prepare(CartItem.SObjectType, 1).build(EntityBuilderFactory.cartItemBuilder).save(false);
            CartItem cartItem  = (CartItem) result.get(CartItem.SObjectType)[0];
            cartItem.CartId = cart.Id;
            cartItem.Product2Id = Product.Id;
            cartItem.CartDeliveryGroupId = cartDeliveryGroup.Id;
            insert cartItem;

            result = ATK.prepare(CartTax.SObjectType, 1).build(EntityBuilderFactory.cartTaxBuilder).save(false);
            CartTax cartTax  = (CartTax) result.get(CartTax.SObjectType)[0];
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

    @IsTest
    static void getCheckoutType_Test(){
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(shopper) {
            Id cartId = [SELECT id FROM WebCart]?.Id;

            Test.startTest();
                DRB2B_CartService cartService = new DRB2B_CartService();
                String checkoutType = cartService.getCheckoutType(cartId);
                system.assertEquals('Digital', checkoutType);
            Test.stopTest();
        }
    }

    @IsTest
    static void getCartTaxAndFee_Test() {
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(shopper) {
            Id cartId = [SELECT id FROM WebCart]?.Id;

            Test.startTest();
                DRB2B_CartService cartService = new DRB2B_CartService();
                DRB2B_CartModel cartModel = cartService.getCartTaxAndFee(cartId);
                system.assertEquals(true, cartModel.cart.get('Has_Landed_Cost__c'));
                system.assertEquals(2.00, cartModel.cart.get('DR_Total_Fees__c'));
                system.assertEquals(5.00, cartModel.cart.get('DR_Total_IOR_Tax__c'));
                system.assertEquals(2.00, cartModel.cart.get('DR_Total_Duty__c'));
            Test.stopTest();
        }
    }

    @IsTest
    static void getCartAsWrapper_Test(){
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(shopper) {
            Id cartId = [SELECT id FROM WebCart]?.Id;
            WebCart cart = [SELECT id,Has_Landed_Cost__c,DR_Total_IOR_Tax__c,DR_Total_Fees__c FROM WebCart where Id =:cartId];
            Test.startTest();
                DRB2B_CartService cartService = new DRB2B_CartService();
                DRB2B_CartModel cartModel = cartService.getCartAsWrapper(cart);
                system.assertEquals(true, cartModel.cart.get('Has_Landed_Cost__c'));
                system.assertEquals(2.00, cartModel.cart.get('DR_Total_Fees__c'));
                system.assertEquals(5.00, cartModel.cart.get('DR_Total_IOR_Tax__c'));
            Test.stopTest();
        }

    }
    
    @IsTest
    static void cancelCartSession_Test(){
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(shopper) {
            Id cartId = [SELECT id FROM WebCart]?.Id;
            WebCart cart = [SELECT id,Has_Landed_Cost__c,DR_Total_IOR_Tax__c,DR_Total_Fees__c FROM WebCart where Id =:cartId];
            Test.startTest();
                DRB2B_CartService cartService = new DRB2B_CartService();
                DRB2B_CartModel cartModel = cartService.getCartAsWrapper(cart);
                system.assertEquals(true, cartModel.cart.get('Has_Landed_Cost__c'));
                system.assertEquals(2.00, cartModel.cart.get('DR_Total_Fees__c'));
                system.assertEquals(5.00, cartModel.cart.get('DR_Total_IOR_Tax__c'));
            Test.stopTest();
        }
    }
    
    @IsTest
    static void cancelSession_Test() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
            Id cartId = [SELECT id FROM WebCart]?.Id;
            
            DRB2B_CartCheckoutSessionSelector CartCheckoutSessionSelector  =  new DRB2B_CartCheckoutSessionSelector();
            List<CartCheckoutSession> beforeSessionClear = new List<CartCheckoutSession>();
            beforeSessionClear.add(CartCheckoutSessionSelector.getActiveSessionForCart(cartId,new Set<String>{'Id','IsArchived'}));
            DRB2B_CheckoutSummaryController.CancelOrder(cartId);
            List<CartCheckoutSession> afterSessionClear = new List<CartCheckoutSession>([SELECT ID, IsArchived From CartCheckoutSession]);
            system.assertNotEquals(afterSessionClear, beforeSessionClear, 'Cart checkout Session Should be clear or null');
            Test.stopTest();
        }
    }
    
    
    @IsTest
    static void clearAllDataLWR_Test() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
            webCart cart = [SELECT id, DR_Source_Id__c FROM WebCart];
            DRB2B_CartService.clearAllDataLWR(cart.Id);
            cart = [SELECT id, DR_Source_Id__c FROM WebCart];
            System.assertEquals(null, cart.DR_Source_Id__c, 'Scource ID Should be null');
            Test.stopTest();
        }
    }
    
    
    @IsTest
    static void clearAllData_Test() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
            webCart cart = [SELECT id, AccountId FROM WebCart];
            contact con = [SELECT Id From contact];
            ATK.SaveResult result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            priceBook.Name = 'PriceBook';
            insert priceBook;
            
            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);
            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = cart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            insert sfOrder;
            
            DR_Transaction_Payment__c transactionPaymentObj = new DR_Transaction_Payment__c();
            transactionPaymentObj.Account__c = cart.AccountID;
            transactionPaymentObj.Amount__c = 12.01;
            transactionPaymentObj.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            transactionPaymentObj.Card_Type__c = 'Visa';
            transactionPaymentObj.Payment_Method__c = 'creditCard';
            transactionPaymentObj.Token__c = TEST_SOURCE_ID;
            transactionPaymentObj.Contact__c = con.Id;
            transactionPaymentObj.User__c = DRB2B_TestEnvironment.shopperUser.Id;
            transactionPaymentObj.CurrencyISOCode__c = 'USD';
            transactionPaymentObj.Order__c = sfOrder.Id;
            transactionPaymentObj.Cart__c = cart.Id;
            transactionPaymentObj.Transaction_Type__c = 'AUTH'; // this will be AUTH and after funds are captured it will be CAPTURE
            insert transactionPaymentObj;
            
            List<DR_Transaction_Payment__c> beforeClearTransactionDataList = new List<DR_Transaction_Payment__c>();
            beforeClearTransactionDataList.add(transactionPaymentObj);
            
            DRB2B_ClearData.clearTransactionPaymentData(cart.Id);
            List<DR_Transaction_Payment__c> afterClearTransactionDataList = new List<DR_Transaction_Payment__c>([SELECT Id, Token__c From DR_Transaction_Payment__c WHERE Cart__c =: cart.Id]);
            System.assertNotEquals(afterClearTransactionDataList, beforeClearTransactionDataList);
            Test.stopTest();
        }
    }

    @isTest
    static void getListOfActiveSessionForCartTest(){
        webCart cart = [SELECT Id FROM webCart LIMIT 1];
        List<String> cartIdList = new List<String>();
        cartIdList.add(cart.Id);
        DRB2B_CartCheckoutSessionSelector cartCheckoutSession = new DRB2B_CartCheckoutSessionSelector();
        List<CartCheckoutSession> session = cartCheckoutSession.getListOfActiveSessionForCart(cartIdList, new Set<String>{ 'Id', 'IsArchived' });
        Assert.isNotNull(session);
    }
    
    @isTest
    static void setIpAddressTest(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            webCart cart = [SELECT Id FROM webCart LIMIT 1];
            DRB2B_CartService cartService = new DRB2B_CartService();
            DRB2B_CartService.setIpAddress('123.22.123.22', cart.Id);
            Set<string> cartIds = new Set<string>();
            cartIds.add(cart.Id);
            cartService.clearAddress(cartIds);
            List<string> cartIdsList = new List<string>();
            cartIdsList.add(cart.Id);
            cartService.cancelActiveCartSession(cartIdsList);
        }        
    }

    @isTest
    static void clearCartItemStructureTest(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            webCart cart = [SELECT Id FROM webCart LIMIT 1];
            DRB2B_CartService cartService = new DRB2B_CartService();
            DRB2B_CartService.clearCartItemStructure(cart.Id);
            
        }        
    }
}