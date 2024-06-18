public with sharing class DRB2B_CreateCustomerModelService {
    private static final String ACCOUNT_ID = 'accountId';
    private static final String ACCOUNT_NAME = 'accountName';
    private static final String USER_ID = 'userId';
    private static final String USER_NAME = 'userName';

    private static final Set<String> USER_FIELDS_NAMES = new Set<String>{ 'Id', 'Name', 'ContactId', 'Contact.AccountId', 'Contact.Email', 'Contact.Account.Name', 'LocaleSidKey' };

    @TestVisible
    private static DRB2B_UserSelector userSelector = new DRB2B_UserSelector();

    public DRB2B_CreateCustomerRequestModel getCreateCustomerRequestModel(Id userId) {
        return getCreateCustomerRequestModel(userId, DRB2B_DRApiConstants.CUSTOMER_TYPE_BUSINESS);
    }

    public DRB2B_CreateCustomerRequestModel getCreateCustomerRequestModel(Id userId, String customerType) {
        User user = userSelector.getById(userId, USER_FIELDS_NAMES);
        if (user.ContactId == null) {
            throw new CustomerRequestException(Label.DR_TaxCertificates_UserDoesntHasRelatedContact);
        }

        DRB2B_CreateCustomerRequestModel model = new DRB2B_CreateCustomerRequestModel();
        model.id = user.ContactId;
        model.email = user?.Contact.Email;
        model.locale = user.LocaleSidKey;
        model.type = customerType;
        model.metadata = new Map<String, String>{ USER_ID => user.Id, USER_NAME => user.Name, ACCOUNT_ID => user?.Contact.AccountId, ACCOUNT_NAME => user?.Contact?.Account.Name };

        return model;
    }

    public DRB2B_TaxCertificateModel formatDatetime(DRB2B_TaxCertificateModel taxCertificate) {
        if (String.isNotBlank(taxCertificate.startDate)) {
            Date startDate = Date.valueOf(taxCertificate.startDate);
            Datetime startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
            taxCertificate.startDate = startDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }

        if (String.isNotBlank(taxCertificate.endDate)) {
            Date endDate = Date.valueOf(taxCertificate.endDate);
            Datetime endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());
            taxCertificate.endDate = endDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }

        return taxCertificate;
    }

    private class CustomerRequestException extends Exception {
    }
}
