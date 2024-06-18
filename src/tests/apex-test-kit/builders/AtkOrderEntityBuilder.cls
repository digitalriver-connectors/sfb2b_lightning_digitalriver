public with sharing class AtkOrderEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity orderEntity, Integer size) {
        orderEntity
                .field(Order.Status).repeat('Draft')
                .field(Order.DR_Order_State__c).repeat('accepted')
                .field(Order.SF_Order_Failure_Reason__c).repeat('You do not have permission to insert field digitalriverv3__Card_Number__c on digitalriverv3__DR_Transaction_Payment__c')
                .field(Order.EffectiveDate).addDays(Date.newInstance(2020, 07, 07), 1);
    }
}