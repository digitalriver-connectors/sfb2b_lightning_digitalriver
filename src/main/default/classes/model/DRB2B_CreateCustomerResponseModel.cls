public with sharing class DRB2B_CreateCustomerResponseModel {
    @AuraEnabled
    public Boolean isSuccess { get; set; }

    //error fields
    @AuraEnabled
    public String type { get; set; }

    @AuraEnabled
    public List<DRB2B_ErrorResponseModel> errors { get; set; }

    //success fields
    @AuraEnabled
    public String id { get; set; }

    @AuraEnabled
    public Datetime createdTime { get; set; }

    @AuraEnabled
    public String email { get; set; }

    @AuraEnabled
    public Boolean liveMode { get; set; }

    @AuraEnabled
    public Boolean enabled { get; set; }

    @AuraEnabled
    public Boolean requestToBeForgotten { get; set; }

    @AuraEnabled
    public String locale { get; set; }

    @AuraEnabled
    public Map<String, String> metadata { get; set; }

    @AuraEnabled
    public List<DRB2B_TaxCertificateModel> taxCertificates { get; set; }

    @AuraEnabled
    public List<DRB2B_SourceModel> sources { get; set; }
    public List<DRB2B_TaxIdentifierModal.response> taxIdentifiers { get; set; }
}
