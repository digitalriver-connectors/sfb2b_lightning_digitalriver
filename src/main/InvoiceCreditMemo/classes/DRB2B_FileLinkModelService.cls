/**
 * @description       : create a request body for file link
 **/
public with sharing class DRB2B_FileLinkModelService {
    public DRB2B_FileLinkModelService() {
    }

    public DRB2B_FileLinkModel.Request getCreateFileLinkRequestModel(String fileID) {
        return getCreateFileLinkRequestModel(fileID, System.now().addMinutes(30));
    }
    public DRB2B_FileLinkModel.Request getCreateFileLinkRequestModel(String fileID, Datetime expiryTime) {
        DRB2B_FileLinkModel.Request fileReq = new DRB2B_FileLinkModel.Request();
        fileReq.fileId = fileID;
        fileReq.expiresTime = expiryTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return fileReq;
    }
}
