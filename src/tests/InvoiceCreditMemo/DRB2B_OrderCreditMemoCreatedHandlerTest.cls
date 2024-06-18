@IsTest
private class DRB2B_OrderCreditMemoCreatedHandlerTest {
    private static final String DR_ORDER_ID = '190296100336';
    private static final String DR_RETRY_ORDER_ID = '190296101336';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';

    @TestSetup
    static void setupData() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();

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
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateWebhookEventPayload_Test() {
        // Assign DR Admin Permission Set to Portal Account Owner user
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            DRB2B_OrderCreditMemoCreatedHandler orderCreditMemoHandler = new DRB2B_OrderCreditMemoCreatedHandler();
            String webhookEventPayload = '{"id":"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0","type":"order.invoice.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"9c163f29-781a-4029-9090-203eb69698c5","orderId":"187775330336","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            DRB2B_OrderInvoiceAndCreditMemoModel orderEventsRequestModel = (DRB2B_OrderInvoiceAndCreditMemoModel) DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(
                webhookEventPayload
            );
            Boolean isWebhookValid = orderCreditMemoHandler.validateWebhookEventPayload(
                orderEventsRequestModel,
                webhookEventPayload
            );
            System.assertEquals(true, isWebhookValid, 'Webhook handler is not valid');
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateWebhookEventPayload_NegativeTest() {
        // Assign DR Admin Permission Set to Portal Account Owner user
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            DRB2B_OrderCreditMemoCreatedHandler orderCreditMemoHandler = new DRB2B_OrderCreditMemoCreatedHandler();
            String webhookEventPayload = '{"id":"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0","type":"order.invoice.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"9c163f29-781a-4029-9090-203eb69698c5","orderId":"","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            DRB2B_OrderInvoiceAndCreditMemoModel orderEventsRequestModel = (DRB2B_OrderInvoiceAndCreditMemoModel) DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(
                webhookEventPayload
            );
            try {
                Boolean isWebhookValid = orderCreditMemoHandler.validateWebhookEventPayload(
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
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void processWebhookEvent_Test() {
        // Assign DR Admin Permission Set to Portal Account Owner user
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            DRB2B_OrderCreditMemoCreatedHandler orderCreditMemoHandler = new DRB2B_OrderCreditMemoCreatedHandler();
            String webhookEventPayload = '{"id":"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0","type":"order.invoice.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"9c163f29-781a-4029-9090-203eb69698c5","orderId":"187775330336","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            RestResponse response = new RestResponse();
            orderCreditMemoHandler.processWebhookEvent(response, webhookEventPayload);
            System.assertEquals(
                DRB2B_ApplicationConstants.SUCCESS_RESPONSE_CODE,
                response.statusCode,
                'Response status code must be 200'
            );
        }
    }

}