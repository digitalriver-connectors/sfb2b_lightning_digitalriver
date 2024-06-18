@IsTest
private class DRB2B_OrderResponseModelTest {
    static testMethod void testParse() {
        String json =
            '{' +
            '    \"id\": \"190497460336\",' +
            '    \"createdTime\": \"2021-06-03T13:05:21Z\",' +
            '    \"customerId\": \"0031100001nomZyAAI\",' +
            '    \"drCurrency\": \"USD\",' +
            '    \"email\": \"salesforceuser@digitalriver.com\",' +
            '    \"shipTo\": {' +
            '        \"address\": {' +
            '            \"line1\": \"Clinton Street Moss\",' +
            '            \"city\": \"Urban city and town\",' +
            '            \"postalCode\": \"05387\",' +
            '            \"state\": \"NY\",' +
            '            \"country\": \"US\"' +
            '        },' +
            '        \"name\": \"Store FrontGBP User\",' +
            '        \"phone\": \"8146945130\"' +
            '    },' +
            '    \"shipFrom\": {' +
            '        \"address\": {' +
            '            \"line1\": \"3000 Northwoods Pkwy\",' +
            '            \"line2\": \"Ste 150\",' +
            '            \"city\": \"Urban city and town\",' +
            '            \"postalCode\": \"BB0 1GR\",' +
            '            \"state\": \"LAN\",' +
            '            \"country\": \"GB\"' +
            '        }' +
            '    },' +
            '    \"billTo\": {' +
            '        \"address\": {' +
            '            \"line1\": \"333 Seymour Street (Billing)\",' +
            '            \"city\": \"Vancouver\",' +
            '            \"postalCode\": \"V6B 5A7\",' +
            '            \"state\": \"BC\",' +
            '            \"country\": \"CA\"' +
            '        },' +
            '        \"name\": \"Arun CreatedViaQuickstart\",' +
            '        \"phone\": \"7018260318\",' +
            '        \"email\": \"youremail@domain.com\"' +
            '    },' +
            '    \"totalAmount\": 38.89,' +
            '    \"subtotal\": 38.89,' +
            '    \"totalFees\": 0.0,' +
            '    \"totalTax\": 0.0,' +
            '    \"totalImporterTax\": 0.0,' +
            '    \"totalDuty\": 0.0,' +
            '    \"totalDiscount\": 0.0,' +
            '    \"totalShipping\": 5.95,' +
            '    \"items\": [' +
            '        {' +
            '            \"id\": \"112211840336\",' +
            '            \"skuId\": \"01t1100000D8MNjAAN\",' +
            '            \"amount\": 14.99,' +
            '            \"quantity\": 1,' +
            '            \"state\": \"created\",' +
            '            \"stateTransitions\": {' +
            '                \"created\": \"2021-06-03T13:05:22Z\"' +
            '            },' +
            '            \"subscriptionInfo\": {'+
		    '                \"freeTrial\": false,'+
		    '                \"autoRenewal\": true,'+
		    '                \"terms\": \"Here are the terms\",'+
		    '                \"subscriptionId\": \"123\",'+
		    '                \"billingAgreementId\": \"12323\"'+
		    '            },'+
            '            \"tax\": {' +
            '                \"rate\": 0.0,' +
            '                \"amount\": 0.0' +
            '            },' +
            '            \"importerTax\": {' +
            '                \"amount\": 0.0' +
            '            },' +
            '            \"duties\": {' +
            '                \"amount\": 0.0' +
            '            },' +
            '            \"availableToRefundAmount\": 0.0,' +
            '            \"fees\": {' +
            '                \"amount\": 0.0,' +
            '                \"taxAmount\": 0.0' +
            '            }' +
            '        },' +
            '        {' +
            '            \"id\": \"112211850336\",' +
            '            \"skuId\": \"01t1100000D8MNkAAN\",' +
            '            \"amount\": 17.95,' +
            '            \"quantity\": 1,' +
            '            \"state\": \"created\",' +
            '            \"stateTransitions\": {' +
            '                \"created\": \"2021-06-03T13:05:22Z\"' +
            '            },' +
            '            \"tax\": {' +
            '                \"rate\": 0.0,' +
            '                \"amount\": 0.0' +
            '            },' +
            '            \"importerTax\": {' +
            '                \"amount\": 0.0' +
            '            },' +
            '            \"duties\": {' +
            '                \"amount\": 0.0' +
            '            },' +
            '            \"availableToRefundAmount\": 0.0,' +
            '            \"fees\": {' +
            '                \"amount\": 0.0,' +
            '                \"taxAmount\": 0.0' +
            '            }' +
            '        }' +
            '    ],' +
            '    \"shippingChoice\": {' +
            '        \"amount\": 5.95,' +
            '        \"taxAmount\": 0.0' +
            '    },' +
            '    \"metadata\": {' +
            '        \"cartId\": \"0a663000000CdcmAAC\"' +
            '    },' +
            '    \"updatedTime\": \"2021-06-03T13:05:21Z\",' +
            '    \"locale\": \"en_US\",' +
            '    \"customerType\": \"business\",' +
            '    \"sellingEntity\": {' +
            '        \"id\": \"DR_IRELAND-ENTITY\",' +
            '        \"name\": \"Digital River Ireland Ltd.\"' +
            '    },' +
            '    \"liveMode\": false,' +
            '    \"payment\": {' +
            '        \"charges\": [' +
            '            {' +
            '                \"id\": \"5c90d8ce-5621-41c2-aab8-bb4e9f474c29\",' +
            '                \"createdTime\": \"2021-06-03T13:05:26Z\",' +
            '                \"drCurrency\": \"USD\",' +
            '                \"amount\": 38.89,' +
            '                \"state\": \"capturable\",' +
            '                \"captured\": false,' +
            '                \"refunded\": false,' +
            '                \"sourceId\": \"adb2a8af-8a07-467c-95d1-1bb010f63ef6\",' +
            '                \"type\": \"customer_initiated\"' +
            '            }' +
            '        ],' +
            '        \"sources\": [' +
            '            {' +
            '                \"id\": \"adb2a8af-8a07-467c-95d1-1bb010f63ef6\",' +
            '                \"type\": \"creditCard\",' +
            '                \"amount\": 38.89,' +
            '                \"owner\": {' +
            '                    \"firstName\": \"Arun\",' +
            '                    \"lastName\": \"CreatedViaQuickstart\",' +
            '                    \"email\": \"youremail@domain.com\",' +
            '                    \"address\": {' +
            '                        \"line1\": \"333 Seymour Street (Billing)\",' +
            '                        \"city\": \"Vancouver\",' +
            '                        \"postalCode\": \"V6B 5A7\",' +
            '                        \"state\": \"BC\",' +
            '                        \"country\": \"CA\"' +
            '                    }' +
            '                },' +
            '                \"creditCard\": {' +
            '                    \"brand\": \"MasterCard\",' +
            '                    \"expirationMonth\": 2,' +
            '                    \"expirationYear\": 2056,' +
            '                    \"lastFourDigits\": \"5454\",' +
            '                    \"fundingSource\": \"credit\"' +
            '                },' +
            '        \"payPal\": {' +
            '          \"payerStatus\": \"https://mypage.com/cancel\",' +
            '          \"payerId\": \"payerId",' +
            '            \"token\": \"EC-53H39048EL439164J\",' +
            '            \"returnUrl\": \"https://mypage.com/success\",' +
            '            \"redirectUrl\": \"https://mypage.com/cancel\",' +
            '          \"directDebit\": {' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '          }' +
            '        },' +
            '        \"wireTransfer\": {' +
            '          \"accountHolder\": \"Netgiro Payments AB\",' +
            '          \"bankName\": \"ABN AMRO Bank N.V.\",' +
            '          \"city\": \"Prague\",' +
            '          \"country\": \"ES\",' +
            '          \"referenceId\": \"DR1651067521\",' +
            '          \"accountNumber\": \"0100037259\",' +
            '          \"additionalBankInformation\": \"Codigo de oficina: 0001 Codigo de entidad: 0156 Digitos de control: 09\",' +
            '          \"swiftCode\": \"ES35 0156 0001 0901 0003 7259\"' +
            '        }' +
            '            }' +
            '        ],' +
            '        \"session\": {' +
            '            \"id\": \"cffc81b7-0fdc-4405-aefd-2e76bac183d3\",' +
            '            \"amountContributed\": 38.89,' +
            '            \"amountRemainingToBeContributed\": 0.0,' +
            '            \"state\": \"complete\",' +
            '            \"clientSecret\": \"cffc81b7-0fdc-4405-aefd-2e76bac183d3_e486086d-8538-4764-b17e-b9d9eaaaf6ed\"' +
            '        }' +
            '    },' +
            '    \"state\": \"accepted\",' +
            '    \"stateTransitions\": {' +
            '        \"accepted\": \"2021-06-03T13:05:27Z\"' +
            '    },' +
            '    \"fraudState\": \"passed\",' +
            '    \"fraudStateTransitions\": {' +
            '        \"passed\": \"2021-06-03T13:05:27Z\"' +
            '    },' +
            '    \"requestToBeForgotten\": false,' +
            '    \"capturedAmount\": 0.0,' +
            '    \"cancelledAmount\": 0.0,' +
            '    \"availableToRefundAmount\": 0.0,' +
            '    \"checkoutId\": \"bd4935c0-c145-4666-ab76-17a090ed3962\"' +
            '}';
        DRB2B_OrderResponseModel r = DRB2B_OrderResponseModel.parse(json);
        System.assert(r.items != null);
        System.assert(r.id != null);
        System.assert(r.createdTime != null);
        System.assert(r.capturedAmount != null);
        System.assert(r.customerId != null);
        System.assert(r.drCurrency != null);
        System.assert(r.email != null);
        System.assert(r.shipTo != null);
        System.assert(r.shipFrom != null);
        System.assert(r.billTo != null);
        System.assert(r.totalAmount != null);
        System.assert(r.subtotal != null);
        System.assert(r.totalFees != null);
        System.assert(r.totalDuty != null);
        System.assert(r.totalDiscount != null);
        System.assert(r.totalImporterTax != null);
        System.assert(r.totalShipping != null);
        System.assert(r.totalTax != null);
        System.assert(r.shippingChoice != null);
        System.assert(r.metadata != null);
        System.assert(r.updatedTime != null);
        System.assert(r.locale != null);
        System.assert(r.customerType != null);
        System.assert(r.locale != null);
        System.assert(r.capturedAmount != null);
        System.assert(r.sellingEntity != null);
        System.assert(r.liveMode != null);
        System.assert(r.state != null);
        System.assert(r.payment != null);
        System.assert(r.stateTransitions != null);
        System.assert(r.fraudState != null);
        System.assert(r.fraudStateTransitions != null);
        System.assert(r.requestToBeForgotten != null);
        System.assert(r.cancelledAmount != null);
        System.assert(r.availableToRefundAmount != null);
        System.assert(r.checkoutId != null);

        DRB2B_OrderResponseModel.Payment payment = r.payment;
        System.assert(payment != null);
        System.assert(payment.charges != null);
        System.assert(payment.session != null);
        System.assert(payment.sources != null);
        DRB2B_OrderResponseModel.ImporterTax importerTax = r.items[0].importerTax;
        System.assert(importerTax != null);
        System.assert(importerTax.amount != null);
        DRB2B_OrderResponseModel.BillTo billTo = r.billTo;
        System.assert(billTo != null);
        System.assert(billTo.name != null);
        System.assert(billTo.address != null);
        System.assert(billTo.email != null);
        System.assert(billTo.phone != null);
        DRB2B_OrderResponseModel.ShipTo shipTo = r.shipTo;
        System.assert(shipTo != null);
        System.assert(shipTo.address != null);
        System.assert(shipTo.phone != null);
        System.assert(shipTo.name != null);
        DRB2B_OrderResponseModel.Items items = r.items[0];
        System.assert(items != null);
        System.assert(items.importerTax != null);
        System.assert(items.id != null);
        System.assert(items.skuId != null);
        System.assert(items.amount != null);
        System.assert(items.quantity != null);
        System.assert(items.state != null);
        System.assert(items.stateTransitions != null);
        System.assert(items.tax != null);
        System.assert(items.importerTax != null);
        System.assert(items.duties != null);
        System.assert(items.availableToRefundAmount != null);
        System.assert(items.fees != null);
        DRB2B_OrderResponseModel.Charges charge = r.payment.charges[0];
        System.assert(charge != null);
        System.assert(charge.id != null);
        System.assert(charge.createdTime != null);
        System.assert(charge.drCurrency != null);
        System.assert(charge.state != null);
        System.assert(charge.amount != null);
        System.assert(charge.sourceId != null);
        System.assert(charge.captured != null);
        System.assert(charge.refunded != null);
        System.assert(charge.type != null);
        DRB2B_OrderResponseModel.FraudStateTransitions fraudStateTransitions = r.FraudStateTransitions;
        System.assert(fraudStateTransitions != null);
        System.assert(fraudStateTransitions.passed != null);
        DRB2B_OrderResponseModel.Session session = r.payment.session;
        System.assert(session != null);
        System.assert(session.id != null);
        System.assert(session.amountContributed != null);
        System.assert(session.amountRemainingToBeContributed != null);
        System.assert(session.clientSecret != null);
        System.assert(session.state != null);
        DRB2B_OrderResponseModel deserializeOrder = DRB2B_OrderResponseModel.deserializeOrder(json);
        System.assert(deserializeOrder != null);
        DRB2B_OrderResponseModel.Owner owner = r.payment.sources[0].owner;
        System.assert(owner != null);
        System.assert(owner.email != null);
        System.assert(owner.firstName != null);
        System.assert(owner.lastName != null);
        System.assert(owner.address != null);
        DRB2B_OrderResponseModel.Address address = r.shipFrom.address;
        System.assert(address != null);
        System.assert(address.city != null);
        System.assert(address.state != null);
        System.assert(address.country != null);
        System.assert(address.line1 != null);
        System.assert(address.postalCode != null);
        DRB2B_OrderResponseModel.ShipFrom shipFrom = r.shipFrom;
        System.assert(shipFrom != null);
        System.assert(shipFrom.address != null);
        DRB2B_OrderResponseModel.StateTransitions stateTransitions = r.stateTransitions;
        System.assert(stateTransitions != null);
        System.assert(stateTransitions.accepted != null);
        DRB2B_OrderResponseModel.Metadata metadata = r.metadata;
        System.assert(metadata != null);
        System.assert(metadata.cartId != null);
        DRB2B_OrderResponseModel.Tax tax = r.items[0].tax;
        System.assert(tax != null);
        System.assert(tax.rate != null);
        System.assert(tax.amount != null);
        DRB2B_OrderResponseModel.Sources source = r.payment.sources[0];
        System.assert(source != null);
        System.assert(source.id != null);
        System.assert(source.owner != null);
        System.assert(source.type != null);
        System.assert(source.amount != null);
        System.assert(source.creditCard != null);
        System.assert(source.wireTransfer != null);
        System.assert(source.payPal != null);
        DRB2B_OrderResponseModel.CreditCard creditCard = r.payment.sources[0].CreditCard;
        System.assert(creditCard != null);
        System.assert(creditCard.brand != null);
        System.assert(creditCard.expirationMonth != null);
        System.assert(creditCard.expirationYear != null);
        System.assert(creditCard.fundingSource != null);
        System.assert(creditCard.lastFourDigits != null);
        DRB2B_OrderResponseModel.Fees fees = r.items[0].fees;
        System.assert(fees != null);
        System.assert(fees.amount != null);
        System.assert(fees.taxAmount != null);
        DRB2B_OrderResponseModel.SellingEntity sellingEntity = r.sellingEntity;
        System.assert(sellingEntity != null);
        System.assert(sellingEntity.id != null);
        System.assert(sellingEntity.name != null);
        DRB2B_OrderResponseModel.PayPal payPal = r.payment.sources[0].PayPal;
        System.assert(payPal != null);
        System.assert(payPal.payerStatus != null);
        System.assert(payPal.payerId != null);
        System.assert(payPal.redirectUrl != null);
        System.assert(payPal.returnUrl != null);
        System.assert(payPal.token != null);
        DRB2B_OrderResponseModel.WireTransfer wireTransfer = r.payment.sources[0].WireTransfer;
        System.assert(wireTransfer != null);
        System.assert(wireTransfer.bankName != null);
        System.assert(wireTransfer.accountHolder != null);
        System.assert(wireTransfer.city != null);
        System.assert(wireTransfer.accountNumber != null);
        System.assert(wireTransfer.referenceId != null);
        System.assert(wireTransfer.swiftCode != null);

        DRB2B_OrderResponseModel.SubscriptionInfo itemSubscriptionInfo = r.items.get(0).subscriptionInfo;
        System.assert(itemSubscriptionInfo.autoRenewal != null);
        System.assert(itemSubscriptionInfo.billingAgreementId != null);
        System.assert(itemSubscriptionInfo.freeTrial != null);
        System.assert(itemSubscriptionInfo.subscriptionId != null);
        System.assert(itemSubscriptionInfo.terms != null);
    }
}
