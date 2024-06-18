public class AtkDigitalRiverTaxMappingEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity digitalRiverTaxMappingEntity, Integer size) {
        digitalRiverTaxMappingEntity
            .field(Digital_River_Tax_Mapping__c.Name).index('DR Tax Mapping {0000}')
            .field(Digital_River_Tax_Mapping__c.DR_Product_Type__c).repeat('Digital')
            .field(Digital_River_Tax_Mapping__c.DR_Tax_Code__c).repeat('4512.1')
            .field(Digital_River_Tax_Mapping__c.DR_Tax_Group__c).repeat('Downloadable Goods (Non-Software)')
            .field(Digital_River_Tax_Mapping__c.DR_Tax_Type__c).repeat('Digital Image');
    }
}