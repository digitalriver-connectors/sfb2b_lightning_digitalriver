public with sharing class DRB2B_FulfillmentService {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.FULFILLMENT);

    @TestVisible
    DRB2B_FulfillmentSelector fulfillmentSelector = new DRB2B_FulfillmentSelector();
    @TestVisible
    private static DRB2B_OrderItemSelector orderItemSelector = new DRB2B_OrderItemSelector();
    @TestVisible
    private DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();

    public Boolean createDRFulfillmentObject(Map<String, Map<String, String>>  fulfillmentToCreateMap) {
        Boolean isDRFulfillmentObjectCreated = false;
        try {
            List<DR_Fulfillment__c> fulfillmentList = new List<DR_Fulfillment__c>();
            for( Map<String, String> orderDataMap: fulfillmentToCreateMap.values() ){
                DR_Fulfillment__c drFulfillment = new DR_Fulfillment__c(
                    DR_Order_Id__c = orderDataMap.get('drOrderId'),
                    DR_Order_State__c = String.isNotBlank(orderDataMap.get('drOrderState'))
                        ? orderDataMap.get('drOrderState')
                        : '',
                    Order_Id__c = String.isNotBlank(orderDataMap.get('orderId')) ? orderDataMap.get('orderId') : '',
                    DR_Fulfillment_Status__c = String.isNotBlank(orderDataMap.get('fulfillmentStatus'))
                        ? orderDataMap.get('fulfillmentStatus')
                        : 'Open',
                    Is_Fulfillment_Completed__c = String.isNotBlank(orderDataMap.get('isOrderCompleteEventReceived'))
                        ? Boolean.valueOf(orderDataMap.get('isOrderCompleteEventReceived'))
                        : false,
                    Eligible_For_Fulfillment__c = String.isNotBlank(orderDataMap.get('isOrderAcceptedEventRecieved'))
                        ? Boolean.valueOf(orderDataMap.get('isOrderAcceptedEventRecieved'))
                        : false,
                    Order_Cancelled__c = String.isNotBlank(orderDataMap.get('orderCancelled'))
                        ? Boolean.valueOf(orderDataMap.get('orderCancelled'))
                        : false,
                    Message__c = String.isNotBlank(orderDataMap.get('message')) ? orderDataMap.get('message') : ''
                );
                //collect all fulfillment records
                fulfillmentList.add(drFulfillment);
            }
            //Create fulfillment records
            DmlManager.insertAsUser(fulfillmentList);
            isDRFulfillmentObjectCreated = true;
        } catch (Exception e) {
            LOGGER.error(e);
        } finally {
            LOGGER.flush();
        }

        return isDRFulfillmentObjectCreated;
    }

     /**
     * Create or Update DR Fulfillment record for a specific DR Order Id
     */
    public Boolean createOrUpdateDrFulfillmentRecord(Map<String, Map<String, String>> orderInfoMap) {

        Boolean drFulfillmentCreatedOrUpdated = false;
        List<String> orderIds =  new List<String>(orderInfoMap.keySet());
        Map<String, Map<String, String>> fulfillmentToCreate = new  Map<String, Map<String, String>> ();
        fulfillmentToCreate.putAll(orderInfoMap);
        //getByDROrderIds
        List<DR_Fulfillment__c> drFulfillmentRecList = fulfillmentSelector.getByDROrderIds(orderIds);
       
        Map<DR_Fulfillment__c, Map<String, String>>  fulfillmentToUpdate = new Map<DR_Fulfillment__c, Map<String, String>>();

        for(DR_Fulfillment__c orderfulfillment: drFulfillmentRecList){
            //remove existing DR Oders from create list
            fulfillmentToCreate.remove(orderfulfillment.DR_Order_Id__c);
            fulfillmentToUpdate.put(orderfulfillment,orderInfoMap.get(orderfulfillment.DR_Order_Id__c)); 
        }
        
        //Update DR Fulfillment records
        if(null != fulfillmentToUpdate && fulfillmentToUpdate.size()>0) {
           // DR_Fulfillment__c drFulfillmentRec = drFulfillmentRecList.get(0);
            drFulfillmentCreatedOrUpdated = updateDrFulfillmentRecord(fulfillmentToUpdate);
        }
       // Create a New DR Fulfillment Record
       if(fulfillmentToCreate.size()>0) {
            drFulfillmentCreatedOrUpdated = createDRFulfillmentObject(fulfillmentToCreate);
        }
        return drFulfillmentCreatedOrUpdated;
    }


    public Boolean updateDrFulfillmentRecord( Map<DR_Fulfillment__c , Map<String, String>> fulfillmentToUpdate) {
        Boolean drFulfillmentRecUpdated = false;
        List<DR_Fulfillment__c> fulfillmentList = new List<DR_Fulfillment__c>();
        for(DR_Fulfillment__c drFulfillmentRec:fulfillmentToUpdate.keySet()){
            Map<String, String> orderDataMap = fulfillmentToUpdate.get(drFulfillmentRec);
            drFulfillmentRec.Order_Id__c = String.isNotBlank(orderDataMap.get('orderId')) ? orderDataMap.get('orderId') : drFulfillmentRec.Order_Id__c;
            drFulfillmentRec.DR_Order_State__c = String.isNotBlank(orderDataMap.get('drOrderState')) ? orderDataMap.get('drOrderState') : drFulfillmentRec.DR_Order_State__c;
            drFulfillmentRec.Eligible_For_Fulfillment__c = String.isNotBlank(orderDataMap.get('isOrderAcceptedEventRecieved')) ? Boolean.valueOf(orderDataMap.get('isOrderAcceptedEventRecieved')) : drFulfillmentRec.Eligible_For_Fulfillment__c;
            drFulfillmentRec.Is_Fulfillment_Completed__c = String.isNotBlank(orderDataMap.get('orderCompleteEventReceived')) ? Boolean.valueOf(orderDataMap.get('orderCompleteEventReceived')) : drFulfillmentRec.Is_Fulfillment_Completed__c;
            drFulfillmentRec.Message__c = String.isNotBlank(orderDataMap.get('message')) ? orderDataMap.get('message') : drFulfillmentRec.Message__c;
            drFulfillmentRec.DR_Fulfillment_Status__c = String.isNotBlank(orderDataMap.get('fulfillmentStatus')) ? orderDataMap.get('fulfillmentStatus') : drFulfillmentRec.DR_Fulfillment_Status__c;
            drFulfillmentRec.Order_Cancelled__c = String.isNotBlank(orderDataMap.get('orderCancelled')) ? Boolean.valueOf(orderDataMap.get('orderCancelled')) : drFulfillmentRec.Order_Cancelled__c;
            fulfillmentList.add(drFulfillmentRec);
        }
        DmlManager.updateAsUser(fulfillmentList);
        drFulfillmentRecUpdated = true;
        return drFulfillmentRecUpdated;
    }

    public Boolean updateDrFulfillmentRecord( DR_Fulfillment__c fulfillmentrec, Map<String, String> dataMap) {
         Map<DR_Fulfillment__c , Map<String, String>> fulfillmentToUpdate = new Map<DR_Fulfillment__c , Map<String, String>>();
         fulfillmentToUpdate.put(fulfillmentrec, dataMap);
         return updateDrFulfillmentRecord(fulfillmentToUpdate);

    }

    /**
     * Get SF Orders which are eligible for Fulfillment Or Cancellation
     * order.accepted event must be received for these Orders
     */
    public List<Order> getOrdersWhichReceivedOrderAcceptedEvent(List<Order> sfOrders) {
        List<Order> sfOrdersWhichReceivedOrderAcceptedEvent = new List<Order>();
        Map<String, Order> sfOrderByDrOrderId = (Map<String, Order>) Collection.of(sfOrders).mapBy(Order.DR_Order_Id__c);
        List<DR_Fulfillment__c> orderFulfillmentRecs = fulfillmentSelector.getByDROrderIds(sfOrderByDrOrderId.keySet());
        if(DCM_BaseUtilities.isNotNullOrEmpty(orderFulfillmentRecs)) {
            for(DR_Fulfillment__c orderFulfillmentRec : orderFulfillmentRecs) {
                if(orderFulfillmentRec.Eligible_For_Fulfillment__c) {
                    sfOrdersWhichReceivedOrderAcceptedEvent.add(sfOrderByDrOrderId.get(orderFulfillmentRec.DR_Order_Id__c));
                }
            }
        }
        return sfOrdersWhichReceivedOrderAcceptedEvent;
    }

    /**
     * Get DR Order Fulfillment Records by DR Order Id
     */
    public Map<String, DR_Fulfillment__c> getOrderFulfillmentRecsByDrOrderId(Set<String> drOrderIds) {
        Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId = new Map<String, DR_Fulfillment__c>();
        List<DR_Fulfillment__c> orderFulfillmentRecs = fulfillmentSelector.getByDROrderIds(drOrderIds);
        for (DR_Fulfillment__c orderFulfillmentRec : orderFulfillmentRecs) {
            orderFulfillmentRecByDrOrderId.put(orderFulfillmentRec.DR_Order_Id__c, orderFulfillmentRec);
        }
        return orderFulfillmentRecByDrOrderId;
    }

    /**
     * Create or Update DR Order Fulfillment Records
     */
    public void createdOrUpdateDrOrderFulfillmentRecs(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs, Set<String> drOrderIds) {
        List<DR_Fulfillment__c> drOrderFulfillmentRecList = new List<DR_Fulfillment__c>();
        List<String> drOrderIdsInOrderFulfillmentList = new List<String>();
        Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId = getOrderFulfillmentRecsByDrOrderId(drOrderIds);
        for(DR_Fulfillment_Request_Log__c fulfillmentRequestLogRec : fulfillmentRequestLogRecs) {
            // Prevent duplicate Order Fulfillment Record Creation
            if(!drOrderIdsInOrderFulfillmentList.contains(fulfillmentRequestLogRec.DR_Order_Id__c)) {
                drOrderFulfillmentRecList.add(getDrOrderFulfillmentRecToCreateOrUpdate(fulfillmentRequestLogRec, orderFulfillmentRecByDrOrderId));
                drOrderIdsInOrderFulfillmentList.add(fulfillmentRequestLogRec.DR_Order_Id__c);
            }
        }
        DmlManager.upsertAsUser(drOrderFulfillmentRecList);
        Map<Id, String> drOrderIdByOrderFulfillmentId = (Map<Id, String>) Collection.of(drOrderFulfillmentRecList).mapBy(DR_Fulfillment__c.Id, DR_Fulfillment__c.DR_Order_Id__c);
        LOGGER.info('Created or Updated DR Order Fulfillment Records. Map of DR Order Id By DR Order Fulfillment Id: ' + drOrderIdByOrderFulfillmentId);
    }

    /**
     * Get DR Order Fulfillment Record to Create or Update
     */
    public DR_Fulfillment__c getDrOrderFulfillmentRecToCreateOrUpdate(DR_Fulfillment_Request_Log__c fulfillmentRequestLogRec, Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId) {
        DR_Fulfillment__c drOrderFulfillmentRec;
        String drOrderId = fulfillmentRequestLogRec.DR_Order_Id__c;
        if(orderFulfillmentRecByDrOrderId.containsKey(drOrderId)) {
            drOrderFulfillmentRec = orderFulfillmentRecByDrOrderId.get(drOrderId);
        }
        else {
            drOrderFulfillmentRec = new DR_Fulfillment__c();
            drOrderFulfillmentRec.DR_Order_Id__c = drOrderId;
        }
        drOrderFulfillmentRec.Order_Id__c = fulfillmentRequestLogRec.OrderId__c;
        drOrderFulfillmentRec.DR_Order_State__c = fulfillmentRequestLogRec.DR_Order_State__c;
        return drOrderFulfillmentRec;
    }

    /**
     * Create DR Line Item Fulfillment Records
     */
    public void createdDrLineItemFulfillmentRecs(List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecs, Set<String> drOrderIds) {
        List<DR_Line_Item_Fulfillment__c> drLineItemFulfillmentRecList = new List<DR_Line_Item_Fulfillment__c>();
        Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId = getOrderFulfillmentRecsByDrOrderId(drOrderIds);
        for(DR_Fulfillment_Request_Log__c fulfillmentRequestLogRec : fulfillmentRequestLogRecs) {
            drLineItemFulfillmentRecList.add(getDrLineItemFulfillmentRecToCreate(fulfillmentRequestLogRec, orderFulfillmentRecByDrOrderId));
        }
        DmlManager.insertAsUser(drLineItemFulfillmentRecList);
        Set<String> drLineItemIds = (Set<String>) Collection.of(drLineItemFulfillmentRecList).setOf(DR_Line_Item_Fulfillment__c.Digital_River_OrderItem_Id__c);
        LOGGER.info('Created DR Line Item Fulfillment Records for DR Line Item Ids: ' + drLineItemIds);
    }

    /**
     * Get DR Line Item Fulfillment Record to Create
     */
    public DR_Line_Item_Fulfillment__c getDrLineItemFulfillmentRecToCreate(DR_Fulfillment_Request_Log__c fulfillmentRequestLogRec, Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId) {
        DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec = new DR_Line_Item_Fulfillment__c (
            DR_Order_Fulfillment__c = orderFulfillmentRecByDrOrderId.get(fulfillmentRequestLogRec.DR_Order_Id__c).Id,
            Digital_River_OrderItem_Id__c = fulfillmentRequestLogRec.DR_OrderItem_Id__c,
            SF_OrderItem_Id__c = fulfillmentRequestLogRec.OrderItem_Id__c,
            Fulfill_Quantity__c = fulfillmentRequestLogRec.Fulfill_Quantity__c,
            Cancel_Quantity__c = fulfillmentRequestLogRec.Cancel_Quantity__c,
            DR_Fulfillment_Request_Log__c = fulfillmentRequestLogRec.Id
        );
        return drLineItemFulfillmentRec;
    }

    /**
     * Send Fulfillment Request to Digital River
     */
    public void sendFulfillmentRequestToDR(DRB2B_FulfillmentResult fulfillmentResult) {
        try {
            // Build Fulfillment Request
            String fulfillmentRequestJson = getFulfillmentRequestToSubmitToDR(fulfillmentResult);
            if(String.isNotBlank(fulfillmentRequestJson)) {
                // Submit Fulfillment Request
                submitFulfillmentRequestToDR(fulfillmentResult, fulfillmentRequestJson);
            }
            else {
                //fulfillmentResult.statusCode = DRB2B_Constants.Base.ERROR_RESPONSE_CODE;
                fulfillmentResult.message = 'Failed building the Fulfillment Request';
                LOGGER.error(fulfillmentResult.orderFulfillmentRec.Id, fulfillmentResult.message);
            }
        }
        catch(Exception e) {
            //fulfillmentResult.statusCode = DRB2B_Constants.Base.ERROR_RESPONSE_CODE;
            fulfillmentResult.message = 'Failed while sending Fulfillment request to DR:' + e.getMessage();
            LOGGER.error(fulfillmentResult.orderFulfillmentRec.Id, e);
        }
        finally {
            LOGGER.flush();
        }
    }

    /**
     * Construct Fulfillment Request to send to DR
     */
    public String getFulfillmentRequestToSubmitToDR(DRB2B_FulfillmentResult fulfillmentResult) {
        DRB2B_CreateFulfillmentRequestModel fulfillmentRequestModel = new DRB2B_CreateFulfillmentRequestModel();
        fulfillmentRequestModel.orderId = fulfillmentResult.orderFulfillmentRec.DR_Order_Id__c;

        // Add Line Item Fulfillment Request
        List<DRB2B_CreateFulfillmentRequestModel.Items> fulfillmentLineItemList = new List<DRB2B_CreateFulfillmentRequestModel.Items>();
        for(DR_Line_Item_Fulfillment__c lineItemFulfillmentRec : fulfillmentResult.lineItemFulfillmentRecs) {
            DRB2B_CreateFulfillmentRequestModel.Items fulfillmentLineItem = new DRB2B_CreateFulfillmentRequestModel.Items();
            fulfillmentLineItem.itemId = lineItemFulfillmentRec.Digital_River_OrderItem_Id__c;
            fulfillmentLineItem.quantity = Integer.valueOf(lineItemFulfillmentRec.Fulfill_Quantity__c);
            fulfillmentLineItem.cancelQuantity = Integer.valueOf(lineItemFulfillmentRec.Cancel_Quantity__c);
            fulfillmentLineItemList.add(fulfillmentLineItem);
        }
        fulfillmentRequestModel.items = fulfillmentLineItemList;

        // Serialize the Fulfillment request
        String fulfillmentRequestJson = DRB2B_CreateFulfillmentRequestModel.serialize(fulfillmentRequestModel);
        LOGGER.info('Fulfillment Request to be submitted to DR: ' + fulfillmentRequestJson);
        return fulfillmentRequestJson;
    }

    /**
     * Submit the Fulfillment Request to DR
     */
    public void submitFulfillmentRequestToDR(DRB2B_FulfillmentResult fulfillmentResult, String fulfillmentRequestJson) {
        DCM_HttpClient.Request request = requestService.getFulfillmentRequest(fulfillmentRequestJson);
        DCM_HttpClient.Response response = request.fetch();
        //fulfillmentResult.statusCode = response.getStatusCode();
        if (response.getStatusCode() == DRB2B_Constants.Base.FULFILLMENT_SUCCESS_RESPONSE_CODE) {
            handleSuccessFulfillmentSubmission(response, fulfillmentResult);
        }
        else if(response.getStatusCode() == DRB2B_Constants.Base.CONFLICT_RESPONSE_CODE) {
            handleConflictFulfillmentSubmission(request, response, fulfillmentResult);
            updateLineItemFulfillmentRecsForFailedFulFulfillment(fulfillmentResult);
        }
        else {
            handleFailureFulfillmentSubmission(request, response, fulfillmentResult);
            updateLineItemFulfillmentRecsForFailedFulFulfillment(fulfillmentResult);
        }
    }

    public void handleSuccessFulfillmentSubmission(DCM_HttpClient.Response response, DRB2B_FulfillmentResult fulfillmentResult) {
        /*DRB2B_CreateFulfillmentResponseModel fulfillmentResponseObj = (DRB2B_CreateFulfillmentResponseModel) DRB2B_CreateFulfillmentResponseModel.parse(response.getBody());
        fulfillmentResult.fulfillmentResponseModel = fulfillmentResponseObj;*/
        fulfillmentResult.isSuccess = true;
        fulfillmentResult.message = 'Line Level Fulfillment request(s) are successfully processed by DR';

        // Update DR Line Item Fulfillment Records
        List<DR_Line_Item_Fulfillment__c> lineItemFulfillmentRecs = fulfillmentResult.lineItemFulfillmentRecs;
        // TODO: Should we capture DR Fulfillment request unique id?
        for(DR_Line_Item_Fulfillment__c lineItemFulfillmentRec : lineItemFulfillmentRecs) {
            lineItemFulfillmentRec.Message__c = 'Request processed successfully by DR';
            lineItemFulfillmentRec.Fulfillment_OrderItem_Status__c = DRB2B_Constants.Fulfillment.LINE_ITEM_COMPLETE_STATUS;
        }
    }

    // TODO: Need to check how to handle this. Need to check how errors come back when one of the line items has an issue and others don't
    // Tried different error combinations and it looks like we always get only on error item in the response even if more than one has an error
    // "quantity_too_large" too large will also send 409. This needs to be treated as error whereas 
    // submitting fulfillment for already submitted one will also send 409 with code "item_fulfilled" which should be treated as success
    public void handleConflictFulfillmentSubmission(DCM_HttpClient.Request request, DCM_HttpClient.Response response, DRB2B_FulfillmentResult fulfillmentResult) {
        DRB2B_ErrorResponse errorResponseObj = DRB2B_ErrorResponse.parse(response.getBody());
        String errorCodeFromResponse = errorResponseObj.errors[0].code;
        if(DRB2B_Constants.Fulfillment.FULFILLMENT_SUCCESS_CODES.contains(errorCodeFromResponse)) {
            fulfillmentResult.isSuccess = true;
            LOGGER.warn(fulfillmentResult.orderFulfillmentRec.Id, request.getOrigin(), response.getHttpResponse());
        }
        else {
            LOGGER.error(fulfillmentResult.orderFulfillmentRec.Id, request.getOrigin(), response.getHttpResponse());
        }
        fulfillmentResult.message = errorResponseObj.errors[0].message;
        fulfillmentResult.errorResponse = errorResponseObj;
    }

    public void handleFailureFulfillmentSubmission(DCM_HttpClient.Request request, DCM_HttpClient.Response response, DRB2B_FulfillmentResult fulfillmentResult) {
        DRB2B_ErrorResponse errorResponseObj = DRB2B_ErrorResponse.parse(response.getBody());
        if(DCM_BaseUtilities.isNotNullOrEmpty(errorResponseObj)) {
            LOGGER.error(fulfillmentResult.orderFulfillmentRec.Id, request.getOrigin(), response.getHttpResponse());
            fulfillmentResult.message = errorResponseObj.errors[0].message;
            fulfillmentResult.errorResponse = errorResponseObj;
        }
    }

    public void updateLineItemFulfillmentRecsForFailedFulFulfillment(DRB2B_FulfillmentResult fulfillmentResult) {
        DRB2B_ErrorResponse errorResponseObj = fulfillmentResult.errorResponse;
        String errorCode = errorResponseObj.errors[0].code;
        String errorMessage = errorResponseObj.errors[0].message;
        for(DR_Line_Item_Fulfillment__c lineItemFulfillmentRec : fulfillmentResult.lineItemFulfillmentRecs) {
            if(fulfillmentResult.isSuccess && DRB2B_Constants.Fulfillment.FULFILLMENT_ORDER_SUCCESS_CODES.contains(errorCode)) {
                lineItemFulfillmentRec.Message__c = errorResponseObj.errors[0].message;
                lineItemFulfillmentRec.Fulfillment_OrderItem_Status__c = DRB2B_Constants.Fulfillment.LINE_ITEM_COMPLETE_STATUS;
            }
            else if(fulfillmentResult.isSuccess && DRB2B_Constants.Fulfillment.FULFILLMENT_ORDER_ITEM_SUCCESS_CODES.contains(errorCode)) {
                if(errorMessage.contains(lineItemFulfillmentRec.Digital_River_OrderItem_Id__c)) {
                    lineItemFulfillmentRec.Message__c = fulfillmentResult.message;
                    lineItemFulfillmentRec.Fulfillment_OrderItem_Status__c = DRB2B_Constants.Fulfillment.LINE_ITEM_COMPLETE_STATUS;
                }
                else {
                    lineItemFulfillmentRec.Message__c = 'Failed as One of the Line Items in this request is already fulfilled/cancelled.' + fulfillmentResult.message;
                    lineItemFulfillmentRec.Fulfillment_OrderItem_Status__c = DRB2B_Constants.Fulfillment.LINE_ITEM_REPROCESS_STATUS;
                }
            }
            else {
                lineItemFulfillmentRec.Message__c = 'Issue with one or more of the line items in the Fulfillment/Cancellation Request. ' + fulfillmentResult.message;
                lineItemFulfillmentRec.Retry_Attempts_Made__c = lineItemFulfillmentRec.Retry_Attempts_Made__c + 1;
                lineItemFulfillmentRec.Fulfillment_OrderItem_Status__c = (lineItemFulfillmentRec.Retry_Attempts_Made__c > Integer.valueOf(configurationSelector.getFulfillmentRetryLimit())) 
                                ? DRB2B_Constants.Fulfillment.LINE_ITEM_FAILED_STATUS 
                                : DRB2B_Constants.Fulfillment.LINE_ITEM_REPROCESS_STATUS;
            }
        }
    }

    public List<String> getCompletelyFulfilledOrCancelledOrders(List<DR_Fulfillment__c> orderFulfillmentRecs) {
        List<String> completelyFulfilledOrCancelledOrderIds = new List<String>();

        // Get Map of Salesforce OrderId by DR Order Fulfillment Record Id
        Map<Id, String> sfOrderIdByOrderFulfillmentId = (Map<Id, String>) Collection.of(orderFulfillmentRecs).mapBy(DR_Fulfillment__c.Id, DR_Fulfillment__c.Order_Id__c);

        // Get All Order Items for this Salesforce Order
        List<Id> sfOrderIds = new List<Id>( (List<Id>) sfOrderIdByOrderFulfillmentId.values());
        List<OrderItem> orderItems = orderItemSelector.getByOrderIdsAndOrderItemType(sfOrderIds, 'Order Product');

        // Group Salesforce Order Items by Order
        Map<Id, List<OrderItem>> orderItemsByOrderId = (Map<Id, List<OrderItem>>)
                Collection.of(orderItems).groupBy(OrderItem.OrderId);

        // Get Orders which are completely fulfilled or cancelled
        for(Id orderId : orderItemsByOrderId.keySet()) {
            Boolean isOrderFulfilledOrCancelled = true;
            List<OrderItem> orderItemRecs = orderItemsByOrderId.get(orderId);
            for(OrderItem orderItem : orderItemRecs) {
                if(orderItem.DR_Open_Quantity__c > 0) {
                    isOrderFulfilledOrCancelled = false;
                    break;
                }
            }
            if(isOrderFulfilledOrCancelled) {
                completelyFulfilledOrCancelledOrderIds.add(String.valueOf(orderId));
            }
        }

        return completelyFulfilledOrCancelledOrderIds;
    }

}
