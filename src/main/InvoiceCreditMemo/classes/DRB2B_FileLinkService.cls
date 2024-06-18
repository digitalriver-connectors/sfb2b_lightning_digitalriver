/**
 * @description       : This class will be responsible to genrate file links
 **/

public with sharing class DRB2B_FileLinkService {
    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();
    @TestVisible
    private static DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
    @TestVisible
    private static DRB2B_FileLinkModelService fileLinkModelService = new DRB2B_FileLinkModelService();

    public DRB2B_FileLinkModel.Response getFileLink(String fileId, String sfOrderId) {
        String webCartId = '';
        if(String.isNotBlank(sfOrderId)){
             webCartId = cartSelector.getBySfOrderId(sfOrderId);
        }
        DRB2B_FileLinkModel.Request fileReqModal = fileLinkModelService.getCreateFileLinkRequestModel(fileId);
        DCM_HttpClient.Response response;
        if(String.isNotBlank(webCartId)){
            response = requestService.getFileLinkRequest(fileReqModal, webCartId).fetch();
        }else{
            response = requestService.getFileLinkRequest(fileReqModal).fetch();
        }
        DRB2B_FileLinkModel.Response apiResponse = (DRB2B_FileLinkModel.Response) response.asType(DRB2B_FileLinkModel.Response.class);
        return apiResponse;
    }
}
