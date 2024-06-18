public with sharing class DRB2B_CreateCustomerErrorWire extends DCM_HttpClient.Wire {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CUSTOMER_MANAGEMENT);

    public override DCM_HttpClient.Response send(HttpRequest request, Map<String, Object> parameters) {
        DCM_HttpClient.Response originResponse = this.getOrigin().send(request, parameters);
        Integer statusCode = originResponse.getStatusCode();
        if ((Integer) statusCode != 201 && statusCode != DRB2B_DRApiConstants.CREATE_CUSTOMER_ALREADY_EXISTS_STATUS) {
            logger.error(request, originResponse.getHttpResponse());
        }
        return originResponse;
    }
}
