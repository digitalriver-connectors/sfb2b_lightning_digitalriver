public with sharing class DRB2B_ErrorResponseModel {
    @AuraEnabled
    public String code { get; set; }

    @AuraEnabled
    public String parameter { get; set; }

    @AuraEnabled
    public String message { get; set; }
}
