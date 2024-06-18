@IsTest
private class DRB2B_InvoiceAndCreditMemoServiceTest {
    private static final String DR_ORDER_ID = '190296100336';
    private static final String DR_RETRY_ORDER_ID = '190296101336';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
    private static final String INVOICE_FILE_ID = '9c163f29-781a-4029-9090-203eb69698c5';
    private static final String CREDIT_MEMO_FILE_ID = '9c16as9-781a-4029-9090-20323h94h7';

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
        }
    }

    @isTest
    static void captureDrInvoiceAndCreditMemoFileIds_InvoiceFileId_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            String payLoad =
                '{"id":"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0","type":"order.invoice.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"' + INVOICE_FILE_ID + '","orderId":"' +
                DR_ORDER_ID +
                '","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            Test.startTest();
                RestResponse response = new RestResponse();
                new DRB2B_InvoiceAndCreditMemoService().captureDrInvoiceAndCreditMemoFileIds(response, payLoad);
            Test.stopTest();
            DR_Invoice_Credit_Memo__c drInvoice = [Select File_Id__c From DR_Invoice_Credit_Memo__c Where File_Type__c = 'Invoice' Limit 1];
            System.assertEquals(true, drInvoice.File_Id__c.contains(INVOICE_FILE_ID), 'DR Invoice File Id should exist');
        }
    }

    @isTest
    static void captureDrInvoiceAndCreditMemoFileIds_CreditMemoFileId_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            String payLoad =
                '{"id":"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0","type":"order.credit_memo.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"' + CREDIT_MEMO_FILE_ID + '","orderId":"' +
                DR_ORDER_ID +
                '","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            Test.startTest();
                RestResponse response = new RestResponse();
                new DRB2B_InvoiceAndCreditMemoService().captureDrInvoiceAndCreditMemoFileIds(response, payLoad);
            Test.stopTest();
            DR_Invoice_Credit_Memo__c drCreditMemo = [Select File_Id__c From DR_Invoice_Credit_Memo__c Where File_Type__c = 'Credit Memo' Limit 1];
            System.assertEquals(true, drCreditMemo.File_Id__c.contains(CREDIT_MEMO_FILE_ID), 'DR Credit Memo File Id should exist');
        }
    }

    @isTest
    static void captureDrInvoiceAndCreditMemoFileIds_SfOrderWithDrOrderIdDoesNotExist_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            String eventId = 'c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0';
            String payLoad = '{"id":"' + eventId + '","type":"order.invoice.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"9c163f29-781a-4029-9090-203eb69698c5","orderId":"32432","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            Test.startTest();
                RestResponse response = new RestResponse();
                new DRB2B_InvoiceAndCreditMemoService().captureDrInvoiceAndCreditMemoFileIds(response, payLoad);
            Test.stopTest();
            DR_Failed_Event__c failedEvent = [Select Event_Id__c from DR_Failed_Event__c][0];
            System.assertEquals(eventId, failedEvent.Event_Id__c, 'Failed Event information should be captured in DR Failed Event object');
        }
    }

    @isTest
    static void getInvoiceAndCreditMemoFileIds_Test() {
        Order orderRec;
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            orderRec = [Select Id, DR_Order_Id__c From Order Limit 1][0];
            ATK.SaveResult result = ATK.prepare(DR_Invoice_Credit_Memo__c.SObjectType, 2)
                                        .build(EntityBuilderFactory.drInvocieCreditMemoBuilder)
                                        .save(false);

            DR_Invoice_Credit_Memo__c drInvocieCreditmemo = (DR_Invoice_Credit_Memo__c) result.get(DR_Invoice_Credit_Memo__c.SObjectType)[0];
            drInvocieCreditmemo.Event_Id__c = 'c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0';
            drInvocieCreditmemo.File_Id__c = INVOICE_FILE_ID;
            drInvocieCreditmemo.File_Type__c = 'Invoice';
            drInvocieCreditmemo.OrderId__c = orderRec.Id;
            insert drInvocieCreditmemo;

            DR_Invoice_Credit_Memo__c drCreditmemo = (DR_Invoice_Credit_Memo__c) result.get(DR_Invoice_Credit_Memo__c.SObjectType)[1];
            drCreditmemo.Event_Id__c = 'd8jbj2da-1510-4cd6-9d91-8d9cd047jsdf8';
            drCreditmemo.File_Id__c = CREDIT_MEMO_FILE_ID;
            drCreditmemo.File_Type__c = 'Credit Memo';
            drCreditmemo.OrderId__c = orderRec.Id;
            insert drCreditmemo;
        }

        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
                Map<String, List<String>> fileTypeFileIdsMap = new DRB2B_InvoiceAndCreditMemoService()
                    .getInvoiceAndCreditMemoFileIds(orderRec.Id);
                System.assertEquals(true, fileTypeFileIdsMap.get('Invoice').contains(INVOICE_FILE_ID), 'DR Invoice File Id should exist');
                System.assertEquals(true, fileTypeFileIdsMap.get('Credit Memo').contains(CREDIT_MEMO_FILE_ID), 'DR Credit Memo File Id should exist');
            Test.stopTest();
        }
    }

}