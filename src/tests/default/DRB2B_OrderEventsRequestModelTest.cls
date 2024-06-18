@Istest
private with sharing class DRB2B_OrderEventsRequestModelTest {
    static testMethod void testParse() {
        String json =
            '{' +
            '    \"id\": \"da137ef4-3744-4ac2-8c92-3859d16f6476\",' +
            '    \"type\": \"order.accepted\",' +
            '    \"data\": {' +
            '        \"order\": {' +
            '            \"id\": \"179747240336\",' +
            '            \"createdTime\": \"2020-08-12T06:22:39Z\",' +
            '            \"customerId\": \"0034R00003KcCvXQAV\",' +
            '            \"drCurrency\": \"USD\",' +
            '            \"email\": \"storefront@gmail.com\",' +
            '            \"shipTo\": {' +
            '                \"address\": {' +
            '                    \"line1\": \"new Back\",' +
            '                    \"city\": \"Wanocia\",' +
            '                    \"postalCode\": \"05397\",' +
            '                    \"state\": \"NY\",' +
            '                    \"country\": \"US\"' +
            '                },' +
            '                \"name\": \"StorefrontUser\",' +
            '                \"phone\": \"98765442310\"' +
            '            },' +
            '            \"shipFrom\": {' +
            '                \"address\": {' +
            '                    \"line1\": \"3000 Northwoods Pkwy\",' +
            '                    \"line2\": \"Ste 150\",' +
            '                    \"city\": \"Eden Prairie\",' +
            '                    \"postalCode\": \"55344\",' +
            '                    \"state\": \"Minnesota\",' +
            '                    \"country\": \"US\"' +
            '                }' +
            '            },' +
            '            \"totalAmount\": 9.0,' +
            '            \"subtotal\": 9.0,' +
            '            \"totalFees\": 0.0,' +
            '            \"totalTax\": 0.0,' +
            '            \"totalDuty\": 0.0,' +
            '            \"totalDiscount\": 0.0,' +
            '            \"totalShipping\": 0.0,' +
            '            \"items\": [' +
            '                {' +
            '                    \"id\": \"99268780336\",' +
            '                    \"skuId\": \"a1F4R000005ycAsUAI\",' +
            '                    \"amount\": 9.0,' +
            '                    \"quantity\": 1,' +
            '                    \"metadata\": {' +
            '                        \"skuId\": \"SS-DR-BB\",' +
            '                        \"cartItemId\": \"a0F4R00002LjuZ5UAJ\"' +
            '                    },' +
            '                    \"state\": \"created\",' +
            '                    \"stateTransitions\": {' +
            '                        \"created\": \"2020-08-12T06:22:39Z\"' +
            '                    },' +
            '                    \"tax\": {' +
            '                        \"rate\": 0.0,' +
            '                        \"amount\": 0.0' +
            '                    },' +
            '                    \"availableToRefundAmount\": 0.0' +
            '                }' +
            '            ],' +
            '            \"metadata\": {' +
            '                \"cartId\": \"a0G4R00001eKotTUAS\",' +
            '                \"sfOrderId\": \"8013F000001TBazQAG\"' +
            '            },' +
            '            \"updatedTime\": \"2020-08-12T06:22:39Z\",' +
            '            \"locale\": \"en_US\",' +
            '            \"customerType\": \"business\",' +
            '            \"paymentSessionId\": \"f310113a-8f1c-42bb-9920-29705451f2e5\",' +
            '            \"sellingEntity\": {' +
            '                \"id\": \"DR_INC-ENTITY\",' +
            '                \"name\": \"Digital River Inc.\"' +
            '            },' +
            '            \"state\": \"accepted\",' +
            '            \"stateTransitions\": {' +
            '                \"accepted\": \"2020-08-12T06:22:41Z\"' +
            '            },' +
            '            \"fraudState\": \"passed\",' +
            '            \"fraudStateTransitions\": {' +
            '                \"passed\": \"2020-08-12T06:22:41Z\"' +
            '            },' +
            '            \"charges\": [' +
            '                {' +
            '                    \"id\": \"babebb92-ba9b-4702-9fbb-5acf8c5ccda4\",' +
            '                    \"createdTime\": \"2020-08-12T06:22:41Z\",' +
            '                    \"drCurrency\": \"USD\",' +
            '                    \"amount\": 9.0,' +
            '                    \"state\": \"capturable\",' +
            '                    \"captured\": false,' +
            '                    \"refunded\": false,' +
            '                    \"sourceId\": \"e016f5e5-ee96-4a45-8e3d-d15d0d4a2db2\"' +
            '                }' +
            '            ],' +
            '            \"requestToBeForgotten\": false,' +
            '            \"capturedAmount\": 0.0,' +
            '            \"cancelledAmount\": 0.0,' +
            '            \"availableToRefundAmount\": 0.0,' +
            '            \"liveMode\": false' +
            '        }' +
            '    },' +
            '    \"digitalRiverVersion\": \"2020-01-07\",' +
            '    \"liveMode\": false,' +
            '    \"createdTime\": \"2020-08-12T06:22:47.419Z\"' +
            '}';

        DRB2B_OrderEventsRequestModel orderEventRequestWrapper = (DRB2B_OrderEventsRequestModel) DRB2B_OrderEventsRequestModel.parse(
            json
        );
        DRB2B_OrderEventsRequestModel.Order orderEventRequestWrapper1 = (DRB2B_OrderEventsRequestModel.Order) DRB2B_OrderEventsRequestModel.parseOrder(
            json
        );
        DRB2B_OrderEventsRequestModel orderEventRequestWrapper2 = (DRB2B_OrderEventsRequestModel) DRB2B_OrderEventsRequestModel.deserializeEvent(
            json
        );
        DRB2B_OrderEventsRequestModel.ConvertFromCheckoutRequest convertCheckout = new DRB2B_OrderEventsRequestModel.ConvertFromCheckoutRequest(
            'tet63636'
        );
        DRB2B_OrderEventsRequestModel.Details details = new DRB2B_OrderEventsRequestModel.Details();
        DRB2B_OrderEventsRequestModel.Duties duties = new DRB2B_OrderEventsRequestModel.Duties();
        DRB2B_OrderEventsRequestModel.Fees fees = new DRB2B_OrderEventsRequestModel.Fees();
        System.assert(details != null);
        System.assert(duties != null);
        System.assert(fees != null);

        String drOrderId = orderEventRequestWrapper.data.order.id;
        List<DRB2B_OrderEventsRequestModel.Item> drOrderItem = orderEventRequestWrapper.data.order.items;
        List<DRB2B_OrderEventsRequestModel.Charges> drChagres = orderEventRequestWrapper.data.order.charges;
        System.assertEquals('179747240336', drOrderId);

        DRB2B_OrderEventsRequestModel.Order objObject_Z = orderEventRequestWrapper.data.order;
        DRB2B_OrderEventsRequestModel.Address address = orderEventRequestWrapper.data.order.shipFrom.address;
        DRB2B_OrderEventsRequestModel.StateTransitions stateTransitions = orderEventRequestWrapper.data.order.stateTransitions;
        DRB2B_OrderEventsRequestModel.ShipTo shipTo = orderEventRequestWrapper.data.order.shipTo;
        System.assert(stateTransitions.accepted != null);
        System.assert(orderEventRequestWrapper.data.order.metadata.cartId != null);
        System.assert(orderEventRequestWrapper.data.order.metadata.sfOrderId != null);
        System.assert(orderEventRequestWrapper.data.order.fraudStateTransitions.passed != null);
        System.assert(orderEventRequestWrapper.data.order.sellingEntity.name != null);
        System.assert(orderEventRequestWrapper.data.order.sellingEntity.id != null);
        for (DRB2B_OrderEventsRequestModel.Item item : drOrderItem) {
            System.assert(item.amount != null);
            System.assert(item.availableToRefundAmount != null);
            System.assert(item.id != null);
            System.assert(item.quantity != null);
            System.assert(item.skuId != null);
            System.assert(item.state != null);
            System.assert(item.stateTransitions != null);
            System.assert(item.tax != null);
            System.assert(item.tax.amount != null);
            System.assert(item.tax.rate != null);
        }
        for (DRB2B_OrderEventsRequestModel.Charges charge : drChagres) {
            System.assert(charge.state != null);
            System.assert(charge.id != null);
            System.assert(charge.drCurrency != null);
            System.assert(charge.createdTime != null);
            System.assert(charge.captured != null);
            System.assert(charge.amount != null);
            System.assert(charge.refunded != null);
            System.assert(charge.sourceId != null);
        }
        System.assert(address.city != null);
        System.assert(address.country != null);
        System.assert(address.line1 != null);
        System.assert(address.line2 != null);
        System.assert(address.postalCode != null);
        System.assert(address.state != null);
        System.assert(shipTo.address != null);
        System.assert(shipTo.name != null);
        System.assert(shipTo.phone != null);

        System.assert(objObject_Z != null);
        System.assert(objObject_Z.id != null);
        System.assert(objObject_Z.createdTime != null);
        System.assert(objObject_Z.customerId != null);
        System.assert(objObject_Z.drCurrency != null);
        System.assert(objObject_Z.email != null);
        System.assert(objObject_Z.shipTo != null);
        System.assert(objObject_Z.shipFrom != null);
        System.assert(objObject_Z.totalAmount != null);
        System.assert(objObject_Z.subtotal != null);
        System.assert(objObject_Z.totalFees != null);
        System.assert(objObject_Z.totalTax != null);
        System.assert(objObject_Z.totalDuty != null);
        System.assert(objObject_Z.totalDiscount != null);
        System.assert(objObject_Z.totalShipping != null);
        System.assert(objObject_Z.items != null);
        System.assert(objObject_Z.metadata != null);
        System.assert(objObject_Z.updatedTime != null);
        System.assert(objObject_Z.locale != null);
        System.assert(objObject_Z.customerType != null);
        System.assert(objObject_Z.paymentSessionId != null);
        System.assert(objObject_Z.sellingEntity != null);
        System.assert(objObject_Z.state != null);
        System.assert(objObject_Z.stateTransitions != null);
        System.assert(objObject_Z.fraudState != null);
        System.assert(objObject_Z.fraudStateTransitions != null);
        System.assert(objObject_Z.charges != null);
        System.assert(objObject_Z.requestToBeForgotten != null);
        System.assert(objObject_Z.capturedAmount != null);
        System.assert(objObject_Z.cancelledAmount != null);
        System.assert(objObject_Z.availableToRefundAmount != null);
        System.assert(objObject_Z.liveMode != null);
    }
}
