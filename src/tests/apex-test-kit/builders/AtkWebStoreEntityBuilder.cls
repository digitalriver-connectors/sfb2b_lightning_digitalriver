public with sharing class AtkWebStoreEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity webStoreEntity, Integer size) {
        webStoreEntity.field(WebStore.Name)
            .index('DigitalRiver-Store-{0000}')
            .field(WebStore.PricingStrategy).repeat('LowestPrice')
            .field(WebStore.DefaultLanguage).repeat('en_US');
    }
}
