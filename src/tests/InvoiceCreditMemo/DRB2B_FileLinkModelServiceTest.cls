@IsTest
private class DRB2B_FileLinkModelServiceTest {
    @IsTest
    static void getCreateFileLinkRequestModel_Test() {
        Test.startTest();
        DRB2B_FileLinkModel.Request request = new DRB2B_FileLinkModelService().getCreateFileLinkRequestModel('FileId');
        System.assertEquals('FileId', request.fileId, 'File Dose not match');
        Test.stopTest();
    }
}
