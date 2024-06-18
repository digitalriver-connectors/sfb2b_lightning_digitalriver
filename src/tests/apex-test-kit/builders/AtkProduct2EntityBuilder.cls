public with sharing class AtkProduct2EntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity product2Entity, Integer size) {
        product2Entity
                .field(Product2.Name).index('Sort Material-{0000}')
                .field(Product2.IsActive).repeat(true)
                .field(Product2.DR_Product_Country_Origin__c).repeat('US')
                .field(Product2.DR_Part_Number__c).repeat('abc12345')
                .field(Product2.DR_TAXGROUP__c).repeat('Downloadable Goods (Non-Software)')
                .field(Product2.DR_TAXTYPE__c).repeat('Digital Image')
                .field(Product2.Sync_Product_to_DR__c).repeat(true)
                .field(Product2.StockKeepingUnit).index('Sort {0000}');
    }
}