public without sharing class DRB2B_RequestService {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.ORG_DEFAULT);

    public DCM_HttpClient.Request getCreateCustomerRequest(Object customerRequestModel, String upStreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_CreateCustomerErrorWire())
            .path(DRB2B_DRApiConstants.CUSTOMERS_PATH)
            .headers(getUpstreamSessionId(upStreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(customerRequestModel, true));
    }

    public DCM_HttpClient.Request getUpdateCustomerRequest(
        DRB2B_CreateCustomerRequestModel customerRequestModel,
        String contactId,
        String upstreamSessionId
    ) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CUSTOMERS_PATH)
            .path(contactId)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(customerRequestModel, true));
    }

    public DCM_HttpClient.Request getUpdateCustomerRequest(
        String contactId,
        String sourceId,
        String upstreamSessionId
    ) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CUSTOMERS_PATH)
            .path(contactId)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .path(DRB2B_DRApiConstants.SOURCE_PATH)
            .path(sourceId)
            .method(DCM_HttpClient.POST)
            .body('');
    }

    public DCM_HttpClient.Request getUploadFileRequest(
        Object DRB2B_uploadTaxCertificateRequestModel,
        String upstreamSessionId
    ) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.FILES)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(DRB2B_uploadTaxCertificateRequestModel, true));
    }

    public DCM_HttpClient.Request deletePaymentSource(string contactId, String sourceId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CUSTOMERS_PATH)
            .path(contactId)
            .path(DRB2B_DRApiConstants.SOURCE_PATH)
            .path(sourceId)
            .headers(getUpstreamSessionId(contactId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.REMOVE);
    }

    public DCM_HttpClient.Request getSourceInformation(String sourceId, String upstreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.SOURCE_PATH)
            .path(sourceId)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.GET);
    }

        public DCM_HttpClient.Request getSourceInformationPayment(String sourceId, String upstreamSessionId) {
          return DCM_HttpClient.paymentRequest()
           .through(new DRB2B_GenericErrorWire())
           .through(new DRB2B_AuthWire())
           .through(new LoggingWire())
            .endpoint('/' + DRB2B_DRApiConstants.SOURCE_PATH)
            .path(sourceId)
            .headers(DRB2B_DRApiConstants.DEFAULT_HEADERS)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .method(DCM_HttpClient.GET);
    }

    public DCM_HttpClient.Request attachSourceToCheckout(String checkoutId, String sourceId, String upstreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CHECKOUT_PATH)
            .path(checkoutId)
            .path(DRB2B_DRApiConstants.SOURCE_PATH)
            .path(sourceId)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST);
    }
    public DCM_HttpClient.Request deleteTaxIdentifier(string taxId, String upstreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.TAX_IDENTIFIER)
            .path(taxId)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.REMOVE);
    }

    public DCM_HttpClient.Request linkTaxIdentifier(string taxId, string userId, String upstreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CUSTOMERS_PATH)
            .path(userId)
            .path(DRB2B_DRApiConstants.TAX_IDENTIFIER)
            .path(taxId)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST);
    }

    //create customer credit payment source
    public DCM_HttpClient.Request createCustomercredit(
        DRB2B_CreateCustomerCreditModel.Request ccRequest,
        String upstreamSessionId
    ) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.PAYMENT_PATH)
            .path(DRB2B_DRApiConstants.SOURCE_PATH)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(ccRequest, true).replace('"currency1":', '"currency":')); // we cannot use curreny as it is reserved keyword.
    }

    //Delete payment source
    public DCM_HttpClient.Request deletePaymentSourceFromCheckout(
        String checkoutId,
        String sourceId,
        String upstreamSessionId
    ) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CHECKOUT_PATH)
            .path(checkoutId)
            .path(DRB2B_DRApiConstants.SOURCE_PATH)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .path(sourceId)
            .method(DCM_HttpClient.REMOVE);
    }

    public DCM_HttpClient.Request createTaxIdentifier(
        DRB2B_TaxIdentifierModal.request taxIdRequest,
        String upstreamSessionId
    ) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.TAX_IDENTIFIER)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(taxIdRequest, true));
    }

    public DCM_HttpClient.Request attachTaxidentifierToCheckout(
        DRB2B_AttachTaxIdTiCheckoutModel req,
        string checkoutId,
        String upstreamSessionId
    ) {
        return getBasicRequest()
            .through(new LoggingWire())
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CHECKOUT_PATH)
            .path(checkoutId)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(req, true));
    }

    public DCM_HttpClient.Request getRetrieveCustomerRequest(String contactId, String upstreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CUSTOMERS_PATH)
            .path(contactId)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.GET);
    }

    public DCM_HttpClient.Request getFileLinkRequest(DRB2B_FileLinkModel.Request reqModal, String upstreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.GET_FILE_LINK_PATH)
            .headers(getUpstreamSessionId(upstreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(reqModal));
    }

    public DCM_HttpClient.Request getFileLinkRequest(DRB2B_FileLinkModel.Request reqModal) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.GET_FILE_LINK_PATH)
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(reqModal));
    }

    public DCM_HttpClient.Request getBasicRequest() {
        return DCM_HttpClient.request()
            .through(new DRB2B_AuthWire())
            .through(new LoggingWire())
            .endpoint(DRB2B_DRApiConstants.END_POINT)
            .headers(DRB2B_DRApiConstants.DEFAULT_HEADERS)
            .timeout(DRB2B_DRApiConstants.REQUEST_TIMEOUT);
    }

    public DCM_HttpClient.Request getAttachCheckoutSourceRequest(
        String checkoutId,
        String sourceId,
        String upStreamSessionId
    ) {
        return DCM_HttpClient.paymentRequest()
            .through(new DRB2B_GenericErrorWire())
            .through(new DRB2B_AuthWire())
            .through(new LoggingWire())
            .endpoint('/' + DRB2B_DRApiConstants.CHECKOUT_PATH)
            .path(checkoutId)
            .path(DRB2B_DRApiConstants.SOURCE_PATH)
            .path(sourceId)
            .headers(DRB2B_DRApiConstants.DEFAULT_HEADERS)
            .headers(getUpstreamSessionId(upStreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .timeout(DRB2B_DRApiConstants.REQUEST_TIMEOUT);
    }

    public DCM_HttpClient.Request updateCheckout(
        DRB2B_updateCheckoutRequestModel req,
        String checkoutId,
        String upStreamSessionId
    ) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CHECKOUT_PATH)
            .path(checkoutId)
            .headers(getUpstreamSessionId(upStreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(req, true));
    }

    public DCM_HttpClient.Request getUpsertProductRequest(Object productRequestModel, String productId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CREATE_SKU_PATH)
            .path(productId)
            .method(DCM_HttpClient.PUT)
            .body(JSON.serialize(productRequestModel, true));
    }

    public class LoggingWire extends DCM_HttpClient.Wire {
        public override DCM_HttpClient.Response send(HttpRequest request, Map<String, Object> parameters) {
            DCM_HttpClient.Response originResponse = this.getOrigin().send(request, parameters);

            //       logger.debug(request, originResponse.getHttpResponse());

            return originResponse;
        }
    }

    public DCM_HttpClient.Request getFulfillmentRequest(String finalRequestJson) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.FULFILLMENT_PATH)
            .method(DCM_HttpClient.POST)
            .body(finalRequestJson);
    }

    public DCM_HttpClient.Request getConvertCheckoutToOrderRequest(String checkoutId, String upStreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .headers(getUpstreamSessionId(upStreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .path(DRB2B_DRApiConstants.ORDER_PATH)
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(new DRB2B_OrderEventsRequestModel.ConvertFromCheckoutRequest(checkoutId)));
    }

    public DCM_HttpClient.Request getOrderRequest(String orderId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.ORDER_PATH)
            .path(orderId)
            .method(DCM_HttpClient.GET);
    }
    public DCM_HttpClient.Request getOrderRequest(String orderId, String upStreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .headers(getUpstreamSessionId(upStreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .path(DRB2B_DRApiConstants.ORDER_PATH)
            .path(orderId)
            .method(DCM_HttpClient.GET);
    }

    public DCM_HttpClient.Request updateOrder(
        DRB2B_updateCheckoutRequestModel req,
        String orderId,
        String upStreamSessionId
    ) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.ORDER_PATH)
            .path(orderId)
            .headers(getUpstreamSessionId(upStreamSessionId))
            .method(DCM_HttpClient.POST)
            .body(JSON.serialize(req, true));
    }

    public DCM_HttpClient.Request getCheckoutRequest(String checkoutId, String upStreamSessionId) {
        return getBasicRequest()
            .through(new DRB2B_GenericErrorWire())
            .path(DRB2B_DRApiConstants.CHECKOUT_PATH)
            .headers(getUpstreamSessionId(upStreamSessionId))
            .headers(getForwardedFor(DRB2B_Utility.getUserIpAddress()))
            .path(checkoutId)
            .method(DCM_HttpClient.GET);
    }

    public DCM_HttpClient.Request getSKUGroupRequest() {
        String finalPath = '';
        if (Test.isRunningTest()) {
            finalPath = DRB2B_DRApiConstants.SKU_GROUP_PATH;
        } else {
            finalPath =
                DRB2B_DRApiConstants.SKU_GROUP_PATH +
                DCM_HttpClient.HTTP_REQUEST_PARAMETER_PREFIX +
                DRB2B_DRApiConstants.DR_QUERY_MAX_LIMIT;
        }
        return getBasicRequest().through(new DRB2B_GenericErrorWire()).path(finalPath).method(DCM_HttpClient.GET);
    }
    public DCM_HttpClient.Request getSKUGroupRequest(String startingQueryPoint) {
        String finalPath = '';
        if (Test.isRunningTest()) {
            finalPath = DRB2B_DRApiConstants.SKU_GROUP_PATH;
        } else {
            finalPath =
                DRB2B_DRApiConstants.SKU_GROUP_PATH +
                DCM_HttpClient.HTTP_REQUEST_PARAMETER_PREFIX +
                DRB2B_DRApiConstants.DR_QUERY_MAX_LIMIT +
                DCM_HttpClient.HTTP_REQUEST_PARAMETER_SEPARATOR +
                DRB2B_DRApiConstants.DR_QUERY_STARTING_PARAMETER +
                DCM_HttpClient.HTTP_REQUEST_KEY_VALUE_SEPARATOR +
                startingQueryPoint;
        }
        return getBasicRequest().through(new DRB2B_GenericErrorWire()).path(finalPath).method(DCM_HttpClient.GET);
    }

    public Map<String, String> getUpstreamSessionId(String sessionId) {
        Map<String, String> upStreamSessionIdMap = new Map<String, String>();
        upStreamSessionIdMap.put('upstream-session-id', sessionId);
        return upStreamSessionIdMap;
    }

    public Map<String, String> getForwardedFor(String ipAddress) {
        Map<String, String> forwardedForMap = new Map<String, String>();
        forwardedForMap.put('forwarded-for', ipAddress);
        return forwardedForMap;
    }

    public DCM_HttpClient.Request getRefundRequest(String orderId) {
        String finalPath =
            DRB2B_DRApiConstants.REFUND_PATH +
            DCM_HttpClient.HTTP_REQUEST_PARAMETER_PREFIX +
            DRB2B_DRApiConstants.DR_QUERY_ORDERID +
            DCM_HttpClient.HTTP_REQUEST_KEY_VALUE_SEPARATOR +
            orderId +
            DCM_HttpClient.HTTP_REQUEST_PARAMETER_SEPARATOR +
            DRB2B_DRApiConstants.REFUND_STATE +
            DCM_HttpClient.HTTP_REQUEST_KEY_VALUE_SEPARATOR +
            DRB2B_DRApiConstants.REFUND_STATE_PENDING_INFO;
        return getBasicRequest().through(new DRB2B_GenericErrorWire()).path(finalPath).method(DCM_HttpClient.GET);
    }
}
