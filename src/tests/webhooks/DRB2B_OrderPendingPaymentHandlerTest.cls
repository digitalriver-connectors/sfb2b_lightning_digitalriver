@IsTest
private class DRB2B_OrderPendingPaymentHandlerTest {
    private static final String DR_ORDER_ID = '190296100336';
    private static final String DR_RETRY_ORDER_ID = '190296101336';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';

    @TestSetup
    static void setupData() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void processWebhookEvent_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                DRB2B_OrderPendingPaymentHandler orderPendingHandler = new DRB2B_OrderPendingPaymentHandler();
                //Given
                setConfigurationStub();
                Test.setMock(HttpCalloutMock.class, new drGetOrderByIdSuccessMock());
                setUserSelectorMock();

                String webhookEventPayload =
                    '{"id":"65d6d6f8-471f-4373-a6cb-0a6e6328c10d","type":"order.review_opened","data":{"object":{"id":"' +
                    DR_ORDER_ID +
                    '","createdTime":"2020-09-01T13:48:51Z","customerId":"0034R00003KcCvXQAV","currency":"USD","email":"storefront@gmail.com","shipTo":{"address":{"line1":"70 Surrey Lane","city":"Danboro","postalCode":"18916","state":"CA","country":"US"},"name":"RandhawaAmarjit","phone":"98765442310"},"shipFrom":{"address":{"line1":"3000 Northwoods Pkwy","line2":"Ste 150","city":"Eden Prairie","postalCode":"55344","state":"Minnesota","country":"US"}},"totalAmount":18,"subtotal":18,"totalFees":9,"totalTax":0,"totalDuty":0,"totalDiscount":0,"totalShipping":0,"items":[{"id":"99985600336","skuId":"a1F4R000005ycAsUAI","amount":9,"quantity":1,"metadata":{"skuId":"SS-DR-BB","cartItemId":"a0F4R00002LjvN9UAJ"},"state":"created","stateTransitions":{"created":"2020-09-01T13:48:51Z"},"tax":{"rate":0,"amount":0},"subscriptionInfo":{"subscriptionId":"a0F4R00002LjvN9UAJ","terms":"terms.","autoRenewal":false,"freeTrial":false,"billingAgreementId":"a684356f-a6e9-4c08-8835-c2da41b59938"},"availableToRefundAmount":0}],"metadata":{"sfOrderId":"801DR000001jXAfYAM"},"updatedTime":"2020-09-01T13:48:51Z","locale":"en_US","customerType":"business","chargeType":"customer_initiated","paymentSessionId":"5f971727-9782-4d5f-afb8-2d7132bfe7c1","sellingEntity":{"id":"DR_INC-ENTITY","name":"Digital River Inc."},"state":"accepted","stateTransitions":{"accepted":"2020-09-01T13:48:54Z"},"fraudState":"passed","fraudStateTransitions":{"passed":"2020-09-01T13:48:54Z"},"charges":[{"id":"164f2090-50f2-4fda-a7c1-ad4490521091","createdTime":"2020-09-01T13:48:53Z","currency":"USD","amount":18,"state":"capturable","captured":false,"refunded":false,"sourceId":"aaff8bfb-0ec2-4ebd-ba8c-56942f30b375","type":"customer_initiated"}],"requestToBeForgotten":false,"capturedAmount":0,"cancelledAmount":0,"availableToRefundAmount":0,"liveMode":false}},"digitalRiverVersion":"2020-01-07","liveMode":false,"createdTime":"2020-09-01T13:49:02.727Z"}';
                RestResponse response = new RestResponse();
                orderPendingHandler.processWebhookEvent(response, webhookEventPayload);
                System.assertEquals(
                    DRB2B_ApplicationConstants.SUCCESS_RESPONSE_CODE,
                    response.statusCode,
                    'Response status code must be 200'
                );
            Test.stopTest();
        }
    }

    @SuppressWarnings('PMD.MethodNamingConventions')
    private class drGetOrderByIdSuccessMock extends HttpCalloutMockRouter {
        public drGetOrderByIdSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Create Customer',
                'GET',
                '{{endpoint}}/' +
                DRB2B_DRApiConstants.ORDER_PATH +
                '/' +
                DR_ORDER_ID,
                200,
                'Success',
                getOrderSuccessResponseModel()
            );
        }
    }

    private static DRB2B_OrderEventsRequestModel getOrderSuccessResponseModel() {
        DRB2B_OrderEventsRequestModel responseModel = new DRB2B_OrderEventsRequestModel();
        DRB2B_OrderEventsRequestModel.Order responseOrderModel = new DRB2B_OrderEventsRequestModel.Order();
        responseOrderModel.Id = DR_RETRY_ORDER_ID;
        responseOrderModel.fraudState = 'Blocked';
        responseModel.Id = '65d6d6f8-471f-4373-a6cb-0a6e6328c10d';
        responseModel.type = 'order.accepted';
        //responseModel.data.order = responseOrderModel;
        return responseModel;
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
