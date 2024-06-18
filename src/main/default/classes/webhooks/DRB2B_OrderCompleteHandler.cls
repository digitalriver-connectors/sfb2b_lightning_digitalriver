public with sharing class DRB2B_OrderCompleteHandler extends DRB2B_WebhookHandler {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.ORDER_COMPLETED_EVENT);

    @TestVisible
    DRB2B_FulfillmentSelector fulfillmentSelector = new DRB2B_FulfillmentSelector();

    @TestVisible
    private static DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();

    @TestVisible
    private static DRB2B_OrderService orderService = new DRB2B_OrderService();

    @TestVisible
    private static DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();

    /**
     * @description Method to validate Event
     **/
    public override Boolean validateWebhookEventPayload(Object webhookEventObj, String webhookEventPayload) {
        super.validateWebhookEventPayload(webhookEventObj, webhookEventPayload);
        DRB2B_OrderEventsRequestModel orderEventsRequestModel = (DRB2B_OrderEventsRequestModel) webhookEventObj;
        String drOrderId = orderEventsRequestModel.data.order.id;
        String drOrderState = orderEventsRequestModel.data.order.state;
        if (String.isNotBlank(drOrderId) && String.isNotBlank(drOrderState)) {
            return true;
        } else {
            throw new DRB2B_WebhookException(
                'validateWebhookEventPayload',
                'DR Order Id and/or DR Order State cannot be NULL for Event Type: ' + orderEventsRequestModel.type
            );
        }
    }

    public override void processWebhookEvent(RestResponse response, String webhookEventPayload) {
        Order orderMetaData = null;
        DRB2B_OrderEventsRequestModel orderEventsRequestModel = (DRB2B_OrderEventsRequestModel) DRB2B_OrderEventsRequestModel.deserializeEvent(
            webhookEventPayload
        );
        validateWebhookEventPayload(orderEventsRequestModel, webhookEventPayload);
        String drOrderId = orderEventsRequestModel.data.order.id;
        String drOrderState = orderEventsRequestModel.data.order.state;
        String drOrderFraudState = orderEventsRequestModel.data.order.fraudState;
        //   String sfOrderId = orderEventsRequestModel.data.order.metadata.sfOrderId;
        String sfOrderId = orderEventsRequestModel.data.order.metadata?.sfOrderId == null
            ? ''
            : orderEventsRequestModel.data.order.metadata.sfOrderId;
        // NEW LOGIC WITH RELEASE 2.1 when SF order not present

        if (orderEventsRequestModel.data.order.metadata?.sfOrderId == null) {
            orderMetaData = orderService.getSFOrderIdFromOrderObject(drOrderId);
            if (orderMetaData != null) {
                sfOrderId = orderMetaData.Id;
            }
        }

        LOGGER.debug(
            'Event Type: ' +
            orderEventsRequestModel.type +
            '; DR Order Id: ' +
            drOrderId +
            '; DR Order State: ' +
            drOrderState +
            '; DR Order Fraud State: ' +
            drOrderFraudState
        );

        if (String.isBlank(sfOrderId) || String.isEmpty(sfOrderId)) {
            response.statusCode = DRB2B_Constants.Base.ERROR_RESPONSE_CODE;
        } else {
            // Populate Order information to be stamped on DR Order Fulfillment record
            Map<String, String> orderDataMap = new Map<String, String>();
            orderDataMap.put('drOrderState', drOrderState);
            orderDataMap.put('fulfillmentStatus', 'Completed');
            orderDataMap.put('orderCompleteEventReceived', 'true');
            orderDataMap.put(
                'message',
                'Received order.complete event from DR and successfully processed by Salesforce'
            );

            List<Order> orderRecList = orderSelector.getByDROrderId(drOrderId);
            if (null != orderRecList && !orderRecList.isEmpty()) {
                // Order orderRec = orderRecList.get(0);

                // Update SF Order with DR Order State and Fraud State
                orderService.captureDrOrderStateAndFraudState(drOrderId, drOrderState, drOrderFraudState, sfOrderId);
                // Update DR Fulfillment record for this Order. It should already exist as this is the last step in Fulfillment process
                List<DR_Fulfillment__c> drFulfillmentRecList = fulfillmentSelector.getByDROrderId(drOrderId);
                if (null != drFulfillmentRecList && !drFulfillmentRecList.isEmpty()) {
                    DR_Fulfillment__c drFulfillmentRec = drFulfillmentRecList.get(0);
                    fulfillmentService.updateDrFulfillmentRecord(drFulfillmentRec, orderDataMap);
                } else {
                    // This should never happen
                    LOGGER.error(
                        'Event Type: ' +
                        orderEventsRequestModel.type +
                        ' with Event Id: ' +
                        orderEventsRequestModel.id +
                        ' could not be processed as DR Fulfillment Record with DR Order Id: ' +
                        drOrderId +
                        ' does not exist.'
                    );
                    String emailMessage =
                        'Event: <b>' +
                        orderEventsRequestModel.type +
                        '</b> could not be processed by DigitalRiver Connector.';
                    DRB2B_WebhookUtil.captureEventInSfAndSendEmail(
                        webhookEventPayload,
                        'DigitalRiver Webhook Event cannot be processed as DR Fulfillment Record with DR Order Id: ' +
                        drOrderId +
                        ' does not exist.',
                        emailMessage
                    );
                }
            } else {
                LOGGER.error(
                    'Event Type: ' +
                    orderEventsRequestModel.type +
                    ' with Event Id: ' +
                    orderEventsRequestModel.id +
                    ' could not be processed as SF Order with DR Order Id: ' +
                    drOrderId +
                    ' does not exist.'
                );
                String emailMessage =
                    'Event: <b>' +
                    orderEventsRequestModel.type +
                    '</b> could not be processed by DigitalRiver Connector.';
                DRB2B_WebhookUtil.captureEventInSfAndSendEmail(
                    webhookEventPayload,
                    'DigitalRiver Webhook Event cannot be processed as SF Order with DR Order Id: ' +
                    drOrderId +
                    ' does not exist.',
                    emailMessage
                );
            }
            response.statusCode = DRB2B_Constants.Base.SUCCESS_RESPONSE_CODE;
            LOGGER.flush();
        }
    }
}
