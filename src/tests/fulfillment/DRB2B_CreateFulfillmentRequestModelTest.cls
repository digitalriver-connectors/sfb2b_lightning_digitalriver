@IsTest
private with sharing class DRB2B_CreateFulfillmentRequestModelTest {
    static testMethod void testParse() {
        String json =
            '{' +
            '  \"orderId\": \"ord_5678901234\",' +
            '  \"items\": [' +
            '      {' +
            '        \"skuId\": \"sku_9234276173\",' +
            '        \"quantity\": 1' +
            '      }' +
            '  ],' +
            '	\"metadata\": {' +
            '		\"lineItemExtRefID\": \"123456\"' +
            '	},' +
            '  \"trackingCompany\": \"Fedex\",' +
            '  \"trackingNumber\": \"5678901234\",' +
            '  \"trackingUrl\": \"http://www.digitalriver.com?code=5678901234\"' +
            '}';
        DRB2B_CreateFulfillmentRequestModel obj = DRB2B_CreateFulfillmentRequestModel.parse(json);
        System.assert(obj != null);
    }
}
