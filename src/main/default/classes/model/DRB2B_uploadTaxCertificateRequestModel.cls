public with sharing class DRB2B_uploadTaxCertificateRequestModel {
    public String file { get; set; }
    public String purpose { get; set; }
    public String title { get; set; }
    public String fileName { get; set; }
    public Datetime linkExpiresTime { get; set; }
    public DRB2B_uploadTaxCertificateRequestModel() {
        this.purpose = 'Tax Certificate';
        this.title = 'tax_document_customer_upload';
    }
    public static DRB2B_uploadTaxCertificateRequestModel parse(String json) {
        return (DRB2B_uploadTaxCertificateRequestModel) System.JSON.deserialize(json, DRB2B_uploadTaxCertificateRequestModel.class);
    }
}
