public without sharing class DRB2B_CheckoutShippingChoiceService {
    private DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    public DRB2B_ShippingChoiceInfo getShippingChoiceInfo(DRB2B_CheckoutContext context) {
        String providerName = configurationSelector.getShippingChoiceInfoProviderName();
        DRB2B_ShippingChoiceProvider provider;
        try {
            Type providerType = Type.forName(providerName);
            provider = (DRB2B_ShippingChoiceProvider) providerType.newInstance();
        } catch (Exception e) {
            throw new DRB2B_CheckoutAddressShippingChoiceException(
                String.format(Label.DR_InvalidCheckoutShippingChoiceException, new List<String>{ providerName })
            );
        }

        return provider.getShippingChoiceInfo(context);
    }

    public class DRB2B_CheckoutAddressShippingChoiceException extends Exception {
    }
}
