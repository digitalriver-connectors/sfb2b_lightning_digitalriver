/**
 * @description       : 
 * @author            : Arun Sood
 * @group             : 
 * @last modified on  : 04-07-2021
 * @last modified by  : Arun Sood
 * Modifications Log 
 * Ver   Date         Author      Modification
 * 1.0   04-07-2021   Arun Sood   Initial Version
**/
@isTest
private class  DRB2B_ProductSyncUpsertSkuRequestTest {
    static testMethod void testParse() {
		String json = '{'+
		'    \"id\": \"sku_5e372da0-79b0-488e-b5f5-100ddf905d66\",'+
		'    \"createdTime\": \"2020-09-07T15:04:54Z\",'+
		'    \"name\": \"Splendid Test\",'+
		'    \"eccn\": \"6E992\",'+
		'    \"partNumber\": \"abc12345\",'+
		'    \"taxCode\": \"601410\",'+
		'    \"countryOfOrigin\": \"US\",'+
		'    \"manufacturerId\": \"654123\",'+
		'    \"managedFulfillment\": \"DRGlobalFulfillment\",'+
		'    \"weight\": 20.5,'+
		'    \"weightUnit\": \"oz\",'+
		'    \"metadata\": {'+
		'        \"taxType\": \"Video Game Consoles and Accessories\",'+
		'        \"taxGroup\": \"Physical Goods\",'+
		'        \"sku\": \"SPL-DRK-Test\"'+
		'    },'+
		'    \"fulfill\": false,'+
		'    \"allowOversell\": true,'+
		'    \"liveMode\": false'+
		'}';
		DRB2B_ProductSyncUpsertSkuRequest obj = DRB2B_ProductSyncUpsertSkuRequest.parse(json);
		System.assert(obj != null);
	}
}
