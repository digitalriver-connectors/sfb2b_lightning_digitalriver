public with sharing class AtkDRLineItemFulfillmentEntityBuilder implements ATK.EntityBuilder {

    public void build(ATK.Entity drLineItemFulfillmentEntity, Integer size) {
        drLineItemFulfillmentEntity
            .field(DR_Line_Item_Fulfillment__c.Fulfill_Quantity__c)
            .repeat(0)
            .field(DR_Line_Item_Fulfillment__c.Cancel_Quantity__c)
            .repeat(0)
            .field(DR_Line_Item_Fulfillment__c.Retry_Attempts_Made__c)
            .repeat(0);
    }

}