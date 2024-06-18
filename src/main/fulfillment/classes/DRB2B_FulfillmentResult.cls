// TODO: Write Setter and Getter for the instance variables
public with sharing class DRB2B_FulfillmentResult {
    public DR_Fulfillment__c orderFulfillmentRec;
    public List<DR_Line_Item_Fulfillment__c> lineItemFulfillmentRecs;
    //public DRB2B_CreateFulfillmentResponseModel fulfillmentResponseModel;
    public DRB2B_ErrorResponse errorResponse;
    public Boolean isSuccess;
    //public Integer statusCode;
    public String message;

    public DRB2B_FulfillmentResult(DR_Fulfillment__c orderFulfillmentRec) {
        this(orderFulfillmentRec, null);
    }

    public DRB2B_FulfillmentResult(DR_Fulfillment__c orderFulfillmentRec, List<DR_Line_Item_Fulfillment__c> lineItemFulfillmentRecs) {
        this.isSuccess = false;
        this.orderFulfillmentRec = orderFulfillmentRec;
        this.lineItemFulfillmentRecs = lineItemFulfillmentRecs;
    }

}