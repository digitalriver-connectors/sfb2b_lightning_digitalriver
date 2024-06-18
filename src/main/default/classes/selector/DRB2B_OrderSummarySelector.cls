public without sharing class DRB2B_OrderSummarySelector {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.ORDER_MANAGEMENT);
    public OrderSummary getById(String orderSummaryId, Set<String> fields) {
        return (OrderSummary) new DCM_Query(OrderSummary.sObjectType)
            .selectFields(new List<String>(fields))
            .addConditionEq('Id', orderSummaryId)
            .run()[0];
    }

    public OrderSummary getByOrderNumber(String orderNumber) {
        return (OrderSummary) new DCM_Query(OrderSummary.sObjectType)
            .selectFields('Id')
            .addConditionEq('OrderNumber', orderNumber)
            .run()[0];
    }
    public OrderSummary getSummaryAndSfOrderId(String orderNumber, Set<String> fields) {
        return (OrderSummary) new DCM_Query(OrderSummary.sObjectType)
            .selectFields(new List<String>(fields))
            .addConditionEq('OrderNumber', orderNumber)
            .run()[0];
    }
}
