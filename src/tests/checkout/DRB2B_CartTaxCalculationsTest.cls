@IsTest
private class DRB2B_CartTaxCalculationsTest {
    private static final String DR_CHECKOUT_ID = 'f2cd50e5-355d-42d3-8bb7-0c14d8b777e4';
    private static final String DR_PAYMENT_SESSION_ID = '897eeaa3-ac2d-411f-9211-b7686b51a18d';
    private static final String DR_REG_FEE_BATTERY_TYPE = 'battery';
    private static final String DR_REG_FEE_ID = 'asdkj1h239lkj123j9123';
    private static final String EN_US = 'en_US';
    private static final String TEST2EXAMPLE_COM = 'test2example.com';
    private static final String TEST_ID = DCM_IdUtils.generate(User.getSObjectType());
    private static final String USER_ID = 'userId';
    private static final String TEST_USER_ID = 'testUserId';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';

    @TestSetup
    static void setup() {
        DRB2B_TestEnvironment.prepareStoreWithNonDigitalCart();
    }

  /*  @IsTest
    static void shouldCreateCartTaxRecordsForNonDigitalCart() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        sfdc_checkout.IntegrationInfo integrationInfo = new sfdc_checkout.IntegrationInfo();
        DRB2B_CartTaxCalculations taxCalculations = new DRB2B_CartTaxCalculations();
        taxCalculations.checkoutService = new CheckoutServiceSuccessCompleteResponseMock();
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRGetByIdSuccessMock());
        setUserSelectorMock();
        sfdc_checkout.IntegrationStatus calculationResult;
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
                .field(WebCart.DR_Checkout_Id__c)
                .repeat(DR_CHECKOUT_ID)
                .field(WebCart.DR_Checkout_Type__c)
                .repeat('Non-Digital')
                .field(WebCart.DR_Payment_Session_Id__c)
                .repeat(DR_PAYMENT_SESSION_ID)
                .withChildren(CartItem.SObjectType, CartItem.CartId, 2)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .field(CartItem.Type)
                .repeat('Product')
                .field(CartItem.Sku)
                .repeat('product{0000}')
                // .withChildren(CartTax.SObjectType, CartTax.CartItemId, 2)
                // .build(EntityBuilderFactory.cartTaxBuilder)
                // .field(CartTax.Amount)
                // .repeat(5.00)
                // .field(CartTax.TaxRate)
                // .repeat(1.00)
                // .field(CartTax.DR_Regulatory_Fee__c)
                // .repeat(5.00)
                // .field(CartTax.DR_IOR_Tax__c)
                // .repeat(5.00)
                // .field(CartTax.DR_Duty__c)
                // .repeat(5.00)
                .also(2)
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
                .repeat(5.00)
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

            DR_Regulatory_Fee__c drRegulatoryFee = (DR_Regulatory_Fee__c) result.get(
                DR_Regulatory_Fee__c.SobjectType
            )[0];
            drRegulatoryFee.Amount__c = 5.00;
            drRegulatoryFee.Per_Unit_Amount__c = 5.00;
            drRegulatoryFee.Fee_Type__c = 'battery';
            drRegulatoryFee.Fee_Id__c = 'asdkj1h239lkj123j9123';
            insert drRegulatoryFee;
            // When
            Test.startTest();
            calculationResult = taxCalculations.startCartProcessAsync(
                integrationInfo,
                DRB2B_TestEnvironment.shopperCart.Id
            );
            Test.stopTest();
        }

        // Then
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, calculationResult.status);
        verifyCart();
        verifyProductCartItemTaxes();
        verifyProductCartItemRegulatoryFees();
        verifyChargeCartItemTaxes();
    }

    @IsTest
    static void shouldCreateCartTaxRecordsForNonDigitalSubscriptionCart() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        sfdc_checkout.IntegrationInfo integrationInfo = new sfdc_checkout.IntegrationInfo();
        DRB2B_CartTaxCalculations taxCalculations = new DRB2B_CartTaxCalculations();
        taxCalculations.checkoutService = new CheckoutServiceSuccessCompleteResponseMock();
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRGetByIdSuccessMock());
        setUserSelectorMock();
        sfdc_checkout.IntegrationStatus calculationResult;
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
                .field(WebCart.DR_Checkout_Id__c)
                .repeat(DR_CHECKOUT_ID)
                .field(WebCart.DR_Checkout_Type__c)
                .repeat('Non-Digital')
                .field(WebCart.DR_Payment_Session_Id__c)
                .repeat(DR_PAYMENT_SESSION_ID)
                .withChildren(CartItem.SObjectType, CartItem.CartId, 2)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .field(CartItem.Type)
                .repeat('Product')
                .field(CartItem.Sku)
                .repeat('product{0000}')
                .field(CartItem.Recurring_Line_Item__c)
                .repeat(true)
                .field(CartItem.Subscription_Id__c)
                .repeat('1233')
                // .withChildren(CartTax.SObjectType, CartTax.CartItemId, 2)
                // .build(EntityBuilderFactory.cartTaxBuilder)
                // .field(CartTax.Amount)
                // .repeat(5.00)
                // .field(CartTax.TaxRate)
                // .repeat(1.00)
                // .field(CartTax.DR_Regulatory_Fee__c)
                // .repeat(5.00)
                // .field(CartTax.DR_IOR_Tax__c)
                // .repeat(5.00)
                // .field(CartTax.DR_Duty__c)
                // .repeat(5.00)
                .also(2)
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
                .repeat(5.00)
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

            DR_Regulatory_Fee__c drRegulatoryFee = (DR_Regulatory_Fee__c) result.get(
                DR_Regulatory_Fee__c.SobjectType
            )[0];
            drRegulatoryFee.Amount__c = 5.00;
            drRegulatoryFee.Per_Unit_Amount__c = 5.00;
            drRegulatoryFee.Fee_Type__c = 'battery';
            drRegulatoryFee.Fee_Id__c = 'asdkj1h239lkj123j9123';
            insert drRegulatoryFee;
            // When
            Test.startTest();
            calculationResult = taxCalculations.startCartProcessAsync(
                integrationInfo,
                DRB2B_TestEnvironment.shopperCart.Id
            );
            Test.stopTest();
        }

        // Then
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, calculationResult.status);
        verifyCart();
        verifyProductCartItemTaxes();
        verifyProductCartItemRegulatoryFees();
        verifyChargeCartItemTaxes();
    }

    @IsTest
    static void shouldReturnErrorStatusBecauseOfIssuesWithDrApi() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        sfdc_checkout.IntegrationInfo integrationInfo = new sfdc_checkout.IntegrationInfo();
        DRB2B_CartTaxCalculations taxCalculations = new DRB2B_CartTaxCalculations();
        taxCalculations.checkoutService = new CheckoutServiceInvalidSellingEntityResponseMock();
        
        setConfigurationStub();
        Test.setMock(HttpCalloutMock.class, new DRGetByIdSuccessMock());
        setUserSelectorMock();

        sfdc_checkout.IntegrationStatus calculationResult;
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
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
                .save();

            // When
            Test.startTest();
            calculationResult = taxCalculations.startCartProcessAsync(
                integrationInfo,
                DRB2B_TestEnvironment.shopperCart.Id
            );
            Test.stopTest();
        }

        // Then
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, calculationResult.status);

        List<CartValidationOutput> cartValidationErrors = [
            SELECT Id, CartId, Level, Message, RelatedEntityId, Type
            FROM CartValidationOutput
        ];
        System.assertEquals(1, cartValidationErrors.size());
        CartValidationOutput cartValidationError = cartValidationErrors.get(0);
        System.assertEquals(DRB2B_TestEnvironment.shopperCart.Id, cartValidationError.CartId);
        System.assertEquals(DRB2B_TestEnvironment.shopperCart.Id, cartValidationError.RelatedEntityId);
        System.assertEquals('Error', cartValidationError.Level);
        System.assertEquals('Taxes', cartValidationError.Type);
        // System.assertEquals(
        //     'An issue occurred during Digital River Checkout creation: No Digital River selling entity allows you to sell this combination of items.',
        //     cartValidationError.Message
        // );
    }

    private static void verifyCart() {
        WebCart actualWebCart = [
            SELECT Id, DR_Checkout_Id__c, DR_Payment_Session_Id__c
            FROM WebCart
            WHERE Id = :DRB2B_TestEnvironment.shopperCart.Id
        ];
        System.assertEquals(DR_CHECKOUT_ID, actualWebCart.DR_Checkout_Id__c);
        System.assertEquals(DR_PAYMENT_SESSION_ID, actualWebCart.DR_Payment_Session_Id__c);
    }

    private static void verifyChargeCartItemTaxes() {
        CartTax actualChargeTaxItem = [
            SELECT Id, DR_Regulatory_Fee__c, DR_IOR_Tax__c, DR_Duty__c, Amount, TaxCalculationDate
            FROM CartTax
            WHERE CartItem.Type = 'Charge'
            LIMIT 1
        ];
        System.assertEquals(5, actualChargeTaxItem.Amount);
        System.assertEquals(Date.today(), actualChargeTaxItem.TaxCalculationDate);
    }

    private static void verifyProductCartItemRegulatoryFees() {
        List<DR_Regulatory_Fee__c> regulatoryFees = [
            SELECT Id, Cart_Item_Id__c, Amount__c, Per_Unit_Amount__c, Fee_Type__c, Fee_Id__c
            FROM DR_Regulatory_Fee__c
        ];
        System.assertEquals(1, regulatoryFees.size());
        for (DR_Regulatory_Fee__c regulatoryFee : regulatoryFees) {
            System.assertEquals(5, regulatoryFee.Amount__c);
            System.assertEquals(5, regulatoryFee.Per_Unit_Amount__c);
            System.assertEquals(DR_REG_FEE_BATTERY_TYPE, regulatoryFee.Fee_Type__c);
            System.assertEquals(DR_REG_FEE_ID, regulatoryFee.Fee_Id__c);
        }
    }

    private static void verifyProductCartItemTaxes() {
        List<CartTax> actualProductTaxItems = [
            SELECT Id, DR_Regulatory_Fee__c, DR_IOR_Tax__c, DR_Duty__c, Amount, TaxRate, TaxCalculationDate
            FROM CartTax
            WHERE CartItem.Type = 'Charge'
        ];
        System.assertEquals(2, actualProductTaxItems.size());
        for (CartTax actualProductTaxItem : actualProductTaxItems) {
            System.assertEquals(5, actualProductTaxItem.Amount);
            System.assertEquals(5, actualProductTaxItem.TaxRate);
            System.assertEquals(5, actualProductTaxItem.DR_Regulatory_Fee__c);
            System.assertEquals(5, actualProductTaxItem.DR_IOR_Tax__c);
            System.assertEquals(5, actualProductTaxItem.DR_Duty__c);
            System.assertEquals(Date.today(), actualProductTaxItem.TaxCalculationDate);
        }
    }

    public class CheckoutServiceSuccessCompleteResponseMock implements DRB2B_CheckoutService {
        public DRB2B_CreateCheckoutResponseModel createCheckout(DRB2B_CreateCheckoutRequestModel request) {
            DRB2B_CreateCheckoutResponseModel response = new DRB2B_CreateCheckoutResponseModel();

            response.id = DR_CHECKOUT_ID;
            response.customerId = null; // todo
            response.drCurrency = 'USD'; // todo
            response.email = null; // todo

            response.items = new List<DRB2B_CreateCheckoutResponseModel.Item>();
            for (DRB2B_CreateCheckoutRequestModel.Item requestItem : request.items) {
                DRB2B_CreateCheckoutResponseModel.Item responseItem = new DRB2B_CreateCheckoutResponseModel.Item();
                responseItem.skuId = requestItem.skuId;

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
                feesDetail.id = DR_REG_FEE_ID;
                feesDetail.type = DR_REG_FEE_BATTERY_TYPE;
                List<DRB2B_CreateCheckoutResponseModel.Details> feesDetails = new List<DRB2B_CreateCheckoutResponseModel.Details>();
                feesDetails.add(feesDetail);
                fees.details = feesDetails;
                responseItem.fees = fees;

                DRB2B_CreateCheckoutResponseModel.Duties duties = new DRB2B_CreateCheckoutResponseModel.Duties();
                duties.amount = 5;
                responseItem.duties = duties;

                response.items.add(responseItem);
            }

            DRB2B_CreateCheckoutResponseModel.ShippingChoice shippingChoice = new DRB2B_CreateCheckoutResponseModel.ShippingChoice();
            shippingChoice.taxAmount = 5;
            response.shippingChoice = shippingChoice;

            DRB2B_CreateCheckoutResponseModel.Payment payment = new DRB2B_CreateCheckoutResponseModel.Payment();
            DRB2B_CreateCheckoutResponseModel.Session paymentSession = new DRB2B_CreateCheckoutResponseModel.Session();
            paymentSession.id = DR_PAYMENT_SESSION_ID;
            payment.session = paymentSession;
            response.payment = payment;

            return response;
        }

        public void attachSource(Id cartId, DRB2B_CreateCheckoutResponseModel.Source source) {
        }

        public void convertToOrder(Id cartId) {
        }

        public void refreshCartBasedOnDrRecord(Id cartId) {
        }

        public void recalculateTaxesAndFees(
            WebCart cart,
            Map<String, CartItem> cartItemsBySkuIds,
            DRB2B_CreateCheckoutResponseModel createCheckoutResponse
        ) {
        }
    }

    private class DRGetByIdSuccessMock extends HttpCalloutMockRouter {
        public DRGetByIdSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock('Create Customer', 'GET', '{{endpoint}}/' + DRB2B_DRApiConstants.CUSTOMERS_PATH + '/' + TEST_CONTACT_ID, 200, 'Success', getCreateSuccessCustomerResponseModel());
        }
    }

    static void setConfigurationStub() {
        DRB2B_ConfigurationSelectorStubProvider stubProvider = new DRB2B_ConfigurationSelectorStubProvider();

        DRB2B_DRApiConstants.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(DRB2B_ConnectorConfigurationSelector.class, stubProvider);

        DRB2B_AuthWire.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(DRB2B_ConnectorConfigurationSelector.class, stubProvider);
    }

    private static void setUserSelectorMock() {
        User user = (User) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'Id' => TEST_USER_ID_FOR_MOCK, 'Name' => 'test', 'ContactId' => TEST_CONTACT_ID, 'LocaleSidKey' => 'en_US' }),
            User.class
        );

        DRB2B_CustomerService.userSelector = (DRB2B_UserSelector) Test.createStub(DRB2B_UserSelector.class, new DCM_GenericStubProvider(new Map<String, Object>{ 'getById' => user }));
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

    public class CheckoutServiceInvalidSellingEntityResponseMock implements DRB2B_CheckoutService {
        public DRB2B_CreateCheckoutResponseModel createCheckout(DRB2B_CreateCheckoutRequestModel request) {
            DRB2B_CreateCheckoutResponseModel response = new DRB2B_CreateCheckoutResponseModel();
            response.type = 'bad_request';

            List<DRB2B_ErrorResponseModel> errors = new List<DRB2B_ErrorResponseModel>();
            DRB2B_ErrorResponseModel error = new DRB2B_ErrorResponseModel();
            error.code = 'selling_entity_not_found';
            error.parameter = 'items[].skuId';
            error.message = 'No Digital River selling entity allows you to sell this combination of items.';
            errors.add(error);

            response.errors = errors;

            return response;
        }

        public void attachSource(Id cartId, DRB2B_CreateCheckoutResponseModel.Source source) {
        }

        public void convertToOrder(Id cartId) {
        }

        public void refreshCartBasedOnDrRecord(Id cartId) {
        }
    

        public void recalculateTaxesAndFees(
            WebCart cart,
            Map<String, CartItem> cartItemsBySkuIds,
            DRB2B_CreateCheckoutResponseModel createCheckoutResponse
        ) {
        }
    }*/
}


