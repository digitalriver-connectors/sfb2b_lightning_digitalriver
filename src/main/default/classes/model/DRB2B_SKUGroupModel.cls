public with sharing class DRB2B_SKUGroupModel {
    public Boolean hasMore;
	public List<Data> data;

	public class Data {
		public String id;
		public String alias;
	}

	public static DRB2B_SKUGroupModel parse(String json) {
		return (DRB2B_SKUGroupModel) System.JSON.deserialize(json, DRB2B_SKUGroupModel.class);
	}
}
