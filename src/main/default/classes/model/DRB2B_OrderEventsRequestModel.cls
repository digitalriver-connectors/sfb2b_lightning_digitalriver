public with sharing class DRB2B_OrderEventsRequestModel {
    public class Address {
        public String line1 { get; set; }
        public String line2 { get; set; }
        public String city { get; set; }
        public String postalCode { get; set; }
        public String state { get; set; }
        public String country { get; set; }
    }

    public class ShipFrom {
        public Address address { get; set; }
    }

    public class Order {
        public String id { get; set; }
        public String createdTime { get; set; }
        public String customerId { get; set; }
        public String drCurrency { get; set; }
        public String email { get; set; }
        public ShipTo shipTo { get; set; }
        public ShipFrom shipFrom { get; set; }
        public Double totalAmount { get; set; }
        public Double subtotal { get; set; }
        public Double totalFees { get; set; }
        public Double totalTax { get; set; }
        public Double totalDuty { get; set; }
        public Double totalDiscount { get; set; }
        public Double totalShipping { get; set; }
        public List<Item> items { get; set; }
        public Metadata metadata { get; set; }
        public String updatedTime { get; set; }
        public String locale { get; set; }
        public String customerType { get; set; }
        public String paymentSessionId { get; set; }
        public SellingEntity sellingEntity { get; set; }
        public String state { get; set; }
        public StateTransitions stateTransitions { get; set; }
        public String fraudState { get; set; }
        public FraudStateTransitions fraudStateTransitions { get; set; }
        public List<Charges> charges { get; set; }
        public Boolean requestToBeForgotten { get; set; }
        public Double capturedAmount { get; set; }
        public Double cancelledAmount { get; set; }
        public Double availableToRefundAmount { get; set; }
        public Boolean liveMode { get; set; }
        public String upstreamId { get; set; }
    }

    public class StateTransitions {
        public String accepted { get; set; }
        public String created { get; set; }
    }

    public class Metadata {
        public String skuId { get; set; }
        public String cartItemId { get; set; }
        public String cartId { get; set; }
        public string sfOrderId{ get; set;}
    }

    public class Tax {
        public Double rate { get; set; }
        public Double amount { get; set; }
    }

    public class Data {
        public Order order { get; set; }
    }

    public class SellingEntity {
        public String id { get; set; }
        public String name { get; set; }
    }

    public String id { get; set; }
    public String type { get; set; }
    public Data data { get; set; }
    public String digitalRiverVersion { get; set; }
    public Boolean liveMode { get; set; }
    public String createdTime { get; set; }

    public class ShipTo {
        public Address address { get; set; }
        public String name { get; set; }
        public String phone { get; set; }
    }

    public class Item {
        public String id { get; set; }
        public String skuId { get; set; }
        public Double amount { get; set; }
        public Fees fees { get; set; }
        public Integer quantity { get; set; }
        public Metadata metadata { get; set; }
        public String state { get; set; }
        public StateTransitions stateTransitions { get; set; }
        public Tax tax { get; set; }
        public Tax importerTax { get; set; }
        public Duties duties { get; set; }
        public Double availableToRefundAmount { get; set; }
    }

    public class Fees {
        public List<Details> details { get; set; }
        public Decimal amount { get; set; }
        public Decimal taxAmount { get; set; }
    }

    public class Duties {
        public Decimal amount { get; set; }
    }

    public class Details {
        public String type { get; set; }
        public Decimal amount { get; set; }
        public Decimal perUnitAmount { get; set; }
        public String id { get; set; }
    }

    public class Charges {
        public String id { get; set; }
        public String createdTime { get; set; }
        public String drCurrency { get; set; }
        public Double amount { get; set; }
        public String state { get; set; }
        public Boolean captured { get; set; }
        public Boolean refunded { get; set; }
        public String sourceId { get; set; }
    }

    public class FraudStateTransitions {
        public String passed { get; set; }
    }

    public class ConvertFromCheckoutRequest {
        public String checkoutId { get; set; }

        public ConvertFromCheckoutRequest(String checkoutId) {
            this.checkoutId = checkoutId;
        }
    }

    public static DRB2B_OrderEventsRequestModel parse(String json) {
        return (DRB2B_OrderEventsRequestModel) System.JSON.deserialize(json, DRB2B_OrderEventsRequestModel.class);
    }

    public static DRB2B_OrderEventsRequestModel.Order parseOrder(String json) {
        return (DRB2B_OrderEventsRequestModel.Order) System.JSON.deserialize(json, DRB2B_OrderEventsRequestModel.Order.class);
    }

    public static DRB2B_OrderEventsRequestModel deserializeEvent(String json) {
        return (DRB2B_OrderEventsRequestModel) System.JSON.deserialize(DRB2B_Utility.modifyJSON(json, new Map<String, String>{ 'currency' => 'drCurrency', 'object' => 'Order'}), DRB2B_OrderEventsRequestModel.class);
    }

}