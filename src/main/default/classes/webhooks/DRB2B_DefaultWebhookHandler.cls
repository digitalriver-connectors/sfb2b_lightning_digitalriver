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
public with sharing class DRB2B_DefaultWebhookHandler extends DRB2B_WebhookHandler  {

    public override void processWebhookEvent(RestResponse response, String webhookEventPayload) {
        response.statusCode = DRB2B_ApplicationConstants.SUCCESS_RESPONSE_CODE;

        // Capture Failed and Unhandled Events in SF and Send an email to Admin - Configured in DR Connector Configuration
        String emailMessage = 'Event: <b>' + DRB2B_WebhookUtil.getEventType(webhookEventPayload) + '</b> is currently not handled by DigitalRiver Connector.';
        captureEventInSfAndSendEmail(webhookEventPayload, 'Unhandled DigitalRiver Webhook Event', emailMessage);
    }

}