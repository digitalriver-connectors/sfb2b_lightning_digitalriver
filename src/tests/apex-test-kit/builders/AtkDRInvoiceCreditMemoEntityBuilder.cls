public with sharing class AtkDRInvoiceCreditMemoEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity drInvoiceCreditMemoEntity, Integer size) {
        drInvoiceCreditMemoEntity.field(DR_Invoice_Credit_Memo__c.Name).index('DRTP-{0000}');
    }
}
