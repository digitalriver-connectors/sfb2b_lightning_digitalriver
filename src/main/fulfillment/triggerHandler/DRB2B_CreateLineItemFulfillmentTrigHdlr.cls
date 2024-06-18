public with sharing class DRB2B_CreateLineItemFulfillmentTrigHdlr  implements TriggerHandler.Logic, TriggerHandler.Parameterizable {
    Map<String, Object> inputParameterMap = new Map<String, Object>();
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.TRIGGER_HANDLER);

    public void setParameters(String parameters) {
        this.inputParameterMap = (Map<String, Object>) JSON.deserializeUntyped(parameters);
        LOGGER.debug('DRB2B_CreateLineItemFulfillmentTrigHdlr --> Input Parameter Map: ' + this.inputParameterMap);
    }

    @TestVisible
    private DRB2B_FulfillmentRequestLogService fulfillmentRequestLogService = new DRB2B_FulfillmentRequestLogService();

    @TestVisible
    private static DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();

    public void execute(List<SObject> records, TriggerContext ctx) {
        List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs = (List<DR_Fulfillment_Request_Log__c>) records;
        Boolean supportPartialFulfillment = inputParameterMap.containsKey('partialFulfillmentSupported') ? Boolean.valueOf(inputParameterMap.get('partialFulfillmentSupported')) : false;
        try{
            if(ctx.isBefore && ctx.isInsert) {
                // Make sure the Order Item Id entered in the request belongs to the Order mentioned in the same request. Also check for Partial Fulfillment/Cancellation
                List<DR_Fulfillment_Request_Log__c> goodFulfillmentReqLogRecs = fulfillmentRequestLogService.checkIfOrderItemsBelongToCorrectOrder(fulfillmentRequestLogRecs, supportPartialFulfillment);

                // Get Eligible Fulfillment Request Logs by checking if order.accepted event is received
                List<DR_Fulfillment_Request_Log__c> eligibleFulfillmentReqLogs = fulfillmentRequestLogService.getEligibleRecsForFulfillment(goodFulfillmentReqLogRecs);

                // Make sure we are not Fulfilling and/or Cancelling more than the Quantity available for Fulfillment/Cancellation for a particular Line Item
                fulfillmentRequestLogService.validateRequestedFulfillAndCancelQuantity(eligibleFulfillmentReqLogs);
            }
            else if(ctx.isAfter && ctx.isInsert) {
                LOGGER.debug('Records in after insert: ' + fulfillmentRequestLogRecs);
                if(inputParameterMap.containsKey('updateAvailableQuantity') && Boolean.valueOf(inputParameterMap.get('updateAvailableQuantity'))) {
                    // Update Available Quantity for Fulfillment and/or Cancellation for Order Items
                    fulfillmentRequestLogService.updateOpenQuantityOnOrderItems(fulfillmentRequestLogRecs);
                }

                // Create or Update DR Order Fulfillment Records
                Set<String> drOrderIds = (Set<String>) Collection.of(fulfillmentRequestLogRecs).setOf(DR_Fulfillment_Request_Log__c.DR_Order_Id__c);
                // There should not be a scenario where we create Order Fulfillment Record as order.accepted is a pre-requisite before doing fulfillment/cancellation
                fulfillmentService.createdOrUpdateDrOrderFulfillmentRecs(fulfillmentRequestLogRecs, drOrderIds);

                // Create Line Item Fulfillment Records
                fulfillmentService.createdDrLineItemFulfillmentRecs(fulfillmentRequestLogRecs, drOrderIds);
            }
        }
        catch(Exception e) {
            // TODO: Need to properly handle exceptions
            LOGGER.error(e);
            // throw exception
        }
        finally {
            LOGGER.flush();
        }
    }

}