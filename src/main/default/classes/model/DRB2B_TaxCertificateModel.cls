public with sharing class DRB2B_TaxCertificateModel {

    @AuraEnabled
    public String companyName {get; set;}

    @AuraEnabled
    public String taxAuthority{get; set;}

    @AuraEnabled
    public String fileId{get; set;}

    @AuraEnabled
    public String startDate{get; set;}

    @AuraEnabled
    public String endDate{get; set;}
}