public with sharing class DRB2B_CancelFulfillmenRequestModel {
    public class Metadata {
        public String lineItemExtRefID;
    }

    public class Items {
        public String itemId;
        public String skuId;
        public Integer cancelQuantity;
    }

    public String orderId;
    public List<Items> items;
    public Metadata metadata;
    public String trackingCompany;
    public String trackingNumber;
    public String trackingUrl;

    public static DRB2B_CancelFulfillmenRequestModel parse(String json) {
        return (DRB2B_CancelFulfillmenRequestModel) System.JSON.deserialize(
            json,
            DRB2B_CancelFulfillmenRequestModel.class
        );
    }
}
