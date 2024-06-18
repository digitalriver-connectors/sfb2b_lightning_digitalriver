public without sharing class DRB2B_InvoiceAndCreditMemoSelector {

    public List<DR_Invoice_Credit_Memo__c> getBySfOrderId(String sfOrderId) {
        return (List<DR_Invoice_Credit_Memo__c>) new DCM_Query(DR_Invoice_Credit_Memo__c.sObjectType)
            .selectField(DR_Invoice_Credit_Memo__c.Id)
            .selectField(DR_Invoice_Credit_Memo__c.Event_Id__c)
            .selectField(DR_Invoice_Credit_Memo__c.File_Id__c)
            .selectField(DR_Invoice_Credit_Memo__c.File_Type__c)
            .selectField(DR_Invoice_Credit_Memo__c.OrderId__c)
            .addConditionEq('OrderId__c', sfOrderId)
            .run();
    }
}
