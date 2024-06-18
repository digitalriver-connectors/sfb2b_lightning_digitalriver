@isTest
private with sharing class DRB2B_CustomerCreditServiceTest {

    private static final String TEST_ID = DCM_IdUtils.generate(User.getSObjectType());
    private static final String TEST2EXAMPLE_COM = 'test2example.com';
    private static final String TEST_USER_ID = 'testUserId';
    private static final String EN_US = 'en_US';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
    private static final String TEST_SOURCE_ID = '02521000007BcYFCC0';
    private static final String TEST_CHECKOUT_ID = '0252100007BcYFVRT0';
    private static final String USER_ID = 'userId';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String PAYMENT_SESSION_ID = '71aa7692-0ed4-4e3f-a172-7793b1a80b8a';
    private static final String DR_ORDER_ID = '190296100336';

    @TestSetup
    static void setupData() {
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            DRB2B_TestEnvironment.prepareStoreWithNonDigitalCart();
        }
    }

    @isTest
    static void addCustomerCreditSourceToCheckout_Test() {

        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
            .field(WebCart.DR_Checkout_Id__c)
            .repeat(TEST_CHECKOUT_ID)
            .field(WebCart.DR_Payment_Session_Id__c)
            .repeat(PAYMENT_SESSION_ID)
            .field(WebCart.DR_Amount_Contributed__c)
            .repeat(50)
            .field(WebCart.DR_Amount_Remaining_to_be_Contributed__c)
            .repeat(2000)
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

     
        // When
        WebCart webCart = [SELECT Id, Name, AccountId, WebStoreId, DR_Checkout_Id__c FROM WebCart LIMIT 1];


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

        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new CreateSecondarySourceAndAttachToCheckoutSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonData ='{"cartId": "'+webCart.id+'","amount":"3"}';
            Map<String,object>  result2;
            try{
                result2 = DRB2B_CustomerCreditService.addCustomerCreditSourceToCheckout(jsonData);
            }catch(exception e){
                System.debug('error '+e.getMessage());
            }
        
        Test.stopTest();
         //   System.assertEquals(true, result2.get('isSuccess'));
        //    System.assertEquals('b3ac2807-d1b6-4b54-bced-e74506453794', result2.get('sourceId'));
        }
        
    }

    @isTest
    static void addCustomerCreditSourceToCheckout_NegativeTest(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
            .field(WebCart.DR_Checkout_Id__c)
            .repeat(TEST_CHECKOUT_ID)
            .field(WebCart.DR_Payment_Session_Id__c)
            .repeat(PAYMENT_SESSION_ID)
            .field(WebCart.DR_Amount_Contributed__c)
            .repeat(50)
            .field(WebCart.DR_Amount_Remaining_to_be_Contributed__c)
            .repeat(2000)
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
        String jsonData ='{"cartId": "'+webCart.id+'","amount":""}';
        Map<String,object>  result2 = DRB2B_CustomerCreditService.addCustomerCreditSourceToCheckout(jsonData);
        Test.stopTest();

        System.assertEquals(false, result2.get('isSuccess'));
        System.assertEquals(System.Label.Missing_Invalid_Input_Parameters, result2.get('errorMessage'));
        }

    }

    @isTest
    static void failedToCreateSecondarySource_Test(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];
        WebCart wCart = webCartList.get(0);
        wCart.DR_Checkout_Id__c = TEST_CHECKOUT_ID;
        wCart.DR_Payment_Session_Id__c = PAYMENT_SESSION_ID;
        wCart.DR_Amount_Contributed__c = 50;
        wCart.DR_Amount_Remaining_to_be_Contributed__c = 2000;
        update wCart;

        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new CreateSecondarySourceFailureMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonData ='{"cartId": "'+wCart.id+'","amount":"3"}';
        Map<String,object>  result = DRB2B_CustomerCreditService.addCustomerCreditSourceToCheckout(jsonData);
        Test.stopTest();

        System.assertEquals(false, result.get('isSuccess'));
        System.assertEquals('DR API error:A parameter is missing.', result.get('errorMessage'));
        }

    }

    @isTest
    static void failedToUpdateCheckoutWithSource_Test(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];
        WebCart wCart = webCartList.get(0);
        wCart.DR_Checkout_Id__c = TEST_CHECKOUT_ID;
        wCart.DR_Payment_Session_Id__c = PAYMENT_SESSION_ID;
        wCart.DR_Amount_Contributed__c = 50;
        wCart.DR_Amount_Remaining_to_be_Contributed__c = 2000;
        update wCart;

        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new UpdateSourceToCheckoutFailureMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonData ='{"cartId": "'+wCart.id+'","amount":"3"}';
        Map<String,object>  result = DRB2B_CustomerCreditService.addCustomerCreditSourceToCheckout(jsonData);
        Test.stopTest();

        System.assertEquals(false, result.get('isSuccess'));
        System.assertEquals('DR API error:Source a72266b9-df61-4d94-8378-21075e2b11723 was not found.', result.get('errorMessage'));
        }

    }

    @isTest
    static void whenInvalidAmountSpecified_Test(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];
        WebCart wCart = webCartList.get(0);

        Test.startTest();
        String jsonData ='{"cartId": "'+wCart.id+'","amount":"-50"}';
        Map<String,object>  result = DRB2B_CustomerCreditService.addCustomerCreditSourceToCheckout(jsonData);
        Test.stopTest();

        System.assertEquals(false, result.get('isSuccess'));
        System.assertEquals(System.Label.Invalid_Amount, result.get('errorMessage'));
        }
    }

    @isTest
    static void whenRequestedAmountGreaterThanRequired_Test(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];
        WebCart wCart = webCartList.get(0);
        wCart.DR_Checkout_Id__c = TEST_CHECKOUT_ID;
        wCart.DR_Payment_Session_Id__c = PAYMENT_SESSION_ID;
        wCart.DR_Amount_Contributed__c = 50;
        wCart.DR_Amount_Remaining_to_be_Contributed__c = 500;
        update wCart;

        Test.startTest();
        String jsonData ='{"cartId": "'+wCart.id+'","amount":"700"}';
        Map<String,object>  result = DRB2B_CustomerCreditService.addCustomerCreditSourceToCheckout(jsonData);
        Test.stopTest();

        System.assertEquals(false, result.get('isSuccess'));
        System.assertEquals(System.Label.Invalid_Amount, result.get('errorMessage'));
        }
    }

    @isTest
    static void deattachPaymentToCheckout_Test() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {

        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];

        WebCart wCart = webCartList.get(0);
        wCart.DR_Checkout_Id__c = TEST_CHECKOUT_ID;
        wCart.DR_Payment_Session_Id__c = PAYMENT_SESSION_ID;
        wCart.DR_Amount_Contributed__c = 50;
        wCart.DR_Amount_Remaining_to_be_Contributed__c = 2000;
        update wCart;

        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DeattachPaymentToCheckoutSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonData ='{"cartId": "'+wCart.id+'","sourceId":"b3ac2807-d1b6-4b54-bced-e74506453794"}';
        Map<String,object>  result = DRB2B_CustomerCreditService.deattachPaymentToCheckout(jsonData);
        Test.stopTest();
        System.assertEquals(true, result.get('isSuccess'));  
        }    
    }

    @isTest
    static void deattachPaymentToCheckout_NegativeTest() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];

        WebCart wCart = webCartList.get(0);
        wCart.DR_Checkout_Id__c = TEST_CHECKOUT_ID;
        wCart.DR_Payment_Session_Id__c = PAYMENT_SESSION_ID;
        wCart.DR_Amount_Contributed__c = 50;
        wCart.DR_Amount_Remaining_to_be_Contributed__c = 2000;
        update wCart;

        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DeattachPaymentToCheckoutFailureMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonData ='{"cartId": "'+wCart.id+'","sourceId":"b3ac2807-d1b6-4b54-bced-e74506453794"}';
        Map<String,object>  result = DRB2B_CustomerCreditService.deattachPaymentToCheckout(jsonData);
        Test.stopTest();
        System.assertEquals(false, result.get('isSuccess'));   
        System.assertEquals('DR API error:Source 1269000e-d21b-46e4-9b02-357724384103 was not found.', result.get('errorMessage')); 
        }
    }


    @isTest
    static void deattachPaymentToCheckout_whenInputParameterMissing(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];
        WebCart wCart = webCartList.get(0);

        Test.startTest();
        String jsonData ='{"cartId": "'+wCart.id+'","sourceId":""}';
        Map<String,object>  result = DRB2B_CustomerCreditService.deattachPaymentToCheckout(jsonData);
        Test.stopTest();

        System.assertEquals(false, result.get('isSuccess'));
        System.assertEquals(System.Label.Missing_Invalid_Input_Parameters, result.get('errorMessage'));
        }

    }

    @isTest
    static void getAmountRemainingforCheckout_Test(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];
        WebCart wCart = webCartList.get(0);
        wCart.DR_Checkout_Id__c = TEST_CHECKOUT_ID;
        wCart.DR_Payment_Session_Id__c = PAYMENT_SESSION_ID;
        wCart.DR_Amount_Contributed__c = 50;
        wCart.DR_Amount_Remaining_to_be_Contributed__c = 2000;
        update wCart;

        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new GetRemainingAmountCheckoutSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonData ='{"cartId": "'+wCart.id+'"}';
        Map<String,object>  result = DRB2B_CustomerCreditService.getAmountRemainingforCheckout(jsonData);
        Test.stopTest();

        System.assertEquals(true, result.get('isSuccess'));     
        System.assertEquals(2000, result.get('amountRemainingToBeContributed'));  
        }   

    }

    @isTest
    static void getAmountRemainingforCheckout_MissingInputParameter(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
        List<WebCart> webCartList = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState FROM WebCart];
        WebCart wCart = webCartList.get(0);

        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new GetRemainingAmountCheckoutSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonData ='{"cartId": ""}';
        Map<String,object>  result = DRB2B_CustomerCreditService.getAmountRemainingforCheckout(jsonData);
        Test.stopTest();

        System.assertEquals(false, result.get('isSuccess'));     
        System.assertEquals(System.Label.Missing_Invalid_Input_Parameters, result.get('errorMessage')); 
        }      

    }

    private class GetRemainingAmountCheckoutSuccessMock extends HttpCalloutMockRouter{
        public GetRemainingAmountCheckoutSuccessMock(){
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'get remaining amount to be contributed',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_CHECKOUT_ID,
                200,
                'Success',
                getCheckoutSuccessMock()
            );

        }
    }

    private class DeattachPaymentToCheckoutSuccessMock extends HttpCalloutMockRouter{
        public DeattachPaymentToCheckoutSuccessMock(){
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Remove Source from Checkout',
                'DELETE',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_CHECKOUT_ID +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH +
                '/' +
                'b3ac2807-d1b6-4b54-bced-e74506453794',
                204,
                'Success',
                null
            );

            this.registerJsonMock(
                'get remaining amount to be contributed',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_CHECKOUT_ID,
                200,
                'Success',
                getCheckoutSuccessMock()
            );

        }
    }

    private class DeattachPaymentToCheckoutFailureMock extends HttpCalloutMockRouter{
        public DeattachPaymentToCheckoutFailureMock(){
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Remove Source from Checkout',
                'DELETE',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_CHECKOUT_ID +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH +
                '/' +
                'b3ac2807-d1b6-4b54-bced-e74506453794',
                409,
                'Success',
                deattachSourceFailureResponse()
            );

        }
    }

    private static  DRB2B_CreateCustomerCreditModel.Response deattachSourceFailureResponse() {
        DRB2B_CreateCustomerCreditModel.Response response = new DRB2B_CreateCustomerCreditModel.Response();
        response.type = 'bad_request';
        List<DRB2B_ErrorResponseModel> errors = new List<DRB2B_ErrorResponseModel>();
        DRB2B_ErrorResponseModel error = new DRB2B_ErrorResponseModel();
        error.code = 'source_not_found';
        error.message = 'Source 1269000e-d21b-46e4-9b02-357724384103 was not found.';
        errors.add(error);

        response.errors = errors;

        return response;
    }

    private static  DRB2B_CreateCustomerCreditModel.Response createCustomerCreditErrorResponse() {
        DRB2B_CreateCustomerCreditModel.Response response = new DRB2B_CreateCustomerCreditModel.Response();
        response.type = 'bad_request';
        List<DRB2B_ErrorResponseModel> errors = new List<DRB2B_ErrorResponseModel>();
        DRB2B_ErrorResponseModel error = new DRB2B_ErrorResponseModel();
        error.code = 'missing_parameter';
        error.message = 'A parameter is missing.';
        errors.add(error);

        response.errors = errors;

        return response;
    }

    Public class UpdateSourceToCheckoutFailureMock extends HttpCalloutMockRouter{
        public UpdateSourceToCheckoutFailureMock(){
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'create secondary Source',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.PAYMENT_PATH +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH,
                201,
                'Success',
                createCustomerCreditResponseModel()
            );

            this.registerJsonMock(
                'attach Source',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_CHECKOUT_ID +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH +
                '/' +
                'b3ac2807-d1b6-4b54-bced-e74506453794',
                409,
                'Success',
                attachSourceErrorResponse()
            );

        }
    }

    public class CreateSecondarySourceFailureMock extends HttpCalloutMockRouter{
        public CreateSecondarySourceFailureMock(){
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'create secondary Source',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.PAYMENT_PATH +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH,
                400,
                'Success',
                createCustomerCreditErrorResponse()
            );

        }
    }

    public class CreateSecondarySourceAndAttachToCheckoutSuccessMock extends HttpCalloutMockRouter {
        public CreateSecondarySourceAndAttachToCheckoutSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'create secondary Source',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.PAYMENT_PATH +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH,
                201,
                'Success',
                createCustomerCreditResponseModel()
            );

            this.registerJsonMock(
                'attach Source',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_CHECKOUT_ID +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH +
                '/' +
                'b3ac2807-d1b6-4b54-bced-e74506453794',
                200,
                'Success',
                attachSourceSuccessResponseModel()
            );

            this.registerJsonMock(
                'get remaining amount to be contributed',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_CHECKOUT_ID,
                200,
                'Success',
                getCheckoutSuccessMock()
            );
        }
    }

    private static  DRB2B_CreateCheckoutResponseModel getCheckoutSuccessMock() {
        DRB2B_CreateCheckoutResponseModel response = new DRB2B_CreateCheckoutResponseModel();

        response.id = TEST_CHECKOUT_ID;
        response.drCurrency = 'USD';

        DRB2B_CreateCheckoutResponseModel.Payment payment = new DRB2B_CreateCheckoutResponseModel.Payment();
        DRB2B_CreateCheckoutResponseModel.Session paymentSession = new DRB2B_CreateCheckoutResponseModel.Session();
        paymentSession.id = PAYMENT_SESSION_ID;
        paymentSession.amountContributed = 50;
        paymentSession.amountRemainingToBeContributed = 2000;
        payment.session = paymentSession;
        response.payment = payment;

        return response;
    }

    private static DRB2B_SourceModel attachSourceSuccessResponseModel() {
        DRB2B_SourceModel responseModel = new DRB2B_SourceModel();
        responseModel.type = 'customerCredit';
        return responseModel;
    }

    private static  DRB2B_CreateCustomerCreditModel.Response attachSourceErrorResponse() {
        DRB2B_CreateCustomerCreditModel.Response response = new DRB2B_CreateCustomerCreditModel.Response();
        response.type = 'conflict';
        List<DRB2B_ErrorResponseModel> errors = new List<DRB2B_ErrorResponseModel>();
        DRB2B_ErrorResponseModel error = new DRB2B_ErrorResponseModel();
        error.code = 'source_not_found';
        error.message = 'Source a72266b9-df61-4d94-8378-21075e2b11723 was not found.';
        errors.add(error);

        response.errors = errors;

        return response;
    }

    static void setConfigurationStub() {
        DRB2B_ConfigurationSelectorStubProvider stubProvider = new DRB2B_ConfigurationSelectorStubProvider();

        DRB2B_DRApiConstants.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(
            DRB2B_ConnectorConfigurationSelector.class,
            stubProvider
        );

        DRB2B_AuthWire.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(
            DRB2B_ConnectorConfigurationSelector.class,
            stubProvider
        );
    }

    private static void setUserSelectorMock() {
        User user = (User) JSON.deserialize(
            JSON.serialize(
                new Map<String, Object>{
                    'Id' => TEST_USER_ID_FOR_MOCK,
                    'Name' => 'test',
                    'ContactId' => TEST_CONTACT_ID,
                    'LocaleSidKey' => 'en_US'
                }
            ),
            User.class
        );

        DRB2B_CustomerService.userSelector = (DRB2B_UserSelector) Test.createStub(
            DRB2B_UserSelector.class,
            new DCM_GenericStubProvider(new Map<String, Object>{ 'getById' => user })
        );
    }

    private static DRB2B_CreateCustomerCreditModel.Response createCustomerCreditResponseModel() {
        DRB2B_CreateCustomerCreditModel.Response responseModel = new DRB2B_CreateCustomerCreditModel.Response();
        responseModel.id = 'b3ac2807-d1b6-4b54-bced-e74506453794';
        return responseModel;
    }
}