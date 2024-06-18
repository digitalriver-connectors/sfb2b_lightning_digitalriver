@IsTest
private with sharing class DRB2B_CustomerServiceTest {
    private static final String ACCOUNT_ID = 'accountId';
    private static final String ACCOUNT_NAME = 'accountName';
    private static final String USER_ID = 'userId';
    private static final String USER_NAME = 'userName';
    private static final String TEST_ID = DCM_IdUtils.generate(User.getSObjectType());
    private static final String TEST2EXAMPLE_COM = 'test2example.com';
    private static final String EN_US = 'en_US';
    private static final String TEST_USER_ID = 'testUserId';
    private static final String TEST_USER_NAME = 'testUserName';
    private static final String TEST_ACCOUNT_ID = 'testAccountId';
    private static final String TEST_COMPANY = 'Test company';
    private static final String TEST_FILE_ID = 'Test file id';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';

    @isTest
    static void createCustomerSuccessTest() {
        //Given
        setCreateCustomerModelService();
        setConfigurationStub();

        Test.setMock(HttpCalloutMock.class, new DRCreateCustomerSuccessMock());

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CustomerService().createCustomer(DCM_IdUtils.generate(User.getSObjectType()), '');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(responseModel.isSuccess);
        System.assert(responseModel.metadata.containsKey(USER_ID));
        System.assert(responseModel.email == TEST2EXAMPLE_COM);
        System.assert(responseModel.locale == EN_US);
    }

    @isTest
    static void createCustomerErrorTest() {
        //Given
        setCreateCustomerModelService();
        setConfigurationStub();

        Test.setMock(HttpCalloutMock.class, new DRCreateCustomerErrorMock());

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CustomerService().createCustomer(TEST_ID, '');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(!responseModel.isSuccess);
        System.assert(String.isNotBlank(responseModel.type));
        System.assert(!responseModel.errors.isEmpty());
    }

    @isTest
    static void updateCustomerSuccessTest() {
        //Given
        setCreateCustomerModelService();
        setConfigurationStub();

        Test.setMock(HttpCalloutMock.class, new DRUpdateCustomerSuccessMock());

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CustomerService().updateCustomer(TEST_ID, '');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(responseModel.isSuccess);
        System.assert(responseModel.metadata.containsKey(USER_ID));
        System.assert(responseModel.email == TEST2EXAMPLE_COM);
        System.assert(responseModel.locale == EN_US);
    }

    @isTest
    static void updateCustomerWithTaxModelSuccessTest() {
        //Given
        setCreateCustomerModelService();
        setConfigurationStub();

        Test.setMock(HttpCalloutMock.class, new DRUpdateCustomerSuccessMock());

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CustomerService().updateCustomer(getTaxCertificate(), '');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(responseModel.isSuccess);
        System.assert(responseModel.metadata.containsKey(USER_ID));
        System.assert(responseModel.email == TEST2EXAMPLE_COM);
        System.assert(responseModel.locale == EN_US);
    }

    @isTest
    static void updateCustomerErrorTest() {
        //Given
        setCreateCustomerModelService();
        setConfigurationStub();

        Test.setMock(HttpCalloutMock.class, new DRUpdateCustomerErrorMock());

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CustomerService().updateCustomer(TEST_ID);
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(!responseModel.isSuccess);
        System.assert(String.isNotBlank(responseModel.type));
        System.assert(!responseModel.errors.isEmpty());
    }

    @isTest
    static void createCustomerAlreadyExistsTest() {
        //Given
        setCreateCustomerModelService();
        setConfigurationStub();

        Test.setMock(HttpCalloutMock.class, new DRCreateCustomerAlreadyExistsMock());

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CustomerService().createCustomer(TEST_ID, '');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(responseModel.isSuccess);
        System.assert(responseModel.metadata.containsKey(USER_ID));
        System.assert(responseModel.email == TEST2EXAMPLE_COM);
        System.assert(responseModel.locale == EN_US);
    }

    @isTest
    static void getByIdTest() {
        //Given
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRGetByIdSuccessMock());
        setUserSelectorMock();

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CustomerService().getById(TEST_ID, '');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(responseModel.id != null);
    }

    static void setConfigurationStub() {
        DRB2B_ConfigurationSelectorStubProvider stubProvider = new DRB2B_ConfigurationSelectorStubProvider();

        DRB2B_DRApiConstants.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(DRB2B_ConnectorConfigurationSelector.class, stubProvider);

        DRB2B_AuthWire.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(DRB2B_ConnectorConfigurationSelector.class, stubProvider);
    }

    private static DRB2B_CreateCustomerResponseModel getCreateCustomerAlreadyExistsResponseModel() {
        DRB2B_ErrorResponseModel errorResponseModel = new DRB2B_ErrorResponseModel();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CreateCustomerResponseModel();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponseModel>{ errorResponseModel };
        return responseModel;
    }

    private static DRB2B_CreateCustomerResponseModel getCreateSuccessCustomerResponseModel() {
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CreateCustomerResponseModel();
        responseModel.locale = EN_US;
        responseModel.type = DRB2B_DRApiConstants.CUSTOMER_TYPE_BUSINESS;
        responseModel.email = TEST2EXAMPLE_COM;
        responseModel.id = TEST_ID;
        responseModel.metadata = new Map<String, String>{ USER_ID => TEST_USER_ID };
        return responseModel;
    }

    private static DRB2B_CreateCustomerResponseModel getCreateErrorCustomerResponseModel() {
        DRB2B_ErrorResponseModel errorResponseModel = new DRB2B_ErrorResponseModel();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CreateCustomerResponseModel();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponseModel>{ errorResponseModel };
        return responseModel;
    }

    private static void setCreateCustomerModelService() {
        DRB2B_CreateCustomerRequestModel model = new DRB2B_CreateCustomerRequestModel();
        model.id = TEST_ID;
        model.email = TEST2EXAMPLE_COM;
        model.locale = EN_US;
        model.type = DRB2B_DRApiConstants.CUSTOMER_TYPE_BUSINESS;
        model.metadata = new Map<String, String>{ USER_ID => TEST_USER_ID, USER_NAME => TEST_USER_NAME, ACCOUNT_ID => TEST_ACCOUNT_ID, ACCOUNT_NAME => ACCOUNT_NAME };

        DRB2B_CustomerService.createCustomerModelService = (DRB2B_CreateCustomerModelService) Test.createStub(
            DRB2B_CreateCustomerModelService.class,
            new DCM_GenericStubProvider(new Map<String, Object>{ 'getCreateCustomerRequestModel' => model })
        );
    }

    private class DRCreateCustomerErrorMock extends HttpCalloutMockRouter {
        public DRCreateCustomerErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock('Create Customer', 'POST', '{{endpoint}}/' + DRB2B_DRApiConstants.CUSTOMERS_PATH, 404, 'Error', getCreateErrorCustomerResponseModel());
        }
    }

    private class DRGetByIdSuccessMock extends HttpCalloutMockRouter {
        public DRGetByIdSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock('Create Customer', 'GET', '{{endpoint}}/' + DRB2B_DRApiConstants.CUSTOMERS_PATH + '/' + TEST_CONTACT_ID, 200, 'Success', getCreateSuccessCustomerResponseModel());
        }
    }

    private class DRCreateCustomerAlreadyExistsMock extends HttpCalloutMockRouter {
        public DRCreateCustomerAlreadyExistsMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerEndpointVariable('id', '([0-9a-zA-Z]{15,18})');
            this.registerJsonMock(
                'Create Customer',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.CUSTOMERS_PATH,
                DRB2B_DRApiConstants.CREATE_CUSTOMER_ALREADY_EXISTS_STATUS,
                'Created',
                getCreateCustomerAlreadyExistsResponseModel()
            );
            this.registerJsonMock(
                'Update Customer',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CUSTOMERS_PATH +
                '/{{id}}',
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                'Created',
                getCreateSuccessCustomerResponseModel()
            );
        }
    }

    private class DRCreateCustomerSuccessMock extends HttpCalloutMockRouter {
        public DRCreateCustomerSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create Customer',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.CUSTOMERS_PATH,
                DRB2B_DRApiConstants.UPSERT_SUCCESS_STATUS,
                'Created',
                getCreateSuccessCustomerResponseModel()
            );
        }
    }

    private class DRUpdateCustomerErrorMock extends HttpCalloutMockRouter {
        public DRUpdateCustomerErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerEndpointVariable('id', '([0-9a-zA-Z]{15,18})');
            this.registerJsonMock('Create Customer', 'POST', '{{endpoint}}/' + DRB2B_DRApiConstants.CUSTOMERS_PATH + '/{{id}}', 404, 'Updated', getCreateErrorCustomerResponseModel());
        }
    }

    private class DRUpdateCustomerSuccessMock extends HttpCalloutMockRouter {
        public DRUpdateCustomerSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerEndpointVariable('id', '([0-9a-zA-Z]{15,18})');
            this.registerJsonMock(
                'Create Customer',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CUSTOMERS_PATH +
                '/{{id}}',
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                'Updated',
                getCreateSuccessCustomerResponseModel()
            );
        }
    }

    private static DRB2B_TaxCertificateModel getTaxCertificate() {
        DRB2B_TaxCertificateModel taxCertificate = new DRB2B_TaxCertificateModel();
        taxCertificate.taxAuthority = 'MN';
        taxCertificate.startDate = Datetime.now().addDays(-10).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        taxCertificate.endDate = Datetime.now().addDays(10).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        taxCertificate.companyName = TEST_COMPANY;
        taxCertificate.fileId = TEST_FILE_ID;
        return taxCertificate;
    }

    private static void setUserSelectorMock() {
        User user = (User) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'Id' => TEST_USER_ID_FOR_MOCK, 'Name' => 'test', 'ContactId' => TEST_CONTACT_ID, 'LocaleSidKey' => 'en_US' }),
            User.class
        );

        DRB2B_CustomerService.userSelector = (DRB2B_UserSelector) Test.createStub(DRB2B_UserSelector.class, new DCM_GenericStubProvider(new Map<String, Object>{ 'getById' => user }));
    }
}
