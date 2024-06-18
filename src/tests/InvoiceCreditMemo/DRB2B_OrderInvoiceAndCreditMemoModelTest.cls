@IsTest
private class DRB2B_OrderInvoiceAndCreditMemoModelTest {
    static testMethod void testParse() {
        String json =
            '{' +
            '    \"id\": \"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0\",' +
            '    \"type\": \"order.invoice.created\",' +
            '    \"data\": {' +
            '        \"object\": {' +
            '            \"id\": \"9c163f29-781a-4029-9090-203eb69698c5\",' +
            '            \"fileId\": \"9c163f29-781a-4029-9090-203eb69698c5\",' +
            '            \"orderId\": \"187775330336\",' +
            '            \"customerId\": \"00302000006XaOPAA0\",' +
            '            \"purpose\": \"customer_invoice\",' +
            '            \"invoiceURL\": \"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content\"' +
            '        }' +
            '    },' +
            '    \"liveMode\": false,' +
            '    \"createdTime\": \"2021-04-16T17:00:11.270436Z\",' +
            '    \"versionIds\": []' +
            '}';
        DRB2B_OrderInvoiceAndCreditMemoModel r = DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(json);
        String id = r.id;
        String type = r.type;
        Boolean liveMode = r.liveMode;
        String createdTime = r.createdTime;
        DRB2B_OrderInvoiceAndCreditMemoModel.Data data = r.data;
        DRB2B_OrderInvoiceAndCreditMemoModel.Object_Z Object_Z = r.data.eventData;
        System.assert(r != null);
        System.assert(liveMode != null);
        System.assert(type != null);
        System.assert(createdTime != null);
        System.assert(data != null);
        System.assert(Object_Z != null);
    }

    static testMethod void testNewParse() {
        String json =
            '{' +
            '    \"id\": \"c99cdbda-1510-4cd6-9d91-8d9cd0bb47f0\",' +
            '    \"type\": \"order.invoice.created\",' +
            '    \"data\": {' +
            '        \"object\": {' +
            '            \"id\": \"9c163f29-781a-4029-9090-203eb69698c5\",' +
            '            \"fileId\": \"9c163f29-781a-4029-9090-203eb69698c5\",' +
            '            \"orderId\": \"187775330336\",' +
            '            \"customerId\": \"00302000006XaOPAA0\",' +
            '            \"purpose\": \"customer_invoice\",' +
            '            \"invoiceURL\": \"https://api.digitalriver.com/files/9c163f29-781a-4029-9090-203eb69698c5/content\"' +
            '        }' +
            '    },' +
            '    \"liveMode\": false,' +
            '    \"createdTime\": \"2021-04-16T17:00:11.270436Z\",' +
            '    \"versionIds\": []' +
            '}';
        DRB2B_OrderInvoiceAndCreditMemoModel r = DRB2B_OrderInvoiceAndCreditMemoModel.deserialize(json);
        String stringy = DRB2B_OrderInvoiceAndCreditMemoModel.serialize(r);
        System.assert(stringy != null);
    }
}
