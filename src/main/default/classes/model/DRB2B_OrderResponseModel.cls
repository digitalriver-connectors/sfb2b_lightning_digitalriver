public with sharing class DRB2B_OrderResponseModel {
    public class Owner {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public Address address { get; set; }
    }

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

    public class StateTransitions {
        public String accepted { get; set; }
    }

    public class Metadata {
        public String cartId { get; set; }
    }

    public class Tax {
        public Double rate { get; set; }
        public Double amount { get; set; }
    }

    public class Fees {
        public Double amount { get; set; }
        public Double taxAmount { get; set; }
    }

    public class SellingEntity {
        public String id { get; set; }
        public String name { get; set; }
    }

    public class Sources {
        public String id { get; set; }
        public String type { get; set; }
        public Double amount { get; set; }
        public Owner owner { get; set; }
        public CreditCard creditCard { get; set; }
        public WireTransfer wireTransfer { get; set; }
        public PayPal payPal { get; set; }
    }

    public class CreditCard {
        public String brand { get; set; }
        public Integer expirationMonth { get; set; }
        public Integer expirationYear { get; set; }
        public String lastFourDigits { get; set; }
        public String fundingSource { get; set; }
    }

    public class WireTransfer {
        public String accountNumber { get; set; }
        public String accountHolder { get; set; }
        public String referenceId { get; set; }
        public String city { get; set; }
        public String bankName { get; set; }
        public String swiftCode { get; set; }
    }

    public class PayPal {
        public String payerStatus { get; set; }
        public String payerId { get; set; }
        public String returnUrl { get; set; }
        public String redirectUrl { get; set; }
        public String token { get; set; }
    }

    public String id { get; set; }
    public String createdTime { get; set; }
    public String customerId { get; set; }
    public String drCurrency { get; set; } // in json: currency
    public String email { get; set; }
    public ShipTo shipTo { get; set; }
    public ShipFrom shipFrom { get; set; }
    public BillTo billTo { get; set; }
    public Double totalAmount { get; set; }
    public Double subtotal { get; set; }
    public Double totalFees { get; set; }
    public Double totalTax { get; set; }
    public Double totalImporterTax { get; set; }
    public Double totalDuty { get; set; }
    public Double totalDiscount { get; set; }
    public Double totalShipping { get; set; }
    public List<Items> items { get; set; }
    public Fees shippingChoice { get; set; }
    public Metadata metadata { get; set; }
    public String updatedTime { get; set; }
    public String locale { get; set; }
    public String customerType { get; set; }
    public SellingEntity sellingEntity { get; set; }
    public Boolean liveMode { get; set; }
    public Payment payment { get; set; }
    public String state { get; set; }
    public StateTransitions stateTransitions { get; set; }
    public String fraudState { get; set; }
    public FraudStateTransitions fraudStateTransitions { get; set; }
    public Boolean requestToBeForgotten { get; set; }
    public Double capturedAmount { get; set; }
    public Double cancelledAmount { get; set; }
    public Double availableToRefundAmount { get; set; }
    public String checkoutId { get; set; }
    public String upstreamId { get; set; }

    public class Payment {
        public List<Charges> charges { get; set; }
        public List<Sources> sources { get; set; }
        public Session session { get; set; }
    }

    public class ImporterTax {
        public Double amount { get; set; }
    }

    public class BillTo {
        public Address address { get; set; }
        public String name { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
    }

    public class ShipTo {
        public Address address { get; set; }
        public String name { get; set; }
        public String phone { get; set; }
    }

    public class Items {
        public String id { get; set; }
        public String skuId { get; set; }
        public Double amount { get; set; }
        public Integer quantity { get; set; }
        public String state { get; set; }
        public StateTransitions stateTransitions { get; set; }
        public Tax tax { get; set; }
        public ImporterTax importerTax { get; set; }
        public ImporterTax duties { get; set; }
        public Double availableToRefundAmount { get; set; }
        public Fees fees { get; set; }
        public SubscriptionInfo subscriptionInfo { get; set; }
    }

    public class SubscriptionInfo {
		public Boolean autoRenewal { get; set; }
		public Boolean freeTrial { get; set; }
		public String terms { get; set; }
		public String subscriptionId { get; set; }
		public String billingAgreementId { get; set; }
	} 

    public class Charges {
        public String id { get; set; }
        public String createdTime { get; set; }
        public String drCurrency { get; set; } // in json: currency
        public Double amount { get; set; }
        public String state { get; set; }
        public Boolean captured { get; set; }
        public Boolean refunded { get; set; }
        public String sourceId { get; set; }
        public String type { get; set; }
    }

    public class FraudStateTransitions {
        public String passed { get; set; }
    }

    public class Session {
        public String id { get; set; }
        public Double amountContributed { get; set; }
        public Double amountRemainingToBeContributed { get; set; }
        public String state { get; set; }
        public String clientSecret { get; set; }
        public NextAction nextaction { get; set; }
    }

    public class NextAction {
        public String action { get; set; }
        public ClientData data { get; set;}
    }

    public class ClientData {
        public String sourceId { get; set; }
        public String sourceClientSecret { get; set; }
    }

    public static DRB2B_OrderResponseModel parse(String json) {
        return (DRB2B_OrderResponseModel) System.JSON.deserialize(json, DRB2B_OrderResponseModel.class);
    }
    public static DRB2B_OrderResponseModel deserializeOrder(String json) {
        return (DRB2B_OrderResponseModel) System.JSON.deserialize(
            DRB2B_Utility.modifyJSON(json, new Map<String, String>{ 'currency' => 'drCurrency' }),
            DRB2B_OrderResponseModel.class
        );
    }
}
