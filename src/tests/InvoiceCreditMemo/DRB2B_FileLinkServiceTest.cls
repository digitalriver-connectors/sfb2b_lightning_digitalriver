@isTest
public with sharing class DRB2B_FileLinkServiceTest {
    private static final String TEST_ID = '111111111111111';
    private static final String DUMMY_URL = 'www.google.com';
    private static final String FILE_TEST_ID = '222222222222';
    private static final String CREATED = 'Created';
    private static final String DR_ORDER_ID = '190296100336';
    
    public DRB2B_FileLinkServiceTest() {
    }
    @TestSetup
    static void setup() {
        DRB2B_TestEnvironment.prepareStoreWithNonDigitalCart();
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
            this.registerJsonMock('Get File Url', 'POST', '{{endpoint}}/' + DRB2B_DRApiConstants.GET_FILE_LINK_PATH, DRB2B_DRApiConstants.SUCCESS_STATUS, CREATED, getFileLinkSuccessResponseModal());
        }
    }

    private class GetFileErrorMock extends HttpCalloutMockRouter {
        private GetFileErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock('Get File Url', 'POST', '{{endpoint}}/' + DRB2B_DRApiConstants.GET_FILE_LINK_PATH, DRB2B_DRApiConstants.SUCCESS_STATUS, CREATED, getFileLinkErrorResponseModal());
        }
    }

    @isTest
    static void getFileLinkSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new GetFileSuccessMock());
        WebCart webCart = [SELECT Id, Name, AccountId, WebStoreId, DR_Checkout_Id__c FROM WebCart LIMIT 1];
        ATK.SaveResult result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

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
        DRB2B_FileLinkModel.Response responseModel = new DRB2B_FileLinkService().getFileLink(TEST_ID, sfOrder.Id);
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        system.assertEquals(FILE_TEST_ID, responseModel.fileId);
        system.assertEquals(DUMMY_URL, responseModel.url);
        system.assertEquals(TEST_ID, responseModel.id);
    }

    @isTest
    static void getFileLinkErrorTest() {
        Test.setMock(HttpCalloutMock.class, new GetFileErrorMock());
        WebCart webCart = [SELECT Id, Name, AccountId, WebStoreId, DR_Checkout_Id__c FROM WebCart LIMIT 1];
        ATK.SaveResult result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

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
        DRB2B_FileLinkModel.Response responseModel = new DRB2B_FileLinkService().getFileLink(TEST_ID, sfOrder.Id);
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(responseModel.errors.size() > 0);
    }
}
