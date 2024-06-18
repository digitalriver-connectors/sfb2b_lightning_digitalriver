public with sharing class AtkContactPointAddressEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity contactPointAddressEntity, Integer size) {
        contactPointAddressEntity
                .field(ContactPointAddress.Name).index('Test Address {0000}')
                .field(ContactPointAddress.City).repeat('Goleta')
                .field(ContactPointAddress.PostalCode).index('93117-{0000}')
                .field(ContactPointAddress.State).repeat('California')
                .field(ContactPointAddress.Country).repeat('United States')
                .field(ContactPointAddress.AddressType).repeat('shipping/Billing')
                .field(ContactPointAddress.ActiveFromDate).addDays(Date.newInstance(2019, 12, 9), 1)
                .field(ContactPointAddress.ActiveFromDate).addDays(Date.newInstance(2019, 12, 9), 1);
    }
}