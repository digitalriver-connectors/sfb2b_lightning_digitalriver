public with sharing class DRB2B_SourceModel {
    public String id;
    public String createdTime;
    public String type;
    public Decimal amount;
    public Boolean reusable;
    public String state;
    public Owner owner;
    public String clientSecret;
    public CreditCard creditCard;

    public class CreditCard {
        public String brand;
        public Integer expirationMonth;
        public Integer expirationYear;
        public String lastFourDigits;
        public String fundingSource;
    }

    public class Owner {
        public String firstName;
        public String lastName;
        public String email;
        public Address address;
    }

    public class Address {
        public String line1;
        public String city;
        public String postalCode;
        public String state;
        public String country;
    }

    public static DRB2B_SourceModel parse(String json) {
        return (DRB2B_SourceModel) System.JSON.deserialize(json, DRB2B_SourceModel.class);
    }
}
