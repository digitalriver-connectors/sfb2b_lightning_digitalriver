public with sharing class AtkDRFulfillmentRequestLogEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity drFulfillmentRequestLogEntity, Integer size) {
        drFulfillmentRequestLogEntity
            .field(DR_Fulfillment_Request_Log__c.Fulfill_Quantity__c)
            .repeat(0)
            .field(DR_Fulfillment_Request_Log__c.Cancel_Quantity__c)
            .repeat(0);
    }
}
