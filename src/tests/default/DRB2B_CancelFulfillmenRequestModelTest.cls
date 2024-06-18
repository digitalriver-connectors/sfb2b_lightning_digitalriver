@isTest
private with sharing class DRB2B_CancelFulfillmenRequestModelTest {
    static testMethod void testParse() {
        String json =
            '{' +
            '  \"orderId\": \"{{orderId}}\",' +
            '  \"items\":' +
            '    [' +
            '      {' +
            '        \"skuId\": \"{{skuId-P}}\",' +
            '        \"cancelQuantity\": 3' +
            '      }' +
            '    ],' +
            '    \"metadata\": {' +
            '        \"lineItemExtRefID\": \"123456\"' +
            '    },' +
            '    \"trackingCompany\": \"Fedex\",' +
            '    \"trackingNumber\": \"5678901234\",' +
            '    \"trackingUrl\": \"http://www.digitalriver.com?code=5678901234\"' +
            '}';
        DRB2B_CancelFulfillmenRequestModel obj = DRB2B_CancelFulfillmenRequestModel.parse(json);
        System.assert(obj != null);
    }
}
