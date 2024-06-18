public with sharing class DRB2B_OrderItemSelector {

    public List<OrderItem> getByOrderIdsAndOrderItemType(List<Id> orderIds, String orderItemType) {
        return (List<OrderItem>) new DCM_Query(OrderItem.sObjectType)
            .selectField(OrderItem.Id)
            .selectField(OrderItem.DR_Order_Item_State__c)
            .selectField(OrderItem.DR_Order_Item_Id__c)
            .selectField(OrderItem.Quantity)
            .selectField(OrderItem.DR_Open_Quantity__c)
            .selectField(OrderItem.DR_Fulfilled_Quantity__c)
            .selectField(OrderItem.DR_Cancelled_Quantity__c)
            .selectField(OrderItem.OrderId)
            .addConditionIn('OrderId', orderIds)
            .addConditionEq('Type', orderItemType)
            .run();
    }

    public List<OrderItem> getByOrderIdAndType(String orderId, String orderItemType, Set<String> fields) {
        return (List<OrderItem>) new DCM_Query(OrderItem.sObjectType)
            .selectFields(new List<String>(fields))
            .addConditionEq('OrderId', orderId)
            .addConditionEq('Type', orderItemType)
            .switchToConjunction()
            .run();
    }

    public List<OrderItem> getQuantityFieldsByIds(Set<Id> orderItemIds) {
        return (List<OrderItem>) new DCM_Query(OrderItem.sObjectType)
            .selectField(OrderItem.Id)
            .selectField(OrderItem.Quantity)
            .selectField(OrderItem.DR_Open_Quantity__c)
            .selectField(OrderItem.DR_Fulfilled_Quantity__c)
            .selectField(OrderItem.DR_Cancelled_Quantity__c)
            .addConditionEq('Type', 'Order Product')
            .addConditionIn('Id', orderItemIds)
            .debug()
            .run();
    }

    public List<OrderItem> getQuantityFieldsByIds(Set<String> orderItemIds) {
        // Convert Set<String> to Set<Id>
        return getQuantityFieldsByIds(new Set<Id>((List<Id>) new List<String>(orderItemIds)));
    }

    public List<OrderItem> getDRFieldsByOrderItemIds(Set<Id> orderItemIds) {
        return (List<OrderItem>) new DCM_Query(OrderItem.sObjectType)
            .selectField(OrderItem.Id)
            .selectField(OrderItem.DR_Order_Item_Id__c)
            .selectField(OrderItem.Quantity)
            .selectField(OrderItem.OrderId)
            .selectField(OrderItem.DR_Open_Quantity__c)
            .selectField(OrderItem.DR_Fulfilled_Quantity__c)
            .selectField(OrderItem.DR_Cancelled_Quantity__c)
            .addConditionEq('Type', 'Order Product')
            .addConditionIn('Id', orderItemIds)
            .debug()
            .run();
    }

    public List<OrderItem> getDRFieldsByOrderItemIds(Set<String> orderItemIds) {
        return getDRFieldsByOrderItemIds(new Set<Id>((List<Id>) new List<String>(orderItemIds)));
    }

    public List<OrderItem> getQuantityFieldsByOrderIds(Set<Id> orderIds) {
        return (List<OrderItem>) new DCM_Query(OrderItem.sObjectType)
            .selectField(OrderItem.Id)
            .selectField(OrderItem.OrderId)
            .selectField(OrderItem.Quantity)
            .selectField(OrderItem.DR_Open_Quantity__c)
            .selectField(OrderItem.DR_Fulfilled_Quantity__c)
            .selectField(OrderItem.DR_Cancelled_Quantity__c)
            .addConditionEq('Type', 'Order Product')
            .addConditionIn('OrderId', orderIds)
            .debug()
            .run();
    }

}