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
private class DRB2B_ProductSyncUpsertSkuResponseTest {
    static testMethod void testParse() {
		String json = '{'+
		'    \"id\": \"CsCsssD7\",'+
		'    \"createdTime\": \"2020-07-02T12:03:56Z\",'+
		'    \"name\": \"Enterprise Cloud - 1 User\",'+
		'    \"eccn\": \"EAR99\",'+
		'    \"partNumber\": \"abc12345\",'+
		'    \"updatedTime\": \"2021-04-07T07:24:06Z\",'+
		'    \"taxCode\": \"95.212\",'+
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
		'    \"liveMode\": false,'+
		'    \"physical\": false'+
		'}';
		DRB2B_ProductSyncUpsertSkuResponse obj = DRB2B_ProductSyncUpsertSkuResponse.parse(json);
		System.assert(obj != null);
	}
}
