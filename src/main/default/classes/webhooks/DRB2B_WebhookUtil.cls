public inherited sharing class DRB2B_WebhookUtil {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.WEBHOOK_EVENT);

    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
    
    /**
     * @description Get Event Type from Webhook Event Payload
     * @param webhookEventPayload Webhook Event Payload from Request
     * @return String Webhook EventType. For example: order.accepted, order.complete
     **/
    public static String getEventType(String webhookEventPayload) {
        Map<String, Object> eventPayloadMap = (Map<String, Object>) JSON.deserializeUntyped(webhookEventPayload);
        return (String) eventPayloadMap.get('type');
    }

    /**
    * @description
    * @return Map<String, String> Map of Webhook Event Name/Type and Webhook Handler Name.
                                  Keys are Event Names and Values are their correponding Webhook Handler Names
    **/
    public static Map<String, String> getWebhookEventHandlerMap() {
        Map<String, String> webhookEventHandlerMap = new Map<String, String>();
        Map<String, DR_Webhook_Configuration__mdt> webhookConfigRecMap = DR_Webhook_Configuration__mdt.getAll();

        for (String webhookConfigName : webhookConfigRecMap.keySet()) {
            webhookEventHandlerMap.put(webhookConfigRecMap.get(webhookConfigName).Webhook_Event_Name__c, webhookConfigRecMap.get(webhookConfigName).Webhook_Handler_Name__c);
        }
        return webhookEventHandlerMap;
    }

    /**
     * @description Get Webhook Handler Class Name
     * @param eventType EventType
     * @return String Returns Webhook Handler Class Name if defined or will return Default Webhook handler Class Name
     **/
    public static String getWebhookHandlerClassName(String eventType) {
        String result;

        // Get Webhook Event Handler Info Map
        Map<String, String> webhookEventHandlerMap = DRB2B_WebhookUtil.getWebhookEventHandlerMap();

        // Get the Webhook Handler Class name from Webhook Configuration
        if (String.isNotBlank(webhookEventHandlerMap.get(eventType))) {
            result = webhookEventHandlerMap.get(eventType);
        } else {
            // Return Default Webhook Handler Class
            logger.error('Event: ' + eventType + ' is currently not handled by the Connector. Default Webhook Handler defined in Webhook Configuration will be used.');
            result = webhookEventHandlerMap.get(DRB2B_ApplicationConstants.WEBHOOK_DEFAULT_HANDLER_CONFIG_NAME);
        }

        logger.flush();

        return result;
    }

    /**
     * @description Method to Store Failed Webhook Event information / Unhandled Event Information in SF custom object and then send an email to Admin
     * @param webhookEventPayload Webhook Event Request Payload
     * @param captureReason Reason this event has been stored in SF
     * @param emailMessage Email Body Message
     **/
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void captureEventInSfAndSendEmail(String webhookEventPayload, String captureReason, String emailMessage) {
        // Store Failed / Unhandled Event in SF
        String capturedEventIdInSf = captureWebhookEvent(webhookEventPayload, captureReason);

        // Send Email
        String emailAddress = DR_Connector_Configuration__mdt.getInstance('Connector_Notification_Email')?.Key__c;
        String emailBodyMessage = emailMessage + ' <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + capturedEventIdInSf + '"> Click here </a> to view this event information';
        DCM_EmailUtil.sendMail(captureReason , '<br>'+emailBodyMessage+'</br></br>'+'Env : ' +configurationSelector.getEnvironmentName()+' : '+ URL.getSalesforceBaseUrl().toExternalForm()+'<br/><br/>Thank you<br/><br/>', emailAddress, '');
    }

    /**
     * @description Method to Store Failed Webhook Event information / Unhandled Event Information in SF custom object
     * @param webhookEventPayload Webhook Event Request Payload
     * @param captureReason Reason this event has been stored in SF
     * @return String Newly Created Failed Event / Unhandled Event SF Record Id
     **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static String captureWebhookEvent(String webhookEventPayload, String captureReason) {
        DR_Failed_Event__c failedEvent;

        try {
            Map<String, Object> eventPayloadMap = (Map<String, Object>) JSON.deserializeUntyped(webhookEventPayload);
            failedEvent = new DR_Failed_Event__c(
                Event_Id__c = String.valueOf(eventPayloadMap.get('id')),
                Event_Type__c = String.valueOf(eventPayloadMap.get('type')),
                Event_Payload__c = webhookEventPayload,
                Event_Capture_Reason__c = captureReason
            );
        } catch (Exception e) {
            // If the Event payload is not JSON, then just capture the payload
            failedEvent = new DR_Failed_Event__c(Event_Payload__c = webhookEventPayload, Event_Capture_Reason__c = captureReason);
        }

        DmlManager.insertAsUser(failedEvent);

        return failedEvent.Id;
    }
}
