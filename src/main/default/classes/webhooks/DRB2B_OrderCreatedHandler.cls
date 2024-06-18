public with sharing class DRB2B_OrderCreatedHandler extends DRB2B_WebhookHandler {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.ORDER_CREATED_EVENT);

    @TestVisible
    private static DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();

    @TestVisible
    private static DRB2B_OrderService orderService = new DRB2B_OrderService();

    /**
     * @description Method to validate Event
     **/
    public override Boolean validateWebhookEventPayload(Object webhookEventObj, String webhookEventPayload) {
        super.validateWebhookEventPayload(webhookEventObj, webhookEventPayload);
        DRB2B_OrderEventsRequestModel orderEventsRequestModel = (DRB2B_OrderEventsRequestModel) webhookEventObj;
        LOGGER.debug('DRB2B_ORDERCreated HandlerEvent webhookEventObj' + webhookEventObj);
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
        String sfOrderId;
        validateWebhookEventPayload(orderEventsRequestModel, webhookEventPayload);
        String drOrderId = orderEventsRequestModel.data.order.id;
        orderMetaData = orderService.getSFOrderIdFromOrderObject(drOrderId);
        if (orderMetaData != null) {
            sfOrderId = orderMetaData.Id;
        }
        if (String.isBlank(sfOrderId) || String.isEmpty(sfOrderId)) {
            response.statusCode = DRB2B_Constants.Base.ERROR_RESPONSE_CODE;
            LOGGER.debug('DRB2B_ORDERCreated HandlerEvent Type:sfOrderId ' + sfOrderId);
        } else {
            response.statusCode = DRB2B_Constants.Base.SUCCESS_RESPONSE_CODE;
            LOGGER.debug(
                'DRB2BEvent Type: ' +
                orderEventsRequestModel.type +
                '; SF Order Id: ' +
                sfOrderId +
                '; DR Order Id: ' +
                drOrderId
            );
            orderService.updateDROrderWithSfOrderUpstreamId(drOrderId, orderMetaData);
            LOGGER.flush();
        }
    }
}
