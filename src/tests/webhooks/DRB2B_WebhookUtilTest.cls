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
private class DRB2B_WebhookUtilTest {

    @TestSetup
    static void setup() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getEventType_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                String eventType = 'order.invoice.created';
                String webhookEventPayload = '{"id":"05a2-b3da-4291-a786-a4b9389","type":"' + eventType + '","data":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
                System.assertEquals(eventType, DRB2B_WebhookUtil.getEventType(webhookEventPayload), 'Expected Event type: ' + eventType);
            Test.stopTest();
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getWebhookHandlerClassName_EventSpecificHandler_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                String eventType = 'order.invoice.created';
                String actualClassName = DRB2B_WebhookUtil.getWebhookHandlerClassName(eventType);
                String expectedClassName = DRB2B_WebhookUtil.getWebhookEventHandlerMap().get(eventType);
                System.assertEquals(expectedClassName, actualClassName, 'Expected Webhook Handler class name: ' + expectedClassName + ' for Event type: ' + eventType);
            Test.stopTest();
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getWebhookHandlerClassName_DefaultHandler_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                String eventType = 'event.not.handled'; // This event is not handled, so it should return Default Handler
                String actualClassName = DRB2B_WebhookUtil.getWebhookHandlerClassName(eventType);
                String expectedClassName = DRB2B_WebhookUtil.getWebhookEventHandlerMap().get(DRB2B_ApplicationConstants.WEBHOOK_DEFAULT_HANDLER_CONFIG_NAME);
                System.assertEquals(expectedClassName, actualClassName, 'Expected Default Webhook Handler class for Event type: ' + eventType);
            Test.stopTest();
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void captureEventInSfAndSendEmail_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                String drEventId = '05a2-b3da-4291-a786-a4b9389';
                String webhookPayload = '{"id":"' + drEventId + '","type":"order.invoice.created","data1":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
                String captureReason = 'Unable to process webhook event';
                String emailMessage = 'This is a test email';
                DRB2B_WebhookUtil.captureEventInSfAndSendEmail(webhookPayload, captureReason, emailMessage);
                List<DR_Failed_Event__c> failedEventList = [SELECT Id, Event_Id__c FROM DR_Failed_Event__c];
                System.assertEquals(drEventId, failedEventList.get(0).Event_Id__c, 'DR Webhook Request Event Id should match with the Event Id field of object DR_Failed_Event__c in SF');
            Test.stopTest();
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void captureWebhookEvent_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                String webhookPayload = '{"id":"05a2-b3da-4291-a786-a4b9389","type":"order.invoice.created","data1":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
                String captureReason = 'Unable to process webhook event';
                String failedEventId = DRB2B_WebhookUtil.captureWebhookEvent(webhookPayload, captureReason);
                List<DR_Failed_Event__c> failedEventList = [SELECT Id FROM DR_Failed_Event__c];
                System.assertEquals(failedEventList.get(0).Id, failedEventId, 'Failed Webhook Event Id in SF should match');
            Test.stopTest();
        }
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void captureWebhookEvent_NotJsonPayload_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                String webhookPayload = 'test123';
                String captureReason = 'Unable to process webhook event';
                String failedEventId = DRB2B_WebhookUtil.captureWebhookEvent(webhookPayload, captureReason);
                List<DR_Failed_Event__c> failedEventList = [SELECT Id, Event_Id__c, Event_Type__c, Event_Payload__c, Event_Capture_Reason__c FROM DR_Failed_Event__c];
                System.assertEquals(failedEventList.get(0).Id, failedEventId, 'Failed Webhook Event Id in SF should match');
            Test.stopTest();
        }
    }

    /*@isTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void captureEventInSfAndSendEmail_GuestUser_Test() {
        DRB2B_WebhookUtil.DRB2B_GuestWebhookUtil guestWebhookUtil = new DRB2B_WebhookUtil.DRB2B_GuestWebhookUtil();
        List<DCM_ApplicationLog> appLogList = new List<DCM_ApplicationLog>();
        String drEventId = '05a2-b3da-4291-a786-a4b9389';
        String webhookPayload = '{"id":"' + drEventId + '","type":"order.invoice.created","data1":{"object":{"id":"05a8d2-b3da-4291-a786-a4b939","fileId":"fbe7-0b79-4302-a40b-fec2","orderId":"1820244","customerId":"rg-customer-36172-2955-3129","purpose":"customer_invoice","invoiceURL":"https://api.digitalriver.com/files/fbea4737-0b79-4302-a40b-fec1fe0fec22/content"}},"liveMode":false,"createdTime":"2020-11-23T13:31:25.68Z"}';
        String captureReason = 'Unable to process webhook event';
        String emailMessage = 'This is a test email';
        guestWebhookUtil.captureEventInSfAndSendEmail(webhookPayload, captureReason, emailMessage, appLogList);
        List<DR_Failed_Event__c> failedEventList = [SELECT Id, Event_Id__c FROM DR_Failed_Event__c];
        System.assertEquals(drEventId, failedEventList.get(0).Event_Id__c, 'DR Webhook Request Event Id should match with the Event Id field of object DR_Failed_Event__c in SF');
    }

    @isTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void captureEventInSfAndSendEmail_GuestUser_NotJsonPayload_Test() {
        DRB2B_WebhookUtil.DRB2B_GuestWebhookUtil guestWebhookUtil = new DRB2B_WebhookUtil.DRB2B_GuestWebhookUtil();
        List<DCM_ApplicationLog> appLogList = new List<DCM_ApplicationLog>();
        String webhookPayload = 'test123';
        String captureReason = 'Unable to process webhook event';
        String emailMessage = 'This is a test email';
        guestWebhookUtil.captureEventInSfAndSendEmail(webhookPayload, captureReason, emailMessage, appLogList);
        List<DR_Failed_Event__c> failedEventList = [SELECT Id, Event_Id__c FROM DR_Failed_Event__c];
        System.assertEquals(false, failedEventList.isEmpty(), 'DFailed Event must be captured in SF');
    }*/
}