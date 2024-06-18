public without sharing class DRB2B_OrderSummaryController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);
    @TestVisible
    private static DRB2B_OrderSummarySelector orderSummarySelector = new DRB2B_OrderSummarySelector();

    @AuraEnabled
    public static String getDROrderIdFromOrderSummary(String summaryId) {
        String ordersummary = [
            SELECT OriginalOrder.digitalriverv3__DR_Order_Id__c
            FROM OrderSummary
            WHERE id = :summaryId
        ][0]
        .OriginalOrder.digitalriverv3__DR_Order_Id__c;
        return ordersummary;
    }

    @AuraEnabled
    public static string getSummaryId(String orderNumber) {
        logger.info('DRB2B_OrderSummarycontroller dislay orderNumber' + orderNumber);
        String result;
        try {
            OrderSummary orderSummary = orderSummarySelector.getByOrderNumber(orderNumber);
            result = orderSummary.id;
            logger.info('DRB2B_OrderSummarycontroller response from selector ' + result);
        } catch (Exception e) {
            LOGGER.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            LOGGER.flush();
        }
        return result;
    }

    @AuraEnabled
    public static Id getIdFromOrderSummary(String sfOrderId) {
        Id orderSummaryId = [SELECT Id FROM OrderSummary WHERE OriginalOrderId = :sfOrderId LIMIT 1].Id;
        logger.info('inside getIdFromOrderSummary orderSummaryId' + orderSummaryId);
        return orderSummaryId;
    }

    @AuraEnabled
    public static Id createOrderSummary(String sfOrderId) {
        logger.info('inside createOrderSummary' + sfOrderId);
        ConnectApi.OrderSummaryInputRepresentation orderSummaryInput = new ConnectApi.OrderSummaryInputRepresentation();
        orderSummaryInput.orderId = sforderId;
        orderSummaryInput.orderLifeCycleType = 'MANAGED';
        orderSummaryInput.businessModel = 'B2B';
        orderSummaryInput.sourceProcess = 'OrderOnBehalf';
        orderSummaryInput.status = 'Created';
        ConnectApi.OrderSummaryOutputRepresentation orderSummaryOutput = ConnectApi.OrderSummaryCreation.createOrderSummary(
            orderSummaryInput
        );
        return orderSummaryOutput.orderSummaryId;
    }
}
