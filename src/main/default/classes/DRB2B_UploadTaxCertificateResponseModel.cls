public with sharing class DRB2B_UploadTaxCertificateResponseModel {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String fileName { get; set; }

     //error fields
 
     @AuraEnabled
     public List<DRB2B_ErrorResponseModel> errors { get; set; }

}
