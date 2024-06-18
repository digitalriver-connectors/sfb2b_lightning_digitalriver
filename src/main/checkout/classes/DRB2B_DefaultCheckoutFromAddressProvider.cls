public with sharing class DRB2B_DefaultCheckoutFromAddressProvider implements DRB2B_CheckoutFromAddressProvider {
    private DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    public DRB2B_Address getAddress(DRB2B_CheckoutContext context) {
        DRB2B_Address address = new DRB2B_Address();

        address.country = configurationSelector.getShipFromCountry();
        address.state = configurationSelector.getShipFromState();
        address.postalCode = configurationSelector.getShipFromPostalCode();
        address.city = configurationSelector.getShipFromCity();
        address.line1 = configurationSelector.getShipFromLine();

        return address;
    }
}
