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
private class DRB2B_WebhookHandlerTest {

    @TestSetup
    static void setup() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateWebhookEventPayload_NullWebhookEventObj_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                DRB2B_WebhookHandler webhookHandler = new DRB2B_DefaultWebhookHandler();
                String webhookPayload = '{"id":"05a2-b3da-4291-a786-a4b9389","type":"order.invoice.created","data1":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
                try {
                    webhookHandler.validateWebhookEventPayload(null, webhookPayload);
                }
                catch(DRB2B_WebhookException we) {
                    System.assertNotEquals(null, we, 'Webhook Exception should be thrown when we pass a NULL Webhook Event Object');
                }
            Test.stopTest();
        }
    }

    /*@isTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void validateWebhookEventPayload_WebhookEventObjNotNull_Test() {
        DRB2B_WebhookHandler webhookHandler = new DRB2B_DefaultWebhookHandler();
        String webhookPayload = '{"id":"05a2-b3da-4291-a786-a4b9389","type":"order.invoice.created","data1":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
        DRB2B_OrderInvoiceCreatedEvent orderInvoiceCreatedEvent = (DRB2B_OrderInvoiceCreatedEvent) DRB2B_OrderInvoiceCreatedEvent.deserialize(webhookPayload);
        Boolean validWebhookEventPayload = webhookHandler.validateWebhookEventPayload(orderInvoiceCreatedEvent, webhookPayload, new List<DCM_ApplicationLog>());
        System.assertEquals(true, validWebhookEventPayload, 'Event Payload should be valid');
    }*/

    @isTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void captureEventInSfAndSendEmail_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                DRB2B_WebhookHandler webhookHandler = new DRB2B_DefaultWebhookHandler();
                String drEventId = '05a2-b3da-4291-a786-a4b9389';
                String webhookPayload = '{"id":"' + drEventId + '","type":"order.invoice.created","data1":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
                String captureReason = 'Unable to process webhook event';
                String emailMessage = 'This is a test email';
                webhookHandler.captureEventInSfAndSendEmail(webhookPayload, captureReason, emailMessage);
                List<DR_Failed_Event__c> failedEventList = [SELECT Id, Event_Id__c FROM DR_Failed_Event__c];
                System.assertEquals(drEventId, failedEventList.get(0).Event_Id__c, 'DR Webhook Request Event Id should match with the Event Id field of object DR_Failed_Event__c in SF');
            Test.stopTest();
        }
    }

    @isTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void captureWebhookEvent_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                DRB2B_WebhookHandler webhookHandler = new DRB2B_DefaultWebhookHandler();
                String webhookPayload = '{"id":"05a2-b3da-4291-a786-a4b9389","type":"order.invoice.created","data1":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
                String captureReason = 'Unable to process webhook event';
                String failedEventId = webhookHandler.captureWebhookEvent(webhookPayload, captureReason);
                List<DR_Failed_Event__c> failedEventList = [SELECT Id FROM DR_Failed_Event__c];
                System.assertEquals(failedEventList.get(0).Id, failedEventId, 'Failed Webhook Event Id in SF should match');
            Test.stopTest();
        }
    }

}