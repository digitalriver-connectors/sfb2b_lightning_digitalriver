public without sharing class DRB2B_WireTransferInstructions {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(
        DRB2B_Constants.Module.DigitalRiver_WIRE_TRANSFER_INSTRUCTIONS
    );
    @TestVisible
    private static DRB2B_OrderService orderService = new DRB2B_OrderService();
    @TestVisible
    private static DRB2B_OrderSummarySelector orderSummarySelector = new DRB2B_OrderSummarySelector();

    @AuraEnabled
    public static string getSourceInfo(String orderSummaryId) {
        String result;
        try {
            result = orderService.getSourceInfo(orderSummaryId);
        } catch (Exception e) {
            LOGGER.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            LOGGER.flush();
        }
        return result;
    }

    @AuraEnabled
    public static string getSummaryId(String orderNumber) {
        logger.info('DRB2B_OrderSummarycontroller dislay orderNumber' + orderNumber);
        String result;
        try {
            OrderSummary orderSummary = orderSummarySelector.getByOrderNumber(orderNumber);
            result = orderSummary.id;
        } catch (Exception e) {
            LOGGER.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            LOGGER.flush();
        }
        return result;
    }
}
