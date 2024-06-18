@isTest
private with sharing class DRB2B_updateCheckoutRequestModelTest {
    static testMethod void testParse() {
        String json = '{'+
		'    \"chargeType\": \"customer_initiated\",'+
		'    \"browserIp\": \"10.1.23.21\",'+
		'    \"upstreamId\": \"d1a22e85-abf2-4780-9f7f-0eb4dc4403ed\",'+
		'    \"customerType\": \"business\",'+
		'    \"email\": \"salesforceuser@digitalriver.com\",'+
		'    \"customerId\": \"0034R00003PzJ0QQAV\",'+
		'    \"drCurrency\": \"USD\",'+
		'    \"locale\": \"en_US\",'+
		'    \"sourceId\": \"\",'+
		'    \"taxIdentifiers\": [],'+
		'    \"shipFrom\": {'+
		'        \"address\": {'+
		'            \"line1\": \"Via Nazario Sauro 89\",'+
		'            \"line2\": \"Schilizzi 106\",'+
		'            \"postalCode\": \"90017\",'+
		'            \"country\": \"US\",'+
		'            \"city\": \"Los Angeles\",'+
		'            \"state\": \"California\"'+
		'        }'+
		'    },'+
		'    \"shippingChoice\": {'+
		'        \"amount\": 10'+
		'    },'+
		'    \"shipTo\": {'+
		'        \"phone\": \"98765442310\",'+
		'        \"name\": \"DR Storfront\",'+
		'        \"email\": \"salesforceuser@digitalriver.com\",'+
		'        \"organization\": \"Digital River\",'+
		'        \"address\": {'+
		'            \"line1\": \"Front office\",'+
		'            \"postalCode\": \"6030\",'+
		'            \"country\": \"CH\",'+
		'            \"city\": \"Toronto\"'+
		'        }'+
		'    },'+
		'    \"billTo\": {'+
		'        \"phone\": \"98765442310\",'+
		'        \"name\": \"DR Storfront\",'+
		'        \"email\": \"salesforceuser@digitalriver.com\",'+
		'        \"organization\": \"Digital River\",'+
		'        \"address\": {'+
		'            \"line1\": \"Front office\",'+
		'            \"postalCode\": \"6030\",'+
		'            \"country\": \"CH\",'+
		'            \"city\": \"Toronto\"'+
		'        }'+
		'    },'+
		'    \"items\": ['+
		'        {'+
		'            \"subscriptionInfo\": {'+
		'                \"freeTrial\": false,'+
		'                \"autoRenewal\": true,'+
		'                \"terms\": \"Here are the terms\",'+
		'                \"subscriptionId\": \"123\",'+
		'                \"billingAgreementId\": \"12323\"'+
		'            },'+
		'            \"metadata\": {'+
		'            }'+
		'        }'+
		'    ]'+
		'}';
        DRB2B_updateCheckoutRequestModel rr = new DRB2B_updateCheckoutRequestModel();
        DRB2B_updateCheckoutRequestModel r = DRB2B_updateCheckoutRequestModel.parse(json);
        System.assert(r != null);
        System.assert(r.billTo != null);
        System.assert(r.shipFrom != null);
        System.assert(r.shipTo != null);
        System.assert(r.sourceId != null);
        System.assert(r.chargeType != null);
        System.assert(r.browserIp != null);
        System.assert(r.upstreamId != null);
        System.assert(r.customerType != null);
        System.assert(r.email != null);
        System.assert(r.customerId != null);
        System.assert(r.drCurrency != null);
        System.assert(r.locale != null);
        System.assert(r.taxIdentifiers != null);
        System.assert(r.shippingChoice != null);
        System.assert(r.items != null);
        System.assert(r.items != null);
        DRB2B_updateCheckoutRequestModel.Address address = r.shipFrom.address;
        System.assert(address != null);
        System.assert(address.city != null);
        System.assert(address.state != null);
        System.assert(address.country != null);
        System.assert(address.line1 != null);
        System.assert(address.postalCode != null);
        DRB2B_updateCheckoutRequestModel.ShipFrom shipFromAddresss = new DRB2B_updateCheckoutRequestModel.ShipFrom(
            address
        );
        DRB2B_Address drAddress = new DRB2B_Address();
        drAddress.city = 'NY City';
        drAddress.country = 'US';
        drAddress.postalCode = '03663';
        drAddress.state = 'NY';
        drAddress.line1 = '123 bank';
        System.assert(drAddress != null);
        System.assert(drAddress.city != null);
        System.assert(drAddress.state != null);
        System.assert(drAddress.country != null);
        System.assert(drAddress.line1 != null);
        System.assert(drAddress.postalCode != null);
        DRB2B_updateCheckoutRequestModel.ShipFrom shipFromAddress = new DRB2B_updateCheckoutRequestModel.ShipFrom(
            drAddress
        );
        DRB2B_updateCheckoutRequestModel.ShippingChoice shippingChoice = r.shippingChoice;
        System.assert(shippingChoice != null);
        System.assert(shippingChoice.amount != null);

        DRB2B_updateCheckoutRequestModel.ShipTo shipTo = r.shipTo;
        System.assert(shipTo != null);
        System.assert(shipTo.address != null);
        System.assert(shipTo.email != null);
        System.assert(shipTo.name != null);
        System.assert(shipTo.organization != null);
        System.assert(shipTo.phone != null);

        DRB2B_updateCheckoutRequestModel.BillTo billTo = r.billTo;
        System.assert(billTo != null);
        System.assert(billTo.address != null);
        System.assert(billTo.email != null);
        System.assert(billTo.name != null);
        System.assert(billTo.organization != null);
        System.assert(billTo.phone != null);

        DRB2B_updateCheckoutRequestModel.SubscriptionInfo itemSubscriptionInfo = r.items.get(0).subscriptionInfo;
        System.assert(itemSubscriptionInfo.autoRenewal != null);
        System.assert(itemSubscriptionInfo.billingAgreementId != null);
        System.assert(itemSubscriptionInfo.freeTrial != null);
        System.assert(itemSubscriptionInfo.subscriptionId != null);
        System.assert(itemSubscriptionInfo.terms != null);
    }
}
