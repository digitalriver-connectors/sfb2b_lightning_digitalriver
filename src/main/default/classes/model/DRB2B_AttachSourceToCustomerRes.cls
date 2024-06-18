public with sharing class DRB2B_AttachSourceToCustomerRes {
    public Boolean isSuccess { get; set; }

    public class Owner {
        public String firstName;
        public String lastName;
        public String email;
        public String organization;
        public String upstreamId;
        public Address address;
        public AdditionalAddressInfo additionalAddressInfo;
    }

    public String paymentSessionId;
    public Decimal amount;
    public String type;
    public String upstreamId;
    public CustomerCredit customerCredit;
    public Owner owner;

    public class Address {
        public String line1;
        public String line2;
        public String city;
        public String postalCode;
        public String state;
        public String country;
    }

    public class CustomerCredit {
    }

    public class AdditionalAddressInfo {
        public String neighborhood;
        public String division;
        public String phoneticName;
    }

    public static DRB2B_AttachSourceToCustomerRes parse(String json) {
        return (DRB2B_AttachSourceToCustomerRes) System.JSON.deserialize(json, DRB2B_AttachSourceToCustomerRes.class);
    }
}
