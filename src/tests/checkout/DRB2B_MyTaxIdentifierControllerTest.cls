@isTest
public class DRB2B_MyTaxIdentifierControllerTest {
    private static final String CONTACT_ID = DCM_IdUtils.generate(Contact.getSObjectType());
    private static final String STATE = 'VERIFIED';
    private static final String TEST_ID = '111111111111111';
    private static final String CREATED = 'Created';
    private static final Map<String, String> INPUT = new Map<String, String>{'type' => 'de', 'value' => 'DE123456789'};
        
        @TestSetup
        static void setup() {
            DRB2B_TestEnvironment.prepareStoreWithNonDigitalCart();
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
    
    private static DRB2B_TaxIdentifierModal.Response taxIdentifierSaveSuccess() {
        DRB2B_TaxIdentifierModal.Response responseModel = new DRB2B_TaxIdentifierModal.Response();
        responseModel.state = STATE;
        responseModel.id = TEST_ID;
        responseModel.value = INPUT.get('value');
        responseModel.type = INPUT.get('type');
        return responseModel;
    }
    
    @isTest public static void createTaxIdentifierTest(){
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new DRCreateAndLinkTaxIdSuccessMock());
        System.runAs(communityUser) {
            Test.startTest();
            DRB2B_MyTaxIdentifierController.createTaxIdentifier(JSON.serialize(INPUT), '');
            Test.stopTest();
        }
    }
    
    @isTest public static void saveTaxIdentifierTest(){
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new DRCreateAndLinkTaxIdSuccessMock());
        System.runAs(communityUser) {
            Test.startTest();
            DRB2B_MyTaxIdentifierController.saveTaxIdentifier(JSON.serialize(INPUT), '');
            Test.stopTest();
        }
    }
    
    @isTest public static void getTaxIdentifierTest(){
        webCart cart = [SELECT ID FROM WebCart LIMIT 1];
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.runAs(communityUser) {
            Test.startTest();
            try{
                DRB2B_MyTaxIdentifierController.getTaxIdentifier(cart.Id);
            }catch(exception e){
                system.debug('Error Ex::>>'+e.getMessage());
            }
            
            Test.stopTest();
        }
    }
    
    @isTest public static void deleteTaxIdentifierTest(){
        webCart cart = [SELECT ID FROM WebCart LIMIT 1];
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.runAs(communityUser) {
            Test.startTest();
            Boolean result;
            try{
                result = DRB2B_MyTaxIdentifierController.deleteTaxIdentifier('',cart.Id);
                result = DRB2B_MyTaxIdentifierController.deleteTaxIdentifier('','');
                
            }catch(exception e){
                Assert.areEqual(false, result);
                system.debug('Error Ex::82>>'+e.getMessage());
            }
            
            Test.stopTest();
        }
    }//(TEST_ID, new List<String>{ '11112222' }, '');
    
    @isTest public static void applyTaxIdenifierTest(){
        webCart cart = [SELECT ID FROM WebCart LIMIT 1];
        User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.runAs(communityUser) {
            Test.startTest();
            String result;
            try{
                result = DRB2B_MyTaxIdentifierController.applyTaxIdenifier('111111111111111', new List<String>{ '11112222' }, '');
            }catch(exception e){
                Assert.areEqual(null, result);
            }
            
            Test.stopTest();
        }
    }
    
    @isTest public static void updateDRRemainingFieldTest(){
        webCart cart = [SELECT ID FROM WebCart LIMIT 1];
        //User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerationJSON());
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
            String result;
            try{
                result = DRB2B_MyTaxIdentifierController.updateDRRemainingField(cart.Id);
            }catch(exception e){
                //Assert.areEqual(null, result);
                System.debug('118 Error::>>'+e.getMessage());
            }
            
            Test.stopTest();
        }
    }
    
    @isTest public static void getCartTest(){
        webCart cart = [SELECT ID FROM WebCart LIMIT 1];
        //User communityUser = [SELECT Id, contactID FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER][0];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerationJSON());
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
            DRB2B_CartModel result;
            try{
                result = DRB2B_MyTaxIdentifierController.getCart(cart.Id);
            }catch(exception e){
                //Assert.areEqual(null, result);
                System.debug('118 Error::>>'+e.getMessage());
            }
            
            Test.stopTest();
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
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req.getEndpoint()::>>'+req.getEndpoint());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{[{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},' 
                        +'{"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpResponseGenerationJSON implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req.getEndpoint()::>>'+req.getEndpoint());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(DRB2B_MyTaxIdentifierControllerTest.getJSON());
            res.setStatusCode(200);
            return res;
        }
    }
        public static string getJSON(){
            String json='';
        return   json =
            '{' +
            '  \"id\": \"5823594809\",' +
            '  \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '  \"updatedTime\": \"2018-04-25T20:36:00Z\",' +
            '  \"customerId\": \"cus_5774321009\",' +
            '  \"drCurrency\": \"USD\",' +
            '  \"email\": \"jsmith@digitalriver.com\",' +
            '  \"locale\": \"en_US\",' +
            '  \"browserIp\": \"111.111.111.111\",' +
            '  \"applicationId\": \"68f72e0c-cb7d-48e1-93c8-998668ad0ff4\",' +
            '  \"shipFrom\": {' +
            '    \"address\": {' +
            '      \"line1\": \"10380 Bren Rd W\",' +
            '      \"line2\": \"string\",' +
            '      \"city\": \"Minnetonka\",' +
            '      \"postalCode\": \"55129\",' +
            '      \"state\": \"MN\",' +
            '      \"country\": \"US\"' +
            '    },' +
            '    \"additionalAddressInfo\": {' +
            '      \"neighborhood\": \"Centro\",' +
            '      \"division\": \"Test Division\",' +
            '      \"phoneticName\": \"Test Phonetic name\"' +
            '    }' +
            '  },' +
            '  \"shipTo\": {' +
            '    \"address\": {' +
            '      \"line1\": \"10380 Bren Rd W\",' +
            '      \"line2\": \"string\",' +
            '      \"city\": \"Minnetonka\",' +
            '      \"postalCode\": \"55129\",' +
            '      \"state\": \"MN\",' +
            '      \"country\": \"US\"' +
            '    },' +
            '    \"name\": \"John Smith\",' +
            '    \"phone\": \"952-111-1111\",' +
            '    \"email\": \"jsmith@digitalriver.com\",' +
            '    \"organization\": \"Digital River\",' +
            '    \"additionalAddressInfo\": {' +
            '      \"neighborhood\": \"Centro\",' +
            '      \"division\": \"Test Division\",' +
            '      \"phoneticName\": \"Test Phonetic name\"' +
            '    }' +
            '  },' +
            '  \"billTo\": {' +
            '    \"address\": {' +
            '      \"line1\": \"10380 Bren Rd W\",' +
            '      \"line2\": \"string\",' +
            '      \"city\": \"Minnetonka\",' +
            '      \"postalCode\": \"55129\",' +
            '      \"state\": \"MN\",' +
            '      \"country\": \"US\"' +
            '    },' +
            '    \"name\": \"John Smith\",' +
            '    \"phone\": \"952-111-1111\",' +
            '    \"email\": \"jsmith@digitalriver.com\",' +
            '    \"organization\": \"Digital River\",' +
            '    \"additionalAddressInfo\": {' +
            '      \"neighborhood\": \"Centro\",' +
            '      \"division\": \"Test Division\",' +
            '      \"phoneticName\": \"Test Phonetic name\"' +
            '    }' +
            '  },' +
            '  \"subtotal\": 1094.5,' +
            '  \"totalTax\": 82.76,' +
            '  \"totalImporterTax\": 82.76,' +
            '  \"importerOfRecordTax\": true,' +
            '  \"totalFees\": 0,' +
            '  \"totalDuty\": 0,' +
            '  \"totalDiscount\": 0,' +
            '  \"totalShipping\": 5.76,' +
            '  \"totalAmount\": 1180.26,' +
            '  \"discount\": {' +
            '    \"amountOff\": 5.95,' +
            '    \"percentOff\": 100,' +
            '    \"quantity\": 1' +
            '  },' +
            '  \"taxIdentifiers\": [' +
            '    {' +
            '      \"id\": \"5774321009\",' +
            '      \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '      \"customerId\": \"5774321009\",' +
            '      \"type\": \"de\",' +
            '      \"value\": \"DE123456789\",' +
            '      \"state\": \"pending\",' +
            '      \"stateTransitions\": \"pending\",' +
            '      \"verifiedName\": \".\",' +
            '      \"verifiedAddress\": \".\",' +
            '      \"updatedTime\": \"2018-04-25T20:36:00Z\"' +
            '    }' +
            '  ],' +
            '  \"purchaseLocation\": {' +
            '    \"country\": \"US\",' +
            '    \"state\": \"MN\",' +
            '    \"postalCode\": \"55364\"' +
            '  },' +
            '  \"customerType\": \"individual\",' +
            '  \"sellingEntity\": {' +
            '    \"id\": \"C5_INC-ENTITY\",' +
            '    \"name\": \"DR globalTech Inc.\"' +
            '  },' +
            '  \"items\": [' +
            '    {' +
            '      \"id\": \"100067660336\",' +
            '      \"skuId\": \"sku_5823594809\",' +
            '      \"subscriptionInfo\": {' +
            '        \"freeTrial\": true,' +
            '        \"autoRenewal\": true,' +
            '        \"terms\": \"Please accept these terms.\",' +
            '        \"subscriptionId\": \"665430999\",' +
            '        \"billingAgreementId\": \"cfeba2ac-d532-49e4-99f4-7a433507facf\",' +
            '        \"startTime\": \"2020-05-21T00:00:00-05:00\",' +
            '        \"endTime\": \"2021-05-20T11:59:59-05:00\"' +
            '      },' +
            '      \"fees\": {' +
            '        \"details\": [' +
            '          {' +
            '            \"type\": \"battery\",' +
            '            \"amount\": 3,' +
            '            \"perUnitAmount\": 1.5,' +
            '            \"id\": \"asdkj1h239lkj123j9123\"' +
            '          }' +
            '        ],' +
            '        \"amount\": 4.5,' +
            '        \"taxAmount\": 1.2' +
            '      },' +
            '      \"quantity\": 2,' +
            '      \"amount\": 18.58,' +
            '      \"availableToRefundAmount\": 18.58,' +
            '      \"tax\": {' +
            '        \"rate\": 0.0675,' +
            '        \"amount\": 89' +
            '      },' +
            '      \"importerTax\": {' +
            '        \"amount\": 12.34' +
            '      },' +
            '      \"duties\": {' +
            '        \"amount\": 12.34' +
            '      },' +
            '      \"discount\": {' +
            '        \"amountOff\": 5.95,' +
            '        \"percentOff\": 100,' +
            '        \"quantity\": 1' +
            '      },' +
            '      \"shipFrom\": {' +
            '        \"address\": {' +
            '          \"line1\": \"10380 Bren Rd W\",' +
            '          \"line2\": \"string\",' +
            '          \"city\": \"Minnetonka\",' +
            '          \"postalCode\": \"55129\",' +
            '          \"state\": \"MN\",' +
            '          \"country\": \"US\"' +
            '        },' +
            '        \"additionalAddressInfo\": {' +
            '          \"neighborhood\": \"Centro\",' +
            '          \"division\": \"Test Division\",' +
            '          \"phoneticName\": \"Test Phonetic Name\"' +
            '        }' +
            '      },' +
            '      \"metadata\": {' +
            '        \"coupon\": \"iOS\"' +
            '      }' +
            '    }' +
            '  ],' +
            '  \"shippingChoice\": {' +
            '    \"amount\": 5.95,' +
            '    \"taxAmount\": 0.1,' +
            '    \"description\": \"USPS: Priority (1 day delivery)\",' +
            '    \"serviceLevel\": \"Standard Ground\"' +
            '  },' +
            '  \"payment\": {' +
            '    \"sources\": [' +
            '      {' +
            '        \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '        \"clientSecret\": \"52199c06-b261-4786-8609-d0a84185a0d2_2b72614b-77f6-4801-bd48-8982e314fdd5\",' +
            '        \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '        \"type\": \"creditCard\",' +
            '        \"drCurrency\": \"USD\",' +
            '        \"amount\": 1180.26,' +
            '        \"reusable\": true,' +
            '        \"owner\": {' +
            '          \"firstName\": \"John\",' +
            '          \"lastName\": \"Smith\",' +
            '          \"email\": \"jsmith@digitalriver.com\",' +
            '          \"organization\": \"Digital River\",' +
            '          \"upstreamId\": \"55129-54673\",' +
            '          \"address\": {' +
            '            \"line1\": \"10380 Bren Rd W\",' +
            '            \"line2\": \"string\",' +
            '            \"city\": \"Minnetonka\",' +
            '            \"postalCode\": \"55129\",' +
            '            \"state\": \"MN\",' +
            '            \"country\": \"US\"' +
            '          },' +
            '          \"additionalAddressInfo\": {' +
            '            \"neighborhood\": \"Centro\",' +
            '            \"division\": \"Test Division\",' +
            '            \"phoneticName\": \"Test Phonetic Name\"' +
            '          }' +
            '        },' +
            '        \"creditCard\": {' +
            '          \"lastFourDigits\": \"3119\",' +
            '          \"expirationMonth\": 3,' +
            '          \"expirationYear\": 2023,' +
            '          \"fundingSource\": \"Visa\",' +
            '          \"brand\": \"Visa\"' +
            '        },' +
            '        \"googlePay\": {' +
            '          \"lastFourDigits\": \"3119\",' +
            '          \"expirationMonth\": 2,' +
            '          \"expirationYear\": 2022,' +
            '          \"brand\": \"Visa\"' +
            '        },' +
            '        \"payPal\": {' +
            '          \"redirect\": {' +
            '            \"redirectUrl\": \"https://api.digitalriver.com:443/payments/redirects/e626ec65-24d6-46fb-b632-10b90f4c4912?apiKey=pk_test_6cb0fe9ce3124093a9ad906f6c589e2d\",' +
            '            \"returnUrl\": \"https://mypage.com/success\",' +
            '            \"cancelUrl\": \"https://mypage.com/cancel\"' +
            '          },' +
            '          \"directDebit\": {' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '          }' +
            '        },' +
            '        \"payPalBilling\": {' +
            '          \"redirect\": {' +
            '            \"redirectUrl\": \"https://api.digitalriver.com:443/payments/redirects/e626ec65-24d6-46fb-b632-10b90f4c4912?apiKey=pk_test_6cb0fe9ce3124093a9ad906f6c589e2d\",' +
            '            \"returnUrl\": \"https://mypage.com/success\",' +
            '            \"cancelUrl\": \"https://mypage.com/cancel\"' +
            '          },' +
            '          \"directDebit\": {' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '          }' +
            '        },' +
            '        \"payPalCredit\": {' +
            '          \"redirect\": {' +
            '            \"redirectUrl\": \"https://api.digitalriver.com:443/payments/redirects/e626ec65-24d6-46fb-b632-10b90f4c4912?apiKey=pk_test_6cb0fe9ce3124093a9ad906f6c589e2d\",' +
            '            \"returnUrl\": \"https://mypage.com/success\",' +
            '            \"cancelUrl\": \"https://mypage.com/cancel\"' +
            '          },' +
            '          \"directDebit\": {' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '          }' +
            '        },' +
            '        \"directDebit\": {' +
            '          \"redirect\": {' +
            '            \"redirectUrl\": \"https://api.digitalriver.com:443/payments/redirects/75743f60-1023-470e-be48-b761260317af?apiKey=pk_test_6cb0fe9ce3124093a9ad906f6c589e2d\",' +
            '            \"returnUrl\": \"https://mypage.com/success\"' +
            '          },' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '        },' +
            '        \"wireTransfer\": {' +
            '          \"accountHolder\": \"Netgiro Payments AB\",' +
            '          \"bankName\": \"ABN AMRO Bank N.V.\",' +
            '          \"city\": \"Prague\",' +
            '          \"country\": \"ES\",' +
            '          \"referenceId\": \"DR1651067521\",' +
            '          \"accountNumber\": \"0100037259\",' +
            '          \"additionalBankInformation\": \"Codigo de oficina: 0001 Codigo de entidad: 0156 Digitos de control: 09\",' +
            '          \"iban\": \"ES35 0156 0001 0901 0003 7259\"' +
            '        },' +
            '        \"bPay\": {' +
            '          \"accountHolder\": \"Global Collect BV\",' +
            '          \"bankName\": \"Commonwealth Bank\",' +
            '          \"city\": \"Sydney\",' +
            '          \"country\": \"Australia\",' +
            '          \"referenceId\": \"12345678\",' +
            '          \"accountNumber\": \"87654321\",' +
            '          \"billId\": \"112233\",' +
            '          \"customerPaymentReference\": \"443322\",' +
            '          \"swiftCode\": \"CTBAAU2S\"' +
            '        },' +
            '        \"onlineBanking\": {' +
            '          \"bankCode\": \"86\"' +
            '        },' +
            '        \"klarnaCredit\": {' +
            '          \"shipping\": {' +
            '            \"recipient\": \"John Doe\",' +
            '            \"phoneNumber\": \"5559895326\",' +
            '            \"address\": {' +
            '              \"line1\": \"10380 Bren Road West\",' +
            '              \"city\": \"Minnetonka\",' +
            '              \"state\": \"MN\",' +
            '              \"country\": \"US\",' +
            '              \"postalCode\": \"55343\"' +
            '            },' +
            '            \"email\": \"jdoe@yahoo.com\"' +
            '          },' +
            '          \"token\": \"1111222233334444\"' +
            '        },' +
            '        \"klarnaCreditRecurring\": {' +
            '          \"returnUrl\": \"https://example.org/return\",' +
            '          \"cancelUrl\": \"https://example.org/cancel\"' +
            '        },' +
            '        \"konbini\": {' +
            '          \"storeId\": \"33334444\",' +
            '          \"receiptNumber\": \"8675309\",' +
            '          \"printableInvoiceUrl\": \"https://printableinvoice.com\",' +
            '          \"storeName\": \"Seven Eleven\",' +
            '          \"localizedStoreName\": \"Test Store\",' +
            '          \"storeLogoUrl\": \"https://storelogo.com\"' +
            '        },' +
            '        \"bankTransfer\": {},' +
            '        \"flow\": \"standard\",' +
            '        \"state\": \"chargeable\",' +
            '        \"metadata\": {' +
            '          \"coupon\": \"iOS\"' +
            '        },' +
            '        \"customerId\": \"5823594809\",' +
            '        \"paymentSessionId\": \"8cecaa32-f692-44cc-b103-4cf24dc93913\",' +
            '        \"liveMode\": false' +
            '      }' +
            '    ],' +
            '    \"charges\": [' +
            '      {' +
            '        \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '        \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '        \"drCurrency\": \"USD\",' +
            '        \"amount\": 1180.26,' +
            '        \"state\": \"pending\",' +
            '        \"orderId\": \"9986340012\",' +
            '        \"sourceId\": \"9986340012\",' +
            '        \"failureCode\": \"a failure code\",' +
            '        \"failureMessage\": \"a failure message\",' +
            '        \"paymentSessionId\": \"8cecaa32-f692-44cc-b103-4cf24dc93913\",' +
            '        \"cancels\": [' +
            '          {' +
            '            \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '            \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"updatedTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"amount\": 1180.26,' +
            '            \"state\": \"pending\",' +
            '            \"failureCode\": \"string\",' +
            '            \"failureMessage\": \"string\"' +
            '          }' +
            '        ],' +
            '        \"captures\": [' +
            '          {' +
            '            \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '            \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"updatedTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"amount\": 1180.26,' +
            '            \"state\": \"pending\",' +
            '            \"failureCode\": \"string\",' +
            '            \"failureMessage\": \"string\"' +
            '          }' +
            '        ],' +
            '        \"captured\": false,' +
            '        \"refunds\": [' +
            '          {' +
            '            \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '            \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"updatedTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"amount\": 1180.26,' +
            '            \"state\": \"pending\",' +
            '            \"failureCode\": \"string\",' +
            '            \"failureMessage\": \"string\"' +
            '          }' +
            '        ],' +
            '        \"refunded\": false,' +
            '        \"type\": \"customer_initiated\",' +
            '        \"liveMode\": true' +
            '      }' +
            '    ],' +
            '    \"session\": {' +
            '      \"id\": \"5823594809\",' +
            '      \"amountContributed\": 10.5,' +
            '      \"amountRemainingToBeContributed\": 5.5,' +
            '      \"clientSecret\": \"f93b4a5a-6971-4a50-b752-58636f9cfa07_35436acd-7d47-41df-8e5\",' +
            '      \"state\": \"requires_confirmation\"' +
            '    }' +
            '  },' +
            '  \"liveMode\": false,' +
            '  \"metadata\": {' +
            '    \"coupon\": \"iOS\"' +
            '  },' +
            '  \"upstreamId\": \"7765374748\"' +
            '}';
    }

}