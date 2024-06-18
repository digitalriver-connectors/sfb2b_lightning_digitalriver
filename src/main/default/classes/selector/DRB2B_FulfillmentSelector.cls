public with sharing class DRB2B_FulfillmentSelector {
    public List<DR_Fulfillment__c> getByDROrderId(String drOrderId) {
        return (List<DR_Fulfillment__c>) new DCM_Query(DR_Fulfillment__c.sObjectType)
            .selectField(DR_Fulfillment__c.Id)
            .selectField(DR_Fulfillment__c.DR_Order_Id__c)
            .selectField(DR_Fulfillment__c.DR_Order_State__c)
            .selectField(DR_Fulfillment__c.Order_Id__c)
            .selectField(DR_Fulfillment__c.DR_Fulfillment_Status__c)
            .selectField(DR_Fulfillment__c.Is_Fulfillment_Completed__c)
            .selectField(DR_Fulfillment__c.Message__c)
            .selectField(DR_Fulfillment__c.Eligible_For_Fulfillment__c)
            .selectField(DR_Fulfillment__c.Order_Cancelled__c)
            .addConditionEq('DR_Order_Id__c', drOrderId)
            .run();
    }

    public List<DR_Fulfillment__c> getByDROrderIds(List<String> drOrderIds) {
        return (List<DR_Fulfillment__c>) new DCM_Query(DR_Fulfillment__c.sObjectType)
            .selectField(DR_Fulfillment__c.Id)
            .selectField(DR_Fulfillment__c.DR_Order_Id__c)
            .selectField(DR_Fulfillment__c.DR_Order_State__c)
            .selectField(DR_Fulfillment__c.Order_Id__c)
            .selectField(DR_Fulfillment__c.DR_Fulfillment_Status__c)
            .selectField(DR_Fulfillment__c.Is_Fulfillment_Completed__c)
            .selectField(DR_Fulfillment__c.Message__c)
            .selectField(DR_Fulfillment__c.Eligible_For_Fulfillment__c)
            .selectField(DR_Fulfillment__c.Order_Cancelled__c)
            .addConditionIn('DR_Order_Id__c', drOrderIds)
            .setLimit(2000)
            .run();
    }

    public List<DR_Fulfillment__c> getByDROrderIds(Set<String> drOrderIds) {
        return getByDROrderIds(new List<String>(drOrderIds));
    }

}