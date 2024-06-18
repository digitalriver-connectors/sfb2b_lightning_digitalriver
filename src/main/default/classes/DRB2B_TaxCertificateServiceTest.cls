@isTest
public with sharing class DRB2B_TaxCertificateServiceTest {
    public DRB2B_TaxCertificateServiceTest() {

    }

    /*input request sample
    * file:this.fileData.base64File,
    * fileName:this.fileData.filename,
    * title:'Tax Certificate',
    * purpose:'tax_document_customer_upload' */
    @isTest
    static void uploadTaxCertificateSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new DRUploadFileSuccessMock());
        Map<string,string> inputMap = new Map<string,string>();

        inputMap.put('file','test');
        inputMap.put('filename','test');
        inputMap.put('title','Tax Certificate');
        inputMap.put('purpose','tax_document_customer_upload');

        //When
        Test.startTest();
        DRB2B_UploadTaxCertificateResponseModel responseModel = DRB2B_UsersTaxCertificatesController.uploadTaxCertificate(JSON.serialize(inputMap), '63646336');
        Test.stopTest();
        system.assertEquals(responseModel.id, '12345');
        system.assertEquals(responseModel.type, 'pdf');
    }

    @isTest
    static void uploadTaxCertificateErrorTest() {
        DRB2B_uploadTaxCertificateRequestModel taxreqModel = new DRB2B_uploadTaxCertificateRequestModel();
        taxreqModel.file = 'txt';
        taxreqModel.fileName = 'fileToUpload';
        taxreqModel.linkExpiresTime = DateTime.now().addDays(2);
        Test.setMock(HttpCalloutMock.class, new DRUploadFileErrorMock());
        Map<string,string> inputMap = new Map<string,string>();

        inputMap.put('file','test');
        inputMap.put('filename','test');
        inputMap.put('title','Tax Certificate');
        inputMap.put('purpose','tax_document_customer_upload');

        //When
        Test.startTest();
        DRB2B_UploadTaxCertificateResponseModel responseModel = DRB2B_UsersTaxCertificatesController.uploadTaxCertificate(JSON.serialize(inputMap), '253636');
        Test.stopTest();
        System.assert(!responseModel.errors.isEmpty());
    }

    private class DRUploadFileSuccessMock extends HttpCalloutMockRouter {
        public DRUploadFileSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'uploadFile',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.FILES,
                DRB2B_DRApiConstants.SUCCESS_STATUS,
                'Created',
                getUploadFileSuccessResponse()
            );
        }
    }

    private class DRUploadFileErrorMock extends HttpCalloutMockRouter {
        public DRUploadFileErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'uploadFile',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.FILES,
                DRB2B_DRApiConstants.ERROR_RESPONSE_CODE,
                'Failed',
                getUploadFileErrorResponse()
            );
        }
    }


    private static DRB2B_UploadTaxCertificateResponseModel getUploadFileSuccessResponse() {
        DRB2B_UploadTaxCertificateResponseModel responseModel = new DRB2B_UploadTaxCertificateResponseModel();
        responseModel.id = '12345';
        responseModel.type = 'pdf';
        responseModel.fileName = 'TEST_FILE';
        return responseModel;
    }

   

    private static DRB2B_UploadTaxCertificateResponseModel getUploadFileErrorResponse() {
        DRB2B_ErrorResponseModel errorResponseModel = new DRB2B_ErrorResponseModel();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_UploadTaxCertificateResponseModel responseModel = new DRB2B_UploadTaxCertificateResponseModel();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponseModel>{ errorResponseModel };
        return responseModel;
    }
}
