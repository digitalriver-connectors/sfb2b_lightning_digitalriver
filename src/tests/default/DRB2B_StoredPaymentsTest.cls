@isTest
private with sharing class DRB2B_StoredPaymentsTest {
    private static final String TEST_ID = DCM_IdUtils.generate(User.getSObjectType());
    private static final String TEST2EXAMPLE_COM = 'test2example.com';
    private static final String TEST_USER_ID = 'testUserId';
    private static final String EN_US = 'en_US';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
    private static final String TEST_SOURCE_ID = '02521000007BcYFCC0';
    private static final String USER_ID = 'userId';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';

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

            result = ATK.prepare(ContactPointAddress.SObjectType, 1)
                .build(EntityBuilderFactory.contactPointAddressBuilder)
                .save(false);

            ContactPointAddress conPointAddress = (ContactPointAddress) result.get(ContactPointAddress.SObjectType)[0];
            insert conPointAddress;
        }
    }

    @isTest
    static void GetAllSavedPayments_Test() {
        List<User> userInfoList = [SELECT Id, Name, ContactId FROM User];

        //Given
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRGetByIdSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonString = '{"contactId": "", "userId": "' + userInfoList.get(1).Id + '" }';
        String allSavedPayments = DRB2B_StoredPayments.getAllSavedPayments(jsonString);
        Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(allSavedPayments);
        System.assertEquals(true, requestData2.get('isSuccess'), 'All payments');
        Test.stopTest();
    }

    @isTest
    static void DeleteSavedPayment_Test() {
        List<User> userInfoList = [SELECT Id, Name, ContactId FROM User];
        //Given
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DrGetDeleteSuccessMock());
        setUserSelectorMock();
        System.runAs(userInfoList.get(1)) {
            Test.startTest();
            String jsonString = '{"sourceId": "02521000007BcYFCC0", "userId": "' + userInfoList.get(2).Id + '" }';
            Boolean isSourceDeleted = DRB2B_StoredPayments.deleteSavedPayment(jsonString);
            System.assertEquals(false, isSourceDeleted, 'payment deleted');
            Test.stopTest();
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

    private class DRGetByIdSuccessMock extends HttpCalloutMockRouter {
        public DRGetByIdSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create Customer',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CUSTOMERS_PATH +
                '/' +
                TEST_CONTACT_ID,
                200,
                'Success',
                getCreateSuccessCustomerResponseModel()
            );
        }
    }

    private class DrGetDeleteSuccessMock extends HttpCalloutMockRouter {
        public DrGetDeleteSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Delete Source',
                'DELETE',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CUSTOMERS_PATH +
                '/' +
                TEST_CONTACT_ID +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH +
                '/' +
                TEST_SOURCE_ID,
                204,
                'Success',
                'Deleted'
            );
        }
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
    
    private static testMethod void testLabelMethod(){
        test.startTest();
        String label = System.label.DR_PaymentMethod + 'creditCard';
        String value = DRB2B_StoredPayments.getLabel(label);
        System.assertNotEquals(null, value);
        label = System.label.DR_PaymentMethod + 'newMethod';
        value =  DRB2B_StoredPayments.getLabel(label);
        System.assertNotEquals(null, value);
        test.stopTest();
    }
}