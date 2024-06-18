// False-positive: the system should return read-only mapping - configurations
// to perform back-end calculations in context of the running Experience User
public without sharing class DRB2B_DigitalRiverTaxMappingSelector {

     // TODO: We should cache this query
    public List<Digital_River_Tax_Mapping__c> getAll() {
        return new DCM_Query(Digital_River_Tax_Mapping__c.sObjectType)
            .selectField(Digital_River_Tax_Mapping__c.DR_Tax_Type__c)
            .selectField(Digital_River_Tax_Mapping__c.DR_Tax_Group__c)
            .selectField(Digital_River_Tax_Mapping__c.DR_Tax_Code__c)
            .selectField(Digital_River_Tax_Mapping__c.DR_Product_Type__c)
            .setLimit(2000)
            .run();
    }
}
