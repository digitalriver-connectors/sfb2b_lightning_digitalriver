@IsTest
private class DRB2B_CheckoutServiceImplTest {
    private static final String DR_CHECKOUT_ID = 'f2cd50e5-355d-42d3-8bb7-0c14d8b777e4';
    private static final String DR_PAYMENT_SESSION_ID = '897eeaa3-ac2d-411f-9211-b7686b51a18d';
    private static final String DR_REG_FEE_BATTERY_TYPE = 'battery';
    private static final String DR_REG_FEE_ID = 'asdkj1h239lkj123j9123';
    private static final String CREATED = 'Created';
    private static final String SOURCE_ID = 'Source_Id';
    private static final String DR_ORDER_ID = '190296100336';
    private static final String DR_RETRY_ORDER_ID = '190296101336';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
    private static String SKU_ID = '00521000007BcYFCC0';
    private static final String DR_ORDER_ITEM_ID = '190296113336';

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
        DRB2B_CreateCheckoutRequestModel request = new DRB2B_CreateCheckoutRequestModel();
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        new CheckoutServiceSuccessCompleteResponseMock();
        DRB2B_CreateCheckoutResponseModel responseModel;
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
            insert drRegulatoryFee;
            // When
            Test.startTest();
            request.upstreamId = '1425464788';
            Test.setMock(HttpCalloutMock.class, new GetCheckoutSuccessMock());
            responseModel = checkoutService.createCheckout(request);
            Test.stopTest();
        }
        // Then
        System.assertEquals('f2cd50e5-355d-42d3-8bb7-0c14d8b777e4', responseModel.id);
    }

    @IsTest
    static void attachSource_Test() {
        // // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        DRB2B_CreateCheckoutRequestModel request = new DRB2B_CreateCheckoutRequestModel();
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CreateCheckoutResponseModel responseModel;
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
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
            insert drRegulatoryFee;
            // When
            WebCart webCart = [SELECT Id, Name, AccountId, WebStoreId, DR_Checkout_Id__c FROM WebCart LIMIT 1];
            StoreIntegratedService storeIntegratedService = new StoreIntegratedService();
            storeIntegratedService.StoreId = webCart.WebStoreId;
            storeIntegratedService.Integration = '0b01D0000004CBtQAM';
            storeIntegratedService.ServiceProviderType = 'Payment';
            insert storeIntegratedService;

            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            priceBook.Name = 'PriceBook-Name';
            insert priceBook;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.Name = 'Product Name';
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

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = webCart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            insert orderItem;
            CartCheckoutSession cartCheckOutSession = new CartCheckoutSession();
            cartCheckOutSession.WebCartId = webCart.Id;
            cartCheckOutSession.OrderId = sfOrder.Id;
            cartCheckOutSession.State = 'Payment And Billing Address';
            cartCheckOutSession.Name = 'Test';
            insert cartCheckOutSession;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GetCheckoutSuccessMock());
            Test.setMock(HttpCalloutMock.class, new UpdateCheckoutSuccessMock());
            // Test.setMock(HttpCalloutMock.class, new GetCheckoutSuccessMock());
            checkoutService.attachSource(webCart.Id, source);
            Test.stopTest();
        }
        // Then
        System.assertNotEquals(null, source, 'Source can not be null');
    }

    @IsTest
    static void differentBillingAddressTest() {
        // // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        Boolean isBillingAddressDifferent = false;
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
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
            insert drRegulatoryFee;
            // When
            WebCart webCart = [
                SELECT
                    Id,
                    Name,
                    AccountId,
                    BillingCity,
                    BillingCountry,
                    BillingState,
                    WebStoreId,
                    BillingPostalCode,
                    DR_Checkout_Id__c
                FROM WebCart
                LIMIT 1
            ];
            DRB2B_CreateCheckoutResponseModel.Address address = new DRB2B_CreateCheckoutResponseModel.Address();
            address.line1 = 'bank road new';
            address.city = 'Waconia';
            address.country = 'US';
            address.postalCode = '05387';
            address.state = 'NJ';
            DRB2B_CreateCheckoutResponseModel.Owner owner = new DRB2B_CreateCheckoutResponseModel.Owner();
            owner.email = 'Test@testclass.com';
            owner.address = address;
            source.owner = owner;
            Test.startTest();
            isBillingAddressDifferent = checkoutService.isBillingAddressDifferent(source, webCart);
            Test.stopTest();
        }
        // Then
        System.assertEquals(true, isBillingAddressDifferent, 'billing address is different');
    }

    @IsTest
    static void setBillingAddress_Test() {
        // // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
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
            insert drRegulatoryFee;
            // When
            WebCart webCart = [
                SELECT
                    Id,
                    Name,
                    AccountId,
                    BillingCity,
                    BillingCountry,
                    BillingState,
                    WebStoreId,
                    BillingPostalCode,
                    DR_Checkout_Id__c
                FROM WebCart
                LIMIT 1
            ];
            DRB2B_CreateCheckoutResponseModel.Address address = new DRB2B_CreateCheckoutResponseModel.Address();
            address.line1 = 'bank road new';
            address.city = 'Waconia';
            address.country = 'US';
            address.postalCode = '05387';
            address.state = 'NJ';
            DRB2B_CreateCheckoutResponseModel.Owner owner = new DRB2B_CreateCheckoutResponseModel.Owner();
            owner.email = 'Test@testclass.com';
            owner.address = address;
            source.owner = owner;
            Test.startTest();
            checkoutService.setBillingAddress(webCart, source);
            Test.stopTest();
        }
        // Then
        System.assertNotEquals(null, source, 'billing address Not set');
    }

    @IsTest
    static void convertToOrder_Test() {
        // // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
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
            insert drRegulatoryFee;
            // When
            WebCart webCart = [
                SELECT
                    Id,
                    Name,
                    AccountId,
                    BillingCity,
                    BillingCountry,
                    BillingState,
                    WebStoreId,
                    BillingPostalCode,
                    DR_Checkout_Id__c
                FROM WebCart
                LIMIT 1
            ];
            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            priceBook.Name = 'PriceBook-Name';
            insert priceBook;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.Name = 'Product Name';
            insert product;
            SKU_ID = product.Id;
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

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = webCart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            orderItem.TotalLineAmount = 10.12;
            insert orderItem;
            CartCheckoutSession cartCheckOutSession = new CartCheckoutSession();
            cartCheckOutSession.WebCartId = webCart.Id;
            cartCheckOutSession.OrderId = sfOrder.Id;
            cartCheckOutSession.State = 'Payment And Billing Address';
            cartCheckOutSession.Name = 'Test';
            insert cartCheckOutSession;

            DRB2B_CreateCheckoutResponseModel.Address address = new DRB2B_CreateCheckoutResponseModel.Address();
            address.line1 = 'bank road new';
            address.city = 'Waconia';
            address.country = 'US';
            address.postalCode = '05387';
            address.state = 'NJ';
            DRB2B_CreateCheckoutResponseModel.Owner owner = new DRB2B_CreateCheckoutResponseModel.Owner();
            owner.email = 'Test@testclass.com';
            owner.address = address;
            source.owner = owner;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GetOrderSuccessMock());
            checkoutService.convertToOrder(webCart.Id);
            Test.stopTest();
        }
        // Then
        System.assertNotEquals(null, source, 'billing address Not set');
    }

    @IsTest
    static void cancelDROrder_Test() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
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
            insert drRegulatoryFee;
            // When
            WebCart webCart = [
                SELECT
                    Id,
                    Name,
                    AccountId,
                    BillingCity,
                    BillingCountry,
                    BillingState,
                    WebStoreId,
                    BillingPostalCode,
                    DR_Checkout_Id__c
                FROM WebCart
                LIMIT 1
            ];
            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            priceBook.Name = 'PriceBook-Name';
            insert priceBook;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.Name = 'Product Name';
            insert product;
            SKU_ID = product.Id;
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

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = webCart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            sfOrder.DR_Order_State__c = 'accepted';
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            orderItem.TotalLineAmount = 10.12;
            insert orderItem;
            String drOrderResponse =
                '{"totalFees":0,"chargeType":"customer_initiated","totalImporterTax":0,"locale":"en_US","totalTax":3.1,"customerType":"individual","liveMode":false,"cancelledAmount":0,"upstreamId":"' +
                sfOrder.Id +
                '","billTo":{"name":"shankar CreatedViaQuickstart","address":{"country":"US","state":"CA","city":"Vancouver","line1":"415 Mission Street (Billing)","postalCode":"94105"},"email":"salesforceuser@digitalriver.com"},"customerId":"0031D00000dzyFGQAY","createdTime":"2021-08-25T07:09:14Z","currency":"USD","requestToBeForgotten":false,"payment":{"charges":[{"sourceId":"bb74750f-4899-4268-9da3-c3535f3c9349","amount":39.09,"captured":false,"createdTime":"2021-08-25T07:09:16Z","currency":"USD","refunded":false,"id":"8c1c32ad-ca4c-4022-9cc4-87e39502f913","state":"capturable","type":"customer_initiated"}],"sources":[{"owner":{"firstName":"shankar","lastName":"CreatedViaQuickstart","address":{"country":"US","state":"CA","city":"Vancouver","line1":"415 Mission Street (Billing)","postalCode":"94105"},"email":"salesforceuser@digitalriver.com"},"amount":39.09,"id":"bb74750f-4899-4268-9da3-c3535f3c9349","type":"creditCard","creditCard":{"expirationYear":2023,"expirationMonth":2,"lastFourDigits":"1111","brand":"Visa"}}],"session":{"amountContributed":39.09,"clientSecret":"3fe67e62-3a94-40ef-a664-9a007da4e93a_ca522f26-540b-42ca-8820-01210b158741","id":"3fe67e62-3a94-40ef-a664-9a007da4e93a","state":"complete","amountRemainingToBeContributed":0}},"state":"accepted","id":"196998030336","fraudStateTransitions":{"passed":"2021-08-25T07:09:17Z"},"totalShipping":0,"email":"salesforceuser@digitalriver.com","stateTransitions":{"accepted":"2021-08-25T07:09:17Z"},"updatedTime":"2021-08-25T07:09:14Z","shipFrom":{"address":{"country":"US"}},"capturedAmount":0,"totalDuty":0,"availableToRefundAmount":0,"shippingChoice":{"taxAmount":0,"amount":0},"totalAmount":39.09,"sellingEntity":{"name":"Digital River Inc.","id":"DR_INC-ENTITY"},"subtotal":35.99,"totalDiscount":0,"fraudState":"passed","checkoutId":"fcc4b755-1a7c-4386-ba37-2ea4cb883974","items":[{"stateTransitions":{"created":"2021-08-25T07:09:14Z"},"fees":{"taxAmount":0,"amount":0},"metadata":{"cartId":"0a61D0000004DDkQAM","cartItemId":"0a91D0000004DDfQAM"},"amount":35.99,"quantity":1,"tax":{"rate":0.08625,"amount":3.1},"availableToRefundAmount":0,"importerTax":{"amount":0},"id":"119284050336","state":"created","skuId":"01t1D00000AyA2oQAF","duties":{"amount":0}}],"shipTo":{"name":"shankar CreatedViaQuickstart","address":{"country":"US","state":"CA","city":"Vancouver","line1":"415 Mission Street (Shipping)","postalCode":"94105"}}}';
            String errorResponse = 'You do not have permission to insert field digitalriverv3__Card_Number__c on digitalriverv3__DR_Transaction_Payment__c';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cancelDROrderMock());
            checkoutService.cancelDROrder(drOrderResponse, errorResponse);
            Test.stopTest();
            Order updatedOrder = [
                SELECT Id, DR_Order_State__c, SF_Order_Failure_Reason__c
                FROM Order
                WHERE id = :sfOrder.Id
                LIMIT 1
            ];
            System.assertEquals(
                'You do not have permission to insert field digitalriverv3__Card_Number__c on digitalriverv3__DR_Transaction_Payment__c',
                updatedOrder.SF_Order_Failure_Reason__c
            );
        }

    }

    @IsTest
    static void convertToOrder_PopulateBillingAgreementId_Test() {
        // // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
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
                .field(CartItem.Recurring_Line_Item__c)
                .repeat(true)
                .field(CartItem.Subscription_Id__c)
                .repeat('1233')
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
            insert drRegulatoryFee;
            // When
            WebCart webCart = [
                SELECT
                    Id,
                    Name,
                    AccountId,
                    BillingCity,
                    BillingCountry,
                    BillingState,
                    WebStoreId,
                    BillingPostalCode,
                    DR_Checkout_Id__c
                FROM WebCart
                LIMIT 1
            ];
            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            priceBook.Name = 'PriceBook-Name';
            insert priceBook;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.Name = 'Product Name';
            insert product;
            SKU_ID = product.Id;
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

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = webCart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            orderItem.Type = 'Order Product';
            orderItem.TotalLineAmount = 10.12;
            insert orderItem;
            CartCheckoutSession cartCheckOutSession = new CartCheckoutSession();
            cartCheckOutSession.WebCartId = webCart.Id;
            cartCheckOutSession.OrderId = sfOrder.Id;
            cartCheckOutSession.State = 'Payment And Billing Address';
            cartCheckOutSession.Name = 'Test';
            insert cartCheckOutSession;

            DRB2B_CreateCheckoutResponseModel.Address address = new DRB2B_CreateCheckoutResponseModel.Address();
            address.line1 = 'bank road new';
            address.city = 'Waconia';
            address.country = 'US';
            address.postalCode = '05387';
            address.state = 'NJ';
            DRB2B_CreateCheckoutResponseModel.Owner owner = new DRB2B_CreateCheckoutResponseModel.Owner();
            owner.email = 'Test@testclass.com';
            owner.address = address;
            source.owner = owner;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GetSubscriptionOrderSuccessMock());
            checkoutService.convertToOrder(webCart.Id);
            Test.stopTest();
        }
        // Then
        OrderItem orderItemRec = [
            SELECT Id, Recurring_Line_Item__c
            FROM OrderItem
            WHERE Type = 'Order Product'
            LIMIT 1
        ];
        System.assertEquals(false, orderItemRec.Recurring_Line_Item__c, 'This is a recurring line item');
    }

    @IsTest
    static void refreshCartBasedOnDrRecord_Test() {
        // // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
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
                .field(CartItem.Name)
                .index('Name {0000}')
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
            insert drRegulatoryFee;
            // When
            WebCart webCart = [
                SELECT
                    Id,
                    Name,
                    AccountId,
                    BillingCity,
                    BillingCountry,
                    BillingState,
                    WebStoreId,
                    BillingPostalCode,
                    DR_Checkout_Id__c
                FROM WebCart
                LIMIT 1
            ];
            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            priceBook.Name = 'PriceBook-Name';
            insert priceBook;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.Name = 'Product Name';
            insert product;
            SKU_ID = product.Id;
            List<CartItem> cartItemList = [SELECT Id, Name, Product2Id, Type FROM CartItem WHERE cartId = :webCart.Id];
            for (CartItem cartItem : cartItemList) {
                cartItem.Product2Id = product.Id;
            }
            update cartItemList;
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

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = webCart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            insert orderItem;
            DRB2B_CreateCheckoutResponseModel.Address address = new DRB2B_CreateCheckoutResponseModel.Address();
            address.line1 = 'bank road new';
            address.city = 'Waconia';
            address.country = 'US';
            address.postalCode = '05387';
            address.state = 'NJ';
            DRB2B_CreateCheckoutResponseModel.Owner owner = new DRB2B_CreateCheckoutResponseModel.Owner();
            owner.email = 'Test@testclass.com';
            owner.address = address;
            source.owner = owner;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GetSuccessCheckoutMock());
            try {
                checkoutService.refreshCartBasedOnDrRecord(webCart.Id);
            } catch (Exception e) {
                System.assertNotEquals(null, e, 'Exception mst be thrown');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void convertToOrder_NegativeTest() {
        // // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
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
            insert drRegulatoryFee;
            // When
            WebCart webCart = [
                SELECT
                    Id,
                    Name,
                    AccountId,
                    BillingCity,
                    BillingCountry,
                    BillingState,
                    WebStoreId,
                    BillingPostalCode,
                    DR_Checkout_Id__c
                FROM WebCart
                LIMIT 1
            ];
            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            priceBook.Name = 'PriceBook-Name';
            insert priceBook;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.Name = 'Product Name';
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

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = webCart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            insert orderItem;
            CartCheckoutSession cartCheckOutSession = new CartCheckoutSession();
            cartCheckOutSession.WebCartId = webCart.Id;
            cartCheckOutSession.OrderId = sfOrder.Id;
            cartCheckOutSession.State = 'Payment And Billing Address';
            cartCheckOutSession.Name = 'Test';
            insert cartCheckOutSession;

            DRB2B_CreateCheckoutResponseModel.Address address = new DRB2B_CreateCheckoutResponseModel.Address();
            address.line1 = 'bank road new';
            address.city = 'Waconia';
            address.country = 'US';
            address.postalCode = '05387';
            address.state = 'NJ';
            DRB2B_CreateCheckoutResponseModel.Owner owner = new DRB2B_CreateCheckoutResponseModel.Owner();
            owner.email = 'Test@testclass.com';
            owner.address = address;
            source.owner = owner;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GetOrderErrorMock());
            try {
                checkoutService.convertToOrder(webCart.Id);
            } catch (DRB2B_CheckoutServiceImpl.CheckoutServiceException e) {
                System.assertNotEquals(null, e, 'CheckoutServiceException Must be thrown');
            }
            Test.stopTest();
        }
    }

    private static DRB2B_CreateCheckoutResponseModel getCheckoutSuccessResponseModal() {
        DRB2B_CreateCheckoutResponseModel response = new DRB2B_CreateCheckoutResponseModel();
        DRB2B_CreateCheckoutResponseModel.SellingEntity sellingEntity = new DRB2B_CreateCheckoutResponseModel.SellingEntity();
        sellingEntity.name = 'DR_INC-ENTITY';
        response.sellingEntity = sellingEntity;
        DRB2B_CreateCheckoutRequestModel.Item requestItems = new DRB2B_CreateCheckoutRequestModel.Item(
            SKU_ID,
            1,
            10.99
        );
        DRB2B_CreateCheckoutRequestModel request = new DRB2B_CreateCheckoutRequestModel();
        request.items = new List<DRB2B_CreateCheckoutRequestModel.Item>{ requestItems };
        response.id = DR_CHECKOUT_ID;
        response.customerId = null; // todo
        response.drCurrency = 'USD'; // todo
        response.email = null; // todo

        response.items = new List<DRB2B_CreateCheckoutResponseModel.Item>();
        for (DRB2B_CreateCheckoutRequestModel.Item requestItem : request.items) {
            DRB2B_CreateCheckoutResponseModel.Item responseItem = new DRB2B_CreateCheckoutResponseModel.Item();
            responseItem.skuId = requestItem.skuId;

            DRB2B_CreateCheckoutResponseModel.Tax tax = new DRB2B_CreateCheckoutResponseModel.Tax();
            tax.amount = 5;
            tax.rate = 1;
            responseItem.tax = tax;

            DRB2B_CreateCheckoutResponseModel.ImporterTax importerTax = new DRB2B_CreateCheckoutResponseModel.ImporterTax();
            importerTax.amount = 5;
            responseItem.importerTax = importerTax;

            DRB2B_CreateCheckoutResponseModel.Fees fees = new DRB2B_CreateCheckoutResponseModel.Fees();
            fees.amount = 5;
            fees.taxAmount = 1;
            DRB2B_CreateCheckoutResponseModel.Details feesDetail = new DRB2B_CreateCheckoutResponseModel.Details();
            feesDetail.amount = 5;
            feesDetail.perUnitAmount = 5;
            feesDetail.id = DR_REG_FEE_ID;
            feesDetail.type = DR_REG_FEE_BATTERY_TYPE;
            List<DRB2B_CreateCheckoutResponseModel.Details> feesDetails = new List<DRB2B_CreateCheckoutResponseModel.Details>();
            feesDetails.add(feesDetail);
            fees.details = feesDetails;
            responseItem.fees = fees;

            DRB2B_CreateCheckoutResponseModel.Duties duties = new DRB2B_CreateCheckoutResponseModel.Duties();
            duties.amount = 5;
            responseItem.duties = duties;

            response.items.add(responseItem);
        }

        DRB2B_CreateCheckoutResponseModel.ShippingChoice shippingChoice = new DRB2B_CreateCheckoutResponseModel.ShippingChoice();
        shippingChoice.taxAmount = 5;
        response.shippingChoice = shippingChoice;

        DRB2B_CreateCheckoutResponseModel.Payment payment = new DRB2B_CreateCheckoutResponseModel.Payment();
        // DRB2B_CreateCheckoutResponseModel.Payment.Sources sources = new DRB2B_CreateCheckoutResponseModel.Payment.Sources();
        DRB2B_CreateCheckoutResponseModel.Source source = new DRB2B_CreateCheckoutResponseModel.Source();
        DRB2B_CreateCheckoutResponseModel.Session paymentSession = new DRB2B_CreateCheckoutResponseModel.Session();
        paymentSession.id = DR_PAYMENT_SESSION_ID;
        payment.session = paymentSession;
        DRB2B_CreateCheckoutResponseModel.CreditCard creditCard = new DRB2B_CreateCheckoutResponseModel.CreditCard();
        creditCard.brand = 'Visa';
        creditCard.lastFourDigits = '1111';
        creditCard.expirationYear = 2039;
        creditCard.expirationMonth = 7;
        //fundingSource

        source.type = 'creditCard';
        source.amount = 12;
        source.creditCard = creditCard;
        payment.sources = new List<DRB2B_CreateCheckoutResponseModel.Source>{ source };

        response.payment = payment;

        return response;
    }

    private static DRB2B_CreateCheckoutResponseModel getCheckoutErrorResponseModal() {
        DRB2B_ErrorResponseModel errorResponseModel = new DRB2B_ErrorResponseModel();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_CreateCheckoutResponseModel responseModel = new DRB2B_CreateCheckoutResponseModel();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponseModel>{ errorResponseModel };
        return responseModel;
    }

    private static DRB2B_ErrorsResponseModel getOrderErrorResponseModal() {
        DRB2B_ErrorResponseModel errorResponseModel = new DRB2B_ErrorResponseModel();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_ErrorsResponseModel responseModel = new DRB2B_ErrorsResponseModel();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponseModel>{ errorResponseModel };
        return responseModel;
    }
    private static DRB2B_OrderResponseModel getOrderResponseModal() {
        DRB2B_OrderResponseModel responseModel = new DRB2B_OrderResponseModel();
        DRB2B_OrderResponseModel.ImporterTax importerOfTax = new DRB2B_OrderResponseModel.ImporterTax();
        importerOfTax.amount = 2.4;
        DRB2B_OrderResponseModel.ImporterTax duties = new DRB2B_OrderResponseModel.ImporterTax();
        duties.amount = 2.49;
        DRB2B_OrderResponseModel.Tax tax = new DRB2B_OrderResponseModel.Tax();
        tax.amount = 2.4;
        tax.rate = 2;
        DRB2B_OrderResponseModel.Items items = new DRB2B_OrderResponseModel.Items();
        items.skuId = SKU_ID;
        items.amount = 20.1;
        items.quantity = 1;
        items.state = 'created';
        items.Id = DR_ORDER_ITEM_ID;
        items.importerTax = importerOfTax;
        items.tax = tax;
        items.duties = duties;
        responseModel.items = new List<DRB2B_OrderResponseModel.Items>{ items };
        responseModel.id = DR_ORDER_ID;
        responseModel.state = 'accepted';
        responseModel.fraudState = 'passed';
        responseModel.totalAmount = 40;
        return responseModel;
    }

    private static DRB2B_OrderResponseModel getDROrderResponseModal() {
        DRB2B_OrderResponseModel responseModel = new DRB2B_OrderResponseModel();
        DRB2B_OrderResponseModel.Items items = new DRB2B_OrderResponseModel.Items();
        DRB2B_OrderResponseModel.CreditCard creditCard = new DRB2B_OrderResponseModel.CreditCard();
        creditCard.brand = 'Visa';
        creditCard.lastFourDigits = '1111';
        creditCard.expirationYear = 2039;
        creditCard.expirationMonth = 7;
        DRB2B_OrderResponseModel.Payment payment = new DRB2B_OrderResponseModel.Payment();
        DRB2B_OrderResponseModel.Fees shippingChoice = new DRB2B_OrderResponseModel.Fees();
        shippingChoice.amount = 20;
        shippingChoice.taxAmount = 4;
        DRB2B_OrderResponseModel.Fees fees = new DRB2B_OrderResponseModel.Fees();
        fees.amount = 2.4;
        fees.taxAmount = 4;
        DRB2B_OrderResponseModel.ImporterTax importerOfTax = new DRB2B_OrderResponseModel.ImporterTax();
        importerOfTax.amount = 2.4;

        DRB2B_OrderResponseModel.Tax tax = new DRB2B_OrderResponseModel.Tax();
        tax.amount = 2.4;
        tax.rate = 2;
        DRB2B_OrderResponseModel.ImporterTax duties = new DRB2B_OrderResponseModel.ImporterTax();
        duties.amount = 2.49;
        DRB2B_OrderResponseModel.Sources sources = new DRB2B_OrderResponseModel.Sources();
        sources.type = 'creditCard';
        sources.amount = 12;
        sources.creditCard = creditCard;

        payment.sources = new List<DRB2B_OrderResponseModel.Sources>{ sources };
        items.skuId = SKU_ID;
        items.amount = 20.1;
        items.quantity = 1;
        items.state = 'created';
        items.Id = DR_ORDER_ITEM_ID;
        items.importerTax = importerOfTax;
        items.tax = tax;
        items.fees = fees;
        items.duties = duties;
        responseModel.items = new List<DRB2B_OrderResponseModel.Items>{ items };
        responseModel.id = DR_ORDER_ID;
        responseModel.state = 'accepted';
        responseModel.fraudState = 'passed';
        responseModel.payment = payment;
        responseModel.shippingChoice = shippingChoice;
        responseModel.totalAmount = 40;
        return responseModel;
    }

    private static DRB2B_OrderResponseModel postSubscriptionOrderResponseModel() {
        DRB2B_OrderResponseModel responseModel = new DRB2B_OrderResponseModel();
        DRB2B_OrderResponseModel.ImporterTax importerOfTax = new DRB2B_OrderResponseModel.ImporterTax();
        importerOfTax.amount = 2.4;
        DRB2B_OrderResponseModel.ImporterTax duties = new DRB2B_OrderResponseModel.ImporterTax();
        duties.amount = 2.49;
        DRB2B_OrderResponseModel.Tax tax = new DRB2B_OrderResponseModel.Tax();
        tax.amount = 2.4;
        tax.rate = 2;
        DRB2B_OrderResponseModel.SubscriptionInfo itemSubscriptionInfo = new DRB2B_OrderResponseModel.SubscriptionInfo();
        itemSubscriptionInfo.billingAgreementId = '1234';
        itemSubscriptionInfo.subscriptionId = '1233';
        itemSubscriptionInfo.autoRenewal = true;
        itemSubscriptionInfo.freeTrial = false;
        itemSubscriptionInfo.terms = 'Here are my terms';
        DRB2B_OrderResponseModel.Items items = new DRB2B_OrderResponseModel.Items();
        items.skuId = SKU_ID;
        items.amount = 20.1;
        items.quantity = 1;
        items.state = 'created';
        items.Id = DR_ORDER_ITEM_ID;
        items.importerTax = importerOfTax;
        items.tax = tax;
        items.duties = duties;
        items.subscriptionInfo = itemSubscriptionInfo;
        responseModel.items = new List<DRB2B_OrderResponseModel.Items>{ items };
        responseModel.id = DR_ORDER_ID;
        responseModel.state = 'accepted';
        responseModel.fraudState = 'passed';
        responseModel.totalAmount = 40;
        return responseModel;
    }

    private static DRB2B_OrderResponseModel getDRSubscriptionOrderResponseModel() {
        DRB2B_OrderResponseModel responseModel = new DRB2B_OrderResponseModel();
        DRB2B_OrderResponseModel.Items items = new DRB2B_OrderResponseModel.Items();
        DRB2B_OrderResponseModel.CreditCard creditCard = new DRB2B_OrderResponseModel.CreditCard();
        creditCard.brand = 'Visa';
        creditCard.lastFourDigits = '1111';
        creditCard.expirationYear = 2039;
        creditCard.expirationMonth = 7;
        DRB2B_OrderResponseModel.Payment payment = new DRB2B_OrderResponseModel.Payment();
        DRB2B_OrderResponseModel.Fees shippingChoice = new DRB2B_OrderResponseModel.Fees();
        shippingChoice.amount = 20;
        shippingChoice.taxAmount = 4;
        DRB2B_OrderResponseModel.Fees fees = new DRB2B_OrderResponseModel.Fees();
        fees.amount = 2.4;
        fees.taxAmount = 4;
        DRB2B_OrderResponseModel.ImporterTax importerOfTax = new DRB2B_OrderResponseModel.ImporterTax();
        importerOfTax.amount = 2.4;

        DRB2B_OrderResponseModel.Tax tax = new DRB2B_OrderResponseModel.Tax();
        tax.amount = 2.4;
        tax.rate = 2;
        DRB2B_OrderResponseModel.SubscriptionInfo itemSubscriptionInfo = new DRB2B_OrderResponseModel.SubscriptionInfo();
        itemSubscriptionInfo.billingAgreementId = '1234';
        itemSubscriptionInfo.subscriptionId = '1233';
        itemSubscriptionInfo.autoRenewal = true;
        itemSubscriptionInfo.freeTrial = false;
        itemSubscriptionInfo.terms = 'Here are my terms';
        DRB2B_OrderResponseModel.ImporterTax duties = new DRB2B_OrderResponseModel.ImporterTax();
        duties.amount = 2.49;
        DRB2B_OrderResponseModel.Sources sources = new DRB2B_OrderResponseModel.Sources();
        sources.type = 'creditCard';
        sources.amount = 12;
        sources.creditCard = creditCard;
        payment.sources = new List<DRB2B_OrderResponseModel.Sources>{ sources };
        items.skuId = SKU_ID;
        items.amount = 20.1;
        items.quantity = 1;
        items.state = 'created';
        items.Id = DR_ORDER_ITEM_ID;
        items.importerTax = importerOfTax;
        items.tax = tax;
        items.fees = fees;
        items.duties = duties;
        items.subscriptionInfo = itemSubscriptionInfo;
        responseModel.items = new List<DRB2B_OrderResponseModel.Items>{ items };
        responseModel.id = DR_ORDER_ID;
        responseModel.state = 'accepted';
        responseModel.fraudState = 'passed';
        responseModel.payment = payment;
        responseModel.shippingChoice = shippingChoice;
        responseModel.totalAmount = 40;
        return responseModel;
    }

    @isTest
    static void updateCheckoutReqSuccess_Test() {
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
                .field(CartItem.Recurring_Line_Item__c)
                .repeat(true)
                .field(CartItem.Subscription_Id__c)
                .repeat('1233')
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
            DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new UpdateCheckoutSuccessMock());
            DCM_HttpClient.Response updateResponse = checkoutService.updateCheckoutReq(
                [SELECT cartId FROM cartItem WHERE Recurring_Line_Item__c = TRUE LIMIT 1]
                .cartId,
                DRB2B_Constants.Subscription.DR_AUTO_RENEWAL_TERMS
            );
            Test.stopTest();
            system.assertEquals(updateResponse.getStatusCode(), 200);
        }


        //system.assertEquals(DRB2B_Constants.Subscription.DR_AUTO_RENEWAL_TERMS, response.items[0].subscriptionInfo.terms);
    }

    @isTest
    static void updateCheckoutReqFail_Test() {
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
                .field(CartItem.Recurring_Line_Item__c)
                .repeat(true)
                .field(CartItem.Subscription_Id__c)
                .repeat('1233')
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
            DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new UpdateCheckoutFailMock());
            DCM_HttpClient.Response updateResponse = checkoutService.updateCheckoutReq(
                [SELECT cartId FROM cartItem WHERE Recurring_Line_Item__c = TRUE LIMIT 1]
                .cartId,
                DRB2B_Constants.Subscription.DR_AUTO_RENEWAL_TERMS
            );
            Test.stopTest();
            system.assertEquals(updateResponse.getStatusCode(), 404);
        }


        //system.assertEquals(DRB2B_Constants.Subscription.DR_AUTO_RENEWAL_TERMS, response.items[0].subscriptionInfo.terms);
    }
    @IsTest
    static void updateCheckout_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        DRB2B_updateCheckoutRequestModel request = new DRB2B_updateCheckoutRequestModel();
        DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();
        new CheckoutServiceSuccessCompleteResponseMock();
        DRB2B_CreateCheckoutResponseModel responseModel;
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
            insert drRegulatoryFee;
            // When
            Test.startTest();
            request.upstreamId = '1425464788';
            Test.setMock(HttpCalloutMock.class, new UpdateSuccessMock());

            responseModel = checkoutService.updateCheckoutReqwithoutItems(DR_CHECKOUT_ID, request);
            WebCart wc = [SELECT id FROM WebCart WHERE DR_Checkout_Id__c = :DR_CHECKOUT_ID];
            Test.stopTest();
        }
        // Then
        System.assertEquals('f2cd50e5-355d-42d3-8bb7-0c14d8b777e4', responseModel.id);
    }

    private static DRB2B_CreateCheckoutResponseModel updateTermsCheckoutresponseModal() {
        DRB2B_CreateCheckoutResponseModel response = new DRB2B_CreateCheckoutResponseModel();
        DRB2B_CreateCheckoutResponseModel.Item item = new DRB2B_CreateCheckoutResponseModel.Item();
        item.subscriptionInfo = new DRB2B_CreateCheckoutResponseModel.SubscriptionInfo();
        item.subscriptionInfo.terms = DRB2B_Constants.Subscription.DR_AUTO_RENEWAL_TERMS;
        response.items = new List<DRB2B_CreateCheckoutResponseModel.Item>();
        response.items.add(item);
        response.upstreamId = '8011D000000ZfuHQAS';
        return response;
    }

    private static DRB2B_CreateFulfillmentResponseModel cancelDROrderResponseModal() {
        DRB2B_CreateFulfillmentResponseModel response = new DRB2B_CreateFulfillmentResponseModel();
        DRB2B_CreateFulfillmentResponseModel.Items item = new DRB2B_CreateFulfillmentResponseModel.Items();
        response.id = 'ful_72465bbb-c8de-412b-8365-0a8fd7136adc';
        response.orderId = '196998030336';
        item.itemId = '119284050336';
        item.quantity = 0;
        item.cancelQuantity = 1;
        item.skuId = '01t1D00000AyA2oQAF';
        response.items = new List<DRB2B_CreateFulfillmentResponseModel.Items>();
        response.items.add(item);
        return response;
    }

    private class UpdateCheckoutSuccessMock extends HttpCalloutMockRouter {
        private UpdateCheckoutSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create TaxId',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                DR_CHECKOUT_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                updateTermsCheckoutresponseModal()
            );
        }
    }

    private class UpdateCheckoutFailMock extends HttpCalloutMockRouter {
        private UpdateCheckoutFailMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create TaxId',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                DR_CHECKOUT_ID,
                DRB2B_DRApiConstants.NOT_FOUND_STATUS,
                CREATED,
                updateTermsCheckoutresponseModal()
            );
        }
    }

    private class GetCheckoutSuccessMock extends HttpCalloutMockRouter {
        private GetCheckoutSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create checkout ',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.CHECKOUT_PATH,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                getCheckoutSuccessResponseModal()
            );
        }
    }
    private class UpdateSuccessMock extends HttpCalloutMockRouter {
        private UpdateSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create checkout ',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                DR_CHECKOUT_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                getCheckoutSuccessResponseModal()
            );
        }
    }
    private class GetSuccessCheckoutMock extends HttpCalloutMockRouter {
        private GetSuccessCheckoutMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create checkout ',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                DR_CHECKOUT_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                getCheckoutSuccessResponseModal()
            );
        }
    }

    private class GetOrderSuccessMock extends HttpCalloutMockRouter {
        private GetOrderSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerEndpointVariable('id', '([0-9a-zA-Z]{15,18})');
            this.registerJsonMock(
                'Create Order',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.ORDER_PATH,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                'Created',
                getOrderResponseModal()
            );
            this.registerJsonMock(
                'Get Order',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.ORDER_PATH +
                '/' +
                DR_ORDER_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                'Created',
                getDROrderResponseModal()
            );
        }
    }

    private class GetSubscriptionOrderSuccessMock extends HttpCalloutMockRouter {
        private GetSubscriptionOrderSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerEndpointVariable('id', '([0-9a-zA-Z]{15,18})');
            this.registerJsonMock(
                'Create Order',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.ORDER_PATH,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                'Created',
                postSubscriptionOrderResponseModel()
            );
            this.registerJsonMock(
                'Get Order',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.ORDER_PATH +
                '/' +
                DR_ORDER_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                'Created',
                getDRSubscriptionOrderResponseModel()
            );
        }
    }

    private class GetCheckoutErrorMock extends HttpCalloutMockRouter {
        private GetCheckoutErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Get File Url',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.CHECKOUT_PATH,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                getCheckoutErrorResponseModal()
            );
        }
    }

    private class GetOrderErrorMock extends HttpCalloutMockRouter {
        private GetOrderErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Post Order',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.ORDER_PATH,
                DRB2B_DRApiConstants.ERROR_RESPONSE_CODE,
                CREATED,
                getOrderErrorResponseModal()
            );
        }
    }

    private class cancelDROrderMock extends HttpCalloutMockRouter {
        private cancelDROrderMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Post Cancel Request',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.FULFILLMENT_PATH,
                DRB2B_DRApiConstants.UPSERT_SUCCESS_STATUS,
                CREATED,
                cancelDROrderResponseModal()
            );
        }
    }

    public class CheckoutServiceSuccessCompleteResponseMock implements DRB2B_CheckoutService {
        public DRB2B_CreateCheckoutResponseModel createCheckout(DRB2B_CreateCheckoutRequestModel request) {
            DRB2B_CreateCheckoutResponseModel response = new DRB2B_CreateCheckoutResponseModel();
            return response;
        }

        public void attachSource(Id cartId, DRB2B_CreateCheckoutResponseModel.Source source) {
            DRB2B_CreateCheckoutResponseModel.Owner owner = new DRB2B_CreateCheckoutResponseModel.Owner();
            DRB2B_CreateCheckoutResponseModel.Address address = new DRB2B_CreateCheckoutResponseModel.Address();
            address.line1 = 'bank road';
            address.city = 'Waconia';
            address.country = 'US';
            address.postalCode = '05387';
            address.state = 'NJ';

            source.Id = SOURCE_ID;
            owner.address = address;
            source.owner = owner;
        }

        public void convertToOrder(Id cartId) {
        }

        public void refreshCartBasedOnDrRecord(Id cartId) {
        }

        public void recalculateTaxesAndFees(
            WebCart cart,
            Map<String, CartItem> cartItemsBySkuIds,
            DRB2B_CreateCheckoutResponseModel createCheckoutResponse
        ) {
        }
        public DRB2B_CreateCheckoutResponseModel updateCheckoutReqwithoutItems(
            String checkoutId,
            DRB2B_updateCheckoutRequestModel req
        ) {
            DRB2B_CreateCheckoutResponseModel response = new DRB2B_CreateCheckoutResponseModel();
            return response;
        }
        public string convertToOrderLWR(Id cartId) {
            return null;
        }

        public boolean attachSourceLWR(Id cartId, DRB2B_CreateCheckoutResponseModel.Source source) { return true;}
        public void sfFailedcancelDROrder(String drOrderId) {}
        public void recalculateTaxesAndFeesCartCalculate(CartExtension.Cart cart, Map<String, CartExtension.CartItem> cartItemsBySkuIds, DRB2B_CreateCheckoutResponseModel createCheckoutResponse) {}
    }

    @isTest
    public static void getOrderNumberTest(){
    //  WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
    //    DRB2B_CheckoutServiceImpl.getOrderNumber(cart.Id);
    }
}