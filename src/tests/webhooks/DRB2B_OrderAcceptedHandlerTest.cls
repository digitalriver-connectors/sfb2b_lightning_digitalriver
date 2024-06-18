@IsTest
private class DRB2B_OrderAcceptedHandlerTest {
    private static final String DR_ORDER_ID = '190296100336';

     @TestSetup
    static void setupData() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult resultAccount = ATK.prepare(Account.SObjectType, 1)
                .build(EntityBuilderFactory.accountBuilder)
                .save(false);
            Account acc = (Account) resultAccount.get(Account.SObjectType)[0];
            acc.OwnerId = DRB2B_TestEnvironment.portalAccountOwner.Id;
            insert acc;

            ATK.SaveResult resultContact = ATK.prepare(Contact.SObjectType, 1)
                .build(EntityBuilderFactory.contactBuilder)
                .save(false);
            Contact con = (Contact) resultContact.get(Contact.SObjectType)[0];
            con.AccountId = acc.Id;
            insert con;

            ATK.SaveResult result = ATK.prepare(User.SObjectType, 1).build(EntityBuilderFactory.userBuilder).save(false);
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
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            insert orderItem;

            result = ATK.prepare(DR_Transaction_Payment__c.SObjectType, 1)
                .build(EntityBuilderFactory.drTransactionPaymentBuilder)
                .save(false);
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateWebhookEventPayload_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                DRB2B_OrderAcceptedHandler orderAcceptedHandler = new DRB2B_OrderAcceptedHandler();
                String webhookEventPayload = '{"id":"65d6d6f8-471f-4373-a6cb-0a6e6328c10d","type":"order.accepted","data":{"object":{"id":"190296100336","createdTime":"2020-09-01T13:48:51Z","customerId":"0034R00003KcCvXQAV","currency":"USD","email":"storefront@gmail.com","shipTo":{"address":{"line1":"70 Surrey Lane","city":"Danboro","postalCode":"18916","state":"CA","country":"US"},"name":"RandhawaAmarjit","phone":"98765442310"},"shipFrom":{"address":{"line1":"3000 Northwoods Pkwy","line2":"Ste 150","city":"Eden Prairie","postalCode":"55344","state":"Minnesota","country":"US"}},"totalAmount":18,"subtotal":18,"totalFees":9,"totalTax":0,"totalDuty":0,"totalDiscount":0,"totalShipping":0,"items":[{"id":"99985600336","skuId":"a1F4R000005ycAsUAI","amount":9,"quantity":1,"metadata":{"skuId":"SS-DR-BB","cartItemId":"a0F4R00002LjvN9UAJ"},"state":"created","stateTransitions":{"created":"2020-09-01T13:48:51Z"},"tax":{"rate":0,"amount":0},"subscriptionInfo":{"subscriptionId":"a0F4R00002LjvN9UAJ","terms":"terms.","autoRenewal":false,"freeTrial":false,"billingAgreementId":"a684356f-a6e9-4c08-8835-c2da41b59938"},"availableToRefundAmount":0}],"metadata":{"cartId":"a0G4R00001eKpIbUAK"},"updatedTime":"2020-09-01T13:48:51Z","locale":"en_US","customerType":"business","chargeType":"customer_initiated","paymentSessionId":"5f971727-9782-4d5f-afb8-2d7132bfe7c1","sellingEntity":{"id":"DR_INC-ENTITY","name":"Digital River Inc."},"state":"accepted","stateTransitions":{"accepted":"2020-09-01T13:48:54Z"},"fraudState":"passed","fraudStateTransitions":{"passed":"2020-09-01T13:48:54Z"},"charges":[{"id":"164f2090-50f2-4fda-a7c1-ad4490521091","createdTime":"2020-09-01T13:48:53Z","currency":"USD","amount":18,"state":"capturable","captured":false,"refunded":false,"sourceId":"aaff8bfb-0ec2-4ebd-ba8c-56942f30b375","type":"customer_initiated"}],"requestToBeForgotten":false,"capturedAmount":0,"cancelledAmount":0,"availableToRefundAmount":0,"liveMode":false}},"digitalRiverVersion":"2020-01-07","liveMode":false,"createdTime":"2020-09-01T13:49:02.727Z"}';
                DRB2B_OrderEventsRequestModel orderEventsRequestModel = (DRB2B_OrderEventsRequestModel) DRB2B_OrderEventsRequestModel.deserializeEvent(
                    webhookEventPayload
                );
                Boolean isWebhookValid = orderAcceptedHandler.validateWebhookEventPayload(
                    orderEventsRequestModel,
                    webhookEventPayload
                );
                System.assertEquals(true, isWebhookValid, 'Webhook handler is not valid');
            Test.stopTest();
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateWebhookEventPayload_NegativeTest() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                DRB2B_OrderAcceptedHandler orderAcceptedHandler = new DRB2B_OrderAcceptedHandler();
                String webhookEventPayload = '{"id":"65d6d6f8-471f-4373-a6cb-0a6e6328c10d","type":"order.accepted","data":{"object":{"id":"","createdTime":"2020-09-01T13:48:51Z","customerId":"0034R00003KcCvXQAV","currency":"USD","email":"storefront@gmail.com","shipTo":{"address":{"line1":"70 Surrey Lane","city":"Danboro","postalCode":"18916","state":"CA","country":"US"},"name":"RandhawaAmarjit","phone":"98765442310"},"shipFrom":{"address":{"line1":"3000 Northwoods Pkwy","line2":"Ste 150","city":"Eden Prairie","postalCode":"55344","state":"Minnesota","country":"US"}},"totalAmount":18,"subtotal":18,"totalFees":9,"totalTax":0,"totalDuty":0,"totalDiscount":0,"totalShipping":0,"items":[{"id":"99985600336","skuId":"a1F4R000005ycAsUAI","amount":9,"quantity":1,"metadata":{"skuId":"SS-DR-BB","cartItemId":"a0F4R00002LjvN9UAJ"},"state":"created","stateTransitions":{"created":"2020-09-01T13:48:51Z"},"tax":{"rate":0,"amount":0},"subscriptionInfo":{"subscriptionId":"a0F4R00002LjvN9UAJ","terms":"terms.","autoRenewal":false,"freeTrial":false,"billingAgreementId":"a684356f-a6e9-4c08-8835-c2da41b59938"},"availableToRefundAmount":0}],"metadata":{"cartId":"a0G4R00001eKpIbUAK"},"updatedTime":"2020-09-01T13:48:51Z","locale":"en_US","customerType":"business","chargeType":"customer_initiated","paymentSessionId":"5f971727-9782-4d5f-afb8-2d7132bfe7c1","sellingEntity":{"id":"DR_INC-ENTITY","name":"Digital River Inc."},"state":"accepted","stateTransitions":{"accepted":"2020-09-01T13:48:54Z"},"fraudState":"passed","fraudStateTransitions":{"passed":"2020-09-01T13:48:54Z"},"charges":[{"id":"164f2090-50f2-4fda-a7c1-ad4490521091","createdTime":"2020-09-01T13:48:53Z","currency":"USD","amount":18,"state":"capturable","captured":false,"refunded":false,"sourceId":"aaff8bfb-0ec2-4ebd-ba8c-56942f30b375","type":"customer_initiated"}],"requestToBeForgotten":false,"capturedAmount":0,"cancelledAmount":0,"availableToRefundAmount":0,"liveMode":false}},"digitalRiverVersion":"2020-01-07","liveMode":false,"createdTime":"2020-09-01T13:49:02.727Z"}';
                DRB2B_OrderEventsRequestModel orderEventsRequestModel = (DRB2B_OrderEventsRequestModel) DRB2B_OrderEventsRequestModel.deserializeEvent(
                    webhookEventPayload
                );
                try {
                    Boolean isWebhookValid = orderAcceptedHandler.validateWebhookEventPayload(
                        orderEventsRequestModel,
                        webhookEventPayload
                    );
                } catch (DRB2B_WebhookException we) {
                    System.assertNotEquals(
                        null,
                        we,
                        'Webhook Exception should be thrown when we pass a NULL Webhook Event Object'
                    );
                }
            Test.stopTest();
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void processWebhookEvent_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                DRB2B_OrderAcceptedHandler orderAcceptedHandler = new DRB2B_OrderAcceptedHandler();
                List<Order> orderlist = [Select Id from Order where DR_Order_Id__c =:DR_ORDER_ID limit 1];
                string SF_OrderId = orderlist.get(0).Id;
                String webhookEventPayload =
                    '{"id":"65d6d6f8-471f-4373-a6cb-0a6e6328c10d","type":"order.accepted","data":{"object":{"id":"' +
                    DR_ORDER_ID +
                    '","createdTime":"2020-09-01T13:48:51Z","customerId":"0034R00003KcCvXQAV","currency":"USD","email":"storefront@gmail.com","shipTo":{"address":{"line1":"70 Surrey Lane","city":"Danboro","postalCode":"18916","state":"CA","country":"US"},"name":"RandhawaAmarjit","phone":"98765442310"},"shipFrom":{"address":{"line1":"3000 Northwoods Pkwy","line2":"Ste 150","city":"Eden Prairie","postalCode":"55344","state":"Minnesota","country":"US"}},"totalAmount":18,"subtotal":18,"totalFees":9,"totalTax":0,"totalDuty":0,"totalDiscount":0,"totalShipping":0,"items":[{"id":"99985600336","skuId":"a1F4R000005ycAsUAI","amount":9,"quantity":1,"metadata":{"skuId":"SS-DR-BB","cartItemId":"a0F4R00002LjvN9UAJ"},"state":"created","stateTransitions":{"created":"2020-09-01T13:48:51Z"},"tax":{"rate":0,"amount":0},"subscriptionInfo":{"subscriptionId":"a0F4R00002LjvN9UAJ","terms":"terms.","autoRenewal":false,"freeTrial":false,"billingAgreementId":"a684356f-a6e9-4c08-8835-c2da41b59938"},"availableToRefundAmount":0}],'+
                    +'"metadata":{"cartId":"a0G4R00001eKpIbUAK","sfOrderId":"'+
                    SF_OrderId+'"},"updatedTime":"2020-09-01T13:48:51Z","locale":"en_US","customerType":"business","chargeType":"customer_initiated","paymentSessionId":"5f971727-9782-4d5f-afb8-2d7132bfe7c1","sellingEntity":{"id":"DR_INC-ENTITY","name":"Digital River Inc."},"state":"accepted","stateTransitions":{"accepted":"2020-09-01T13:48:54Z"},"fraudState":"passed","fraudStateTransitions":{"passed":"2020-09-01T13:48:54Z"},"charges":[{"id":"164f2090-50f2-4fda-a7c1-ad4490521091","createdTime":"2020-09-01T13:48:53Z","currency":"USD","amount":18,"state":"capturable","captured":false,"refunded":false,"sourceId":"aaff8bfb-0ec2-4ebd-ba8c-56942f30b375","type":"customer_initiated"}],"requestToBeForgotten":false,"capturedAmount":0,"cancelledAmount":0,"availableToRefundAmount":0,"liveMode":false}},"digitalRiverVersion":"2020-01-07","liveMode":false,"createdTime":"2020-09-01T13:49:02.727Z"}';
                RestResponse response = new RestResponse();
                //Needs to make success status
                orderAcceptedHandler.processWebhookEvent(response, webhookEventPayload);
                System.assertEquals(
                    DRB2B_ApplicationConstants.SUCCESS_RESPONSE_CODE,
                    response.statusCode,
                    'Response status code must be 200'
                );
            Test.stopTest();
        }
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('https://api.digitalriver.com/orders/190296100336', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
}
