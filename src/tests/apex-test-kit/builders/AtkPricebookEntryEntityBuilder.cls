public with sharing class AtkPricebookEntryEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity pricebookEntryEntity, Integer size) {
        pricebookEntryEntity
            .field(PricebookEntry.Name)
            .index('Test Book {0000}')
            .field(PricebookEntry.IsActive)
            .repeat(true)
            .field(PricebookEntry.UnitPrice)
            .repeat(10);
    }
}
