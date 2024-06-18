public with sharing class AtkOrderItemEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity orderItemEntity, Integer size) {
        orderItemEntity
                .field(OrderItem.UnitPrice).repeat(400)
                .field(OrderItem.Quantity).repeat(4)
                .field(OrderItem.ListPrice).repeat(30)
                .field(OrderItem.DR_Order_Item_State__c).repeat('created');
    }
}