public with sharing class DRB2B_AttachCheckoutSourceRequestModel {
    public String id { get; set; }
    public String sourceId { get; set; }

    public DRB2B_AttachCheckoutSourceRequestModel(String id, String sourceId) {
        this.id = id;
        this.sourceId = sourceId;
    }
}
