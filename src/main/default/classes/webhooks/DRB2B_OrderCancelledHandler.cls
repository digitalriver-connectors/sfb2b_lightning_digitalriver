/**
 * Created by gkalidindi on 1/18/22.
 */

public with sharing class DRB2B_OrderCancelledHandler extends DRB2B_WebhookHandler {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.ORDER_CANCELLED_EVENT);

    @TestVisible
    private static DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();
    @TestVisible
    private static DRB2B_OrderItemSelector orderItemSelector = new DRB2B_OrderItemSelector();
    @TestVisible
    private static DRB2B_OrderService orderService = new DRB2B_OrderService();
    @TestVisible
    DRB2B_FulfillmentSelector fulfillmentSelector = new DRB2B_FulfillmentSelector();
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
        Map<String, String> orderDataMap = new Map<String, String>();
        DRB2B_OrderEventsRequestModel orderEventsRequestModel = (DRB2B_OrderEventsRequestModel) DRB2B_OrderEventsRequestModel.deserializeEvent(
            webhookEventPayload
        );
        validateWebhookEventPayload(orderEventsRequestModel, webhookEventPayload);
        String drOrderId = orderEventsRequestModel.data.order.id;
        String drOrderState = orderEventsRequestModel.data.order.state;
        String drOrderFraudState = orderEventsRequestModel.data.order.fraudState;
        //  String sfOrderId = orderEventsRequestModel.data.order.metadata.sfOrderId;
        // NEW LOGIC WITH RELEASE 2.1 when SF order not present
        String sfOrderId = orderEventsRequestModel.data.order.metadata?.sfOrderId == null
            ? ''
            : orderEventsRequestModel.data.order.metadata.sfOrderId;

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
            orderDataMap.put('fulfillmentStatus', 'Completed');
            orderDataMap.put('orderCancelled', 'true');
            orderDataMap.put(
                'message',
                'Received ' +
                orderEventsRequestModel.type +
                ' Event from DR and successfully processed by Salesforce'
            );

            // Get SF Order and DR Order Fulfillment record. This should exist in all scenarios
            List<DR_Fulfillment__c> drOrderFulfillmentRecs = fulfillmentSelector.getByDROrderId(drOrderId);
            List<Order> orderRecList = orderSelector.getByDROrderId(drOrderId);
            Order orderRec;
            if (DCM_BaseUtilities.isNotNullOrEmpty(orderRecList)) {
                orderRec = orderRecList.get(0);
            } else {
                // In case order.cancelled event is sent due to an error at the SF end and DR Order Id is not captured on SF Order
                String sfOrderNumber = orderEventsRequestModel.data.order.upstreamId;
                orderRec = orderSelector.getBySfOrderNumber(new List<String>{ sfOrderNumber }).get(0);
            }
            orderDataMap.put('orderId', orderRec.Id);
            String existingDrOrderState = orderRec.DR_Order_State__c;

            // Cancellation initiated by Client. Client can initiate cancellation only after receiving order.accepted event
            // DR Order Fulfillment record should exist as client can cancel order only if order.accepted event is received
            if (existingDrOrderState.equalsIgnoreCase(DRB2B_Constants.DrOrderState.CANCELLED)) {
                logger.info(orderRec.Id, 'Cancellation is initiated by Client');
                // Set OrderCancelled flag to true, DROrderState to "cancelled" and FulfillmentStatus to "Completed" on DR Fulfillment record
                orderDataMap.put('drOrderState', drOrderState);
                fulfillmentService.updateDrFulfillmentRecord(drOrderFulfillmentRecs.get(0), orderDataMap);
            } else if (existingDrOrderState.equalsIgnoreCase(DRB2B_Constants.DrOrderState.CANCELLED_BY_SF)) {
                // Cancellation initiated by SF due to an error
                logger.info(orderRec.Id, 'Cancellation is initiated by SF due to an error');
                // Set OrderCancelled flag to true, DROrderState to "cancelled_by_sf" and FulfillmentStatus to "Completed" on DR Fulfillment record
                // If order.accepted event is not received, then DR Order Fulfillment record is not created
                if (DCM_BaseUtilities.isNotNullOrEmpty(drOrderFulfillmentRecs)) {
                    orderDataMap.put('drOrderState', DRB2B_Constants.DrOrderState.CANCELLED_BY_SF);
                    fulfillmentService.updateDrFulfillmentRecord(drOrderFulfillmentRecs.get(0), orderDataMap);
                }
            } else if (areAllLineItemsCancelled(new List<Id>{ orderRec.Id })) {
                // Check if all the line items are cancelled. This scenario happens if all Line Items are cancelled independently
                // and order.accepted event is previously received
                logger.info(
                    orderRec.Id,
                    'Cancellation is initiated by Client. All Line Items are cancelled independently'
                );
                // Set OrderCancelled flag to true, DROrderState to "cancelled" and FulfillmentStatus to "Completed" on DR Fulfillment record
                orderDataMap.put('drOrderState', drOrderState);
                fulfillmentService.updateDrFulfillmentRecord(drOrderFulfillmentRecs.get(0), orderDataMap);

                // Set "cancelled" as the DR Order State on SF Order
                orderService.captureDrOrderStateAndFraudState(drOrderId, drOrderState, drOrderFraudState, sfOrderId);
            } else if (
                DCM_BaseUtilities.isNullOrEmpty(drOrderFulfillmentRecs) //|| (DCM_BaseUtilities.isNotNullOrEmpty(drOrderFulfillmentRecs) && !drOrderFulfillmentRecs.get(0).Eligible_For_Fulfillment__c)
            ) {
                // Customer cannot initiate cancellation without receiving order.accepted event
                // So if order.accepted event is not received (DR Order Fulfillment record is not created),
                // but order.cancelled event is sent, then this is a cancellation initiated by DR (for wire transfer)
                logger.info(orderRec.Id, 'Cancellation is initiated by DR.');
                // Set "cancelled_by_dr" as the DR Order State on SF Order
                orderService.captureDrOrderStateAndFraudState(
                    drOrderId,
                    DRB2B_Constants.DrOrderState.CANCELLED_BY_DR,
                    drOrderFraudState,
                    sfOrderId
                );
            } else {
                // This scenario might happen if
                // 1. All Line items are independently cancelled and the cancellation requests are sent to DR
                // 2. In the Fulfillment/Cancellation batch job, we update the DR line item states in the finish block of batch job
                // 3. So in the scenario where DR sends order.cancelled event before all the line item states get updated to cancelled,
                // this condition should handle it
                logger.warn(
                    orderRec.Id,
                    'Received order.cancelled event before all line item states are set to cancelled. Setting the order status to cancelled'
                );
                // Set OrderCancelled flag to true, DROrderState to "cancelled" and FulfillmentStatus to "Completed" on DR Fulfillment record
                orderDataMap.put('drOrderState', drOrderState);
                orderDataMap.put(
                    'message',
                    'Received order.cancelled event before all line item states are set to cancelled. Setting the order status to cancelled'
                );
                fulfillmentService.updateDrFulfillmentRecord(drOrderFulfillmentRecs.get(0), orderDataMap);

                // Set "cancelled" as the DR Order State on SF Order
                orderService.captureDrOrderStateAndFraudState(drOrderId, drOrderState, drOrderFraudState, sfOrderId);
            }

            response.statusCode = DRB2B_Constants.Base.SUCCESS_RESPONSE_CODE;
            LOGGER.flush();
        }
    }

    // Check if all the Order Line items are cancelled. This might happen if line items are cancelled independently
    public Boolean areAllLineItemsCancelled(List<Id> orderIds) {
        Boolean areAllLineItemsCancelled = true;
        List<OrderItem> orderItems = orderItemSelector.getByOrderIdsAndOrderItemType(orderIds, 'Order Product');
        for (OrderItem orderItemRec : orderItems) {
            if (
                !orderItemRec.DR_Order_Item_State__c.equalsIgnoreCase(
                    DRB2B_Constants.Fulfillment.LINE_ITEM_CANCELLED_STATUS
                )
            ) {
                areAllLineItemsCancelled = false;
                break;
            }
        }
        return areAllLineItemsCancelled;
    }
}
