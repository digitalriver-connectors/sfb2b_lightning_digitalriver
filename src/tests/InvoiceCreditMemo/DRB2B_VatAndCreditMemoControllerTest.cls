@IsTest
private class DRB2B_VatAndCreditMemoControllerTest {
    private static final String DR_ORDER_ID = '190296100336';
    private static final String DR_RETRY_ORDER_ID = '190296101336';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
    private static final String FILE_ID = 'c939fc0f-b9ae-4b17-a1ba-f86ae46e0c66';
    private static final String TEST_ID = '111111111111111';
    private static final String DUMMY_URL = 'www.google.com';
    private static final String FILE_TEST_ID = '222222222222';
    private static final String CREATED = 'Created';

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
            result = ATK.prepare(DR_Invoice_Credit_Memo__c.SObjectType, 1)
                .build(EntityBuilderFactory.drInvocieCreditMemoBuilder)
                .save(false);

            DR_Invoice_Credit_Memo__c drInvocieCreditmemo = (DR_Invoice_Credit_Memo__c) result.get(
                DR_Invoice_Credit_Memo__c.SObjectType
            )[0];
            drInvocieCreditmemo.Event_Id__c = 'EventId';
            drInvocieCreditmemo.File_Id__c = FILE_ID;
            drInvocieCreditmemo.File_Type__c = 'Invoice';
            drInvocieCreditmemo.OrderId__c = sfOrder.Id;
            insert drInvocieCreditmemo;

            CartCheckoutSession cartCheckOutSession = new CartCheckoutSession();
            cartCheckOutSession.WebCartId = webCart.Id;
            cartCheckOutSession.OrderId = sfOrder.Id;
            cartCheckOutSession.State = 'Payment And Billing Address';
            cartCheckOutSession.Name = 'Test';
            insert cartCheckOutSession;
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getFileLink_Test() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetFileSuccessMock());
        Order sfOrder = [Select id from Order where DR_Order_Id__c=:DR_ORDER_ID Limit 1];

        RestResponse response = new RestResponse();
        String result = DRB2B_VatAndCreditMemoController.getFileLink(FILE_ID, sfOrder.Id);
        Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.debug('requestData2 : ' + requestData2);
        System.assertEquals(FILE_ID, requestData2.get('fileId'), 'File dose not match');
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getFileLink_NegativeTest() {
        RestResponse response = new RestResponse();
        try {
            Order sfOrder = [Select id from Order where DR_Order_Id__c=:DR_ORDER_ID Limit 1];
            String result = DRB2B_VatAndCreditMemoController.getFileLink(FILE_ID, sfOrder.Id);
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.debug('requestData2 : ' + requestData2);
        } catch (Exception e) {
            System.assertEquals(DRB2B_DRApiConstants.ERROR_RESPONSE_CODE, 400, 'Error code should be matched');
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getInvoiceAndCreditMemo_Test() {
        Order sfOrder = [SELECT Id FROM Order LIMIT 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
                String result = DRB2B_VatAndCreditMemoController.getInvoiceAndCreditMemo(sfOrder.Id);
                Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(result);
                System.debug('requestData2 : ' + requestData2);
                System.assertEquals(
                    new List<String>{ FILE_ID },
                    requestData2.get('Invoice'),
                    'File Id does not match'
                );
            Test.stopTest();
        }
    }

    private static DRB2B_FileLinkModel.Response getFileLinkSuccessResponseModal() {
        DRB2B_FileLinkModel.Response responseModel = new DRB2B_FileLinkModel.Response();
        responseModel.id = TEST_ID;
        responseModel.url = DUMMY_URL;
        responseModel.fileId = FILE_ID;
        return responseModel;
    }

    private static DRB2B_TaxIdentifierModal.Response getFileLinkErrorResponseModal() {
        DRB2B_ErrorResponseModel errorResponseModel = new DRB2B_ErrorResponseModel();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierModal.Response();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponseModel>{ errorResponseModel };
        return responseModel;
    }

    private class GetFileSuccessMock extends HttpCalloutMockRouter {
        private GetFileSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Get File Url',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.GET_FILE_LINK_PATH,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                getFileLinkSuccessResponseModal()
            );
        }
    }

    private class GetFileErrorMock extends HttpCalloutMockRouter {
        private GetFileErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Get File Url',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.GET_FILE_LINK_PATH,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                getFileLinkErrorResponseModal()
            );
        }
    }
}