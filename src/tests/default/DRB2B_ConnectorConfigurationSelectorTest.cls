@IsTest
private class DRB2B_ConnectorConfigurationSelectorTest {
    private static final String COUNTRIES = 'countries';
    private static final String STATES = 'states';
    private static final String TEST_COMPANY = 'Test company';
    private static final String TEST_FILE_ID = 'Test file id';

    private static final String USER_ID = 'userId';
    private static final String TEST_ID = DCM_IdUtils.generate(User.getSObjectType());
    private static final String TEST2EXAMPLE_COM = 'test2example.com';
    private static final String EN_US = 'en_US';
    private static final String TEST_USER_ID = 'testUserId';

    
    @isTest
    static void getCountriesAndStatesTest() {
        //Given

        //When
        Test.startTest();
        Map<String, Object> result = DRB2B_UsersTaxCertificatesController.getCountriesAndStates();
        Test.stopTest();

        //Then
        System.assert(!result.isEmpty());
        System.assert(result.containsKey(COUNTRIES));
        System.assert(result.containsKey(STATES));
    }


    @isTest
    static void updateCustomerWithTaxCertificateTest() {
        //Given
        DRB2B_TaxCertificateModel taxCertificate = getTaxCertificate();
        stubCustomerServiceForUpdate();

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = DRB2B_UsersTaxCertificatesController.updateCustomerWithTaxCertificate(
            taxCertificate, ''
        );
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(responseModel.isSuccess);
        System.assert(!responseModel.taxCertificates.isEmpty());
    }

    @isTest
    static void getCustomerTest() {
        //Given
        stubCustomerServiceForGet();

        //When
        Test.startTest();
        DRB2B_CreateCustomerResponseModel responseModel = DRB2B_UsersTaxCertificatesController.getCustomer('');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(responseModel.isSuccess);
        System.assert(responseModel.id != null);
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

    private static void stubCustomerServiceForUpdate() {
        DRB2B_UsersTaxCertificatesController.customerService = (DRB2B_CustomerService) Test.createStub(
            DRB2B_CustomerService.class,
            new DCM_GenericStubProvider(
                new Map<String, Object>{ 'updateCustomer' => getCreateSuccessCustomerResponseModel() }
            )
        );
    }

    private static void stubCustomerServiceForGet() {
        DRB2B_CreateCustomerResponseModel getByIdResponse = getCreateSuccessCustomerResponseModel();
        getByIdResponse.id = null;

        DRB2B_UsersTaxCertificatesController.customerService = (DRB2B_CustomerService) Test.createStub(
            DRB2B_CustomerService.class,
            new DCM_GenericStubProvider(
                new Map<String, Object>{
                    'createCustomer' => getCreateSuccessCustomerResponseModel(),
                    'getById' => getByIdResponse
                }
            )
        );
    }

    private static DRB2B_CreateCustomerResponseModel getCreateSuccessCustomerResponseModel() {
        DRB2B_CreateCustomerResponseModel responseModel = new DRB2B_CreateCustomerResponseModel();
        responseModel.locale = EN_US;
        responseModel.type = DRB2B_DRApiConstants.CUSTOMER_TYPE_BUSINESS;
        responseModel.email = TEST2EXAMPLE_COM;
        responseModel.id = TEST_ID;
        responseModel.metadata = new Map<String, String>{ USER_ID => TEST_USER_ID };
        responseModel.taxCertificates = new List<DRB2B_TaxCertificateModel>{ getTaxCertificate() };
        responseModel.isSuccess = true;
        return responseModel;
    }

    private static void setConfigurationStub() {
        DRB2B_ConfigurationSelectorStubProvider stubProvider = new DRB2B_ConfigurationSelectorStubProvider();
        DRB2B_UsersTaxCertificatesController.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(
            DRB2B_ConnectorConfigurationSelector.class,
            stubProvider
        );
    }
    
    private static testmethod void getConfigAllMethodInvoke() {
        DRB2B_ConnectorConfigurationSelector configSelector = new DRB2B_ConnectorConfigurationSelector();
        configSelector.getApiEndpoint();
        configSelector.getApiTimeout();
		configSelector.getSecretKey();
        configSelector.getBatchScheduleTime();
        configSelector.getBatchSize();
        configSelector.getConnectorNotificationEmail();
        configSelector.getJSResource();
        configSelector.getCSSresource();
        configSelector.getClientCSSresource();
        configSelector.getDefaultEntity();    
        configSelector.getpublicKey();
        configSelector.getShipFromCountry();
        configSelector.getShipFromState();
        configSelector.getShipFromPostalCode(); 
        configSelector.getShipFromCity();
        configSelector.getShipFromLine();    
        configSelector.getEnvironmentName();
        configSelector.getWebhookRetryInterval();    
        configSelector.getFulfillmentRetryLimit();    
        configSelector.getOrderFulfillmentJobQueryLimit();    
        configSelector.getEmailFromAddress();    
        configSelector.getStorefrontBaseURL();
        configSelector.getDRStoredPayments();
        configSelector.getShippingChoiceInfoProviderName();
        configSelector.getDRConnectorVersion();
        configSelector.getDRBatchFulfillments();
        configSelector.getDRBatchFulfillmentsTimePeriod();    
        configSelector.getDRShipFromAddressConfiguration();    
            
    }
}