trigger DigitalRiverOrderCancellationEventTrigger on DigitalRiverOrderCancellation__e (after insert) {

  private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);
  List<Order> sfOrder = new List<Order>();
  List<String> SfOrderIds = new List<String>();
  Map<string,string> errorMap = new Map<string,string>();
  try {
      //update SF order
      for (DigitalRiverOrderCancellation__e record : Trigger.new) {
          DRB2B_OrderResponseModel drOrder = DRB2B_OrderResponseModel.deserializeOrder(record.orderResponse__c);
          SfOrderIds.add(drOrder.upstreamId);
          errorMap.put(drOrder.upstreamId,record.errorMessage__c);

      }
      // Get Salesforce order details by salesforce order number
      DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();
      List<Order> sfOrderList = orderSelector.getBySfOrderNumber(SfOrderIds);

      // update DR Order State and order failure reason
      for(Order sfOrderRecord: sfOrderList){
        sfOrderRecord.DR_Order_State__c = DRB2B_Constants.DrOrderState.CANCELLED_BY_SF;
        sfOrderRecord.SF_Order_Failure_Reason__c = errorMap.get(sfOrderRecord.OrderNumber);
        sfOrder.add(sfOrderRecord);
      }
      DmlManager.upsertAsSystem(sfOrder); 

      //Cancel DR Order
      for (DigitalRiverOrderCancellation__e record : Trigger.new) {
        DRB2B_CheckoutServiceImpl.cancelDRFailedOrder(record.orderResponse__c);
      }
  } catch (Exception e) {
      logger.error(e);
  } finally {
      logger.flush();
  }
}