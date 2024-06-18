global with sharing class DRB2B_ProductDetail {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.MY_WALLET);
    @TestVisible
    private static DRB2B_OrderService orderService = new DRB2B_OrderService();
    @AuraEnabled
    public static string getProductDetail(String orderSummaryId) {
        String result;
        try {
            result = orderService.getProductDetail(orderSummaryId);
        } catch (Exception e) {
            LOGGER.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            LOGGER.flush();
        }
        return result;
    }
}
