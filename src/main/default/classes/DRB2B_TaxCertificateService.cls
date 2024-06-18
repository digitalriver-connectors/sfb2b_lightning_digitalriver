public with sharing class DRB2B_TaxCertificateService {

    private static final String CONTACT_ID_FIELD = 'ContactId';
    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();
    @TestVisible
    private static DRB2B_UserSelector userSelector = new DRB2B_UserSelector();

    public DRB2B_UploadTaxCertificateResponseModel uploadTaxCertificate(string taxCertReq, String cartId) {
        String upStreamSessionId = '';
        if(String.isBlank(cartId)){
            User usr = userSelector.getById(UserInfo.getUserId(), new Set<String>{ CONTACT_ID_FIELD });
            upStreamSessionId = usr.ContactId;
        }else{
            upStreamSessionId = cartId;
        }
        DRB2B_uploadTaxCertificateRequestModel taxCertificateModel = DRB2B_uploadTaxCertificateRequestModel.parse(taxCertReq);
        DCM_HttpClient.Response response = requestService.getUploadFileRequest(taxCertificateModel, upStreamSessionId).fetch();
        DRB2B_UploadTaxCertificateResponseModel apiResponse = (DRB2B_UploadTaxCertificateResponseModel) response.asType(
            DRB2B_UploadTaxCertificateResponseModel.class
        );
        return apiResponse;
    }
    
}
