public without sharing class DRB2B_updateCheckoutRequestModel {
    public String chargeType { get; set; }
    public String browserIp { get; set; }
    public String customerType { get; set; }
    public String upstreamId { get; set; }
    public List<Item> items { get; set; }
    public String sourceId { get; set; }
    public Metadata metadata{get; set;}
    public String email { get; set; }
    public String customerId { get; set; }
    public String drCurrency { get; set; } // in json: currency
    public String locale { get; set; }
    public List<TaxIdentifiers> taxIdentifiers { get; set; }
    public ShipFrom shipFrom { get; set; }
    public ShippingChoice shippingChoice { get; set; }
    public ShipTo shipTo { get; set; }
    public BillTo billTo { get; set; }

    public DRB2B_updateCheckoutRequestModel(String upstreamId) {
        this.upstreamId = upstreamId;
    }

    public DRB2B_updateCheckoutRequestModel() {
    }

    public class Metadata {
        public string sfOrderId { get; set; }
    }

    public class SubscriptionInfo {
        public String terms { get; set; }
        public Boolean autoRenewal { get; set; }
        public String subscriptionId { get; set; }
        public Boolean freeTrial { get; set; }
        public Datetime startTime { get; set; }
        public Datetime endTime { get; set; }
        public String billingAgreementId { get; set; }

    }

    public class Item {
        public String id { get; set; }
        public SubscriptionInfo subscriptionInfo { get; set; }
    }
    public class Address {
        public String line1 { get; set; }
        public String line2 { get; set; }
        public String postalCode { get; set; }
        public String country { get; set; }
        public String city { get; set; }
        public String state { get; set; }
    }

    public class ShipFrom {
        public Address address { get; set; }

        public ShipFrom(Address address) {
            this.address = address;
        }

        public ShipFrom(DRB2B_Address address) {
            Address fromAddress = new Address();

            fromAddress.country = address.country;
            fromAddress.city = address.city;
            fromAddress.postalCode = address.postalCode;
            fromAddress.state = address.state;
            fromAddress.line1 = address.line1;
            fromAddress.line2 = address.line2;

            this.address = fromAddress;
        }
    }
    public class TaxIdentifiers {
    }
    public class ShippingChoice {
        public Decimal amount { get; set; }
        public String description {get; set;}
        public String serviceLevel {get; set;}
    }
    public class ShipTo {
        public String phone { get; set; }
        public String name { get; set; }
        public String email { get; set; }
        public String organization { get; set; }
        public Address address { get; set; }
    }

    public class BillTo {
        public String phone { get; set; }
        public String name { get; set; }
        public String email { get; set; }
        public String organization { get; set; }
        public Address address { get; set; }
    }
    public static DRB2B_updateCheckoutRequestModel parse(String json) {
        return (DRB2B_updateCheckoutRequestModel) System.JSON.deserialize(json, DRB2B_updateCheckoutRequestModel.class);
    }
}
