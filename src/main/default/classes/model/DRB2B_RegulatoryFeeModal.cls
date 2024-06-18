public with sharing class DRB2B_RegulatoryFeeModal implements Collection.Wrapper {
    public DRB2B_RegulatoryFeeModal() {
    }

    public DRB2B_RegulatoryFeeModal(DR_Regulatory_Fee__c fee) {
        this.regulatoryFee = fee;
    }

    public DR_Regulatory_Fee__c regulatoryFee;

    public void wrap(Object item) {
        this.regulatoryFee = (DR_Regulatory_Fee__c) item;
        this.id = this.regulatoryFee.id;
        this.name = this.regulatoryFee.Name;
        this.amount = this.regulatoryFee.Amount__c;
        this.feeType = this.regulatoryFee.Fee_Type__c;
        this.cartItemId = this.regulatoryFee.Cart_Item_Id__c;
        if (this.cartItemId != null) {
            DRB2B_CartItemSelector itemSelector = new DRB2B_CartItemSelector();
            this.productName = itemSelector.getById(this.cartItemId, new Set<String>{ 'Name' }).Name; //TODO: make this bulkified
        }
    }

    @AuraEnabled
    public String id { get; set; }

    @AuraEnabled
    public Decimal amount { get; set; }

    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String feeType { get; set; }

    @AuraEnabled
    public Id cartItemId { get; set; }

    @AuraEnabled
    public String productName { get; set; }

    public class DRB2B_RegulatoryFeeModalFactory implements Collection.WrapperFactory {
        public Object wrap(Object item) {
            return new DRB2B_RegulatoryFeeModal((DR_Regulatory_Fee__c) item);
        }
    }
}
