@IsTest
private class DRB2B_CreateCustomerModelServiceTest {
    private static final String TEST_COMPANY = 'Test company';
    private static final String TEST_FILE_ID = 'Test file id';

    @isTest
    static void getBCreateCustomerRequestModelTest() {
        //Given
        User user = (User) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'Id' => '00521000007BcYFAA0', 'Name' => 'test', 'ContactId' => '00521000007BcYFCC0', 'LocaleSidKey' => 'en_US' }),
            User.class
        );

        DRB2B_CreateCustomerModelService.userSelector = (DRB2B_UserSelector) Test.createStub(DRB2B_UserSelector.class, new DCM_GenericStubProvider(new Map<String, Object>{ 'getById' => user }));

        //When
        Test.startTest();
        DRB2B_CreateCustomerRequestModel model = new DRB2B_CreateCustomerModelService().getCreateCustomerRequestModel(user.Id);
        Test.stopTest();

        //Then
        System.assert(model != null);
        System.assert(model.id == user.ContactId);
        System.assert(model.type == DRB2B_DRApiConstants.CUSTOMER_TYPE_BUSINESS);
        System.assert(model.locale == user.LocaleSidKey);
    }

    @isTest
    static void formatDatetimeTest() {
        //When
        Test.startTest();
        DRB2B_TaxCertificateModel taxCertificateModel = new DRB2B_CreateCustomerModelService().formatDatetime(getTaxCertificate());
        Test.stopTest();

        //Then
        System.assert(taxCertificateModel != null);
        System.assert(taxCertificateModel.startDate.length() == Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'').length());
        System.assert(taxCertificateModel.endDate.length() == Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'').length());
    }

    private static DRB2B_TaxCertificateModel getTaxCertificate() {
        DRB2B_TaxCertificateModel taxCertificate = new DRB2B_TaxCertificateModel();
        taxCertificate.taxAuthority = 'MN';
        taxCertificate.startDate = Datetime.now().addDays(-10).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        taxCertificate.endDate = Datetime.now().addDays(10).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        taxCertificate.companyName = TEST_COMPANY;
        taxCertificate.fileId = TEST_FILE_ID;
        return taxCertificate;
    }
}
