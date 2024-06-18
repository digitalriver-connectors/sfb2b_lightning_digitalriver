public with sharing class DRB2B_TaxIdentifierModal {
    public DRB2B_TaxIdentifierModal() {
    }
    public class Request {
        public string type;
        public string value;
    }

    public class Response {
        //success fields
        public string id;
        public string state;
        public string verifiedName;
        public string verifiedAddress;
        public string liveMode;
        public string customerId;
        public string createdTime;
        public string updatedTime;
        public string value;

        //error fields
        public String type;
        public List<DRB2B_ErrorResponseModel> errors;
    }
}
