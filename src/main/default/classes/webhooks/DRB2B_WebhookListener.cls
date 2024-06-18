@RestResource(urlMapping='/webhooks/*')
global with sharing class DRB2B_WebhookListener {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.WEBHOOK_EVENT);

    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    /**
    * @description Webhook Controller Method to receive Event Payload and to route the request for processing
    **/
    @HttpPost
    global static void getWebhookEventInformationFromDR() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String webhookEventPayload = request.requestBody.toString();
        logger.info('Event Payload received from DR: ' + webhookEventPayload);
        try {
            if(String.isNotBlank(webhookEventPayload)) {
                String eventType = DRB2B_WebhookUtil.getEventType(webhookEventPayload);
                logger.info('Received Event: ' + eventType);

                // Get Instance of Webhook Handler Class
                DRB2B_IWebHookHandler webhookHandler = (DRB2B_IWebHookHandler) DRB2B_WebhookHandlerFactory.getWebhookHandlerInstance(eventType);

                // Process Webhook
                webhookHandler.processWebhookEvent(response, webhookEventPayload);
            }
            else {
                logger.error('Webhook Event Payload is NULL');
                response.statusCode = DRB2B_Constants.Base.ERROR_RESPONSE_CODE;
                // Send email
                String emailAddress = DR_Connector_Configuration__mdt.getInstance('Connector_Notification_Email')?.Key__c;
                DCM_EmailUtil.sendMail(
                    'Received Empty Event Payload ' ,
                    '<br/> Received Empty Event Payload <br/><br/>'+'Env : '+configurationSelector.getEnvironmentName()+' : '+ URL.getSalesforceBaseUrl().toExternalForm()+'<br/><br/>Thank you<br/><br/>', emailAddress, ''
                );
            }
        }
        catch(DRB2B_WebhookException we) {
            response.statusCode = DRB2B_Constants.Base.ERROR_RESPONSE_CODE;
            logger.error(null, 'Encountered Error while processing Event Payload: ' + webhookEventPayload, we);

            // Store Failed / Unhandled Event in SF and Send an email to Admin
            String emailMessage = 'Event: <b>' + DRB2B_WebhookUtil.getEventType(webhookEventPayload) + '</b> could not be processed by DigitalRiver Connector.';
            DRB2B_WebhookUtil.captureEventInSfAndSendEmail(webhookEventPayload, 'Error while processing DigitalRiver Webhook: ' + we.getMessage(), emailMessage);
        }
        catch(Exception ex) {
            response.statusCode = DRB2B_Constants.Base.SUCCESS_RESPONSE_CODE;
            logger.error(null, 'Encountered Error while processing Event Payload: ' + webhookEventPayload, ex);
            // Store Failed/Unhandled Event in SF and Send an email to Admin
            String emailMessage = 'Webhook Event could not be processed by the DigitalRiver Connector. Error Message: ' + ex.getMessage();
            DRB2B_WebhookUtil.captureEventInSfAndSendEmail(webhookEventPayload, 'Error while processing DigitalRiver Webhook: ' + ex.getMessage(), emailMessage);
        }
        finally {
            logger.flush();
        }
    }
}