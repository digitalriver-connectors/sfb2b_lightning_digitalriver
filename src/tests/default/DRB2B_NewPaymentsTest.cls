@isTest
private with sharing class DRB2B_NewPaymentsTest {
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
    static void GetBillingContactPointAddress_Test() {
        List<ContactPointAddress> contactPointadd = [
            SELECT Id, Name, AddressType, Country, City
            FROM ContactPointAddress
        ];

        Test.startTest();
        String contactPointAddressList = DRB2B_NewPayments.getBillingContactPointAddress();
        System.assertEquals('United States', contactPointadd.get(0).Country, 'Country is different');
        Test.stopTest();
    }

    @isTest
    static void AttachSourceWithCustomer_Test() {
        List<User> userInfoList = [SELECT Id, Name, ContactId FROM User];
        //Given
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRAttachSourceSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonString =
            '{"contactId": "' +
            TEST_CONTACT_ID +
            '", "userId": "' +
            userInfoList.get(1).Id +
            '", "sourceId":"' +
            TEST_SOURCE_ID +
            '"}';
        String attachedPaymentSource = DRB2B_NewPayments.attachSourceWithCustomer(jsonString);
        Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(attachedPaymentSource);
        System.assertEquals(true, requestData2.get('isSuccess'), 'All payments');
        Test.stopTest();
    }

    private class DRAttachSourceSuccessMock extends HttpCalloutMockRouter {
        public DRAttachSourceSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create Customer',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CUSTOMERS_PATH +
                '/' +
                TEST_CONTACT_ID +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH +
                '/' +
                TEST_SOURCE_ID,
                200,
                'Success',
                getAttachSourceSuccessResponseModel()
            );
        }
    }

    private static DRB2B_AttachSourceToCustomerRes getAttachSourceSuccessResponseModel() {
        DRB2B_AttachSourceToCustomerRes responseModel = new DRB2B_AttachSourceToCustomerRes();
        DRB2B_AttachSourceToCustomerRes.Address addressResponseModel = new DRB2B_AttachSourceToCustomerRes.Address();
        addressResponseModel.city = 'Wocania';
        addressResponseModel.state = 'US';
        addressResponseModel.postalCode = '05387';
        addressResponseModel.line1 = 'Wocania street';
        addressResponseModel.line2 = 'back road';
        addressResponseModel.state = 'NJ';

        DRB2B_AttachSourceToCustomerRes.Owner ownerResponseModel = new DRB2B_AttachSourceToCustomerRes.Owner();
        ownerResponseModel.firstName = 'firstName';
        ownerResponseModel.lastName = 'lastName';
        ownerResponseModel.email = 'email@digitalriver.com';
        ownerResponseModel.address = addressResponseModel;

        responseModel.type = 'creditCard';
        responseModel.isSuccess = true;
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
