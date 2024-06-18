public with sharing class AtkContactEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity contactEntity, Integer size) {
        contactEntity
                .field(Contact.FirstName).repeat('Test')
                .field(Contact.LastName).repeat('Contact')
                .field(Contact.Email).repeat('test@test.com');
    }
}