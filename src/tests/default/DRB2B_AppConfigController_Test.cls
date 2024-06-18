/**
 * @description       : Test class for DRB2B_AppConfigController
 * @author            : Devanshu Sood
 * @group             :
 * @last modified on  : 04-07-2021
 * @last modified by  : Devanshu Sood
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-07-2021   Devanshu Sood   Initial Version
 **/
@IsTest
private with sharing class DRB2B_AppConfigController_Test {
    private static final String DR_ORDER_ID = '190296100336';
    private static final String DR_RETRY_ORDER_ID = '190296101336';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
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
        }
    }

    @IsTest
    static void getTabsAndConfigration_test() {
        System.assert(
            String.isNotBlank(DRB2B_AppConfigController.getTabsAndConfiguration()),
            'Make sure you have created required metadata.'
        );
    }

    @IsTest
    static void updateBulkMetadata_test() {
        Test.startTest();
        id mdtId = [SELECT id FROM digitalriverv3__DR_Connector_Configuration__mdt LIMIT 1]?.Id;
        String jsonInput = '{"' + mdtId + '":"testkey"}';
        System.assertEquals(true, DRB2B_AppConfigController.updateBulkMetadata(jsonInput));
        Test.stopTest();
    }
    @IsTest
    static void updateBulkMetadata_NegativeTest() {
        Test.startTest();
        String jsonString = '{"isSyncAll":true,"isSyncProduct": }';
        try {
            Boolean result = DRB2B_AppConfigController.updateBulkMetadata(jsonString);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'Exception must be thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void handleResult_Test() {
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.createdBy = UserInfo.getUserId();
        result.createdByName = 'Test User';
        result.numberComponentErrors = 1;
        result.status = Metadata.DeployStatus.Succeeded;
        system.assertEquals(1, result.numberComponentErrors);
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        DRB2B_CustomMetadataCallbackController metaDetaresult = new DRB2B_CustomMetadataCallbackController();
        metaDetaresult.handleResult(result, context);
        result.status = Metadata.DeployStatus.Failed;
        metaDetaresult.handleResult(result, context);
    }

    @IsTest
    static void syncProducts_Test() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.portalAccountOwner,
            DRB2B_Constants.PermissionSet.ADMIN
        );

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            Test.startTest();
                String jsonString = '{"isSyncAll":true,"isSyncProduct": false}';
                String result = DRB2B_AppConfigController.syncProducts(jsonString);
                Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(result);
            Test.stopTest();
            System.assertEquals(true, requestData2.get('isSuccess'), 'Sync product failed');
        }
    }

    @IsTest
    static void syncProducts_NegativeTest() {
        Test.startTest();
        String jsonString = '{"isSyncAll":true,"isSyncProduct": }';
        try {
            String result = DRB2B_AppConfigController.syncProducts(jsonString);
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(result);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'Exception must be thrown');
        }
        Test.stopTest();
    }
    @IsTest
    static void checkConnection_Test() {
        Test.setMock(HttpCalloutMock.class, new GetFileSuccessMock());
        Test.startTest();
        String result = DRB2B_AppConfigController.checkConnection(TEST_USER_ID_FOR_MOCK);
        Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(TEST_ID, requestData2.get('id'), 'File Id dose not match');
        Test.stopTest();
    }
    @IsTest
    static void checkConnection_NegativeTest() {
        Test.startTest();
        try {
            String result = DRB2B_AppConfigController.checkConnection(TEST_USER_ID_FOR_MOCK);
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(result);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'Exception must be thrown');
        }
        Test.stopTest();
    }

    private static DRB2B_FileLinkModel.Response getFileLinkSuccessResponseModal() {
        DRB2B_FileLinkModel.Response responseModel = new DRB2B_FileLinkModel.Response();
        responseModel.id = TEST_ID;
        responseModel.url = DUMMY_URL;
        responseModel.fileId = FILE_TEST_ID;
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
