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
@SuppressWarnings('PMD.AvoidGlobalModifier')
global abstract with sharing class DRB2B_WebhookHandler implements DRB2B_IWebHookHandler {

    public virtual  Boolean validateWebhookEventPayload(Object webhookEventObj, String webhookEventPayload) {
        if(null == webhookEventObj) {
            throw new DRB2B_WebhookException('validateWebhookEventPayload', 'Webhook Event Object cannot be NULL');
        }
        return true;
    }

    global abstract void processWebhookEvent(RestResponse response, String webhookEventPayload);

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public virtual void captureEventInSfAndSendEmail(String webhookEventPayload, String captureReason, String emailMessage) {
        DRB2B_WebhookUtil.captureEventInSfAndSendEmail(webhookEventPayload, captureReason, emailMessage);
    }

    public virtual String captureWebhookEvent(String webhookEventPayload, String captureReason) {
        return DRB2B_WebhookUtil.captureWebhookEvent(webhookEventPayload, captureReason);
    }
}