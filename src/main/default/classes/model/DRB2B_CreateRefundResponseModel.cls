public with sharing class DRB2B_CreateRefundResponseModel {
    public boolean hasMore;
    public cls_data[] data;
    public class Cls_data {
        public String id;
        public Double amount{ get; set; }
        public String createdTime{ get; set; }
        public String drCurrency{ get; set; }
        public List<Items> items{ get; set; }
        public String orderId{ get; set; }
        public Double refundedAmount{ get; set; }
        public String state{ get; set; }
        public TokenInformation tokenInformation{ get; set; }
        public Boolean liveMode{ get; set; }
        public List<Charges> charges { get; set; }
    }

    public class Items {
        public Integer quantity{ get; set; }
        public Integer cancelQuantity{ get; set; }
        public String skuId{ get; set; }
        public String itemId{ get; set; }
    }

    public class TokenInformation {
        public String token{ get; set; }
        public String expiresTime{ get; set; }
    }

    public class Charges {
        public String id { get; set; }
        public Boolean captured { get; set; }
        public Boolean refunded { get; set; }
        public List<Refunds> refunds { get; set; }
        public String sourceId { get; set; }
    }

    public class Refunds {
        public String createdTime{ get; set; }
        public Double amount { get; set; }
        public String state{ get; set; }
    }

    public static DRB2B_CreateRefundResponseModel parse(String json) {
        return (DRB2B_CreateRefundResponseModel) System.JSON.deserialize(
            json,
            DRB2B_CreateRefundResponseModel.class
        );
    }
}