public with sharing class DRB2B_ComplainceController {
    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

    @TestVisible
    private static final DRB2B_OrderSummarySelector summarySelector = new DRB2B_OrderSummarySelector();

    @AuraEnabled
    public static String getSellingEntity(Id recordId) {
        logger.info('RecordId: ' + recordId);
        String entity;
        try {
            entity = summarySelector.getById(recordId, new Set<String>{ 'OriginalOrder.DR_Selling_Entity__c' })
                .OriginalOrder.DR_Selling_Entity__c;
            logger.info('Entity: ' + entity);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return entity;
    }

    @AuraEnabled
    public static string getOrderComplianceAddress(String summaryId) {
        Map<String, String> orderComplianceData = new Map<String, String>();
        Boolean isCountryPickListEnabled = DRB2B_Utility.isCountryStateEnabled();
        try {
            OrderSummary orderSummary = [
                SELECT OriginalOrder.DR_SF_CartId__c
                FROM OrderSummary
                WHERE Id = :summaryId
            ][0];
            orderComplianceData.put('DR_SF_CartId', orderSummary.OriginalOrder.DR_SF_CartId__c);
        } catch (Exception e) {
            orderComplianceData.put('error', e.getMessage());
        }
        return JSON.serialize(orderComplianceData);
    }
}
