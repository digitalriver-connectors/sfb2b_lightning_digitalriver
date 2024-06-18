@IsTest
public with sharing class DRB2B_SKUGroupModelTest {
    static testMethod void testParse() {
		String json = '{'+
		'  \"hasMore\": true,'+
		'  \"data\": ['+
		'    {'+
		'      \"id\": \"wireless-keyboards\",'+
		'      \"alias\": \"alias123\"'+
		'    }'+
		'  ]'+
		'}';
		DRB2B_SKUGroupModel obj = DRB2B_SKUGroupModel.parse(json);
		System.assert(obj != null);
	}
}
