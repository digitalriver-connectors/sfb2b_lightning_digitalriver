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
private class DRB2B_ErrorResponseTest {
    static testMethod void testParse() {
		String json = '{'+
		'    \"type\": \"bad_request\",'+
		'    \"errors\": ['+
		'        {'+
		'            \"code\": \"invalid_parameter\",'+
		'            \"parameter\": \"taxCode\",'+
		'            \"message\": \"\'95xx.212\' is not a valid Tax Code.\"'+
		'        }'+
		'    ]'+
		'}';
		DRB2B_ErrorResponse obj = DRB2B_ErrorResponse.parse(json);
		System.assert(obj != null);
	}
}
