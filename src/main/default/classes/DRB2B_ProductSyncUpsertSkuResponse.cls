/**
 * @description       : 
 * @author            : Arun Sood
 * @group             : 
 * @last modified on  : 04-16-2021
 * @last modified by  : Arun Sood
 * Modifications Log 
 * Ver   Date         Author      Modification
 * 1.0   04-07-2021   Arun Sood   Initial Version
**/
public with sharing class DRB2B_ProductSyncUpsertSkuResponse {
	public Boolean isSuccess;
	
    public class Metadata {
		public String taxType;
		public String taxGroup;
		public String sku;
	}

	public String id;
	public String createdTime;
	public String name;
	public String eccn;
	public String partNumber;
	public String updatedTime;
	public String taxCode;
	public String countryOfOrigin;
	public Metadata metadata;
	public Boolean fulfill;
	public Boolean allowOversell;
	public Boolean liveMode;
	public Boolean physical;
	public Double weight;
	public String weightUnit;
	public String manufacturerId;
	public String managedFulfillment;
	public String skuGroupId;

	public static DRB2B_ProductSyncUpsertSkuResponse parse(String json) {
		return (DRB2B_ProductSyncUpsertSkuResponse) System.JSON.deserialize(json, DRB2B_ProductSyncUpsertSkuResponse.class);
	}
}
