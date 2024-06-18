@IsTest
private with sharing class DRB2B_CreateFulfillmentResponseModelTest {
    static testMethod void testParse() {
        String json =
            '{' +
            '  \"createdTime\": \"2021-05-24T09:42:48Z\",' +
            '  \"id\": \"ful_f7f57990-d729-43af-aa9f-7a64654a6e62\",' +
            '  \"items\": [' +
            '    {' +
            '      \"cancelQuantity\": 1,' +
            '      \"itemId\": \"111555950336\",' +
            '      \"skuId\": \"a1F4R000009dZkFUAU\",' +
            '      \"quantity\": 0' +
            '    },' +
            '    {' +
            '      \"cancelQuantity\": 1,' +
            '      \"itemId\": \"111555960336\",' +
            '      \"skuId\": \"a1F4R00000Bflv1UAB\",' +
            '      \"quantity\": 0' +
            '    }' +
            '  ],' +
            '  \"liveMode\": false,' +
            '  \"orderId\": \"189903910336\",' +
            '  \"metadata\": {' +
            '    \"lineItemExtRefID\": null' +
            '  }' +
            '}';
        DRB2B_CreateFulfillmentResponseModel obj = DRB2B_CreateFulfillmentResponseModel.parse(json);
        System.assert(obj != null);
    }
}
