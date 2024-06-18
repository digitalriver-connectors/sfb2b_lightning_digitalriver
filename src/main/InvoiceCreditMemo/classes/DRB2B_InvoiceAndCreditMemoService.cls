public without sharing class DRB2B_InvoiceAndCreditMemoService {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.INVOICE_CREDIT_MEMO);

    @TestVisible
    private DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();

    @TestVisible
    private DRB2B_InvoiceAndCreditMemoSelector invoiceAndCreditMemoSelector = new DRB2B_InvoiceAndCreditMemoSelector();

    public void captureDrInvoiceAndCreditMemoFileIds(RestResponse response, String webhookEventPayload) {
        DRB2B_OrderInvoiceAndCreditMemoModel orderInvoiceCreditMemoEvent = (DRB2B_OrderInvoiceAndCreditMemoModel) DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(
            webhookEventPayload
        );
        String eventId = orderInvoiceCreditMemoEvent.id;
        String eventType = orderInvoiceCreditMemoEvent.type;
        String drOrderId = orderInvoiceCreditMemoEvent.data.eventData.orderId;
        String drFileId = orderInvoiceCreditMemoEvent.data.eventData.fileId;
        LOGGER.debug('Processing Event Type: ' + eventType + ' for DR Order Id: ' + drOrderId + ' and DR File Id: ' + drFileId);

        // Capture DR Invoice And Credit Memo File Id(s)
        List<Order> orderRecList = orderSelector.getByDROrderId(drOrderId);
        if (null != orderRecList && !orderRecList.isEmpty()) {
            Order orderRec = orderRecList.get(0);
            DR_Invoice_Credit_Memo__c invoiceCreditMemoRec = new DR_Invoice_Credit_Memo__c (
                Event_Id__c = eventId,
                File_Id__c = drFileId,
                File_Type__c = eventType.equalsIgnoreCase(DRB2B_Constants.WebhookEventType.ORDER_INVOICE_CREATED) ? 'Invoice' : 'Credit Memo',
                OrderId__c = orderRec.Id
            );
            DmlManager.insertAsUser(invoiceCreditMemoRec);
            LOGGER.info('Processed Event Type: ' + eventType + ' for Event Id: ' + eventId + '; DR Order Id: ' + drOrderId + '; DR File Id: ' + drFileId);
        } else {
            LOGGER.error('Event Type: ' + eventType + ' with Event Id: ' + eventId + ' could not be processed as SF Order with DR Order Id: ' + drOrderId + ' does not exist.');
            String emailMessage = 'Event: <b>' + eventType + '</b> could not be processed by DigitalRiver Connector.';
            DRB2B_WebhookUtil.captureEventInSfAndSendEmail(
                webhookEventPayload,
                'DigitalRiver Webhook Event cannot be processed as SF Order with DR Order Id: ' + drOrderId + ' does not exist.',
                emailMessage
            );
        }
        response.statusCode = DRB2B_Constants.Base.SUCCESS_RESPONSE_CODE;
        LOGGER.flush();
    }

    /**
     * Get List of DR Invoice and Credit Memo File Ids for a SF Order
     */
    public Map<String, List<String>> getInvoiceAndCreditMemoFileIds(String sfOrderId) {
        Map<String, List<String>> fileTypeFileIdsMap = new Map<String, List<String>>();
        List<String> invoiceFileIds = new List<String>();
        List<String> creditMemoFileIds = new List<String>();
        List<DR_Invoice_Credit_Memo__c> invoiceCreditMemoRecList = invoiceAndCreditMemoSelector.getBySfOrderId(sfOrderId);
        if(DCM_BaseUtilities.isNullOrEmpty(invoiceCreditMemoRecList)) {
            LOGGER.info(sfOrderId, 'SF Order with id: ' + sfOrderId + ' does not have any Invoices or Credit Memos');
        }
        else {
            for(DR_Invoice_Credit_Memo__c invoiceCreditMemoRec : invoiceCreditMemoRecList) {
                if(invoiceCreditMemoRec.File_Type__c.equalsIgnoreCase('Invoice')) {
                    invoiceFileIds.add(invoiceCreditMemoRec.File_Id__c);
                }
                else if(invoiceCreditMemoRec.File_Type__c.equalsIgnoreCase('Credit Memo')) {
                    creditMemoFileIds.add(invoiceCreditMemoRec.File_Id__c);
                }
            }
        }
        fileTypeFileIdsMap.put('Invoice', invoiceFileIds);
        fileTypeFileIdsMap.put('Credit Memo', creditMemoFileIds);
        LOGGER.flush();
        return fileTypeFileIdsMap;
    }

}