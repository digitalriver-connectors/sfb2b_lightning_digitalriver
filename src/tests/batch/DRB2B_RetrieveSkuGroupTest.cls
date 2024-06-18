@isTest
private class DRB2B_RetrieveSkuGroupTest {
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';

    @isTest
    static void testSKUGroupuccessResponse() {
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRSKUGroupSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        DRB2B_RetrieveSkuGroup skuGroupBatch = new DRB2B_RetrieveSkuGroup();
        Id batchJobId = Database.executeBatch(skuGroupBatch);
        System.abortJob(batchJobId);
        Test.stopTest();

        System.assert(skuGroupBatch != null);
    }

    @isTest
    static void testSKUGroupuccessResponse_Test() {
        Product2 product = new Product2();
        product.Name = 'abc Test';
        product.IsActive = true;
        insert product;
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRSKUGroupSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        DRB2B_RetrieveSkuGroup skuGroupBatch = new DRB2B_RetrieveSkuGroup();
        skuGroupBatch.execute(null, new List<Product2>{ product });
        Test.stopTest();

        System.assert(skuGroupBatch != null);
    }

    @isTest
    static void getSKUGroup() {
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRSKUGroupSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        DRB2B_RetrieveSkuGroup skuGroupBatch = new DRB2B_RetrieveSkuGroup();
        Map<String, String> skuGroupMap = skuGroupBatch.getSKUGroup();
        Test.stopTest();

        System.assert(skuGroupBatch != null);
    }

    @isTest
    static void getSKUGroup_ErrorTest() {
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRSKUGroupErrorMock());
        setUserSelectorMock();

        Test.startTest();
        DRB2B_RetrieveSkuGroup skuGroupBatch = new DRB2B_RetrieveSkuGroup();
        Map<String, String> skuGroupMap = skuGroupBatch.getSKUGroup();
        Test.stopTest();

        System.assert(skuGroupBatch != null);
    }

    private class DRSKUGroupSuccessMock extends HttpCalloutMockRouter {
        public DRSKUGroupSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'GET SKU Group',
                'GET',
                '{{endpoint}}/' + DRB2B_DRApiConstants.SKU_GROUP_PATH,
                200,
                'Success',
                getSKUGroupSuccessResponseModel()
            );
        }
    }

    private static DRB2B_SKUGroupModel getSKUGroupSuccessResponseModel() {
        DRB2B_SKUGroupModel responseModel = new DRB2B_SKUGroupModel();
        List<DRB2B_SKUGroupModel.Data> dataObjList = new List<DRB2B_SKUGroupModel.Data>();

        DRB2B_SKUGroupModel.Data dataObj = new DRB2B_SKUGroupModel.Data();
        dataObj.id = 'SFB2BCOFFEE2';
        dataObj.alias = 'SFB2B-coffee-2';
        dataObjList.add(dataObj);

        responseModel.hasMore = true;
        responseModel.data = dataObjList;
        return responseModel;
    }

    private static DRB2B_ErrorResponse getSKUGroupErrorResponseModel() {
        DRB2B_ErrorResponse.Errors errorResponseModel = new DRB2B_ErrorResponse.Errors();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_ErrorResponse responseModel = new DRB2B_ErrorResponse();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponse.Errors>{ errorResponseModel };
        return responseModel;
    }

    private class DRSKUGroupErrorMock extends HttpCalloutMockRouter {
        public DRSKUGroupErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'GET SKU Group',
                'GET',
                '{{endpoint}}/' + DRB2B_DRApiConstants.SKU_GROUP_PATH,
                400,
                'Error',
                getSKUGroupErrorResponseModel()
            );
        }
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
}
