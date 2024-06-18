public with sharing class DRB2B_ErrorsResponseModel {
    public String type { get; set; }
    public List<DRB2B_ErrorResponseModel> errors { get; set; }

    public static DRB2B_ErrorsResponseModel parse(String json) {
        return (DRB2B_ErrorsResponseModel) System.JSON.deserialize(json, DRB2B_ErrorsResponseModel.class);
    }
}
