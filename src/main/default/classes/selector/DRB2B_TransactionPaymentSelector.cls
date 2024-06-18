public without sharing class DRB2B_TransactionPaymentSelector {
    public List<DR_Transaction_Payment__c> getByOrderId(String orderId) {
        return (List<DR_Transaction_Payment__c>) new DCM_Query(DR_Transaction_Payment__c.sObjectType)
            .selectField(DR_Transaction_Payment__c.Id)
            .selectField(DR_Transaction_Payment__c.Card_Number__c)
            .selectField(DR_Transaction_Payment__c.Card_Type__c)
            .selectField(DR_Transaction_Payment__c.Order__c)
            .selectField(DR_Transaction_Payment__c.Payment_Instructions__c)
            .selectField(DR_Transaction_Payment__c.Payment_Method__c)
            .selectField(DR_Transaction_Payment__c.Transaction_Type__c)
            .selectField(DR_Transaction_Payment__c.Token__c)
            .selectField(DR_Transaction_Payment__c.Amount__c)
            .selectField(DR_Transaction_Payment__c.Display_Name__c)
            .addConditionEq('Order__c', orderId)
            .orderBy('DR_Transaction_Payment__c.Name', 'ASC')
            .run();
    }

    public List<DR_Transaction_Payment__c> getByCartId(String cartId) {
        return (List<DR_Transaction_Payment__c>) new DCM_Query(DR_Transaction_Payment__c.sObjectType)
            .selectField(DR_Transaction_Payment__c.Id)
            .selectField(DR_Transaction_Payment__c.Card_Number__c)
            .selectField(DR_Transaction_Payment__c.Card_Type__c)
            .selectField(DR_Transaction_Payment__c.Order__c)
            .selectField(DR_Transaction_Payment__c.Payment_Instructions__c)
            .selectField(DR_Transaction_Payment__c.Payment_Method__c)
            .selectField(DR_Transaction_Payment__c.Transaction_Type__c)
            .selectField(DR_Transaction_Payment__c.Token__c)
            .selectField(DR_Transaction_Payment__c.Amount__c)
            .selectField(DR_Transaction_Payment__c.Display_Name__c)
            .addConditionEq('Cart__c', cartId)
            .orderBy('DR_Transaction_Payment__c.Name', 'ASC')
            .run();
    }

    public List<DR_Transaction_Payment__c> getBySourceId(String sourceId) {
        return (List<DR_Transaction_Payment__c>) new DCM_Query(DR_Transaction_Payment__c.sObjectType)
            .selectField(DR_Transaction_Payment__c.Id)
            .selectField(DR_Transaction_Payment__c.Card_Number__c)
            .selectField(DR_Transaction_Payment__c.Card_Type__c)
            .selectField(DR_Transaction_Payment__c.Order__c)
            .selectField(DR_Transaction_Payment__c.Payment_Instructions__c)
            .selectField(DR_Transaction_Payment__c.Payment_Method__c)
            .selectField(DR_Transaction_Payment__c.Transaction_Type__c)
            .selectField(DR_Transaction_Payment__c.Token__c)
            .addConditionEq('Token__c', sourceId)
            .run();
    }

    public List<DR_Transaction_Payment__c> getBycartId(String cartId, List<String> fields) {
        return (List<DR_Transaction_Payment__c>) new DCM_Query(DR_Transaction_Payment__c.sObjectType)
            .selectFields(new List<String>(fields))
            .addConditionEq('Cart__c', cartId)
            .run();
    }
}
