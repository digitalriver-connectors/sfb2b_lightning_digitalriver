public with sharing class DRB2B_OrderCreditMemoCreatedHandler extends DRB2B_WebhookHandler{
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.INVOICE_CREDIT_MEMO);

    @TestVisible
    private static DRB2B_OrderService orderService = new DRB2B_OrderService();

    @TestVisible
    private DRB2B_InvoiceAndCreditMemoService invoiceAndCreditMemoService = new DRB2B_InvoiceAndCreditMemoService();

    /**
    * @description Method to validate order.credit_memo Event
    **/
    public override Boolean validateWebhookEventPayload(Object webhookEventObj, String webhookEventPayload) {
        super.validateWebhookEventPayload(webhookEventObj, webhookEventPayload);
        DRB2B_OrderInvoiceAndCreditMemoModel orderCreditMemoEventObj = (DRB2B_OrderInvoiceAndCreditMemoModel) webhookEventObj;
        String drOrderId = orderCreditMemoEventObj.data.eventData.orderId;
        String drCreditMemoFileId = orderCreditMemoEventObj.data.eventData.fileId;
        if(String.isNotBlank(drOrderId) && String.isNotBlank(drCreditMemoFileId)) {
            return true;
        }
        else {
            throw new DRB2B_WebhookException('validateWebhookEventPayload', 'DR Order Id and/or DR Credit Memo File Id cannot be NULL for Event Type: ' + orderCreditMemoEventObj.type);
        }
    }

    /**
     * @description Method to process order.credit_memo Event
     * @param response Response object
     * @param webhookEventPayload Webhook Event Request Payload
     **/
    public override void processWebhookEvent(RestResponse response, String webhookEventPayload) {
        DRB2B_OrderInvoiceAndCreditMemoModel orderCreditMemoEventObj = (DRB2B_OrderInvoiceAndCreditMemoModel) DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(webhookEventPayload);
        validateWebhookEventPayload(orderCreditMemoEventObj, webhookEventPayload);
        invoiceAndCreditMemoService.captureDrInvoiceAndCreditMemoFileIds(response, webhookEventPayload);
        LOGGER.flush();
    }

}