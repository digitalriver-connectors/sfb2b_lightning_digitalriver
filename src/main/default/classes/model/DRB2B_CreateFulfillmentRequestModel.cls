public with sharing class DRB2B_CreateFulfillmentRequestModel {
    public class Metadata {
        public String lineItemExtRefID;
    }

    public class Items {
        public String itemId;
        public String skuId;
        public Integer quantity;
        public Integer cancelQuantity;
    }

    public String orderId;
    public List<Items> items;
    public Metadata metadata;
    public String trackingCompany;
    public String trackingNumber;
    public String trackingUrl;

    public static DRB2B_CreateFulfillmentRequestModel parse(String json) {
        return (DRB2B_CreateFulfillmentRequestModel) System.JSON.deserialize(
            json,
            DRB2B_CreateFulfillmentRequestModel.class
        );
    }

    public static DRB2B_CreateFulfillmentRequestModel deserialize(String json) {
        return (DRB2B_CreateFulfillmentRequestModel) System.JSON.deserialize(json, DRB2B_CreateFulfillmentRequestModel.class);
    }

    public static String serialize(DRB2B_CreateFulfillmentRequestModel fulfillmentRequestModel) {
        return System.JSON.serialize(fulfillmentRequestModel, true);
    }

}