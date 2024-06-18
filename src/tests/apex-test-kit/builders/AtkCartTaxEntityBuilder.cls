public with sharing class AtkCartTaxEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity cartTaxEntity, Integer size) {
        cartTaxEntity
            .field(CartTax.Name)
            .index('GST')
            .field(CartTax.TaxCalculationDate)
            .repeat(Date.today())
            .field(CartTax.TaxType)
            .repeat('Actual')
            .field(CartTax.TaxRate)
            .repeat(0.08)
            .field(CartTax.Amount)
            .repeat(10.00)
            .field(CartTax.DR_Duty__c)
            .repeat(1.00)
            .field(CartTax.DR_IOR_Tax__c)
            .repeat(2.00)
            .field(CartTax.DR_Regulatory_Fee__c)
            .repeat(3.00);
    }
}
