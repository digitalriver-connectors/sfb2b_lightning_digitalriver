public with sharing class AtkRegulatoryFeeEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity regulatoryFeeEntity, Integer size) {
        regulatoryFeeEntity
            .field(DR_Regulatory_Fee__c.Amount__c)
            .repeat(5.00)
            .field(DR_Regulatory_Fee__c.Per_Unit_Amount__c)
            .repeat(5.00)
            .field(DR_Regulatory_Fee__c.Fee_Type__c)
            .repeat('battery')
            .field(DR_Regulatory_Fee__c.Fee_Id__c)
            .repeat('asdkj1h239lkj123j9123');
    }
}
