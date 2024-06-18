global without sharing class DRB2B_PaymentGatewayAdapter implements CommercePayments.PaymentGatewayAdapter {
    private static final CommercePayments.SalesforceResultCodeInfo SUCCESS_RESULT_CODE_INFO = new CommercePayments.SalesforceResultCodeInfo(
        CommercePayments.SalesforceResultCode.Success
    );
    private static final CommercePayments.SalesforceResultCodeInfo DECLINE_RESULT_CODE_INFO = new CommercePayments.SalesforceResultCodeInfo(
        CommercePayments.SalesforceResultCode.Decline
    );
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);
    private static DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();

    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();
    private static final commercepayments.SalesforceResultCodeInfo RC_SUCCESS = toCodeInfo(
        commercepayments.SalesforceResultCode.Success
    );
    private static final commercepayments.SalesforceResultCodeInfo RC_DECLINE = toCodeInfo(
        commercepayments.SalesforceResultCode.Decline
    );

    public class SalesforceValidationException extends Exception {
    }

    global CommercePayments.GatewayResponse processRequest(CommercePayments.PaymentGatewayContext context) {
        CommercePayments.RequestType requestType = context.getPaymentRequestType();
        CommercePayments.PaymentGatewayRequest paymentRequest = context.getPaymentRequest();

        CommercePayments.GatewayResponse response;
        try {
            if (requestType == CommercePayments.RequestType.Authorize) {
                response = createAuthResponse((CommercePayments.AuthorizationRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.PostAuth) {
                response = createPostAuthResponse((commercepayments.PostAuthorizationRequest) paymentRequest);
            }
        } catch (Exception e) {
            logger.error(e);
            response = new CommercePayments.GatewayErrorResponse(e.getTypeName(), e.getMessage());
        } finally {
            logger.flush();
        }

        return response;
    }

    private CommercePayments.GatewayResponse createAuthResponse(CommercePayments.AuthorizationRequest authRequest) {
        DCM_HttpClient.Response sourceAttachmentResponse = attachSourceToCheckout(authRequest);

        CommercePayments.AuthorizationResponse authResponse = new CommercePayments.AuthorizationResponse();
        if (isValidStatusCode(sourceAttachmentResponse)) {
            DRB2B_SourceModel source = DRB2B_SourceModel.parse(sourceAttachmentResponse.getBody());

            authResponse.setGatewayResultCode(source.state);
            authResponse.setGatewayResultCodeDescription(source.clientSecret);
            authResponse.setGatewayAuthCode(source.id);
            authResponse.setSalesforceResultCodeInfo(SUCCESS_RESULT_CODE_INFO);
            authResponse.setAmount((Double) authRequest.amount);
            authResponse.setGatewayReferenceNumber(source.clientSecret);
        } else {
            authResponse = handleInvalidAuthorization(sourceAttachmentResponse);
        }

        authResponse.setGatewayDate(System.now());
        return authResponse;
    }

    // Payment Gateway new method with redesign
    public commercepayments.GatewayResponse createPostAuthResponse(
        commercepayments.PostAuthorizationRequest postAuthRequest
    ) {
        DRB2B_SourceModel source;
        commercepayments.PostAuthorizationResponse postAuthResponse = new commercepayments.PostAuthorizationResponse();
        DCM_HttpClient.Response sourceResponse;
        try {
            commercepayments.PostAuthApiPaymentMethodRequest apiPaymentMethod = (commercepayments.PostAuthApiPaymentMethodRequest) postAuthRequest.paymentMethod;
            commercepayments.AlternativePaymentMethodRequest altPaymentMethod = (commercepayments.AlternativePaymentMethodRequest) apiPaymentMethod.alternativePaymentMethod;
            String gatewayToken = (String) altPaymentMethod.gatewayToken;
            String sourceId = gatewayToken.substringBeforeLast('_');
            String cartId = gatewayToken.substringAfterLast('_');
            // dummy post auth for zero dollar scenario when amt is 0 and source is empty
            if (postAuthRequest.amount == 0) {
                postAuthResponse.setAmount(postAuthRequest.amount);
                postAuthResponse.setGatewayResultCode('00');
                postAuthResponse.setGatewayResultCodeDescription('Transaction Normal');
                postAuthResponse.setGatewayAuthCode('DR' + getRandomNumber(6));
                postAuthResponse.setGatewayReferenceNumber(getRandomNumber(10));
                postAuthResponse.setSalesforceResultCodeInfo(SUCCESS_RESULT_CODE_INFO);
                postAuthResponse.setGatewayDate(system.now());
            } else {
                sourceResponse = getPaymentSourceForValidation(sourceId, cartId);
                if (isValidStatusCode(sourceResponse)) {
                    source = DRB2B_SourceModel.parse(sourceResponse.getBody());

                    if (postAuthRequest.amount != null) {
                        postAuthResponse.setAmount(postAuthRequest.amount);
                    } else {
                        throw new SalesforceValidationException('Required Field Missing Amount');
                    }
                    //TO-DO update the placeholder values below with appropriate values
                    postAuthResponse.setGatewayResultCode('sucess');
                    postAuthResponse.setGatewayResultCodeDescription('Transaction Normal');
                    postAuthResponse.setGatewayAuthCode(source.id);
                    postAuthResponse.setGatewayReferenceNumber(source.clientSecret);
                    postAuthResponse.setSalesforceResultCodeInfo(SUCCESS_RESULT_CODE_INFO);
                    postAuthResponse.setGatewayDate(system.now());
                } else {
                    return new commercepayments.GatewayErrorResponse('500', sourceResponse.getBody());
                }
            }
        } catch (CalloutException ce) {
            logger.error('drb2b_paymentgateway createPostAuthResponse' + ce);
            return new commercepayments.GatewayErrorResponse('500', sourceResponse.getBody());
        } finally {
            logger.flush();
        }
        return postAuthResponse;
    }

    private static commercepayments.SalesforceResultCodeInfo toCodeInfo(commercepayments.SalesforceResultCode code) {
        return new commercepayments.SalesforceResultCodeInfo(code);
    }

    private static Boolean isValidStatusCode(DCM_HttpClient.Response createOrderResponse) {
        return createOrderResponse.getStatusCode() >= 200 && createOrderResponse.getStatusCode() < 300;
    }

    private DCM_HttpClient.Response attachSourceToCheckout(CommercePayments.AuthorizationRequest authRequest) {
        String checkoutId = authRequest.additionalData.get('checkoutId');
        String sourceId = authRequest.additionalData.get('sourceId');
        String cartId = authRequest.additionalData.get('cartId');
        return requestService.getAttachCheckoutSourceRequest(checkoutId, sourceId, cartId).fetch();
    }

    private CommercePayments.AuthorizationResponse handleInvalidAuthorization(DCM_HttpClient.Response response) {
        CommercePayments.AuthorizationResponse authResponse = new CommercePayments.AuthorizationResponse();

        DRB2B_ErrorsResponseModel errorResponse = DRB2B_ErrorsResponseModel.parse(response.getBody());

        List<String> codes = new List<String>();
        for (DRB2B_ErrorResponseModel e : errorResponse.errors) {
            codes.add(e.code);
        }

        authResponse.setGatewayResultCode(errorResponse.type);
        authResponse.setGatewayResultCodeDescription(String.join(codes, ';'));
        authResponse.setGatewayMessage(JSON.serializePretty(errorResponse));
        authResponse.setSalesforceResultCodeInfo(DECLINE_RESULT_CODE_INFO);

        return authResponse;
    }

    //TO-DO remove from final code
    private String getRandomNumber(integer stringLength) {
        final integer MAX = integer.valueOf(Math.pow(10, stringLength) - 1);
        return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength, '0');
    }

    public DCM_HttpClient.Response getPaymentSourceForValidation(String sourceId, String cartId) {
        DCM_HttpClient.Response response;
        try {
            response = requestService.getSourceInformationPayment(sourceId, cartId).fetch();
        } catch (CalloutException e) {
            logger.error('drb2b_paymentgateway createPostAuthResponse getPaymentSourceForValidation' + e);
        } catch (Exception e) {
            logger.error('drb2b_paymentgateway createPostAuthResponse' + e);
        } finally {
            logger.flush();
        }
        return response;
    }
}
