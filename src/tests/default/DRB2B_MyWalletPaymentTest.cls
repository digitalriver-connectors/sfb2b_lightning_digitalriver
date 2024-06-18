@isTest
private with sharing class DRB2B_MyWalletPaymentTest {
    private static final String TEST_ID = DCM_IdUtils.generate(User.getSObjectType());
    private static final String TEST2EXAMPLE_COM = 'test2example.com';
    private static final String TEST_USER_ID = 'testUserId';
    private static final String EN_US = 'en_US';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
    private static final String TEST_SOURCE_ID = '02521000007BcYFCC0';
    private static final String TEST_CHECKOUT_ID = '0252100007BcYFVRT0';
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

            result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);

            WebStore webStore = (WebStore) result.get(WebStore.SObjectType)[0];
            insert webStore;

            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);

            WebCart webcart = (WebCart) result.get(WebCart.SObjectType)[0];
            webcart.WebStoreId = webStore.id;
            webcart.AccountId = acc.Id;
            insert webcart;
        }
    }

    @isTest
    static void getCheckoutAndSourceInfoForSCA_Test() {
        List<User> userInfoList = [SELECT Id, Name, ContactId FROM User];
        List<WebCart> webCartList = [
            SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState
            FROM WebCart
        ];
        WebCart wCart = webCartList.get(0);
        //Given
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new GetSourceInformationSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonString = '{"userId": "' + userInfoList.get(1).Id + '", "sourceId":"' + TEST_SOURCE_ID + '", "cartId": "'+ wCart.Id +'"}';
        String checkoutAndSourceResponse = DRB2B_MyWalletPayment.getCheckoutAndSourceInfoForSCA(jsonString);
        Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(checkoutAndSourceResponse);
        System.assertEquals(true, requestData2.get('isSuccess'), 'All payments');
        Test.stopTest();
    }

    @isTest
    static void getCheckoutAndSourceInfoForSCA_NegativeTest() {
        Test.startTest();
        String jsonString = '{"userId": true, "sourceId":"' + TEST_SOURCE_ID + '"}';
        String checkoutAndSourceResponse = DRB2B_MyWalletPayment.getCheckoutAndSourceInfoForSCA(jsonString);
        Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(checkoutAndSourceResponse);
        System.assertEquals(false, requestData2.get('isSuccess'), 'All payments');
        Test.stopTest();
    }

    @isTest
    static void attachSourceToCheckout_Test() {
        List<User> userInfoList = [SELECT Id, Name, ContactId FROM User];
        List<WebCart> webCartList = [
            SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingState
            FROM WebCart
        ];
        WebCart wCart = webCartList.get(0);
        wCart.DR_Checkout_Id__c = TEST_CHECKOUT_ID;
        update wCart;
        //Given
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new AttachSourceToCheckOutSuccessMock());
        setUserSelectorMock();

        Test.startTest();
        String jsonString = '{"checkoutId": "' + TEST_CHECKOUT_ID + '", "sourceId":"' + TEST_SOURCE_ID + '", "cartId": "'+ wCart.Id+'"}';
        Boolean attachedSourced = DRB2B_MyWalletPayment.attachSourceToCheckout(jsonString);
        System.assertEquals(true, attachedSourced, 'All payments');
        Test.stopTest();
    }

    private class GetSourceInformationSuccessMock extends HttpCalloutMockRouter {
        public getSourceInformationSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'get Source',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.SOURCE_PATH +
                '/' +
                TEST_SOURCE_ID,
                200,
                'Success',
                getSourceSuccessResponseModel()
            );
        }
    }

    private class AttachSourceToCheckOutSuccessMock extends HttpCalloutMockRouter {
        public AttachSourceToCheckOutSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'attach Source',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_CHECKOUT_ID +
                '/' +
                DRB2B_DRApiConstants.SOURCE_PATH +
                '/' +
                TEST_SOURCE_ID,
                200,
                'Success',
                attachSourceSuccessResponseModel()
            );
        }
    }

    private static DRB2B_SourceModel getSourceSuccessResponseModel() {
        DRB2B_SourceModel responseModel = new DRB2B_SourceModel();
        DRB2B_SourceModel.Address addressResponseModel = new DRB2B_SourceModel.Address();
        addressResponseModel.city = 'Wocania';
        addressResponseModel.state = 'US';
        addressResponseModel.postalCode = '05387';
        addressResponseModel.line1 = 'Wocania street';
        addressResponseModel.state = 'NJ';

        DRB2B_SourceModel.Owner ownerResponseModel = new DRB2B_SourceModel.Owner();
        ownerResponseModel.firstName = 'firstName';
        ownerResponseModel.lastName = 'lastName';
        ownerResponseModel.email = 'email@digitalriver.com';
        ownerResponseModel.address = addressResponseModel;

        responseModel.type = 'creditCard';
        return responseModel;
    }
    private static DRB2B_SourceModel attachSourceSuccessResponseModel() {
        DRB2B_SourceModel responseModel = new DRB2B_SourceModel();
        DRB2B_SourceModel.Address addressResponseModel = new DRB2B_SourceModel.Address();
        addressResponseModel.city = 'Wocania';
        addressResponseModel.state = 'US';
        addressResponseModel.postalCode = '05387';
        addressResponseModel.line1 = 'Wocania street';
        addressResponseModel.state = 'NJ';

        DRB2B_SourceModel.Owner ownerResponseModel = new DRB2B_SourceModel.Owner();
        ownerResponseModel.firstName = 'firstName';
        ownerResponseModel.lastName = 'lastName';
        ownerResponseModel.email = 'email@digitalriver.com';
        ownerResponseModel.address = addressResponseModel;

        responseModel.type = 'creditCard';
        responseModel.owner = ownerResponseModel;
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
