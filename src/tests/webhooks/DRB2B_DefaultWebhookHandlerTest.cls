/**
 * @description       : 
 * @author            : Girish Kalidindi
 * @group             : 
 * @last modified on  : 04-12-2021
 * @last modified by  : Girish Kalidindi
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   04-08-2021   Girish Kalidindi   Initial Version
**/
@IsTest
private class DRB2B_DefaultWebhookHandlerTest {

    @TestSetup
    static void setup() {
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
                DRB2B_WebhookHandler defaultWebhookHandler = new DRB2B_DefaultWebhookHandler();
                RestResponse response = new RestResponse();
                String drEventId = '05a2-b3da-4291-a786-a4b9389';
                String webhookEventPayload = '{"id":"' + drEventId + '","type":"order.invoice.created","data1":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
                defaultWebhookHandler.processWebhookEvent(response, webhookEventPayload);
                List<DR_Failed_Event__c> failedEventList = [SELECT Id, Event_Id__c FROM DR_Failed_Event__c];
                System.assertEquals(drEventId, failedEventList.get(0).Event_Id__c, 'DR Webhook Request Event Id should match with the Event Id field of object DR_Failed_Event__c in SF');
                System.assertEquals(DRB2B_ApplicationConstants.SUCCESS_RESPONSE_CODE, response.statusCode, 'Response status code must be 200');
            Test.stopTest();
        }
    }
}