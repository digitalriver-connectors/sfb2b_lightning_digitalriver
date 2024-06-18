/**
 * @description       : 
 * @author            : Arun Sood
 * @group             : 
 * @last modified on  : 04-08-2021
 * @last modified by  : Arun Sood
 * Modifications Log 
 * Ver   Date         Author      Modification
 * 1.0   04-07-2021   Arun Sood   Initial Version
**/
public with sharing class DRB2B_ProductSyncUpsertSkuRequest {
    public String eccn;
	public String countryOfOrigin;
	public String taxCode;
	public String name;
	public String partNumber;
	public Boolean fulfill;
	public String hsCode;
	public Double weight;
	public String weightUnit;
	public String manufacturerId;
	public String managedFulfillment;
	public Metadata metadata;
	public String skuGroupId;
	
	public class Metadata {
		public String taxType;
		public String taxGroup;
		public String sku;
	}

	
	public static DRB2B_ProductSyncUpsertSkuRequest parse(String json) {
		return (DRB2B_ProductSyncUpsertSkuRequest) System.JSON.deserialize(json, DRB2B_ProductSyncUpsertSkuRequest.class);
	}
}
