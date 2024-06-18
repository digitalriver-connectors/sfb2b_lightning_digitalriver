public with sharing class DRB2B_CreateFulfillmentResponseModel {
    public String id;
    public String createdTime;
    public List<Items> items;
    public Metadata metadata;
    public String orderId;
    public Boolean liveMode;
    public String trackingCompany;
    public String trackingNumber;
    public String trackingUrl;

    public class Metadata {
        public String lineItemExtRefID;
    }

    public class Items {
        public Integer quantity;
        public Integer cancelQuantity;
        public String skuId;
        public String itemId;
    }

    public static DRB2B_CreateFulfillmentResponseModel parse(String json) {
        return (DRB2B_CreateFulfillmentResponseModel) System.JSON.deserialize(
            json,
            DRB2B_CreateFulfillmentResponseModel.class
        );
    }
}
