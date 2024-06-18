@IsTest
private class DRB2B_OrderInvoiceCreatedHandlerTest {

    @TestSetup
    static void setup() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateWebhookEventPayload_Test() {
        // Assign DR Admin Permission Set to Portal Account Owner user
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            DRB2B_OrderInvoiceCreatedHandler orderCreatedMemoHandler = new DRB2B_OrderInvoiceCreatedHandler();
            String webhookEventPayload = '{"id":"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0","type":"order.invoice.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"9c163f29-781a-4029-9090-203eb69698c5","orderId":"187775330336","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            DRB2B_OrderInvoiceAndCreditMemoModel orderEventsRequestModel = (DRB2B_OrderInvoiceAndCreditMemoModel) DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(
                webhookEventPayload
            );
            Boolean isWebhookValid = orderCreatedMemoHandler.validateWebhookEventPayload(
                orderEventsRequestModel,
                webhookEventPayload
            );
            System.assertEquals(true, isWebhookValid, 'Webhook handler is not valid');
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateWebhookEventPayload_NegativeTest() {
        // Assign DR Admin Permission Set to Portal Account Owner user
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            DRB2B_OrderInvoiceCreatedHandler orderCreatedMemoHandler = new DRB2B_OrderInvoiceCreatedHandler();
            String webhookEventPayload = '{"id":"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0","type":"order.invoice.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"9c163f29-781a-4029-9090-203eb69698c5","orderId":"","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            DRB2B_OrderInvoiceAndCreditMemoModel orderEventsRequestModel = (DRB2B_OrderInvoiceAndCreditMemoModel) DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(
                webhookEventPayload
            );
            try {
                Boolean isWebhookValid = orderCreatedMemoHandler.validateWebhookEventPayload(
                    orderEventsRequestModel,
                    webhookEventPayload
                );
            } catch (DRB2B_WebhookException we) {
                System.assertNotEquals(
                    null,
                    we,
                    'Webhook Exception should be thrown when we pass a NULL Webhook Event Object'
                );
            }
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void processWebhookEvent_Test() {
        // Assign DR Admin Permission Set to Portal Account Owner user
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            DRB2B_OrderInvoiceCreatedHandler orderCreatedMemoHandler = new DRB2B_OrderInvoiceCreatedHandler();

            String webhookEventPayload = '{"id":"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0","type":"order.invoice.created","data":{"object":{"id":"9c163f29-781a-4029-9090-203eb69698c5","fileId":"9c163f29-781a-4029-9090-203eb69698c5","orderId":"187775330336","customerId":"00302000006XaOPAA0","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content"}},"liveMode":false,"createdTime":"2021-04-16T17:00:11.270436Z","versionIds":[]}';
            RestResponse response = new RestResponse();
            orderCreatedMemoHandler.processWebhookEvent(response, webhookEventPayload);
            System.assertEquals(
                DRB2B_ApplicationConstants.SUCCESS_RESPONSE_CODE,
                response.statusCode,
                'Response status code must be 200'
            );
        }
    }

}