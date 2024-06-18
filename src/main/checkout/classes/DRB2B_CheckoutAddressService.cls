public with sharing class DRB2B_CheckoutAddressService {
    private DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    public DRB2B_Address getFromAddress(DRB2B_CheckoutContext context) {
        String providerName = configurationSelector.getFromAddressProviderName();
        DRB2B_CheckoutFromAddressProvider provider;
        try {
            Type providerType = Type.forName(providerName);
            provider = (DRB2B_CheckoutFromAddressProvider) providerType.newInstance();
        } catch (Exception e) {
            throw new DRB2B_CheckoutAddressServiceException(
                    String.format(Label.DR_InvalidCheckoutShipFromAddressException, new List<String>{ providerName })
            );
        }

        return provider.getAddress(context);
    }

    public class DRB2B_CheckoutAddressServiceException extends Exception {}
}
