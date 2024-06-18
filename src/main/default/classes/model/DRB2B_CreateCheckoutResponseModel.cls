public without sharing class DRB2B_CreateCheckoutResponseModel {
    public String id { get; set; }
    public String createdTime { get; set; }
    public String updatedTime { get; set; }
    public String customerId { get; set; }
    public String drCurrency { get; set; } // in json: currency
    public String email { get; set; }
    public String locale { get; set; }
    public String browserIp { get; set; }
    public String applicationId { get; set; }
    public ShipFrom shipFrom { get; set; }
    public ShipTo shipTo { get; set; }
    public ShipTo billTo { get; set; }
    public Decimal subtotal { get; set; }
    public Decimal totalTax { get; set; }
    public Decimal totalImporterTax { get; set; }
    public Boolean importerOfRecordTax { get; set; }
    public Decimal totalFees { get; set; }
    public Decimal totalDuty { get; set; }
    public Decimal totalDiscount { get; set; }
    public Decimal totalShipping { get; set; }
    public Decimal totalAmount { get; set; }
    public Discount discount { get; set; }
    public List<TaxIdentifier> taxIdentifiers { get; set; }
    public PurchaseLocation purchaseLocation { get; set; }
    public String customerType { get; set; }
    public SellingEntity sellingEntity { get; set; }
    public List<Item> items { get; set; }
    public ShippingChoice shippingChoice { get; set; }
    public Payment payment { get; set; }
    public Boolean liveMode { get; set; }
    public Metadata metadata { get; set; }
    public String upstreamId { get; set; }

    public String type { get; set; }
    public List<DRB2B_ErrorResponseModel> errors { get; set; }

    public class Owner {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String organization { get; set; }
        public String upstreamId { get; set; }
        public Address address { get; set; }
        public AdditionalAddressInfo additionalAddressInfo { get; set; }
    }

    public class Discount {
        public Decimal amountOff { get; set; }
        public Integer percentOff { get; set; }
        public Integer quantity { get; set; }
    }

    public class Address {
        public String line1 { get; set; }
        public String line2 { get; set; }
        public String city { get; set; }
        public String postalCode { get; set; }
        public String state { get; set; }
        public String country { get; set; }
    }

    public class Metadata {
        public String coupon { get; set; }
    }

    public class SubscriptionInfo {
        public Boolean freeTrial { get; set; }
        public Boolean autoRenewal { get; set; }
        public String terms { get; set; }
        public String subscriptionId { get; set; }
        public String billingAgreementId { get; set; }
        public String startTime { get; set; }
        public String endTime { get; set; }
    }

    public class Tax {
        public Decimal rate { get; set; }
        public Decimal amount { get; set; }
    }

    public class SellingEntity {
        public String id { get; set; }
        public String name { get; set; }
    }

    public class OnlineBanking {
        public String bankCode { get; set; }
    }

    public class ImporterTax {
        public Decimal amount { get; set; }
    }

    public class Duties {
        public Decimal amount { get; set; }
    }

    public class KlarnaCreditRecurring {
        public String returnUrl { get; set; }
        public String cancelUrl { get; set; }
    }

    public class BPay {
        public String accountHolder { get; set; }
        public String bankName { get; set; }
        public String city { get; set; }
        public String country { get; set; }
        public String referenceId { get; set; }
        public String accountNumber { get; set; }
        public String billId { get; set; }
        public String customerPaymentReference { get; set; }
        public String swiftCode { get; set; }
    }

    public class Item {
        public String id { get; set; }
        public String skuId { get; set; }
        public SubscriptionInfo subscriptionInfo { get; set; }
        public Fees fees { get; set; }
        public Integer quantity { get; set; }
        public Decimal amount { get; set; }
        public Decimal availableToRefundAmount { get; set; }
        public Tax tax { get; set; }
        public ImporterTax importerTax { get; set; }
        public Duties duties { get; set; }
        public Discount discount { get; set; }
        public ShipFrom shipFrom { get; set; }
        public Metadata metadata { get; set; }
    }

    public class Charge {
        public String id { get; set; }
        public String createdTime { get; set; }
        public String drCurrency { get; set; } // in json: currency
        public Decimal amount { get; set; }
        public String state { get; set; }
        public String orderId { get; set; }
        public String sourceId { get; set; }
        public String failureCode { get; set; }
        public String failureMessage { get; set; }
        public String paymentSessionId { get; set; }
        public List<Cancels> cancels { get; set; }
        public List<Cancels> captures { get; set; }
        public Boolean captured { get; set; }
        public List<Cancels> refunds { get; set; }
        public Boolean refunded { get; set; }
        public String type { get; set; }
        public Boolean liveMode { get; set; }
    }

    public class Shipping {
        public String recipient { get; set; }
        public String phoneNumber { get; set; }
        public Address address { get; set; }
        public String email { get; set; }
    }

    public class Cancels {
        public String id { get; set; }
        public String createdTime { get; set; }
        public String updatedTime { get; set; }
        public Decimal amount { get; set; }
        public String state { get; set; }
        public String failureCode { get; set; }
        public String failureMessage { get; set; }
    }

    public class PayPal {
        public Redirect redirect { get; set; }
        public DirectDebit directDebit { get; set; }
    }

    public class KlarnaCredit {
        public Shipping shipping { get; set; }
        public String token { get; set; }
    }

    public class WireTransfer {
        public String accountHolder { get; set; }
        public String bankName { get; set; }
        public String city { get; set; }
        public String country { get; set; }
        public String referenceId { get; set; }
        public String accountNumber { get; set; }
        public String additionalBankInformation { get; set; }
        public String iban { get; set; }
    }

    public class ShipFrom {
        public Address address { get; set; }
        public AdditionalAddressInfo additionalAddressInfo { get; set; }
    }

    public class AdditionalAddressInfo {
        public String neighborhood { get; set; }
        public String division { get; set; }
        public String phoneticName { get; set; }
    }

    public class ShippingChoice {
        public Decimal amount { get; set; }
        public Decimal taxAmount { get; set; }
        public String description { get; set; }
        public String serviceLevel { get; set; }
    }

    public class Redirect {
        public String redirectUrl { get; set; }
        public String returnUrl { get; set; }
        public String cancelUrl { get; set; }
    }

    public class Fees {
        public List<Details> details { get; set; }
        public Decimal amount { get; set; }
        public Decimal taxAmount { get; set; }
    }

    public class Source {
        public String id { get; set; }
        public String clientSecret { get; set; }
        public String createdTime { get; set; }
        public String type { get; set; }
        public String drCurrency { get; set; } // in json: currency
        public Decimal amount { get; set; }
        public Boolean reusable { get; set; }
        public Owner owner { get; set; }
        public CreditCard creditCard { get; set; }
        public CreditCard googlePay { get; set; }
        public PayPal payPal { get; set; }
        public PayPal payPalBilling { get; set; }
        public PayPal payPalCredit { get; set; }
        public DirectDebit directDebit { get; set; }
        public WireTransfer wireTransfer { get; set; }
        public BPay bPay { get; set; }
        public OnlineBanking onlineBanking { get; set; }
        public KlarnaCredit klarnaCredit { get; set; }
        public KlarnaCreditRecurring klarnaCreditRecurring { get; set; }
        public Konbini konbini { get; set; }
        public BankTransfer bankTransfer { get; set; }
        public String flow { get; set; }
        public String state { get; set; }
        public Metadata metadata { get; set; }
        public String customerId { get; set; }
        public String paymentSessionId { get; set; }
        public Boolean liveMode { get; set; }
    }

    public class CreditCard {
        public String lastFourDigits { get; set; }
        public Integer expirationMonth { get; set; }
        public Integer expirationYear { get; set; }
        public String brand { get; set; }
        public String fundingSource { get; set; }
    }

    public class PurchaseLocation {
        public String country { get; set; }
        public String state { get; set; }
        public String postalCode { get; set; }
    }

    public class Payment {
        public List<Source> sources { get; set; }
        public List<Charge> charges { get; set; }
        public Session session { get; set; }
    }

    public class Details {
        public String type { get; set; }
        public Decimal amount { get; set; }
        public Decimal perUnitAmount { get; set; }
        public String id { get; set; }
    }

    public class DirectDebit {
        public String token { get; set; }
        public Redirect redirect { get; set; }
    }

    public class Konbini {
        public String storeId { get; set; }
        public String receiptNumber { get; set; }
        public String printableInvoiceUrl { get; set; }
        public String storeName { get; set; }
        public String localizedStoreName { get; set; }
        public String storeLogoUrl { get; set; }
    }

    public class BankTransfer {
    }

    public class TaxIdentifier {
        public String id { get; set; }
        public String createdTime { get; set; }
        public String customerId { get; set; }
        public String type { get; set; }
        public String value { get; set; }
        public String state { get; set; }
        //public String stateTransitions { get; set; }
        public String verifiedName { get; set; }
        public String verifiedAddress { get; set; }
        public String updatedTime { get; set; }
    }

    public class ShipTo {
        public Address address { get; set; }
        public String name { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
        public String organization { get; set; }
        public AdditionalAddressInfo additionalAddressInfo { get; set; }
    }

    public class Session {
        public String id { get; set; }
        public Decimal amountContributed { get; set; }
        public Decimal amountRemainingToBeContributed { get; set; }
        public String clientSecret { get; set; }
        public String state { get; set; }
    }

    public static DRB2B_CreateCheckoutResponseModel parse(String json) {
        return (DRB2B_CreateCheckoutResponseModel) System.JSON.deserialize(
            json,
            DRB2B_CreateCheckoutResponseModel.class
        );
    }

    public static DRB2B_CreateCheckoutResponseModel deserializeCheckout(String json) {
        return (DRB2B_CreateCheckoutResponseModel) System.JSON.deserialize(
            DRB2B_Utility.modifyJSON(json, new Map<String, String>{ 'currency' => 'drCurrency' }),
            DRB2B_CreateCheckoutResponseModel.class
        );
    }
}
