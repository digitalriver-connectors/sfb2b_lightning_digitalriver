public with sharing class DRB2B_RegulatoryFeeSelector {
    public list<DR_Regulatory_Fee__c> getByCartItemId(Set<String> fields, Set<Id> cartItemIds) {
        return (list<DR_Regulatory_Fee__c>) new DCM_Query('DR_Regulatory_Fee__c')
            .selectFields(new List<String>(fields))
            .addConditionIn('Cart_Item_Id__c', cartItemIds)
            .debug()
            .run();
    }
}
