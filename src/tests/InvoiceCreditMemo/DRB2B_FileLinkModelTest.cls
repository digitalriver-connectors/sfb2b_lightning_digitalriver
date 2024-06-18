@IsTest
private class DRB2B_FileLinkModelTest {
    private static final String TEST_ID = '111111111111111';
    private static final String DUMMY_URL = 'www.google.com';
    private static final String FILE_TEST_ID = '222222222222';
    private static final String CREATED = 'Created';

    static testMethod void testRequest() {
        DRB2B_FileLinkModel.Request requestData = new DRB2B_FileLinkModelService()
            .getCreateFileLinkRequestModel(TEST_ID, System.now().addMinutes(30));
        String fileId = requestData.fileId;
        String expiresTime = requestData.expiresTime;
        System.assertEquals(TEST_ID, fileId, 'File Dose not match');
        System.assert(expiresTime != null);
    }

    static testMethod void testResponse() {
        String errorJson =
            '[' +
            '        {' +
            '            \"code\": \"invalid_parameter\",' +
            '            \"parameter\": \"expiresTime\",' +
            '            \"message\": \"Please provide a valid link expiration time in ISO8601 format and UTC timezone\"' +
            '        }' +
            '    ]';

        String json =
            '{' +
            '    \"id\": \"b4a1e13e-6003-4984-866d-a440542c985b\",' +
            '    \"createdTime\": \"2021-06-21T11:55:54Z\",' +
            '    \"expired\": true,' +
            '    \"expiresTime\": \"2020-11-26T12:30:25Z\",' +
            '    \"fileId\": \"c939fc0f-b9ae-4b17-a1ba-f86ae46e0c66\",' +
            '    \"liveMode\": false,' +
            '    \"type\": \"type\",' +
            '    \"errors\":  ' +
            errorJson +
            ',' +
            '    \"liveMode\": false,' +
            '    \"url\": \"https://files-test.digitalriver.com/links/b4a1e13e-6003-4984-866d-a440542c985b\"' +
            '}';

        DRB2B_FileLinkModel.Response responseData = (DRB2B_FileLinkModel.Response) System.JSON.deserialize(
            json,
            DRB2B_FileLinkModel.Response.class
        );
        String fileId = responseData.fileId;
        String expiresTime = responseData.expiresTime;
        String id = responseData.id;
        String createdTime = responseData.createdTime;
        String expired = responseData.expired;
        String url = responseData.url;
        String type = responseData.type;
        List<DRB2B_ErrorResponseModel> errors = responseData.errors;
        System.assert(fileId != null);
        System.assert(expiresTime != null);
        System.assert(id != null);
        System.assert(createdTime != null);
        System.assert(url != null);
        System.assert(type != null);
        System.assert(errors != null);
    }
}
