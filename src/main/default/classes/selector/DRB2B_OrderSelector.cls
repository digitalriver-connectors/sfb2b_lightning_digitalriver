public with sharing class DRB2B_OrderSelector {
    public List<Order> getByDROrderId(String drOrderId) {
        return (List<Order>) new DCM_Query(Order.sObjectType)
            .selectField(Order.Id)
            .selectField(Order.DR_Order_Id__c)
            .selectField(Order.DR_Order_State__c)
            .selectField(Order.DR_Fraud_State__c)
            .addConditionEq('DR_Order_Id__c', drOrderId)
            .run();
    }

    public List<Order> getDrOrderInfoBySfOrderId(String orderId) {
        return (List<Order>) new DCM_Query(Order.sObjectType)
            .selectField(Order.Id)
            .selectField(Order.DR_Order_Id__c)
            .selectField(Order.DR_Order_State__c)
            .selectField(Order.DR_Fraud_State__c)
            .addConditionEq('Id', orderId)
            .run();
    }

    public List<Order> getDrOrderInfoBySfOrderIds(Set<Id> orderIds) {
        return (List<Order>) new DCM_Query(Order.sObjectType)
            .selectField(Order.Id)
            .selectField(Order.DR_Order_Id__c)
            .selectField(Order.DR_Order_State__c)
            .selectField(Order.DR_Fraud_State__c)
            .addConditionIn('Id', orderIds)
            .debug()
            .run();
    }

    public List<Order> getByDrOrderIds(List<String> drOrderIds) {
        return (List<Order>) new DCM_Query(Order.sObjectType)
            .selectField(Order.Id)
            .selectField(Order.DR_Order_Id__c)
            .addConditionIn('DR_Order_Id__c', drOrderIds)
            .debug()
            .run();
    }

    public List<Order> getBySfOrderNumber(List<String> sfOrderNumbers) {
        return (List<Order>) new DCM_Query(Order.sObjectType)
            .selectField(Order.Id)
            .selectField(Order.DR_Order_Id__c)
            .selectField(Order.OrderNumber)
            .selectField(Order.DR_Order_State__c)
            .selectField(Order.DR_Fraud_State__c)
            .selectField(Order.SF_Order_Failure_Reason__c)
            .addConditionIn('OrderNumber', sfOrderNumbers)
            .debug()
            .run();
    }

}