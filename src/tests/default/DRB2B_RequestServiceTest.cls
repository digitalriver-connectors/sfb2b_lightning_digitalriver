@IsTest
private class DRB2B_RequestServiceTest {
    private static final String TEST_CONTACT_ID = 'testContactId';

    @TestSetup
    static void setup() {
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
        }
    }

    @isTest
    static void getCreateCustomerRequestTest() {
        //Given
        setConfigurationStub();

        Map<String, Object> customerRequestModel = new Map<String, Object>{ 'key' => 'value' };

        //When
        Test.startTest();
        DCM_HttpClient.BaseRequest request;

        request = (DCM_HttpClient.BaseRequest) new DRB2B_RequestService()
            .getCreateCustomerRequest(customerRequestModel, TEST_CONTACT_ID);
        // }
        Test.stopTest();

        //Then
        System.assert(request != null);
        System.assert(request.httpRequest.getEndpoint() == DRB2B_DRApiConstants.END_POINT);
        System.assert(String.isNotBlank(request.httpRequest.getBody()));
        System.assert(request.httpRequest.getMethod() == DCM_HttpClient.POST);
        System.assert(request.pathElements.contains(DRB2B_DRApiConstants.CUSTOMERS_PATH));
    }

    @isTest
    static void getUpdateCustomerRequestTest() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        //Given
        setConfigurationStub();

        DRB2B_CreateCustomerModelService createCustomerModelService = new DRB2B_CreateCustomerModelService();

        //When
        DCM_HttpClient.BaseRequest request;

        Test.startTest();

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            DRB2B_CreateCustomerRequestModel customerModel = createCustomerModelService.getCreateCustomerRequestModel(
                UserInfo.getUserId(),
                DRB2B_DRApiConstants.CUSTOMER_TYPE_BUSINESS
            );
            request = (DCM_HttpClient.BaseRequest) new DRB2B_RequestService()
                .getUpdateCustomerRequest(customerModel, TEST_CONTACT_ID, TEST_CONTACT_ID);
        }
        Test.stopTest();

        //Then
        System.assert(request != null);
        System.assert(request.httpRequest.getEndpoint() == DRB2B_DRApiConstants.END_POINT);
        System.assert(String.isNotBlank(request.httpRequest.getBody()));
        System.assert(request.httpRequest.getMethod() == DCM_HttpClient.POST);
        System.assert(request.pathElements.contains(DRB2B_DRApiConstants.CUSTOMERS_PATH));
        System.assert(request.pathElements.contains(TEST_CONTACT_ID));
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
}
