trigger DRB2B_FulfillmentRequestLogTrigger on DR_Fulfillment_Request_Log__c (before insert, before update, before delete, after insert, after update) {
    TriggerDispatcher.runMetadataDefinedTriggers();
}