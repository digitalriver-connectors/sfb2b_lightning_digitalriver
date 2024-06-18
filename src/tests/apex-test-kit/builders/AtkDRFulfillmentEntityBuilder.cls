public with sharing class AtkDRFulfillmentEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity drFulfillmentEntity, Integer size) {
        drFulfillmentEntity
            .field(DR_Fulfillment__c.DR_Fulfillment_Status__c)
            .repeat('Open')
            .field(DR_Fulfillment__c.Retry_Attempts_Made__c)
            .repeat(0);
    }
}
