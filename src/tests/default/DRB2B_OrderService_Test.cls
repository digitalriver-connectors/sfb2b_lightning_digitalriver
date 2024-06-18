@isTest
public class DRB2B_OrderService_Test {
    
    private static final String DR_ORDER_ID = '190296100336';
    private static final String DR_ORDER_ID2 = '260234230336';
    
     @TestSetup
    static void setupData() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult result = ATK.prepare(User.SObjectType, 1)
                .build(EntityBuilderFactory.userBuilder)
                .save(false);

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

            User usr1 = (User) result.get(User.SObjectType)[0];
            Profile shopperProfile = [SELECT Id FROM Profile WHERE Name = :DRB2B_Constants.Profile.DR_SHOPPER LIMIT 1];
            usr1.ProfileId = shopperProfile.Id;
            usr1.ContactId = con.Id;
            insert usr1;

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

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = webCart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            sfOrder.DR_Order_State__c = DRB2B_Constants.DrOrderState.CANCELLED;
            insert sfOrder;

            CartCheckoutSession cartCheckOutSession = new CartCheckoutSession();
            cartCheckOutSession.WebCartId = WebCart.Id;
            cartCheckOutSession.OrderId = sfOrder.Id;
            cartCheckOutSession.State = 'Payment And Billing Address';
            cartCheckOutSession.Name = 'Test';
            insert cartCheckOutSession;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            orderItem.Type = 'Order Product';
            orderItem.DR_Order_Item_State__c = DRB2B_Constants.Fulfillment.LINE_ITEM_CANCELLED_STATUS;
            insert orderItem;

            result = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                .build(EntityBuilderFactory.drFulfillmentBuilder)
                .save(false);
            DR_Fulfillment__c drFulfillment = (DR_Fulfillment__c) result.get(DR_Fulfillment__c.SObjectType)[0];
            drFulfillment.DR_Order_Id__c = '190296100336';
            drFulfillment.Eligible_For_Fulfillment__c = true;
            drFulfillment.Order_Id__c = sfOrder.Id;
            insert drFulfillment;
            
            result = ATK.prepare(DR_Transaction_Payment__c.SObjectType, 1)
                .build(EntityBuilderFactory.drTransactionPaymentBuilder)
                .save(false);

            DR_Transaction_Payment__c drTransactioPayment = (DR_Transaction_Payment__c) result.get(
                DR_Transaction_Payment__c.SobjectType
            )[0];
            drTransactioPayment.Order__c = sfOrder.Id;
            drTransactioPayment.Cart__c = WebCart.Id;
            drTransactioPayment.Account__c = sfOrder.AccountId;
            drTransactioPayment.Amount__c = 20.99;
            drTransactioPayment.Card_Type__c = 'Visa';
            drTransactioPayment.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            drTransactioPayment.User__c = usr1.Id;
            drTransactioPayment.CurrencyISOCode__c = 'USD';
            drTransactioPayment.Payment_Method__c = 'creditCard';
            drTransactioPayment.Transaction_Type__c = 'AUTH';
            insert drTransactioPayment;
        }
    }

    
    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateOfflineRefund_Test() {
        Test.setMock(HttpCalloutMock.class, new DRB2B_MockResponseOrderServiceTest());
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
            String actualValue = DRB2B_OrderService.getRefundsWithPendingInformation(DR_ORDER_ID2);
            String expectedValue = '[{"token":"token1234","refundId":"id123","orderId":"260234230336"}]';
            System.assertEquals(actualValue, expectedValue);
            Test.stopTest();
        }
    }

    
    @isTest
    static void getSFOrderIdFromOrderObject_Test () {
         Test.setMock(HttpCalloutMock.class, new DRB2B_MockResponseOrderServiceTest());
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();

            DRB2B_OrderService orderService = new DRB2B_OrderService();
            Order order = orderService.getSFOrderIdFromOrderObject(DR_ORDER_ID2);
            System.assertEquals(null, order);
            
            Id orderId = [select id from Order where DR_Order_Id__c =: DR_ORDER_ID].Id;
            order = orderService.getSFOrderIdFromOrderObject(DR_ORDER_ID);
            System.assertEquals(orderId,order.Id);

            Test.stopTest();
        } 
    }

    @isTest
    static void isValidStatusCode_Test () {
        String testBody = 'testBody';
        Integer testStatusCode = 200;
        String testStatus = 'SUCCESS';
        String testHeaderKey = 'testKey';
        String testHeaderValue = 'testValue';

        HttpResponse response = new HttpResponse();
        response.setBody(testBody);
        response.setStatusCode(testStatusCode);
        response.setStatus(testStatus);
        response.setHeader(testHeaderKey, testHeaderValue);
        //When
        DCM_HttpClient.Response testResponse = new DCM_HttpClient.BaseResponse(response);
        boolean isSuccess = DRB2B_OrderService.isValidStatusCode(testResponse);
        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void getOrderWithLines_Test () {
        Test.setMock(HttpCalloutMock.class, new DRB2B_MockResponseOrderServiceTest());
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        Id cartId = [select Id from WebCart].Id;
        Id orderId = [select Id from Order].Id;

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();

            DRB2B_OrderService obj = new DRB2B_OrderService();
            Order o = obj.getOrderWithLines(cartId);
            system.assertEquals(orderId, o.Id);
            Test.stopTest();
        }
    }

    @isTest
    static void updateDROrderWithSfOrderUpstreamId_Test () {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        Id cartId = [select Id from WebCart].Id;
        //Id sfOrderId = [select Id from Order].Id;

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Order sfOrder = [SELECT Id,orderNumber, AccountId, DR_Order_Id__c, DR_Order_State__c FROM Order LIMIT 1];
            sfOrder.DR_Order_State__c = DRB2B_Constants.DrOrderState.ACCEPTED;
            sfOrder.DR_SF_CartId__c = cartId;
            update sfOrder;
            Test.startTest();

            DRB2B_OrderService obj = new DRB2B_OrderService();
            obj.updateDROrderWithSfOrderUpstreamId(DR_ORDER_ID2,sfOrder);
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void updateDROrderWithSfOrderUpstreamIdInvalid_Test () {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorInvalid());
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        Id cartId = [select Id from WebCart].Id;
        //Id sfOrderId = [select Id from Order].Id;

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Order sfOrder = [SELECT Id,orderNumber, AccountId, DR_Order_Id__c, DR_Order_State__c FROM Order LIMIT 1];
            sfOrder.DR_Order_State__c = DRB2B_Constants.DrOrderState.ACCEPTED;
            sfOrder.DR_SF_CartId__c = cartId;
            update sfOrder;
            Test.startTest();

            DRB2B_OrderService obj = new DRB2B_OrderService();
            try{
                obj.updateDROrderWithSfOrderUpstreamId(DR_ORDER_ID2,sfOrder);
            }catch(exception ex){
                System.debug('Exception ::>>'+ex.getMessage());
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void getPaymentDetail_Test () {
        // Assign DR Integration Permission Set to User
        
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        Id cartId = [select Id from WebCart].Id;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.StartTest();
            DRB2B_OrderService orderService = new DRB2B_OrderService();
            String result = orderservice.getPaymentDetail(cartId);
            //system.assertEquals(true, result.contains('isSuccess'));
            Test.stopTest();
        } 
    }
    
    @isTest
    static void getPaymentDetailByCartId_Test () {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        Id cartId = [select Id from WebCart].Id;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {

            Test.startTest();
            DRB2B_OrderService orderService = new DRB2B_OrderService();
            String result = orderservice.getPaymentDetailByCartId(cartId);
            system.assertEquals(true, result.contains('isSuccess'));
            Test.stopTest();
        } 
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://api.digitalriver.com/orders/260234230336', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            Product2 pro = [SELECT ID from Product2 LIMIT 1];
            DRB2B_updateCheckoutRequestModel response = new DRB2B_updateCheckoutRequestModel();
            DRB2B_OrderResponseModel.Items items = new DRB2B_OrderResponseModel.Items();
            items.id = '245854040336';
            items.skuId = pro.Id;
            
            DRB2B_OrderResponseModel.Fees fees = new DRB2B_OrderResponseModel.Fees();
            fees.amount = 10.5;
            fees.taxAmount = 5.5;
            
            DRB2B_OrderResponseModel resModel = new DRB2B_OrderResponseModel();
            resModel.items = new List<DRB2B_OrderResponseModel.Items>();
            resModel.items.add(items);
            resModel.shippingChoice = fees;
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.Serialize(resModel));
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpResponseGeneratorInvalid implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://api.digitalriver.com/orders/260234230336', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            DRB2B_ErrorsResponseModel errors = new DRB2B_ErrorsResponseModel();
            
            DRB2B_ErrorResponseModel error = new DRB2B_ErrorResponseModel();
            error.code = '400';
            error.message = 'Invalid Request';
            error.parameter = 'NA';
            
            errors.errors = new List<DRB2B_ErrorResponseModel>();
            errors.errors.add(error);
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.Serialize(errors));
            res.setStatusCode(400);
            return res;
        }
    }
}