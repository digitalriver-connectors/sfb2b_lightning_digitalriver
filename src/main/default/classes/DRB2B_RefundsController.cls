public with sharing class DRB2B_RefundsController {

    private static final DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();

    private static final DCM_Logger logger = DCM_Logger.getInstance();

    @AuraEnabled
    public static String getDROrderDetails(Id orderId) {
        String result;
        
        try {
            Map<String, object> response = new Map<String, object>();
            List<Order> order = orderSelector.getDrOrderInfoBySfOrderId(orderId);
            response.put('order', order[0]);
            result = JSON.serialize(response);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
}
