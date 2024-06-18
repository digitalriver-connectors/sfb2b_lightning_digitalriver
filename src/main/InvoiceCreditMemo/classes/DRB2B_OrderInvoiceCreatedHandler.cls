public with sharing class DRB2B_OrderInvoiceCreatedHandler extends DRB2B_WebhookHandler  {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.INVOICE_CREDIT_MEMO);

    @TestVisible
    private static DRB2B_OrderService orderService = new DRB2B_OrderService();

    @TestVisible
    private DRB2B_InvoiceAndCreditMemoService invoiceAndCreditMemoService = new DRB2B_InvoiceAndCreditMemoService();

    /**
    * @description Method to validate order.invoice.created Event
    **/
    public override Boolean validateWebhookEventPayload(Object webhookEventObj, String webhookEventPayload) {
        super.validateWebhookEventPayload(webhookEventObj, webhookEventPayload);
        DRB2B_OrderInvoiceAndCreditMemoModel orderInvoiceCreatedEventObj = (DRB2B_OrderInvoiceAndCreditMemoModel) webhookEventObj;
        String drOrderId = orderInvoiceCreatedEventObj.data.eventData.orderId;
        String drInvoiceFileId = orderInvoiceCreatedEventObj.data.eventData.fileId;
        if(String.isNotBlank(drOrderId) && String.isNotBlank(drInvoiceFileId)) {
            return true;
        }
        else {
            throw new DRB2B_WebhookException('validateWebhookEventPayload', 'DR Order Id and/or DR Invoice File Id cannot be NULL for Event Type: ' + orderInvoiceCreatedEventObj.type);
        }
    }

    /**
     * @description Method to process order.invoice.created Event
     * @param response Response object
     * @param webhookEventPayload Webhook Event Request Payload
     **/
    public override void processWebhookEvent(RestResponse response, String webhookEventPayload) {
        String methodName = 'processWebhookEvent';
        DRB2B_OrderInvoiceAndCreditMemoModel orderInvoiceCreatedEventObj = (DRB2B_OrderInvoiceAndCreditMemoModel) DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(webhookEventPayload);
        validateWebhookEventPayload(orderInvoiceCreatedEventObj, webhookEventPayload);
        invoiceAndCreditMemoService.captureDrInvoiceAndCreditMemoFileIds(response, webhookEventPayload);
        LOGGER.flush();
    }

}