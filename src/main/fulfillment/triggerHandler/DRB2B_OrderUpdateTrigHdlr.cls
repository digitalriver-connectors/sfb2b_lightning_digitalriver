public with sharing class DRB2B_OrderUpdateTrigHdlr implements TriggerHandler.Logic {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.TRIGGER_HANDLER);

    @TestVisible
    private static DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();

    public void execute(List<SObject> records, TriggerContext ctx) {
        List<Order> orderRecs = (List<Order>) records;
        LOGGER.info('Order Ids in after trigger: ' + Collection.of(orderRecs).setOf(Order.Id));
        createFulfillmentForOrders(orderRecs, ctx);
        LOGGER.flush();
    }

    /**
     * Create fulfillment for orders that are accepted.
    */
    public void createFulfillmentForOrders(List<Order> orderRecs, TriggerContext ctx) {
        LOGGER.info('Order Ids in after trigger: ' + Collection.of(orderRecs).setOf(Order.Id));
        Map<String, Map<String, String>> orderInfoMap = new Map<String, Map<String, String>>();
        for(Order orderRec : orderRecs) {
            if(ctx.isChanged(orderRec, Order.DR_Order_State__c) && 
                    ctx.isChangedTo(orderRec, Order.DR_Order_State__c, DRB2B_Constants.DrOrderState.ACCEPTED)) {
                Map<String, String> orderDataMap = new Map<String, String>();
                // Populate Order information to be stamped on DR Order Fulfillment record
                orderDataMap.put('drOrderId', orderRec.DR_Order_Id__c);
                orderDataMap.put('drOrderState', orderRec.DR_Order_State__c);
                orderDataMap.put('isOrderAcceptedEventRecieved', 'true');
                orderDataMap.put('orderId', orderRec.Id);
                orderDataMap.put('message', 'Received order.accepted Event from DR and successfully processed by Salesforce');
                orderInfoMap.put(orderRec.DR_Order_Id__c, orderDataMap);
            }
        }
        
        if(orderInfoMap.size()>0){
            fulfillmentService.createOrUpdateDrFulfillmentRecord(orderInfoMap);
        }
        
    }

}