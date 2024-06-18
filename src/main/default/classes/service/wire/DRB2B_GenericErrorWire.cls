public without sharing class DRB2B_GenericErrorWire extends DCM_HttpClient.Wire {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.ORG_DEFAULT);
    private static final list<Integer> SUCCESS_STATUS = new List<Integer>{ 200, 201, 202, 203, 204, 205 };

    public override DCM_HttpClient.Response send(HttpRequest request, Map<String, Object> parameters) {
        DCM_HttpClient.Response originResponse = this.getOrigin().send(request, parameters);
        Integer statusCode = originResponse.getStatusCode();
        if (SUCCESS_STATUS.contains(statusCode)) {
            // to do uncomment below code, commented from babithas guest checkout branch
            //logger.info(request, originResponse.getHttpResponse());
        } else {
            //  logger.error(request, originResponse.getHttpResponse());
        }
        return originResponse;
    }
}
