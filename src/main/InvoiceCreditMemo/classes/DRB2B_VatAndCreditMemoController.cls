public without sharing class DRB2B_VatAndCreditMemoController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.INVOICE_CREDIT_MEMO);
    @TestVisible
    private static DRB2B_OrderSummarySelector orderSummarySelector = new DRB2B_OrderSummarySelector();

    @TestVisible
    private static final Set<String> ORDER_SUMMARY_FIELDSET = new Set<String>{
        'Id',
        'OriginalOrderId',
        'SalesStoreId',
        'AccountId',
        'OriginalOrder.DR_Order_Id__c'
    };

    @AuraEnabled
    public static String getFileLink(String fileId, String sfOrderId) {
        String result;
        try {
            DRB2B_FileLinkService fileLinkService = new DRB2B_FileLinkService();
            result = JSON.serialize(fileLinkService.getFileLink(fileId, sfOrderId));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static String getInvoiceAndCreditMemo(String sfOrderId) {
        String result;
        try {
            DRB2B_InvoiceAndCreditMemoService invoiceCreditMemoService = new DRB2B_InvoiceAndCreditMemoService();
            result = JSON.serialize(invoiceCreditMemoService.getInvoiceAndCreditMemoFileIds(sfOrderId));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static string getSummaryAndSfOrderId(String orderNumber) {
        OrderSummary orderSummary = orderSummarySelector.getSummaryAndSfOrderId(orderNumber, ORDER_SUMMARY_FIELDSET);
        Map<String, Object> ordersummaryDetails = new Map<String, Object>();
        ordersummaryDetails.put('summaryId', orderSummary.Id);
        ordersummaryDetails.put('sfOrderId', orderSummary.OriginalOrderId);
        return JSON.serialize(ordersummaryDetails);
    }
    
    @AuraEnabled
    public static string getOriginalOrderID (String summaryID) {
        OrderSummary orderSummary = orderSummarySelector.getById(summaryID, ORDER_SUMMARY_FIELDSET);
        Map<String, Object> ordersummaryDetails = new Map<String, Object>();
        ordersummaryDetails.put('sfOrderId', orderSummary.OriginalOrderId);
        return JSON.serialize(ordersummaryDetails);
    }
}
