/**
 * Factory class for creating Webhook Handler instances based on Event Type
**/
public with sharing class DRB2B_WebhookHandlerFactory {

    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.WEBHOOK_EVENT);

    /**
     * Get an instance of Webhook Handler Class for the given EventType
     *
     * @param eventType the name of the webhook Apex class to instantiate
     *
     * @return DRB2B_IWebHookHandler Instance of Webhook Handler class
     **/
    public static DRB2B_IWebHookHandler getWebhookHandlerInstance(String eventType) {
        // Get the Webhook Handler Class Name
        String className = DRB2B_WebhookUtil.getWebhookHandlerClassName(eventType);
        logger.info('Event: ' + eventType + ' will be processed by Webhook Handler: ' + className);

        // Create an instance of Event specific Webhook Handler or Default Webhook Handler Class
        return (DRB2B_IWebHookHandler) Type.forName(className).newInstance();
    }

}
