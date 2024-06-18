public without sharing class DRB2B_PaymentDetailsModel {
    public class paymentDetails {
        public String name { get; set; }
        public Decimal amount { get; set; }
        public String cardNumber { get; set; }
    }

    public DRB2B_PaymentDetailsModel parse(String json) {
        return (DRB2B_PaymentDetailsModel) System.JSON.deserialize(json, DRB2B_PaymentDetailsModel.class);
    }
}
