public with sharing class DRB2B_CustomerService {
    private static final String CONTACT_ID_FIELD = 'ContactId';

    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();

    @TestVisible
    private static DRB2B_CreateCustomerModelService createCustomerModelService = new DRB2B_CreateCustomerModelService();

    @TestVisible
    private static DRB2B_UserSelector userSelector = new DRB2B_UserSelector();

    public DRB2B_CreateCustomerResponseModel createCustomer(Id userId, String upStreamSessionId) {
        return createCustomer(userId, DRB2B_DRApiConstants.CUSTOMER_TYPE_BUSINESS, upStreamSessionId);
    }

    public DRB2B_CreateCustomerResponseModel createCustomer(Id userId, String customerType, String upStreamSessionId) {
        DRB2B_CreateCustomerRequestModel customerModel = createCustomerModelService.getCreateCustomerRequestModel(userId, customerType);
        if(String.isBlank(upStreamSessionId)){
            upStreamSessionId = customerModel.id;
        }
        DCM_HttpClient.Response response = requestService.getCreateCustomerRequest(customerModel, upStreamSessionId).fetch();
        DRB2B_CreateCustomerResponseModel createCustomerResponse = (DRB2B_CreateCustomerResponseModel) response.asType(DRB2B_CreateCustomerResponseModel.class);

        if (response.getStatusCode() == DRB2B_DRApiConstants.CREATE_CUSTOMER_ALREADY_EXISTS_STATUS) {
            return updateCustomer(customerModel, upStreamSessionId);
        }

        createCustomerResponse.isSuccess = response.getStatusCode() == DRB2B_DRApiConstants.UPSERT_SUCCESS_STATUS;

        if (createCustomerResponse.taxCertificates == null) {
            createCustomerResponse.taxCertificates = new List<DRB2B_TaxCertificateModel>();
        }
        if (createCustomerResponse.sources == null) {
            createCustomerResponse.sources = new List<DRB2B_SourceModel>();
        }

        return createCustomerResponse;
    }

    public DRB2B_CreateCustomerResponseModel updateCustomer(Id userId) {
        return updateCustomer(userId, DRB2B_DRApiConstants.CUSTOMER_TYPE_BUSINESS);
    }

    public DRB2B_CreateCustomerResponseModel updateCustomer(Id userId, String customerType) {
        return updateCustomer(createCustomerModelService.getCreateCustomerRequestModel(userId, customerType), '');
    }

    public DRB2B_CreateCustomerResponseModel updateCustomer(DRB2B_TaxCertificateModel taxCertificateModel, String upStreamSessionId) {
        DRB2B_CreateCustomerRequestModel customerRequestModel = createCustomerModelService.getCreateCustomerRequestModel(UserInfo.getUserId());
        customerRequestModel.taxCertificate = createCustomerModelService.formatDatetime(taxCertificateModel);
        return updateCustomer(customerRequestModel, upStreamSessionId);
    }

    public DRB2B_CreateCustomerResponseModel getForCurrentUser() {
        return getById(UserInfo.getUserId(), '');
    }

    public DRB2B_CreateCustomerResponseModel getById(Id userId, String upStreamSessionId) {
        User usr = userSelector.getById(userId, new Set<String>{ CONTACT_ID_FIELD });
        if(String.isBlank(upStreamSessionId)){
            upStreamSessionId = usr.ContactId;
        }
        System.debug('upStreamSessionId---->'+upStreamSessionId);
        DCM_HttpClient.Response response = requestService.getRetrieveCustomerRequest(usr.ContactId, upStreamSessionId).fetch();
        DRB2B_CreateCustomerResponseModel getCustomerResponse = (DRB2B_CreateCustomerResponseModel) response.asType(DRB2B_CreateCustomerResponseModel.class);
        getCustomerResponse.isSuccess = response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS;

        if (getCustomerResponse.taxCertificates == null) {
            getCustomerResponse.taxCertificates = new List<DRB2B_TaxCertificateModel>();
        }
        if (getCustomerResponse.sources == null) {
            getCustomerResponse.sources = new List<DRB2B_SourceModel>();
        }

        return getCustomerResponse;
    }

    private DRB2B_CreateCustomerResponseModel updateCustomer(DRB2B_CreateCustomerRequestModel customer, String upStreamSessionId) {
        String customerId = customer.id;
        if(String.isBlank(upStreamSessionId)){
            upStreamSessionId = customerId;
        }
        customer.id = null;
        DCM_HttpClient.Response response = requestService.getUpdateCustomerRequest(customer, customerId, upStreamSessionId).fetch();
        DRB2B_CreateCustomerResponseModel createCustomerResponse = (DRB2B_CreateCustomerResponseModel) response.asType(DRB2B_CreateCustomerResponseModel.class);
        createCustomerResponse.isSuccess = response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS;
        return createCustomerResponse;
    }

    public DCM_HttpClient.Response attachSourceToCustomer(String sourceId, String customerId,  String upStreamSessionId) {
        DCM_HttpClient.Response response = requestService.getUpdateCustomerRequest(customerId, sourceId, upStreamSessionId).fetch();
        return response;
    }
}
