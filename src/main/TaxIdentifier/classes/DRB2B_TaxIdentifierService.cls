/**
 * @description       : This class will be responsible for genrating , deleting and will link taxid to customer
 **/
public without sharing class DRB2B_TaxIdentifierService {
    private class TaxIdentifierException extends Exception {
    }
    private static final String CONTACT_ID_FIELD = 'ContactId';

    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();

    @TestVisible
    private static DRB2B_UserSelector userSelector = new DRB2B_UserSelector();

    @TestVisible
    private static final DRB2B_CustomerService customerService = new DRB2B_CustomerService();

    @TestVisible
    private static final DRB2B_CartTaxService cartTaxService = new DRB2B_CartTaxService();

    public DRB2B_TaxIdentifierModal.Response createTaxIdentifier(string JsonInput, String cartId) {
        DRB2B_TaxIdentifierModal.Request taxReq = (DRB2B_TaxIdentifierModal.Request) JSON.deserialize(
            JsonInput,
            DRB2B_TaxIdentifierModal.Request.class
        );
        User user = userSelector.getById(UserInfo.getUserId(), new Set<string>{ CONTACT_ID_FIELD });
        if (String.isBlank(cartId)) {
            cartId = user.ContactId;
        }
        DCM_HttpClient.Response Response = requestService.createTaxIdentifier(taxReq, cartId).fetch();
        DRB2B_TaxIdentifierModal.Response apiResponse = (DRB2B_TaxIdentifierModal.Response) response.asType(
            DRB2B_TaxIdentifierModal.Response.class
        );
        return apiResponse;
    }

    public Boolean deleteTaxIdentifier(string taxId, String cartId) {
        User user = userSelector.getById(UserInfo.getUserId(), new Set<string>{ CONTACT_ID_FIELD });
        if (String.isBlank(cartId)) {
            cartId = user.ContactId;
        }
        DCM_HttpClient.Response response = requestService.deleteTaxIdentifier(taxId, cartId).fetch();
        return response.getStatusCode() == DRB2B_DRApiConstants.DELETE_SUCCESS_STATUS;
    }

    public DRB2B_TaxIdentifierModal.Response linkTaxIdentifierToCustomer(string taxId, String cartId) {
        User user = userSelector.getById(UserInfo.getUserId(), new Set<string>{ CONTACT_ID_FIELD });
        if (String.isBlank(cartId)) {
            cartId = user.ContactId;
        }
        DCM_HttpClient.Response response = requestService.linkTaxIdentifier(taxId, user.ContactId, cartId).fetch();
        DRB2B_TaxIdentifierModal.Response apiResponse = (DRB2B_TaxIdentifierModal.Response) response.asType(
            DRB2B_TaxIdentifierModal.Response.class
        );
        return apiResponse;
    }

    public DRB2B_TaxIdentifierModal.Response saveTaxIdentifier(string jsonString, String cartId) {
        DRB2B_TaxIdentifierModal.Response resp = createTaxIdentifier(jsonString, cartId);
        if (resp.errors != null) {
            throw new TaxIdentifierException(JSON.serialize(resp.errors));
        }
        DRB2B_TaxIdentifierModal.Response linkResponse = linkTaxIdentifierToCustomer(resp.id, cartId);
        DRB2B_CreateCustomerResponseModel customerResponse;
        if (linkResponse.errors != null && linkResponse.errors[0].code == DRB2B_DRApiConstants.NOT_FOUND) {
            customerResponse = customerService.createCustomer(UserInfo.getUserId(), cartId);
            linkResponse = linkTaxIdentifierToCustomer(resp.id, cartId);
        }
        return linkResponse;
    }

    public DRB2B_CreateCheckoutResponseModel attachTaxId(String checkoutId, List<String> taxIds, String cartId) {
        DRB2B_AttachTaxIdTiCheckoutModel req = new DRB2B_AttachTaxIdTiCheckoutModel();
        List<DRB2B_AttachTaxIdTiCheckoutModel.TaxIdentifiers> taxIdList = new List<DRB2B_AttachTaxIdTiCheckoutModel.TaxIdentifiers>();
        for (String id : taxIds) {
            DRB2B_AttachTaxIdTiCheckoutModel.TaxIdentifiers taxObj = new DRB2B_AttachTaxIdTiCheckoutModel.TaxIdentifiers();
            taxObj.id = id;
            taxIdList.add(taxObj);
        }
        req.taxIdentifiers = taxIdList;
        req.sourceId = '';
        User user = userSelector.getById(UserInfo.getUserId(), new Set<string>{ CONTACT_ID_FIELD });
        if (String.isBlank(cartId)) {
            cartId = user.ContactId;
        }
        DCM_HttpClient.Response response = requestService.attachTaxidentifierToCheckout(req, checkoutId, cartId)
            .fetch();
        DRB2B_CreateCheckoutResponseModel apiResponse = (DRB2B_CreateCheckoutResponseModel) response.asType(
            DRB2B_CreateCheckoutResponseModel.class
        );
        if (response.getStatusCode() >= 200 && response.getStatusCode() < 300)
            cartTaxService.updateCartTax(apiResponse);
        return apiResponse;
    }

    public string appliedTaxIds(List<DRB2B_CreateCheckoutResponseModel.TaxIdentifier> taxIds) {
        String taxIdString;
        for (DRB2B_CreateCheckoutResponseModel.TaxIdentifier taxId : taxIds) {
            if (String.isEmpty(taxIdString)) {
                taxIdString = taxId.id;
            } else {
                taxIdString = ',' + taxId.id;
            }
        }
        return taxIdString;
    }
}
