global with sharing class DRB2B_OrderFulfillmentBatchJob implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.BATCH_FULFILLMENT);

    public List<DRB2B_FulfillmentResult> fulfillmentResultList = new List<DRB2B_FulfillmentResult>();

    @TestVisible
    private DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();

    @TestVisible
    private DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();

    @TestVisible
    private DRB2B_OrderItemSelector orderItemSelector = new DRB2B_OrderItemSelector();

    @TestVisible
    private DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String jobId = bc.getJobId();
        if(B2BUtils.isBatchExecuting(bc.getJobId(),  'DRB2B_OrderFulfillmentBatchJob')){
            return  Database.getQueryLocator([SELECT Id, State, IsActive  from user  where id =:UserInfo.getUserId() and IsActive = false]);
        }
        LOGGER.info('Order Fulfillment Batch Job Id: ' + jobId);
        Integer queryLimit = Integer.valueOf(configurationSelector.getOrderFulfillmentJobQueryLimit());
        List<String> orderFulfillmentStatuses = new List<String>{ DRB2B_Constants.Fulfillment.ORDER_OPEN_STATUS, DRB2B_Constants.Fulfillment.ORDER_REPROCESS_STATUS };
        List<String> lineItemFulfillmentStatuses = new List<String>{ DRB2B_Constants.Fulfillment.LINE_ITEM_OPEN_STATUS, DRB2B_Constants.Fulfillment.LINE_ITEM_REPROCESS_STATUS };
        LOGGER.flush();
        return Database.getQueryLocator([
            SELECT Id, Order_Id__c, DR_Order_Id__c, Retry_Attempts_Made__c,
                (SELECT Id, SF_OrderItem_Id__c, Digital_River_OrderItem_Id__c, Fulfill_Quantity__c, Cancel_Quantity__c, Retry_Attempts_Made__c, CreatedDate
                    FROM DR_Line_Item_Fulfillments__r
                    WHERE Fulfillment_OrderItem_Status__c in :lineItemFulfillmentStatuses)
            FROM DR_Fulfillment__c
            WHERE DR_Fulfillment_Status__c IN :orderFulfillmentStatuses and Eligible_For_Fulfillment__c = true and Num_Of_Line_Item_Records_To_Process__c > 0
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate LIMIT :queryLimit
        ]);
    }

    global void execute(Database.BatchableContext bc, List<DR_Fulfillment__c> orderFulfillmentRecs) {
        LOGGER.debug('Order Fulfillment Records to process: ' + orderFulfillmentRecs);
        List<String> completelyFulfilledOrCancelledOrderIds = new List<String>();
        try {
            Integer batchFulfillmentsTimePeriod = String.isBlank(configurationSelector.getDRBatchFulfillmentsTimePeriod())
                    ? 0 : Integer.valueOf(configurationSelector.getDRBatchFulfillmentsTimePeriod());

            // Get a list of Completely Fulfilled/Cancelled SF Order Ids
            if(DCM_BaseUtilities.isNotNullOrEmpty(orderFulfillmentRecs)) {
                completelyFulfilledOrCancelledOrderIds = fulfillmentService.getCompletelyFulfilledOrCancelledOrders(orderFulfillmentRecs);
                logger.debug('Completely Fulfilled/Cancelled SF Order Ids: ' + completelyFulfilledOrCancelledOrderIds);
            }

            // Loop through all Order Fulfillment Records and get the Line Item Fulfillment Records for each
            for (DR_Fulfillment__c orderFulfillmentRec : orderFulfillmentRecs) {
                DRB2B_FulfillmentResult fulfillmentResult;
                List<DR_Line_Item_Fulfillment__c> lineItemFulfillmentRecs = orderFulfillmentRec.DR_Line_Item_Fulfillments__r;
                if(DCM_BaseUtilities.isNotNullOrEmpty(lineItemFulfillmentRecs)) {
                    // Check if all the Line Items are completely fulfilled/cancelled
                    if(completelyFulfilledOrCancelledOrderIds.contains(orderFulfillmentRec.Order_Id__c)) {
                        LOGGER.info('All the LineItems are either Fulfilled/Cancelled. Skipping Batching of Fulfillments/Cancellations check');
                    }
                    else {
                        // Check if Batching of Fulfillments/Cancellations is required
                        Boolean batchFulfillmentOrCancellationSupported = Boolean.valueOf(configurationSelector.getDRBatchFulfillments());
                        if(batchFulfillmentOrCancellationSupported) {
                            LOGGER.debug('Batching of Fulfillments/Cancellations will happen every ' + batchFulfillmentsTimePeriod + ' minutes.');
                            // Sort DR LineItem Fulfillment Records by CreatedDate
                            List<DR_Line_Item_Fulfillment__c> sortedLineItemFulfillmentRecs = (List<DR_Line_Item_Fulfillment__c>)
                                    Collection.of(lineItemFulfillmentRecs).orderBy(DR_Line_Item_Fulfillment__c.CreatedDate,
                                            Ordering.ASCENDING).get();

                            // Get Earliest Created DR LineItem Fulfillment Record
                            DR_Line_Item_Fulfillment__c earliestCreatedLineItemFulfillmentRec = sortedLineItemFulfillmentRecs.get(0);
                            LOGGER.info(orderFulfillmentRec.Id, 'Earliest DR Line Item Fulfillment Record in Open/Reprocess status: ' + earliestCreatedLineItemFulfillmentRec);

                            // Check if this exceeds the time configured for Batching Fulfillments/Cancellations
                            Long earliestLineItemCreatedTimeInMillisecs = earliestCreatedLineItemFulfillmentRec.createdDate.getTime();
                            Long currentSystemTimeInMillisecs = DateTime.now().getTime();
                            Long timeDiffInMinutes = (currentSystemTimeInMillisecs - earliestLineItemCreatedTimeInMillisecs)/60000;
                            LOGGER.info(orderFulfillmentRec.Id, 'Time difference between CurrentTime and Earliest Created LineItem Fulfillment record: ' + timeDiffInMinutes);
                            if(timeDiffInMinutes < batchFulfillmentsTimePeriod) {
                                LOGGER.warn('Configured Batch Fulfillments/Cancellations wait time is not exceeded. Skipping Fulfillment/Cancellation request');
                                continue;
                            }
                        }
                        else {
                            LOGGER.warn('Batching of Fulfillments/Cancellations is not requested');
                        }
                    }
                    // Submit Fulfillment/Cancellation request
                    fulfillmentResult = new DRB2B_FulfillmentResult(orderFulfillmentRec, lineItemFulfillmentRecs);
                    LOGGER.info('Line Item Fulfillment Records to process: ' + lineItemFulfillmentRecs);
                    // TODO: Update Order Fulfillment status to IN PROCESS to indicate that Line Item Records were processed before??
                    fulfillmentService.sendFulfillmentRequestToDR(fulfillmentResult);
                }
                this.fulfillmentResultList.add(fulfillmentResult);
            }
            LOGGER.info('Fulfillment Result List: ' + this.fulfillmentResultList);
        }
        catch(Exception e) { // TODO: Handle Exceptions properly
            LOGGER.error(e);
        }
        finally {
            LOGGER.flush();
        }
    }

    global void finish(Database.BatchableContext bc) {
        LOGGER.info('Fulfillment Result List in finish method: ' + this.fulfillmentResultList);
        List<DR_Fulfillment__c> orderFulfillmentRecs = new List<DR_Fulfillment__c>();
        List<DR_Line_Item_Fulfillment__c> allLineItemFulfillmentRecs = new List<DR_Line_Item_Fulfillment__c>();
        List<DR_Line_Item_Fulfillment__c> successfulLineItemFulfillmentRecs = new List<DR_Line_Item_Fulfillment__c>();
        try {
            // Get all Fulfillment Results
            for(DRB2B_FulfillmentResult fulfillmentResult : this.fulfillmentResultList) {
                if(DCM_BaseUtilities.isNotNullOrEmpty(fulfillmentResult.lineItemFulfillmentRecs)) {
                    if(fulfillmentResult.isSuccess) {
                        successfulLineItemFulfillmentRecs.addAll(
                            (List<DR_Line_Item_Fulfillment__c>)
                                Collection.of(fulfillmentResult.lineItemFulfillmentRecs)
                                    .filter(DR_Line_Item_Fulfillment__c.Fulfillment_OrderItem_Status__c).equals(DRB2B_Constants.Fulfillment.LINE_ITEM_COMPLETE_STATUS)
                                    .get()
                        );
                    }
                    allLineItemFulfillmentRecs.addAll(fulfillmentResult.lineItemFulfillmentRecs);
                }
                else {
                    fulfillmentResult.orderFulfillmentRec.Message__c = fulfillmentResult.message;
                }
                orderFulfillmentRecs.add(fulfillmentResult.orderFulfillmentRec);
            }

            // Update Line Item Fulfillment Records
            if(DCM_BaseUtilities.isNotNullOrEmpty(allLineItemFulfillmentRecs)) {
                DmlManager.updateAsUser(allLineItemFulfillmentRecs);
                LOGGER.info('Line Item Fulfillment records Updated.');
            }

            // Update Order Items
            if(DCM_BaseUtilities.isNotNullOrEmpty(successfulLineItemFulfillmentRecs)) {
                updateOrderItems(successfulLineItemFulfillmentRecs);
            }

            // Update DR Order Fulfillment Records
            if(DCM_BaseUtilities.isNotNullOrEmpty(orderFulfillmentRecs)) {
                updateOrderFulfillmentRecords(orderFulfillmentRecs);
            }
        }
        catch(Exception e) { // TODO: Handle Exceptions properly
            LOGGER.error(e);
        }
        finally {
            LOGGER.flush();
        }
    }

    public void updateOrderItems(List<DR_Line_Item_Fulfillment__c> successfulLineItemFulfillmentRecs) {
        // Group by SF Order Item Id as there can be multiple Line Item Fulfillment records for the same Order Item
        Map<Id, List<DR_Line_Item_Fulfillment__c>> successfulLineItemFulfillmentRecsBySfOrderItemId = (Map<Id, List<DR_Line_Item_Fulfillment__c>>) 
                Collection.of(successfulLineItemFulfillmentRecs).groupBy(DR_Line_Item_Fulfillment__c.SF_OrderItem_Id__c);
        List<OrderItem> orderItemRecs = orderItemSelector.getDRFieldsByOrderItemIds(successfulLineItemFulfillmentRecsBySfOrderItemId.keySet());
        LOGGER.info('Order Items to Update: ' + (Set<Id>) Collection.of(orderItemRecs).setOf(OrderItem.Id));
        for(OrderItem orderItemRec : orderItemRecs) {
            List<DR_Line_Item_Fulfillment__c> lineItemFulfillmentRecs = successfulLineItemFulfillmentRecsBySfOrderItemId.get(orderItemRec.Id);
            Decimal totalFulfilledQuantity = Collection.of(lineItemFulfillmentRecs).sum(DR_Line_Item_Fulfillment__c.Fulfill_Quantity__c);
            Decimal totalCancelledQuantity = Collection.of(lineItemFulfillmentRecs).sum(DR_Line_Item_Fulfillment__c.Cancel_Quantity__c);
            orderItemRec.DR_Fulfilled_Quantity__c = orderItemRec.DR_Fulfilled_Quantity__c + totalFulfilledQuantity;
            orderItemRec.DR_Cancelled_Quantity__c = orderItemRec.DR_Cancelled_Quantity__c + totalCancelledQuantity;
            if(orderItemRec.DR_Fulfilled_Quantity__c > 0) {
                if(orderItemRec.DR_Fulfilled_Quantity__c == orderItemRec.Quantity) {
                    orderItemRec.DR_Order_Item_State__c = DRB2B_Constants.Fulfillment.LINE_ITEM_FULFILLED_STATUS;
                }
                else {
                    orderItemRec.DR_Order_Item_State__c = DRB2B_Constants.Fulfillment.LINE_ITEM_PARTIALLY_FULFILLED_STATUS;
                }
            }
            else if(orderItemRec.DR_Cancelled_Quantity__c == orderItemRec.Quantity) {
                orderItemRec.DR_Order_Item_State__c = DRB2B_Constants.Fulfillment.LINE_ITEM_CANCELLED_STATUS;
            }
            else if(orderItemRec.DR_Cancelled_Quantity__c > 0) {
                orderItemRec.DR_Order_Item_State__c = DRB2B_Constants.Fulfillment.LINE_ITEM_PARTIALLY_CANCELLED_STATUS;
            }
        }
        DmlManager.updateAsUser(orderItemRecs);
        LOGGER.info('Order Item records Updated.');
    }

    public void updateOrderFulfillmentRecords(List<DR_Fulfillment__c> orderFulfillmentRecs) {
        Map<Id, String> orderFulfillmentStatusByOrderId = new Map<Id, String>();
        //LOGGER.info('orderFulfillmentRecs --> ' + orderFulfillmentRecs);
        // Get all Order Items based on SF Order Id
        List<String> drOrderIds = (List<String>) Collection.of(orderFulfillmentRecs).listOf(DR_Fulfillment__c.DR_Order_Id__c);
        //LOGGER.info('drOrderIds --> ' + drOrderIds);
        List<Order> orders = orderSelector.getByDrOrderIds(drOrderIds);
        Map<String, Id> sfOrderIdByDrOrderId = (Map<String, Id>) Collection.of(orders).mapBy(Order.DR_Order_Id__c, Order.Id);
        List<OrderItem> orderItems = orderItemSelector.getByOrderIdsAndOrderItemType(sfOrderIdByDrOrderId.values(), 'Order Product');
        //LOGGER.info('orderItems --> ' + orderItems);

        // Group Order Items by SF Order Id
        Map<Id, List<OrderItem>> orderItemsBySfOrderId = (Map<Id, List<OrderItem>>) 
                    Collection.of(orderItems).groupBy(OrderItem.OrderId);
        //LOGGER.info('orderItemsBySfOrderId --> ' + orderItemsBySfOrderId);

        // Loop through all order items and check if there are more items to fulfill or cancel
        for(Id orderId : orderItemsBySfOrderId.keySet()) {
            for(OrderItem orderItem : orderItemsBySfOrderId.get(orderId)) {
                if((orderItem.DR_Fulfilled_Quantity__c + orderItem.DR_Cancelled_Quantity__c) < orderItem.Quantity) {
                    orderFulfillmentStatusByOrderId.put(orderId, DRB2B_Constants.Fulfillment.ORDER_OPEN_STATUS);
                    break;
                }
                else {
                    orderFulfillmentStatusByOrderId.put(orderId, DRB2B_Constants.Fulfillment.ORDER_COMPLETE_STATUS);
                }
            }
        }

        for(DR_Fulfillment__c orderFulfillmentRec : orderFulfillmentRecs) {
            // Check if a SF Order exists for DR Order Id
            if(DCM_BaseUtilities.isNotNullOrEmpty(sfOrderIdByDrOrderId.get(orderFulfillmentRec.DR_Order_Id__c))) {
                orderFulfillmentRec.Order_Id__c = sfOrderIdByDrOrderId.get(orderFulfillmentRec.DR_Order_Id__c);
                orderFulfillmentRec.DR_Fulfillment_Status__c = orderFulfillmentStatusByOrderId.get(orderFulfillmentRec.Order_Id__c);
                if(orderFulfillmentRec.DR_Fulfillment_Status__c.equalsIgnoreCase(DRB2B_Constants.Fulfillment.ORDER_COMPLETE_STATUS)) {
                    orderFulfillmentRec.Message__c = 'Fulfillment process completed for this Order';
                }
            }
            else {
                orderFulfillmentRec.Message__c = 'SF Order with this DR Order Id does not exist';
                orderFulfillmentRec.Retry_Attempts_Made__c = orderFulfillmentRec.Retry_Attempts_Made__c + 1;
                orderFulfillmentRec.DR_Fulfillment_Status__c = (orderFulfillmentRec.Retry_Attempts_Made__c > Integer.valueOf(configurationSelector.getFulfillmentRetryLimit())) 
                                ? DRB2B_Constants.Fulfillment.ORDER_FAILED_STATUS 
                                : DRB2B_Constants.Fulfillment.ORDER_REPROCESS_STATUS;
            }
        }

        LOGGER.info('orderFulfillmentRecs before update --> ' + orderFulfillmentRecs);
        DmlManager.updateAsUser(orderFulfillmentRecs);
        LOGGER.info('Order Fulfillment records Updated.');
    }

}