public with sharing class DRB2B_OrderAcceptedHandler extends DRB2B_WebhookHandler {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.ORDER_ACCEPTED_EVENT);

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
        LOGGER.debug('DRB2B_ORDERAcceptedHandlerEvent webhookEventObj' + webhookEventObj);
        system.debug('DRB2B_ORDERAcceptedHandlerEvent webhookEventObj' + webhookEventObj);
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
        if (String.isBlank(sfOrderId) || String.isEmpty(sfOrderId)) {
            response.statusCode = DRB2B_Constants.Base.ERROR_RESPONSE_CODE;
            LOGGER.debug('DRB2B_ORDERAcceptedHandlerEvent Type:sfOrderId ' + sfOrderId);
        } else {
            LOGGER.debug(
                'DRB2BEvent Type: ' +
                orderEventsRequestModel.type +
                '; SF Order Id: ' +
                sfOrderId +
                '; DR Order Id: ' +
                drOrderId +
                '; DR Order State: ' +
                drOrderState +
                '; DR Order Fraud State: ' +
                drOrderFraudState
            );
            LOGGER.INFO('DRB2B_OrderAcceptedHandler orderRecList input sforder' + sfOrderId);
            // Order Accepted Webhook is usually recevied before a SF Order is stamped with DR Order information
            List<Order> orderRecList = orderSelector.getDrOrderInfoBySfOrderId(sfOrderId);
            LOGGER.INFO('DRB2B_OrderAcceptedHandler orderRecList' + orderRecList);
            if (null != orderRecList && !orderRecList.isEmpty()) {
                // Update SF Order with DR Order State and Fraud State
                orderService.captureDrOrderStateAndFraudState(drOrderId, drOrderState, drOrderFraudState, sfOrderId);
            } else {
                LOGGER.warn(
                    'Event Id: ' +
                    orderEventsRequestModel.id +
                    ' for DR Order Id: ' +
                    drOrderId +
                    ' could not be processed as SF Order: ' +
                    sforderId +
                    ' does not exist.'
                );
            }
            response.statusCode = DRB2B_Constants.Base.SUCCESS_RESPONSE_CODE;
            LOGGER.flush();
        }
    }
}
