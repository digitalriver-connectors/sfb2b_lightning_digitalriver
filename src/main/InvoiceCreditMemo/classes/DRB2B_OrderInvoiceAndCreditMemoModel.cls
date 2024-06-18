public with sharing class DRB2B_OrderInvoiceAndCreditMemoModel {
    public String id {get;set;}
	public String type {get;set;}
	public Data data {get;set;}
	public Boolean liveMode {get;set;}
    public String createdTime {get;set;}

    public class Data {
        public Object_Z eventData {get;set;} // in json: object
    }

    public class Object_Z {
        public String id {get;set;}
		public String fileId {get;set;}
		public String orderId {get;set;}
		public String customerId {get;set;}
		public String purpose {get;set;}
        public String invoiceURL {get;set;}
    }

    public static DRB2B_OrderInvoiceAndCreditMemoModel deserialize(String json) {
        return (DRB2B_OrderInvoiceAndCreditMemoModel) System.JSON.deserialize(DRB2B_Utility.modifyJSON(json, new Map<String, String> {'object' => 'eventData'}), DRB2B_OrderInvoiceAndCreditMemoModel.class);
    }

    public static String serialize(DRB2B_OrderInvoiceAndCreditMemoModel orderInvoiceCreatedEvent) {
        return DRB2B_Utility.modifyJSON(System.JSON.serialize(orderInvoiceCreatedEvent), new Map<String, String> {'eventData' => 'object'});
    }
}
