
public with sharing class DRB2B_AuthWire extends DCM_HttpClient.Wire {
    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    public override DCM_HttpClient.Response send(HttpRequest request, Map<String, Object> parameters) {
        String authKey = configurationSelector.getSecretKey();
        if (String.isBlank(authKey)) {
            throw new DRB2B_AuthKeyException(
                'Auth Secret Key was not found'
            );
        }

        request.setHeader(
            DRB2B_DRApiConstants.AUTH_HEADER_NAME,
            DRB2B_DRApiConstants.BEARER+' '+authKey
        );

        return this.getOrigin().send(request, parameters);
    }

    private class DRB2B_AuthKeyException extends Exception {
    }
}