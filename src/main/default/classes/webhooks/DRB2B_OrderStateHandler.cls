public virtual class DRB2B_OrderStateHandler extends DRB2B_WebhookHandler {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.ORDER_MANAGEMENT);

    @TestVisible
    private static DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();

    @TestVisible
    private static DRB2B_OrderService orderService = new DRB2B_OrderService();

    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    /**
     * @description Method to validate Event
     **/
    public override Boolean validateWebhookEventPayload(Object webhookEventObj, String webhookEventPayload) {
        super.validateWebhookEventPayload(webhookEventObj, webhookEventPayload);
        DRB2B_OrderEventsRequestModel orderEventsRequestModel = (DRB2B_OrderEventsRequestModel) webhookEventObj;
        String drOrderId = orderEventsRequestModel.data.order.id;
        if (String.isNotBlank(drOrderId)) {
            return true;
        } else {
            throw new DRB2B_WebhookException(
                'validateWebhookEventPayload',
                'DR Order Id cannot be NULL for Event Type: ' + orderEventsRequestModel.type
            );
        }
    }

    /**
     * @description Method to process order Event
     * @param response Response object
     * @param webhookEventPayload Webhook Event Request Payload
     **/
    public virtual override void processWebhookEvent(RestResponse response, String webhookEventPayload) {
        DRB2B_OrderEventsRequestModel orderEventsRequestModel = (DRB2B_OrderEventsRequestModel) DRB2B_OrderEventsRequestModel.deserializeEvent(
            webhookEventPayload
        );
        Order orderMetaData = null;
        validateWebhookEventPayload(orderEventsRequestModel, webhookEventPayload);
        // NEW LOGIC WITH RELEASE 2.1 when SF order not present
        String drOrderId = orderEventsRequestModel.data.order.id;
        String sfOrderId = orderEventsRequestModel.data.order.metadata?.sfOrderId == null
            ? ''
            : orderEventsRequestModel.data.order.metadata.sfOrderId;
        if (orderEventsRequestModel.data.order.metadata?.sfOrderId == null) {
            orderMetaData = orderService.getSFOrderIdFromOrderObject(drOrderId);
            if (orderMetaData != null) {
                sfOrderId = orderMetaData.OrderNumber;
            }
        }
        if (String.isBlank(sfOrderId) || String.isEmpty(sfOrderId)) {
            response.statusCode = DRB2B_Constants.Base.ERROR_RESPONSE_CODE;
            LOGGER.info('DRB2B_Order State Handler sfOrderId ' + sfOrderId);
        } else {
            // Update SF Order With DR Order State and DR Order Fraud State
            captureDrOrderStateAndFraudStateOnOrder(orderEventsRequestModel, webhookEventPayload, sfOrderId);
            response.statusCode = DRB2B_Constants.Base.SUCCESS_RESPONSE_CODE;
            LOGGER.flush();
        }
    }

    public void captureDrOrderStateAndFraudStateOnOrder(
        DRB2B_OrderEventsRequestModel orderEventsRequestModel,
        String webhookEventPayload,
        String sfOrderId
    ) {
        String drOrderId = orderEventsRequestModel.data.order.id;
        String drOrderState = orderEventsRequestModel.data.order.state;
        String drFraudState = orderEventsRequestModel.data.order.fraudState;
        LOGGER.debug(
            'Event Type: ' +
            orderEventsRequestModel.type +
            '; SF Order Id: ' +
            sfOrderId +
            '; DR Order Id: ' +
            drOrderId +
            '; DR Order State: ' +
            drOrderState +
            '; DR Order Fraud State: ' +
            drFraudState
        );
        orderService.captureDrOrderStateAndFraudState(drOrderId, drOrderState, drFraudState, sfOrderId);
    }
}
