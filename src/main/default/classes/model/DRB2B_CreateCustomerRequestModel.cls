public with sharing class DRB2B_CreateCustomerRequestModel {
    public String id;
    public String type;
    public String email;
    public String locale;
    public Map<String, String> metadata;

    // for post(attach tax certificate)
    public DRB2B_TaxCertificateModel taxCertificate;
}
