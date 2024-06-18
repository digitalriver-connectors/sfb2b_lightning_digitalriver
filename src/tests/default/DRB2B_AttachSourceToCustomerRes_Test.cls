@isTest
private with sharing class DRB2B_AttachSourceToCustomerRes_Test {
    static testMethod void testParse() {
		String json = '{'+
		'  \"paymentSessionId\": \"{{checkout_session-id}}\",'+
		'  \"amount\": 20,'+
		'  \"type\": \"customerCredit\",'+
		'  \"upstreamId\": \"custCredit_orderId_16008796\",'+
		'  \"customerCredit\": {},'+
		'  \"owner\": {'+
		'    \"firstName\": \"John\",'+
		'    \"lastName\": \"Smith\",'+
		'    \"email\": \"jsmith@digitalriver.com\",'+
		'    \"organization\": \"Digital River\",'+
		'    \"upstreamId\": \"55129-54673\",'+
		'    \"address\": {'+
		'      \"line1\": \"10380 Bren Rd W\",'+
		'      \"line2\": \"string\",'+
		'      \"city\": \"Minnetonka\",'+
		'      \"postalCode\": \"55129\",'+
		'      \"state\": \"MN\",'+
		'      \"country\": \"US\"'+
		'    },'+
		'    \"additionalAddressInfo\": {'+
		'      \"neighborhood\": \"Centro\",'+
		'      \"division\": \"???\",'+
		'      \"phoneticName\": \"??? ??\"'+
		'    }'+
		'  }'+
		'}';
		DRB2B_AttachSourceToCustomerRes obj = DRB2B_AttachSourceToCustomerRes.parse(json);
		System.assert(obj != null);
	}
}
