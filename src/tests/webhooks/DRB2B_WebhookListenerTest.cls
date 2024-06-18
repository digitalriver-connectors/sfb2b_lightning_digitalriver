@IsTest
private class DRB2B_WebhookListenerTest {
    private static final String DR_ORDER_ID = '190296100336';

    @TestSetup
    static void setup() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();
    }

    @isTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getWebhookEventInformationFromDR() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        String webhookResourceName = 'DRB2B_WebhookListener_Request';
        StaticResource webhookRequestResource = [
            SELECT Id, Body, Name
            FROM StaticResource
            WHERE Name = :webhookResourceName
            LIMIT 1
        ];
        String webhookBody = webhookRequestResource.Body.toString();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/digitalriverv3/webhooks/';
        req.addHeader('Accept', 'application/json');
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(webhookBody);
        RestContext.request = req;
        RestContext.response = res;

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                DRB2B_WebhookListener.getWebhookEventInformationFromDR();
                System.assertEquals(200, res.statusCode);
            Test.stopTest();
        }
    }

    @isTest
    static void getWebhookEventInformationFromDREmptyPayload() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/digitalriverv3/webhooks/';
        req.addHeader('Accept', 'application/json');
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                DRB2B_WebhookListener.getWebhookEventInformationFromDR();
                System.assertEquals(400, res.statusCode);
            Test.stopTest();
        }
    }
    @isTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getWebhookEventInformationFromDRException() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        String webhookResourceName = 'DRB2B_WebhookListener_NullOrderIdRequest';
        StaticResource webhookRequestResource = [
            SELECT Id, Body, Name
            FROM StaticResource
            WHERE Name = :webhookResourceName
            LIMIT 1
        ];
        String webhookBody = webhookRequestResource.Body.toString();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/digitalriverv3/webhooks/';
        req.addHeader('Accept', 'application/json');
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(webhookBody);
        RestContext.request = req;
        RestContext.response = res;

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                try {
                    DRB2B_WebhookListener.getWebhookEventInformationFromDR();
                } catch (DRB2B_WebhookException e) {
                    System.assertEquals(400, res.statusCode, 'Error response should be 400');
                } catch (Exception e) {
                    System.assertEquals(400, res.statusCode, 'Error response should be 400');
                }
            Test.stopTest();
        }
    }

}