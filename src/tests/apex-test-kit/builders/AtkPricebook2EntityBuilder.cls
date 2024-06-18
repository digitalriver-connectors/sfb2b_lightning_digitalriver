public with sharing class AtkPricebook2EntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity pricebook2entity, Integer size) {
        pricebook2entity
                .field(Pricebook2.Name).index('Test Book {0000}')
                .field(Pricebook2.IsActive).repeat(true);
    }
}