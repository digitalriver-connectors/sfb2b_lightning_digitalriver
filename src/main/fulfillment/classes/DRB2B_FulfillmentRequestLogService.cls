public with sharing class DRB2B_FulfillmentRequestLogService {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.FULFILLMENT);

    @TestVisible
    private DRB2B_OrderItemSelector orderItemSelector = new DRB2B_OrderItemSelector();

    @TestVisible
    private DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();

    @TestVisible
    DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();

    /**
     * Check if the Order Item Id entered in the request belongs to the Order selected in the same request
     * Also check for Quantity requested based on Support for Partial Fulfillment/Cancellation
     */
    public List<DR_Fulfillment_Request_Log__c> checkIfOrderItemsBelongToCorrectOrder(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs, Boolean partialFulfillmentSupported) {
        List<DR_Fulfillment_Request_Log__c> goodFulfillmentReqLogRecs = new List<DR_Fulfillment_Request_Log__c>();
        List<OrderItem> orderItems = getSfOrderItemsFromRequestLogRecs(fulfillmentRequestLogRecs);
        Map<Id, Id> sfOrderIdBySfOrderItemId = (Map<Id, Id>) Collection.of(orderItems).mapBy(OrderItem.Id, OrderItem.OrderId);
        Map<Id, Decimal> orderItemQuantityBySfOrderItemId = (Map<Id, Decimal>) Collection.of(orderItems).mapBy(OrderItem.Id, OrderItem.Quantity);
        Map<Id, Decimal> orderItemOpenQuantityBySfOrderItemId = (Map<Id, Decimal>) Collection.of(orderItems).mapBy(OrderItem.Id, OrderItem.DR_Open_Quantity__c);
        LOGGER.debug('OrderItem Quantity By SfOrderItemId --> ' + orderItemQuantityBySfOrderItemId
                + '; OrderItem OpenQuantity By SfOrderItemId --> ' + orderItemOpenQuantityBySfOrderItemId);
        for(DR_Fulfillment_Request_Log__c fulfillmentRequestLogRec : fulfillmentRequestLogRecs) {
            String sfOrderItemId = fulfillmentRequestLogRec.OrderItem_Id__c;
            String sfOrderId = fulfillmentRequestLogRec.OrderId__c;
            if(sfOrderId.equalsIgnoreCase(sfOrderIdBySfOrderItemId.get(sfOrderItemId))) {
                Decimal requestedFulfillQuantity = fulfillmentRequestLogRec.Fulfill_Quantity__c;
                Decimal requestedCancelQuantity = fulfillmentRequestLogRec.Cancel_Quantity__c;
                Decimal sumOfFulfillAndCancelQuantity = requestedFulfillQuantity + requestedCancelQuantity;
                Decimal orderItemPurchaseQuantity = orderItemQuantityBySfOrderItemId.get(sfOrderItemId);
                Decimal orderItemOpenQuantity = orderItemOpenQuantityBySfOrderItemId.get(sfOrderItemId);
                LOGGER.debug('RequestedFulfillQuantity --> ' + requestedFulfillQuantity + '; RequestedCancelQuantity --> ' + requestedCancelQuantity
                        + '; OrderItemOpenQuantity --> ' + orderItemOpenQuantity + '; OrderItemPurchaseQuantity --> ' + orderItemPurchaseQuantity);
                if(sumOfFulfillAndCancelQuantity == 0.00) {
                    fulfillmentRequestLogRec.addError('Both Fulfill and Cancel quantity cannot be 0');
                    LOGGER.error('Both Fulfill and Cancel quantity cannot be zero: ' + fulfillmentRequestLogRec);
                }
                else if(sumOfFulfillAndCancelQuantity > orderItemOpenQuantity) {
                    fulfillmentRequestLogRec.addError('Sum of Requested Fulfill and Cancel quantity cannot be greater than Available/Open Quantity');
                }
                else {
                    if(partialFulfillmentSupported) {
                        goodFulfillmentReqLogRecs.add(fulfillmentRequestLogRec);
                    }
                    else {
                        if(requestedFulfillQuantity > 0 && requestedCancelQuantity > 0) {
                            fulfillmentRequestLogRec.addError('Both Fulfill and Cancel quantity cannot be greater than 0 as Partial Fulfillment/Cancellation is not supported');
                        }
                        else if((requestedFulfillQuantity < orderItemOpenQuantity) && (requestedCancelQuantity < orderItemOpenQuantity))
                        {
                            fulfillmentRequestLogRec.addError('Partial Fulfillment/Cancellation is not supported');
                        }
                        else {
                            goodFulfillmentReqLogRecs.add(fulfillmentRequestLogRec);
                        }
                    }
                }
            }
            else {
                fulfillmentRequestLogRec.addError('Order Item Id entered does not belong to the Order selected');
            }
        }
        return goodFulfillmentReqLogRecs;
    }

    /**
     * We should not allow fulfillment/cancellation of orders that are in statuses such as blocked, in_review, or opened.
     * Orders can be fulfilled or cancelled only if order.accepted event is received
     */
    public List<DR_Fulfillment_Request_Log__c> getEligibleRecsForFulfillment(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs) {
        List<DR_Fulfillment_Request_Log__c> eligibleFulfillmentReqLogs = new List<DR_Fulfillment_Request_Log__c>();
        List<Id> orderIdsNotEligibleForFulfillmentOrCancellation = new List<Id>();

        // Get SF Orders for which Fulfillment Request Log records are created
        List<Order> orders = getSfOrdersFromRequestLogRecs(fulfillmentRequestLogRecs);

        // Filter orders whose DR Order state is not "cancelled_by_sf"
        List<Order> ordersNotCancelledBySf = (List<Order>) Collection.of(orders)
                                    .filter(Order.DR_Order_State__c).notEquals(DRB2B_Constants.DrOrderState.CANCELLED_BY_SF)
                                    .get();

        // Get Orders eligible for fulfillment/cancellation.
        // Orders/OrderItems cannot be fulfilled or cancelled if order.accepted event is not received
        List<Order> sfOrdersEligibleForFulfillmentOrCancellation = fulfillmentService.getOrdersWhichReceivedOrderAcceptedEvent(ordersNotCancelledBySf);
        Set<Id> orderIdsEligibleForFulfillmentOrCancellation = (Set<Id>) Collection.of(sfOrdersEligibleForFulfillmentOrCancellation).setOf(Order.Id);
        for(DR_Fulfillment_Request_Log__c fulfillmentRequestLogRec : fulfillmentRequestLogRecs) {
            if(orderIdsEligibleForFulfillmentOrCancellation.contains(fulfillmentRequestLogRec.OrderId__c)) {
                eligibleFulfillmentReqLogs.add(fulfillmentRequestLogRec);
            }
            else {
                fulfillmentRequestLogRec.addError('Order is not eligible for Fulfillment/Cancellation as order.accepted event is not received');
                orderIdsNotEligibleForFulfillmentOrCancellation.add(fulfillmentRequestLogRec.OrderId__c);
            }
        }
        LOGGER.info('SF Orders which received order.accepted event: ' + orderIdsEligibleForFulfillmentOrCancellation);
        LOGGER.warn('SF Orders which did not receive order.accepted event and are not eligible for fulfillment/cancellation: ' + orderIdsNotEligibleForFulfillmentOrCancellation);

        return eligibleFulfillmentReqLogs;
    }

    /**
     * Cannot Fulfill and/or Cancel more than the Quantity available for Fulfillment/Cancellation for a particular Line Item
     * Both Fulfill and Cancel Quantity in Fulfillment Request Log record cannot be set to 0
     */
    public void validateRequestedFulfillAndCancelQuantity(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs) {
        // Both Fulfill and Cancel Quantity in Fulfillment Request Log record cannot be zero. This logic is moved to the method "checkIfOrderItemsBelongToCorrectOrder"
        //List<DR_Fulfillment_Request_Log__c> validFulfillmentReqLogRecs = validateBothFulfillandCancelQuantityCannotBeZero(fulfillmentRequestLogRecs);

        Map<String, List<DR_Fulfillment_Request_Log__c>> fulfillmentReqLogsByOrderItemId = (Map<String, List<DR_Fulfillment_Request_Log__c>>) 
                    Collection.of(fulfillmentRequestLogRecs).groupBy(DR_Fulfillment_Request_Log__c.OrderItem_Id__c);
        LOGGER.debug('Fulfillment Request Log Records by Order Item Id: ' + fulfillmentReqLogsByOrderItemId);

        // Populate DR Order Id, DR Order State and DR Line Item Id on Fulfillment Request Log Record
        populateDrOrderInfoOnFulfillmentReqLog(fulfillmentRequestLogRecs);
        LOGGER.debug('Captured DR Order Id, DR Order State and DR Line Item Id on Fulfillment Request Log Records');

        // Get the Available Quantity for Fulfillment and/or Cancellation for each Order Item
        Map<Id, Decimal> openQuantityByOrderItemId = getOrderItemAvailableQuantityToFulfillAndCancel(fulfillmentReqLogsByOrderItemId.keySet());

        // Get Fulfillment Request Log Records whose Fulfillment And Cancel Quantity exceed the Available Quantity for Fulfillment/Cancellation
        List<DR_Fulfillment_Request_Log__c> failedFulfillmentReqLogs = getFulfillmentReqLogsThatExceededAvailableQuantity(fulfillmentReqLogsByOrderItemId, openQuantityByOrderItemId);

        // Add Error Messages
        for(DR_Fulfillment_Request_Log__c failedFulfillmentReqLog : failedFulfillmentReqLogs) {
            failedFulfillmentReqLog.addError('Requested Fulfillment/Cancellation quantity cannot be more than the Quantity Available for Fulfillment/Cancellation');
        }

        LOGGER.flush();
    }

    /**
     * Populate DR Order Id, DR Order State and DR Line Item Id on DR Fulfillment Request Log object
     */
    public void populateDrOrderInfoOnFulfillmentReqLog(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs) {
        List<Order> orders = getSfOrdersFromRequestLogRecs(fulfillmentRequestLogRecs);
        List<OrderItem> orderItems = getSfOrderItemsFromRequestLogRecs(fulfillmentRequestLogRecs);
        Map<Id, String> drOrderIdBySfOrderId = (Map<Id, String>) Collection.of(orders).mapBy(Order.Id, Order.DR_Order_Id__c);
        Map<Id, String> drOrderStateBySfOrderId = (Map<Id, String>) Collection.of(orders).mapBy(Order.Id, Order.DR_Order_State__c);
        Map<Id, String> drLineItemIdBySfOrderItemId = (Map<Id, String>) Collection.of(orderItems).mapBy(OrderItem.Id, OrderItem.DR_Order_Item_Id__c);
        LOGGER.debug('DR Order Id by SF Order Id: ' + drOrderIdBySfOrderId);
        for(DR_Fulfillment_Request_Log__c fulfillmentRequestLogRec : fulfillmentRequestLogRecs) {
            fulfillmentRequestLogRec.DR_Order_Id__c = drOrderIdBySfOrderId.get(fulfillmentRequestLogRec.OrderId__c);
            fulfillmentRequestLogRec.DR_Order_State__c = drOrderStateBySfOrderId.get(fulfillmentRequestLogRec.OrderId__c);
            fulfillmentRequestLogRec.DR_OrderItem_Id__c = drLineItemIdBySfOrderItemId.get(fulfillmentRequestLogRec.OrderItem_Id__c);
        }
    }

    public List<Order> getSfOrdersFromRequestLogRecs(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs) {
        Set<Id> sfOrderIds = (Set<Id>) Collection.of(fulfillmentRequestLogRecs).setOf(DR_Fulfillment_Request_Log__c.OrderId__c);
        return orderSelector.getDrOrderInfoBySfOrderIds(sfOrderIds);
    }

    public List<OrderItem> getSfOrderItemsFromRequestLogRecs(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs) {
        Set<String> sfOrderItemIds = (Set<String>) Collection.of(fulfillmentRequestLogRecs).setOf(DR_Fulfillment_Request_Log__c.OrderItem_Id__c);
        return orderItemSelector.getDRFieldsByOrderItemIds(sfOrderItemIds);
    }

    /**
     * Get the Available Quantity for Fulfillment and/or Cancellation per Order Item
     */
    public Map<Id, Decimal> getOrderItemAvailableQuantityToFulfillAndCancel(Set<String> orderItemIds) {
        List<OrderItem> orderItems = orderItemSelector.getQuantityFieldsByIds(orderItemIds);
        LOGGER.debug('Order Items with Fulfillment/Cancelled Quantities: ' + orderItems);
        Map<Id, Decimal> openQuantityByOrderItemId = (Map<Id, Decimal>) Collection.of(orderItems).mapBy(OrderItem.Id, OrderItem.DR_Open_Quantity__c);
        LOGGER.debug('Available OrderItem Quantity to Fulfill/Cancel: ' + openQuantityByOrderItemId);
        return openQuantityByOrderItemId;
    }

    /**
     * Both Fulfill and Cancel Quantity in Fulfillment Request Log record cannot be zero
     */
    public List<DR_Fulfillment_Request_Log__c> validateBothFulfillandCancelQuantityCannotBeZero(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs) {
        List<DR_Fulfillment_Request_Log__c> validFulfillmentRequestLogRecs = new List<DR_Fulfillment_Request_Log__c>();
        for(DR_Fulfillment_Request_Log__c fulfillmentReqLogRec : fulfillmentRequestLogRecs) {
            Decimal totalQuantityToFulfillAndCancel = fulfillmentReqLogRec.Fulfill_Quantity__c + fulfillmentReqLogRec.Cancel_Quantity__c;
            if(totalQuantityToFulfillAndCancel > 0) {
                validFulfillmentRequestLogRecs.add(fulfillmentReqLogRec);
            }
            else {
                fulfillmentReqLogRec.addError('Both Fulfill and Cancel quantity cannot be zero');
                LOGGER.error('Both Fulfill and Cancel quantity cannot be zero: ' + fulfillmentReqLogRec);
            }
        }
        return validFulfillmentRequestLogRecs;
    }

    /**
     * Get Fulfillment Request Log Records whose Fulfillment And Cancel Quantity exceed the Available Quantity for Fulfillment/Cancellation
     */
    public List<DR_Fulfillment_Request_Log__c> getFulfillmentReqLogsThatExceededAvailableQuantity(
            Map<String, List<DR_Fulfillment_Request_Log__c>> fulfillmentReqLogsByOrderItemId, Map<Id, Decimal> openQuantityByOrderItemId) {
        List<DR_Fulfillment_Request_Log__c> failedFulfillmentReqLogs = new List<DR_Fulfillment_Request_Log__c>();
        for(String orderItemId : fulfillmentReqLogsByOrderItemId.keySet()) {
            List<DR_Fulfillment_Request_Log__c> fulfillmentReqLogs = fulfillmentReqLogsByOrderItemId.get(orderItemId);
            Decimal quantityToFulfillAndCancelByOrderItemId = Collection.of(fulfillmentReqLogs).sum(DR_Fulfillment_Request_Log__c.Fulfill_Quantity__c) + Collection.of(fulfillmentReqLogs).sum(DR_Fulfillment_Request_Log__c.Cancel_Quantity__c);
            Decimal availableQuantityToFulfillOrCancel = openQuantityByOrderItemId.get(orderItemId);
            LOGGER.debug(orderItemId, 'Available Quantity to Fulfill/Cancel: ' + availableQuantityToFulfillOrCancel + '; Quantity Requested to Fulfill and/or cancel: ' + quantityToFulfillAndCancelByOrderItemId);
            if(quantityToFulfillAndCancelByOrderItemId > availableQuantityToFulfillOrCancel) {
                failedFulfillmentReqLogs.addAll(fulfillmentReqLogs);
            }
        }

        if(Collection.of(failedFulfillmentReqLogs).isNotEmpty()) {
            LOGGER.error('Fulfillment Request Log Records where requested Fulfill/Cancel quantity is more than the available quantity: ' + failedFulfillmentReqLogs);
        }
        return failedFulfillmentReqLogs;
    }

    public void updateOpenQuantityOnOrderItems(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs) {
        Map<String, List<DR_Fulfillment_Request_Log__c>> fulfillmentReqLogsByOrderItemId = (Map<String, List<DR_Fulfillment_Request_Log__c>>) 
                    Collection.of(fulfillmentRequestLogRecs).groupBy(DR_Fulfillment_Request_Log__c.OrderItem_Id__c);
        LOGGER.debug('Fulfillment Request Log Records by Order Item Id: ' + fulfillmentReqLogsByOrderItemId);

        Map<String, Decimal> requestedQuantityToFulfillCancelByOrderItemId = getRequestedQuantityToFulfillAndCancelByOrderItemId(fulfillmentReqLogsByOrderItemId);
        List<OrderItem> orderItems = orderItemSelector.getQuantityFieldsByIds(requestedQuantityToFulfillCancelByOrderItemId.keySet());
        for(OrderItem orderItem : orderItems) {
            orderItem.DR_Open_Quantity__c = orderItem.DR_Open_Quantity__c - requestedQuantityToFulfillCancelByOrderItemId.get(orderItem.Id);
        }
        DmlManager.updateAsUser(orderItems);
        LOGGER.debug('Updated Available Quantity for Fulfillment/Cancellation on Order Items: ' + (Set<Id>) Collection.of(orderItems).setOf(OrderItem.Id));
    }

    public Map<String, Decimal> getRequestedQuantityToFulfillAndCancelByOrderItemId(Map<String, List<DR_Fulfillment_Request_Log__c>> fulfillmentReqLogsByOrderItemId) {
        Map<String, Decimal> requestedQuantityToFulfillCancelByOrderItemId = new Map<String, Decimal>();
        for(String orderItemId : fulfillmentReqLogsByOrderItemId.keySet()) {
            List<DR_Fulfillment_Request_Log__c> fulfillmentReqLogs = fulfillmentReqLogsByOrderItemId.get(orderItemId);
            Decimal quantityToFulfillAndCancelByOrderItemId = Collection.of(fulfillmentReqLogs).sum(DR_Fulfillment_Request_Log__c.Fulfill_Quantity__c) + Collection.of(fulfillmentReqLogs).sum(DR_Fulfillment_Request_Log__c.Cancel_Quantity__c);
            LOGGER.debug(orderItemId, 'Quantity Requested to Fulfill and/or cancel: ' + quantityToFulfillAndCancelByOrderItemId);
            requestedQuantityToFulfillCancelByOrderItemId.put(orderItemId, quantityToFulfillAndCancelByOrderItemId);
        }
        return requestedQuantityToFulfillCancelByOrderItemId;
    }

    /**
     * Create DR Fulfillment request log records based on OrderItem Open Quantity
     */
    public void createFulfillmentRequestLogRecs(List<Order> orderRecs) {
        List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
        Set<Id> orderItemIds = new Set<Id>();

        // Get Line Items for all Orders
        Set<Id> orderIds = (Set<Id>) Collection.of(orderRecs).setOf(Order.Id);
        List<OrderItem> orderItemRecs = orderItemSelector.getQuantityFieldsByOrderIds(orderIds);

        // Get DR Order State by SF Order Id
        Map<Id, String> drOrderStateBySfOrderId = (Map<Id, String>) Collection.of(orderRecs).mapBy(Order.Id, Order.DR_Order_State__c);

        // Create DR Fulfillment Request Log record for each Order Item if DR Open Quantity is greater than 0
        for(OrderItem orderItemRec : orderItemRecs) {
            if(orderItemRec.DR_Open_Quantity__c > 0) {
                fulfillmentRequestLogRecList.add(getFulfillmentReqLogToCreate(orderItemRec, drOrderStateBySfOrderId.get(orderItemRec.OrderId)));
                orderItemIds.add(orderItemRec.Id);
            }
        }

        if(DCM_BaseUtilities.isNotNullOrEmpty(fulfillmentRequestLogRecList)) {
            DmlManager.insertAsUser(fulfillmentRequestLogRecList);
            LOGGER.debug('Created Fulfillment Request Log Records for Order Item Ids: ' + orderItemIds);
        }
    }

    public DR_Fulfillment_Request_Log__c getFulfillmentReqLogToCreate(OrderItem orderItemRec, String drOrderState) {
        DR_Fulfillment_Request_Log__c fulfillmentRequestLogRec = new DR_Fulfillment_Request_Log__c();
        fulfillmentRequestLogRec.OrderId__c = orderItemRec.OrderId;
        fulfillmentRequestLogRec.OrderItem_Id__c = orderItemRec.Id;
        if(drOrderState.equalsIgnoreCase(DRB2B_Constants.Fulfillment.FULFILL_STATUS)) {
            fulfillmentRequestLogRec.Fulfill_Quantity__c = orderItemRec.DR_Open_Quantity__c;
        }
        else if(drOrderState.equalsIgnoreCase(DRB2B_Constants.Fulfillment.CANCEL_STATUS)) {
            fulfillmentRequestLogRec.Cancel_Quantity__c = orderItemRec.DR_Open_Quantity__c;
        }
        return fulfillmentRequestLogRec;
    }

}