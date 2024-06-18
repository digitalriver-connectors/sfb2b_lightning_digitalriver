@IsTest
private class DRB2B_CreateCustomerResponseModelTest {
    static testMethod void testParse() {
        String errorJson =
            '[' +
            '        {' +
            '            \"code\": \"invalid_parameter\",' +
            '            \"parameter\": \"expiresTime\",' +
            '            \"message\": \"Please provide a valid link expiration time in ISO8601 format and UTC timezone\"' +
            '        }' +
            '    ]';

        String json =
            '{' +
            '      \"id\": \"acc_ndeds\",' +
            '      \"email\": \"asoodnd@docmatiosn.com\",' +
            '        \"createdTime\": \"2021-04-22T22:09:31Z\",' +
            '      \"shipping\": {' +
            '        \"address\": {' +
            '        	\"line1\": \"10380 Bren Road West\",' +
            '            \"city\": \"Waconia\",' +
            '            \"postalCode\": \"05387\",' +
            '            \"state\": \"NY\",' +
            '            \"country\": \"US\"' +
            '        },' +
            '        \"name\": \"DR salesforce\",' +
            '        \"phone\": \"952-111-1111\",' +
            '        \"email\": \"salesforceuser@digitalriver.com\",' +
            '        \"organization\": \"DigitalRiver\",' +
            '        \"additionalAddressInfo\": {' +
            '          \"neighborhood\": \"Centro\"' +
            '        }' +
            '      },' +
            '      \"requestToBeForgotten\": true,' +
            '      \"locale\": \"en_US\",' +
            '      \"enabled\": true,' +
            '    \"type\": \"type\",' +
            '    \"errors\":  ' +
            errorJson +
            ',' +
            '      \"isSuccess\": true,' +
            '      \"liveMode\": false' +
            '    }';
        DRB2B_CreateCustomerResponseModel obj = (DRB2B_CreateCustomerResponseModel) System.JSON.deserialize(
            json,
            DRB2B_CreateCustomerResponseModel.class
        );
        System.assert(obj != null);
        System.assert(obj.id != null);
        System.assert(obj.isSuccess != null);
        System.assert(obj.liveMode != null);
        System.assert(obj.locale != null);
        System.assert(obj.email != null);
        System.assert(obj.createdTime != null);
        System.assert(obj.requestToBeForgotten != null);
        System.assert(obj.errors != null);
        System.assert(obj.type != null);
        System.assert(obj.enabled != null);
    }
}
