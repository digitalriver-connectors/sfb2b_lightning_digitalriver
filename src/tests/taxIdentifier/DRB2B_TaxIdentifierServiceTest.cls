@isTest
private with sharing class DRB2B_TaxIdentifierServiceTest {
    private static final String CONTACT_ID = DCM_IdUtils.generate(Contact.getSObjectType());
    private static final String STATE = 'VERIFIED';
    private static final String TEST_ID = '111111111111111';
    private static final String CREATED = 'Created';
    private static final Map<String, String> INPUT = new Map<String, String>{
        'type' => 'de',
        'value' => 'DE123456789'
    };

    @TestSetup
    static void setup() {
        DRB2B_TestEnvironment.prepareStoreWithNonDigitalCart();
    }

    private static DRB2B_TaxIdentifierModal.Response taxIdentifierSaveSuccess() {
        DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierModal.Response();
        responseModel.state = STATE;
        responseModel.id = TEST_ID;
        responseModel.value = INPUT.get('value');
        responseModel.type = INPUT.get('type');
        return responseModel;
    }

    private class DRCreateTaxIdSuccessMock extends HttpCalloutMockRouter {
        private DRCreateTaxIdSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create TaxId',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.TAX_IDENTIFIER,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                taxIdentifierSaveSuccess()
            );
        }
    }

    @isTest
    static void createTaxIDSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new DRCreateTaxIdSuccessMock());

        Test.startTest();
        DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierService()
            .createTaxIdentifier(JSON.serialize(INPUT), '2372387423');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        system.assertEquals(INPUT.get('type'), responseModel.type);
        system.assertEquals(INPUT.get('value'), responseModel.value);
        system.assertEquals(STATE, responseModel.state);
        system.assertEquals(TEST_ID, responseModel.id);
    }

    private static DRB2B_TaxIdentifierModal.Response taxIdentifierLinkSuccess() {
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierModal.Response();
        responseModel.customerId = communityUser.contactID;
        responseModel.state = STATE;
        responseModel.id = TEST_ID;
        responseModel.value = INPUT.get('value');
        responseModel.type = INPUT.get('type');
        return responseModel;
    }

    private class DRLinkTaxIdSuccessMock extends HttpCalloutMockRouter {
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        private DRLinkTaxIdSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Link TaxId',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CUSTOMERS_PATH +
                '/' +
                communityUser.contactID +
                '/' +
                DRB2B_DRApiConstants.TAX_IDENTIFIER +
                '/' +
                TEST_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                taxIdentifierLinkSuccess()
            );
        }
    }

    @isTest
    static void linkTaxIDSuccessTest() {
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new DRLinkTaxIdSuccessMock());
        System.runAs(communityUser) {
            Test.startTest();
            DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierService()
                .linkTaxIdentifierToCustomer(TEST_ID, '');
            Test.stopTest();
            // Then
            System.assert(responseModel != null);
            system.assertEquals(communityUser.contactID, responseModel.customerId);
            system.assertEquals(INPUT.get('type'), responseModel.type);
            system.assertEquals(INPUT.get('value'), responseModel.value);
            system.assertEquals(STATE, responseModel.state);
            system.assertEquals(TEST_ID, responseModel.id);
        }

    }

    private class DRCreateAndLinkTaxIdSuccessMock extends HttpCalloutMockRouter {
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        private DRCreateAndLinkTaxIdSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create TaxId',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CUSTOMERS_PATH +
                '/' +
                communityUser.contactID +
                '/' +
                DRB2B_DRApiConstants.TAX_IDENTIFIER +
                '/' +
                TEST_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                taxIdentifierLinkSuccess()
            );

            this.registerJsonMock(
                'link TaxId',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.TAX_IDENTIFIER,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                taxIdentifierSaveSuccess()
            );
        }
    }

    @isTest
    static void createAndLinkSuccessTest() {
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new DRCreateAndLinkTaxIdSuccessMock());
        System.runAs(communityUser) {
            Test.startTest();
            DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierService()
                .saveTaxIdentifier(JSON.serialize(INPUT), '');
            Test.stopTest();
            // Then
            System.assert(responseModel != null);
            system.assertEquals(communityUser.contactID, responseModel.customerId);
            system.assertEquals(INPUT.get('type'), responseModel.type);
            system.assertEquals(INPUT.get('value'), responseModel.value);
            system.assertEquals(STATE, responseModel.state);
            system.assertEquals(TEST_ID, responseModel.id);
        }
    }

    private class DRDeleteTaxIDSuccessMock extends HttpCalloutMockRouter {
        private DRDeleteTaxIDSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Delete TaxId',
                'DELETE',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.TAX_IDENTIFIER +
                '/' +
                TEST_ID,
                DRB2B_DRApiConstants.DELETE_SUCCESS_STATUS,
                CREATED,
                ''
            );
        }
    }

    @isTest
    static void deleteTaxIdentifier() {
        Test.setMock(HttpCalloutMock.class, new DRDeleteTaxIDSuccessMock());
        Test.startTest();
        System.assert(new DRB2B_TaxIdentifierService().deleteTaxIdentifier(TEST_ID, '464666547'));
        Test.stopTest();
    }

    private static DRB2B_TaxIdentifierModal.Response getCreateErrorTaxIDResponseModel() {
        DRB2B_ErrorResponseModel errorResponseModel = new DRB2B_ErrorResponseModel();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierModal.Response();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponseModel>{ errorResponseModel };
        return responseModel;
    }

    private class DRCreateTaxIdErrorMock extends HttpCalloutMockRouter {
        public DRCreateTaxIdErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create Customer',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.TAX_IDENTIFIER,
                404,
                'Error',
                getCreateErrorTaxIDResponseModel()
            );
        }
    }

    @isTest
    static void createTaxIDErrorTest() {
        Test.setMock(HttpCalloutMock.class, new DRCreateTaxIdErrorMock());

        Test.startTest();
        DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierService()
            .createTaxIdentifier(JSON.serialize(INPUT), '09623456789');
        Test.stopTest();

        //Then
        System.assert(responseModel != null);
        System.assert(!responseModel.errors.isEmpty());
        system.assertEquals('bad_request', responseModel.type);
    }

    private class DRLinkTaxIdErrorMock extends HttpCalloutMockRouter {
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        private DRLinkTaxIdErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Link TaxId',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CUSTOMERS_PATH +
                '/' +
                communityUser.contactId +
                '/' +
                DRB2B_DRApiConstants.TAX_IDENTIFIER +
                '/' +
                TEST_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                getCreateErrorTaxIDResponseModel()
            );
        }
    }

    @isTest
    static void linkTaxIDErrorTest() {
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new DRLinkTaxIdErrorMock());
        System.runAs(communityUser) {
            Test.startTest();
            DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierService()
                .linkTaxIdentifierToCustomer(TEST_ID, '');
            Test.stopTest();
            // Then
            System.assert(responseModel != null);
            System.assert(!responseModel.errors.isEmpty());
            system.assertEquals('bad_request', responseModel.type);
        }
    }

    private class DRDeleteTaxIDErrorMock extends HttpCalloutMockRouter {
        private DRDeleteTaxIDErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Delete TaxId',
                'DELETE',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.TAX_IDENTIFIER +
                '/' +
                TEST_ID,
                404,
                CREATED,
                getCreateErrorTaxIDResponseModel()
            );
        }
    }

    @isTest
    static void deleteTaxIdentifierError() {
        Test.setMock(HttpCalloutMock.class, new DRDeleteTaxIDErrorMock());
        Test.startTest();
        System.assert(!new DRB2B_TaxIdentifierService().deleteTaxIdentifier(TEST_ID, '2345678'));
        Test.stopTest();
    }

    private class DRAttachTaxIdSuccessMock extends HttpCalloutMockRouter {
        private DRAttachTaxIdSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'attach TaxId',
                'POST',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.CHECKOUT_PATH +
                '/' +
                TEST_ID,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                CREATED,
                getcreateCheckout()
            );
        }
    }

    private static DRB2B_AttachTaxIdTiCheckoutModel getAttachTaxIdToCheckoutModel() {
        DRB2B_AttachTaxIdTiCheckoutModel req = new DRB2B_AttachTaxIdTiCheckoutModel();
        List<DRB2B_AttachTaxIdTiCheckoutModel.TaxIdentifiers> taxIdList = new List<DRB2B_AttachTaxIdTiCheckoutModel.TaxIdentifiers>();

        DRB2B_AttachTaxIdTiCheckoutModel.TaxIdentifiers taxObj = new DRB2B_AttachTaxIdTiCheckoutModel.TaxIdentifiers();
        taxObj.id = TEST_ID;
        taxIdList.add(taxObj);

        req.taxIdentifiers = taxIdList;
        req.sourceId = '';

        return req;
    }

    @isTest
    static void attachRequestcheckoutTest() {
        DRB2B_TestEnvironment.prepareStoreWithNonDigitalCart();
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
                .field(WebCart.DR_Checkout_Id__c)
                .repeat('11111111')
                .field(WebCart.DR_Payment_Session_Id__c)
                .repeat('22222222')
                .withChildren(CartItem.SObjectType, CartItem.CartId, 2)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .also()
                .withChildren(CartItem.SObjectType, CartItem.CartId, 1)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.Type)
                .repeat('Charge')
                .field(CartItem.Sku)
                .repeat('Charge {0000}')
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .withChildren(CartTax.SObjectType, CartTax.CartItemId, 2)
                .build(EntityBuilderFactory.cartTaxBuilder)
                .field(CartTax.Amount)
                .repeat(5.00)
                .field(CartTax.TaxRate)
                .repeat(1.00)
                .field(CartTax.DR_Regulatory_Fee__c)
                .repeat(5.00)
                .field(CartTax.DR_IOR_Tax__c)
                .repeat(5.00)
                .field(CartTax.DR_Duty__c)
                .repeat(5.00)
                .save();

            ATK.SaveResult result = ATK.prepare(DR_Regulatory_Fee__c.SObjectType, 2)
                .build(EntityBuilderFactory.regulatoryFeeBuilder)
                .save(false);
            Test.setMock(HttpCalloutMock.class, new DRAttachTaxIdSuccessMock());
            Test.startTest();
            DRB2B_CreateCheckoutResponseModel response = new DRB2B_TaxIdentifierService()
                .attachTaxId(TEST_ID, new List<String>{ '11112222' }, '');
            system.assertEquals(response.id, TEST_ID);
            system.assertEquals(response.taxIdentifiers[0].Id, TEST_ID);
            Test.stopTest();
        }
    }

    private static DRB2B_CreateCheckoutResponseModel getcreateCheckout() {
        DRB2B_CreateCheckoutResponseModel response = new DRB2B_CreateCheckoutResponseModel();

        response.id = TEST_ID;
        response.customerId = null; // todo
        response.drCurrency = 'USD'; // todo
        response.email = null; // todo
        response.upstreamId = [SELECT Id FROM webcart LIMIT 1]?.Id;
        response.items = new List<DRB2B_CreateCheckoutResponseModel.Item>();
        // for (DRB2B_CreateCheckoutRequestModel.Item requestItem : request.items) {
        DRB2B_CreateCheckoutResponseModel.Item responseItem = new DRB2B_CreateCheckoutResponseModel.Item();
        responseItem.skuId = [SELECT Id FROM product2 LIMIT 1]?.Id;

        DRB2B_CreateCheckoutResponseModel.Tax tax = new DRB2B_CreateCheckoutResponseModel.Tax();
        tax.amount = 5;
        tax.rate = 1;
        responseItem.tax = tax;

        DRB2B_CreateCheckoutResponseModel.ImporterTax importerTax = new DRB2B_CreateCheckoutResponseModel.ImporterTax();
        importerTax.amount = 5;
        responseItem.importerTax = importerTax;

        DRB2B_CreateCheckoutResponseModel.Fees fees = new DRB2B_CreateCheckoutResponseModel.Fees();
        fees.amount = 5;
        fees.taxAmount = 1;
        DRB2B_CreateCheckoutResponseModel.Details feesDetail = new DRB2B_CreateCheckoutResponseModel.Details();
        feesDetail.amount = 5;
        feesDetail.perUnitAmount = 5;
        feesDetail.id = '1111';
        feesDetail.type = 'TESTFEEE';
        List<DRB2B_CreateCheckoutResponseModel.Details> feesDetails = new List<DRB2B_CreateCheckoutResponseModel.Details>();
        feesDetails.add(feesDetail);
        fees.details = feesDetails;
        responseItem.fees = fees;

        DRB2B_CreateCheckoutResponseModel.Duties duties = new DRB2B_CreateCheckoutResponseModel.Duties();
        duties.amount = 5;
        responseItem.duties = duties;

        response.items.add(responseItem);

        DRB2B_CreateCheckoutResponseModel.TaxIdentifier responseModel = new DRB2B_CreateCheckoutResponseModel.TaxIdentifier();
        responseModel.state = STATE;
        responseModel.id = TEST_ID;
        responseModel.value = INPUT.get('value');
        responseModel.type = INPUT.get('type');
        response.taxIdentifiers = new List<DRB2B_CreateCheckoutResponseModel.TaxIdentifier>{ responseModel };

        DRB2B_CreateCheckoutResponseModel.ShippingChoice shippingChoice = new DRB2B_CreateCheckoutResponseModel.ShippingChoice();
        shippingChoice.taxAmount = 5;
        response.shippingChoice = shippingChoice;

        DRB2B_CreateCheckoutResponseModel.Payment payment = new DRB2B_CreateCheckoutResponseModel.Payment();
        DRB2B_CreateCheckoutResponseModel.Session paymentSession = new DRB2B_CreateCheckoutResponseModel.Session();
        paymentSession.id = '1111111111';
        payment.session = paymentSession;
        response.payment = payment;

        return response;
    }
}
