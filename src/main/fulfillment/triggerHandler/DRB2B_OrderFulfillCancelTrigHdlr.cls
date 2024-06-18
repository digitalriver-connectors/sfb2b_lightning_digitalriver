public with sharing class DRB2B_OrderFulfillCancelTrigHdlr implements TriggerHandler.Logic {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.TRIGGER_HANDLER);

    @TestVisible
    DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();

    @TestVisible
    DRB2B_FulfillmentRequestLogService fulfillmentRequestLogService = new DRB2B_FulfillmentRequestLogService();

    public void execute(List<SObject> records, TriggerContext ctx) {
        List<Order> orderRecs = (List<Order>) records;
        if (ctx.isAfter && ctx.isUpdate) {
            LOGGER.info('Order Ids in after trigger: ' + Collection.of(orderRecs).setOf(Order.Id));

            // Get All Orders which are sent for Fulfillment or Cancellation
            List<Order> ordersSentToFulfillOrCancel = getOrdersToFulfillOrCancel(orderRecs, ctx);
            if(!ordersSentToFulfillOrCancel.isEmpty()) {
                LOGGER.debug('Orders sent for Fulfillment or Cancellation: ' + Collection.of(ordersSentToFulfillOrCancel).setOf(Order.Id));

                // Do not allow fulfillment or cancellation of Orders that did not receive order.accepted event
                List<Order> sfOrdersEligibleForFulfillmentOrCancellation = fulfillmentService.getOrdersWhichReceivedOrderAcceptedEvent(ordersSentToFulfillOrCancel);
                addErrorForIneligibleOrderRecs(ordersSentToFulfillOrCancel, sfOrdersEligibleForFulfillmentOrCancellation);

                // Create DR Fulfillment request log records for Eligible Orders
                if(DCM_BaseUtilities.isNotNullOrEmpty(sfOrdersEligibleForFulfillmentOrCancellation)) {
                    fulfillmentRequestLogService.createFulfillmentRequestLogRecs(sfOrdersEligibleForFulfillmentOrCancellation);
                }
            }
            else {
                LOGGER.debug('None of the Orders are eligible for Order Level Fulfillment/Cancellation');
            }
        }
        LOGGER.flush();
    }

    /**
     * Get Orders which are sent for Fulfillment or Cancellation i.e., DR Order state is either fulfilled or cancelled.
     * DR Order State must be changed to either fulfilled or cancelled.
     */
    public List<Order> getOrdersToFulfillOrCancel(List<Order> orderRecs, TriggerContext ctx) {
        List<Order> ordersToFulfillOrCancel = new List<Order>();
        for(Order orderRec : orderRecs) {
            if(
                DRB2B_Constants.Fulfillment.ORDER_FULFILL_CANCEL_STATUSES.contains(orderRec.DR_Order_State__c) &&
                (ctx.isChangedTo(orderRec, Order.DR_Order_State__c, DRB2B_Constants.Fulfillment.FULFILL_STATUS) ||
                    ctx.isChangedTo(orderRec, Order.DR_Order_State__c, DRB2B_Constants.Fulfillment.CANCEL_STATUS))
            ) {
                ordersToFulfillOrCancel.add(orderRec);
            }
        }
        return ordersToFulfillOrCancel;
    }

    /**
     * Add Error to Orders which are not eligible for Fulfillment or Cancellation
     * order.accepted event is not received for these Orders
     */
    public void addErrorForIneligibleOrderRecs(List<Order> ordersSentToFulfillOrCancel, List<Order> sfOrdersEligibleForFulfillmentOrCancellation) {
        Set<Id> orderIdsEligibleForFulfillmentOrCancellation = (Set<Id>) Collection.of(sfOrdersEligibleForFulfillmentOrCancellation).setOf(Order.Id);
        LOGGER.debug('SF Order Ids Eligible for Fulfillment/Cancellation (Received order.accepted event): ' + orderIdsEligibleForFulfillmentOrCancellation);
        for(Order orderRec : ordersSentToFulfillOrCancel) {
            if(!orderIdsEligibleForFulfillmentOrCancellation.contains(orderRec.Id)) {
                String requestedState = (orderRec.DR_Order_State__c.equals(DRB2B_Constants.Fulfillment.FULFILL_STATUS)) ? 'Fulfillment' : 'Cancellation';
                orderRec.addError('Order is not eligible for ' + requestedState + ' as DR Order is not in accepted state');
            }
        }
    }

}