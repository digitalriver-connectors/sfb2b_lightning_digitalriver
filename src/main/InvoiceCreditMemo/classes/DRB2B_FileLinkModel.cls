/**
 * @description       : Contains request and response modal for file-link request
 */
public with sharing class DRB2B_FileLinkModel {
    public class Request {
        public String fileId;
        public String expiresTime;
    }

    public class Response {
        //success fields
        public String id;
        public String createdTime;
        public String expired;
        public String expiresTime;
        public String fileId;
        public String url;

        //error fields
        public String type;
        public List<DRB2B_ErrorResponseModel> errors;
    }
}
