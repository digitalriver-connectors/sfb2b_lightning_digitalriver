/**
 * @description       :
 * @author            : Girish Kalidindi
 * @group             :
 * @last modified on  : 04-12-2021
 * @last modified by  : Girish Kalidindi
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   04-12-2021   Girish Kalidindi   Initial Version
 **/
@isTest
private class DRB2B_WebhookHandlerFactoryTest {
    @isTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getWebhookHandlerInstance_Test() {
        String eventType = 'unsupported.event';
        DRB2B_IWebHookHandler webhookHandler = DRB2B_WebhookHandlerFactory.getWebhookHandlerInstance(eventType);
        System.assertEquals(
            true,
            webhookHandler instanceof DRB2B_DefaultWebhookHandler,
            'Webhook event: ' +
            eventType +
            ' is not supported. We will use Default Webhook Handler'
        );
    }
}
