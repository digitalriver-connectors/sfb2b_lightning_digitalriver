public with sharing class DRB2B_CartModel implements Collection.Wrapper {
    public DRB2B_CartModel(List<DRB2B_RegulatoryFeeModal> fee) {
        this.regulatoryFee = new List<DRB2B_RegulatoryFeeModal>();
        this.regulatoryFee = fee;
    }

    public DRB2B_CartModel() {
    }
    public void wrap(Object item) {
        this.cart = (Webcart) item;
        this.id = containField('Id') ? this.cart.Id : null;
        this.IOR = containField('DR_Total_IOR_Tax__c') ? this.cart.DR_Total_IOR_Tax__c : null;
        this.hasLandedCost = containField('Has_Landed_Cost__c') ? this.cart.Has_Landed_Cost__c : null;
        this.totaFee = containField('DR_Total_Fees__c') ? this.cart.DR_Total_Fees__c : null;
        this.totalDuty = containField('DR_Total_Duty__c') ? this.cart.DR_Total_Duty__c : null;
        this.grandTotalAmount = containField('GrandTotalAmount') ? this.cart.GrandTotalAmount : null;
        this.totalAmount = containField('TotalProductAmount') ? this.cart.TotalProductAmount : null;
        this.shipping = containField('TotalChargeAmount') ? this.cart.TotalChargeAmount : null;
        this.totalTax = containField('TotalTaxAmount') ? this.cart.TotalTaxAmount : null;
        this.buyerName = containField('Buyer_Name__c') ? this.cart.Buyer_Name__c : null;
        this.buyerPhone = containField('Buyer_Phone__c') ? this.cart.Buyer_Phone__c : null;
        this.billingAddress = containField('BillingAddress') ? this.cart.BillingAddress : null;
        this.buyerEmail = containField('Buyer_Email__c') ? this.cart.Buyer_Email__c : null;
        this.paymentSession = containField('DR_Payment_Session_Id__c') ? this.cart.DR_Payment_Session_Id__c : null;
        this.drcheckoutId = containField('DR_Checkout_Id__c') ? this.cart.DR_Checkout_Id__c : null;
        this.sourceId = containField('DR_Source_Id__c') ? this.cart.DR_Source_Id__c : null;
        this.customerType = containField('DR_Customer_Type__c') ? this.cart.DR_Customer_Type__c : null;
        this.isRecurring = containField('Recurring_Line_Item_Count__c') ? this.cart.Recurring_Line_Item_Count__c > 0 : false;
        this.amountContributed = containField('DR_Amount_Contributed__c') ? this.cart.DR_Amount_Contributed__c : null;
        this.remainingAmount = containField('DR_Amount_Remaining_to_be_Contributed__c') ? this.cart.DR_Amount_Remaining_to_be_Contributed__c : null;
        this.totalAdjustmentAmount = containField('TotalAdjustmentAmount') ? this.cart.TotalAdjustmentAmount : null;
    }

    private String NAMESPACE = DRB2B_Utility.nameSpacePrefix();

    private boolean containField(string fieldName) {
        Set<String> fields = this.cart.getPopulatedFieldsAsMap().keySet();
        if (fieldName.endsWith('__c')) {
            return fields.contains(NAMESPACE + fieldName);
        }
        return fields.contains(fieldName);
    }

    public Webcart cart;

    @AuraEnabled
    public Decimal IOR { get; set; }

    @AuraEnabled
    public String id { get; set; }

    @AuraEnabled
    public Boolean hasLandedCost { get; set; }

    @AuraEnabled
    public Decimal totalAdjustmentAmount { get; set; }

    @AuraEnabled
    public Decimal totaFee { get; set; }

    @AuraEnabled
    public Decimal totalDuty { get; set; }

    @AuraEnabled
    public Decimal grandTotalAmount { get; set; }

    @AuraEnabled
    public Decimal totalAmount { get; set; }

    @AuraEnabled
    public Decimal shipping { get; set; }

    @AuraEnabled
    public Decimal amountContributed { get; set; }

    @AuraEnabled
    public Decimal remainingAmount { get; set; }

    @AuraEnabled
    public Decimal totalTax { get; set; }

    @AuraEnabled
    public String buyerName { get; set; }

    @AuraEnabled
    public String buyerPhone { get; set; }

    @AuraEnabled
    public String buyerEmail { get; set; }

    @AuraEnabled
    public Address billingAddress { get; set; }

    @AuraEnabled
    public String paymentSession { get; set; }

    @AuraEnabled
    public String drcheckoutId { get; set; }

    @AuraEnabled
    public String sourceId { get; set; }

    @AuraEnabled
    public String shipCountry { get; set; }

    @AuraEnabled
    public String customerType { get; set; }

    @AuraEnabled
    public Boolean isRecurring { get; set; }

    @AuraEnabled
    public List<DRB2B_RegulatoryFeeModal> regulatoryFee { get; set; }
}