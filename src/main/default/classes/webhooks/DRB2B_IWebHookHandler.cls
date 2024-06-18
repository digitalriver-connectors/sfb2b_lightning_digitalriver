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
global interface DRB2B_IWebHookHandler {

    Boolean validateWebhookEventPayload(Object webhookEventObj, String webhookEventPayload);

    void processWebhookEvent(RestResponse response, String webhookEventPayload);

}