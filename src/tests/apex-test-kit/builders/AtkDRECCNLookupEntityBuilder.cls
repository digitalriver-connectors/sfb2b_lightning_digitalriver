public  class AtkDRECCNLookupEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity drECCNLookupEntity, Integer size) {
        drECCNLookupEntity
                .field(DR_ECCN_Lookup__c.Name).repeat('EAR99')
                .field(DR_ECCN_Lookup__c.DR_Notes__c).repeat('Subject to the Export Administration Regulations, but not controlled elsewhere on the Commerce Control List.');
    }
}