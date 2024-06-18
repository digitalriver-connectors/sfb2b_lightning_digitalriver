    public with sharing class DRB2B_CreateCustomerCreditModel {
    public DRB2B_CreateCustomerCreditModel() {

    }
    public class customerCredit {}
    

    public class Request {
        public String type;
        public String paymentSessionId;
        public String currency1;
        public Decimal amount;
        public customerCredit customerCredit;

    }

    public class Response {
        //success fields
        public String channelId;
        public String liveMode;
        public String id;
        public String clientSecret;
        public String reusable;
        public String amount;
        public String state;
        public String creationIp;
        public String createdTime;
        public String updatedTime;
        public String flow;
        public customerCredit customerCredit;

    
        //error fields
        public String type;
        public List<DRB2B_ErrorResponseModel> errors;

        public  DRB2B_CreateCustomerCreditModel parse(String json) {
            return (DRB2B_CreateCustomerCreditModel) System.JSON.deserialize(json, DRB2B_CreateCustomerCreditModel.class);
        }
    }
}
