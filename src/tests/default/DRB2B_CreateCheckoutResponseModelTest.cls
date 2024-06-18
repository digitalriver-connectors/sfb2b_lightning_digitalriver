@isTest
private with sharing class DRB2B_CreateCheckoutResponseModelTest {
    static testMethod void testParse() {
        String json =
            '{' +
            '  \"id\": \"5823594809\",' +
            '  \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '  \"updatedTime\": \"2018-04-25T20:36:00Z\",' +
            '  \"customerId\": \"cus_5774321009\",' +
            '  \"drCurrency\": \"USD\",' +
            '  \"email\": \"jsmith@digitalriver.com\",' +
            '  \"locale\": \"en_US\",' +
            '  \"browserIp\": \"111.111.111.111\",' +
            '  \"applicationId\": \"68f72e0c-cb7d-48e1-93c8-998668ad0ff4\",' +
            '  \"shipFrom\": {' +
            '    \"address\": {' +
            '      \"line1\": \"10380 Bren Rd W\",' +
            '      \"line2\": \"string\",' +
            '      \"city\": \"Minnetonka\",' +
            '      \"postalCode\": \"55129\",' +
            '      \"state\": \"MN\",' +
            '      \"country\": \"US\"' +
            '    },' +
            '    \"additionalAddressInfo\": {' +
            '      \"neighborhood\": \"Centro\",' +
            '      \"division\": \"Test Division\",' +
            '      \"phoneticName\": \"Test Phonetic name\"' +
            '    }' +
            '  },' +
            '  \"shipTo\": {' +
            '    \"address\": {' +
            '      \"line1\": \"10380 Bren Rd W\",' +
            '      \"line2\": \"string\",' +
            '      \"city\": \"Minnetonka\",' +
            '      \"postalCode\": \"55129\",' +
            '      \"state\": \"MN\",' +
            '      \"country\": \"US\"' +
            '    },' +
            '    \"name\": \"John Smith\",' +
            '    \"phone\": \"952-111-1111\",' +
            '    \"email\": \"jsmith@digitalriver.com\",' +
            '    \"organization\": \"Digital River\",' +
            '    \"additionalAddressInfo\": {' +
            '      \"neighborhood\": \"Centro\",' +
            '      \"division\": \"Test Division\",' +
            '      \"phoneticName\": \"Test Phonetic name\"' +
            '    }' +
            '  },' +
            '  \"billTo\": {' +
            '    \"address\": {' +
            '      \"line1\": \"10380 Bren Rd W\",' +
            '      \"line2\": \"string\",' +
            '      \"city\": \"Minnetonka\",' +
            '      \"postalCode\": \"55129\",' +
            '      \"state\": \"MN\",' +
            '      \"country\": \"US\"' +
            '    },' +
            '    \"name\": \"John Smith\",' +
            '    \"phone\": \"952-111-1111\",' +
            '    \"email\": \"jsmith@digitalriver.com\",' +
            '    \"organization\": \"Digital River\",' +
            '    \"additionalAddressInfo\": {' +
            '      \"neighborhood\": \"Centro\",' +
            '      \"division\": \"Test Division\",' +
            '      \"phoneticName\": \"Test Phonetic name\"' +
            '    }' +
            '  },' +
            '  \"subtotal\": 1094.5,' +
            '  \"totalTax\": 82.76,' +
            '  \"totalImporterTax\": 82.76,' +
            '  \"importerOfRecordTax\": true,' +
            '  \"totalFees\": 0,' +
            '  \"totalDuty\": 0,' +
            '  \"totalDiscount\": 0,' +
            '  \"totalShipping\": 5.76,' +
            '  \"totalAmount\": 1180.26,' +
            '  \"discount\": {' +
            '    \"amountOff\": 5.95,' +
            '    \"percentOff\": 100,' +
            '    \"quantity\": 1' +
            '  },' +
            '  \"taxIdentifiers\": [' +
            '    {' +
            '      \"id\": \"5774321009\",' +
            '      \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '      \"customerId\": \"5774321009\",' +
            '      \"type\": \"de\",' +
            '      \"value\": \"DE123456789\",' +
            '      \"state\": \"pending\",' +
            '      \"stateTransitions\": \"pending\",' +
            '      \"verifiedName\": \".\",' +
            '      \"verifiedAddress\": \".\",' +
            '      \"updatedTime\": \"2018-04-25T20:36:00Z\"' +
            '    }' +
            '  ],' +
            '  \"purchaseLocation\": {' +
            '    \"country\": \"US\",' +
            '    \"state\": \"MN\",' +
            '    \"postalCode\": \"55364\"' +
            '  },' +
            '  \"customerType\": \"individual\",' +
            '  \"sellingEntity\": {' +
            '    \"id\": \"C5_INC-ENTITY\",' +
            '    \"name\": \"DR globalTech Inc.\"' +
            '  },' +
            '  \"items\": [' +
            '    {' +
            '      \"id\": \"100067660336\",' +
            '      \"skuId\": \"sku_5823594809\",' +
            '      \"subscriptionInfo\": {' +
            '        \"freeTrial\": true,' +
            '        \"autoRenewal\": true,' +
            '        \"terms\": \"Please accept these terms.\",' +
            '        \"subscriptionId\": \"665430999\",' +
            '        \"billingAgreementId\": \"cfeba2ac-d532-49e4-99f4-7a433507facf\",' +
            '        \"startTime\": \"2020-05-21T00:00:00-05:00\",' +
            '        \"endTime\": \"2021-05-20T11:59:59-05:00\"' +
            '      },' +
            '      \"fees\": {' +
            '        \"details\": [' +
            '          {' +
            '            \"type\": \"battery\",' +
            '            \"amount\": 3,' +
            '            \"perUnitAmount\": 1.5,' +
            '            \"id\": \"asdkj1h239lkj123j9123\"' +
            '          }' +
            '        ],' +
            '        \"amount\": 4.5,' +
            '        \"taxAmount\": 1.2' +
            '      },' +
            '      \"quantity\": 2,' +
            '      \"amount\": 18.58,' +
            '      \"availableToRefundAmount\": 18.58,' +
            '      \"tax\": {' +
            '        \"rate\": 0.0675,' +
            '        \"amount\": 89' +
            '      },' +
            '      \"importerTax\": {' +
            '        \"amount\": 12.34' +
            '      },' +
            '      \"duties\": {' +
            '        \"amount\": 12.34' +
            '      },' +
            '      \"discount\": {' +
            '        \"amountOff\": 5.95,' +
            '        \"percentOff\": 100,' +
            '        \"quantity\": 1' +
            '      },' +
            '      \"shipFrom\": {' +
            '        \"address\": {' +
            '          \"line1\": \"10380 Bren Rd W\",' +
            '          \"line2\": \"string\",' +
            '          \"city\": \"Minnetonka\",' +
            '          \"postalCode\": \"55129\",' +
            '          \"state\": \"MN\",' +
            '          \"country\": \"US\"' +
            '        },' +
            '        \"additionalAddressInfo\": {' +
            '          \"neighborhood\": \"Centro\",' +
            '          \"division\": \"Test Division\",' +
            '          \"phoneticName\": \"Test Phonetic Name\"' +
            '        }' +
            '      },' +
            '      \"metadata\": {' +
            '        \"coupon\": \"iOS\"' +
            '      }' +
            '    }' +
            '  ],' +
            '  \"shippingChoice\": {' +
            '    \"amount\": 5.95,' +
            '    \"taxAmount\": 0.1,' +
            '    \"description\": \"USPS: Priority (1 day delivery)\",' +
            '    \"serviceLevel\": \"Standard Ground\"' +
            '  },' +
            '  \"payment\": {' +
            '    \"sources\": [' +
            '      {' +
            '        \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '        \"clientSecret\": \"52199c06-b261-4786-8609-d0a84185a0d2_2b72614b-77f6-4801-bd48-8982e314fdd5\",' +
            '        \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '        \"type\": \"creditCard\",' +
            '        \"drCurrency\": \"USD\",' +
            '        \"amount\": 1180.26,' +
            '        \"reusable\": true,' +
            '        \"owner\": {' +
            '          \"firstName\": \"John\",' +
            '          \"lastName\": \"Smith\",' +
            '          \"email\": \"jsmith@digitalriver.com\",' +
            '          \"organization\": \"Digital River\",' +
            '          \"upstreamId\": \"55129-54673\",' +
            '          \"address\": {' +
            '            \"line1\": \"10380 Bren Rd W\",' +
            '            \"line2\": \"string\",' +
            '            \"city\": \"Minnetonka\",' +
            '            \"postalCode\": \"55129\",' +
            '            \"state\": \"MN\",' +
            '            \"country\": \"US\"' +
            '          },' +
            '          \"additionalAddressInfo\": {' +
            '            \"neighborhood\": \"Centro\",' +
            '            \"division\": \"Test Division\",' +
            '            \"phoneticName\": \"Test Phonetic Name\"' +
            '          }' +
            '        },' +
            '        \"creditCard\": {' +
            '          \"lastFourDigits\": \"3119\",' +
            '          \"expirationMonth\": 3,' +
            '          \"expirationYear\": 2023,' +
            '          \"fundingSource\": \"Visa\",' +
            '          \"brand\": \"Visa\"' +
            '        },' +
            '        \"googlePay\": {' +
            '          \"lastFourDigits\": \"3119\",' +
            '          \"expirationMonth\": 2,' +
            '          \"expirationYear\": 2022,' +
            '          \"brand\": \"Visa\"' +
            '        },' +
            '        \"payPal\": {' +
            '          \"redirect\": {' +
            '            \"redirectUrl\": \"https://api.digitalriver.com:443/payments/redirects/e626ec65-24d6-46fb-b632-10b90f4c4912?apiKey=pk_test_6cb0fe9ce3124093a9ad906f6c589e2d\",' +
            '            \"returnUrl\": \"https://mypage.com/success\",' +
            '            \"cancelUrl\": \"https://mypage.com/cancel\"' +
            '          },' +
            '          \"directDebit\": {' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '          }' +
            '        },' +
            '        \"payPalBilling\": {' +
            '          \"redirect\": {' +
            '            \"redirectUrl\": \"https://api.digitalriver.com:443/payments/redirects/e626ec65-24d6-46fb-b632-10b90f4c4912?apiKey=pk_test_6cb0fe9ce3124093a9ad906f6c589e2d\",' +
            '            \"returnUrl\": \"https://mypage.com/success\",' +
            '            \"cancelUrl\": \"https://mypage.com/cancel\"' +
            '          },' +
            '          \"directDebit\": {' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '          }' +
            '        },' +
            '        \"payPalCredit\": {' +
            '          \"redirect\": {' +
            '            \"redirectUrl\": \"https://api.digitalriver.com:443/payments/redirects/e626ec65-24d6-46fb-b632-10b90f4c4912?apiKey=pk_test_6cb0fe9ce3124093a9ad906f6c589e2d\",' +
            '            \"returnUrl\": \"https://mypage.com/success\",' +
            '            \"cancelUrl\": \"https://mypage.com/cancel\"' +
            '          },' +
            '          \"directDebit\": {' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '          }' +
            '        },' +
            '        \"directDebit\": {' +
            '          \"redirect\": {' +
            '            \"redirectUrl\": \"https://api.digitalriver.com:443/payments/redirects/75743f60-1023-470e-be48-b761260317af?apiKey=pk_test_6cb0fe9ce3124093a9ad906f6c589e2d\",' +
            '            \"returnUrl\": \"https://mypage.com/success\"' +
            '          },' +
            '            \"token\": \"EC-53H39048EL439164J\"' +
            '        },' +
            '        \"wireTransfer\": {' +
            '          \"accountHolder\": \"Netgiro Payments AB\",' +
            '          \"bankName\": \"ABN AMRO Bank N.V.\",' +
            '          \"city\": \"Prague\",' +
            '          \"country\": \"ES\",' +
            '          \"referenceId\": \"DR1651067521\",' +
            '          \"accountNumber\": \"0100037259\",' +
            '          \"additionalBankInformation\": \"Codigo de oficina: 0001 Codigo de entidad: 0156 Digitos de control: 09\",' +
            '          \"iban\": \"ES35 0156 0001 0901 0003 7259\"' +
            '        },' +
            '        \"bPay\": {' +
            '          \"accountHolder\": \"Global Collect BV\",' +
            '          \"bankName\": \"Commonwealth Bank\",' +
            '          \"city\": \"Sydney\",' +
            '          \"country\": \"Australia\",' +
            '          \"referenceId\": \"12345678\",' +
            '          \"accountNumber\": \"87654321\",' +
            '          \"billId\": \"112233\",' +
            '          \"customerPaymentReference\": \"443322\",' +
            '          \"swiftCode\": \"CTBAAU2S\"' +
            '        },' +
            '        \"onlineBanking\": {' +
            '          \"bankCode\": \"86\"' +
            '        },' +
            '        \"klarnaCredit\": {' +
            '          \"shipping\": {' +
            '            \"recipient\": \"John Doe\",' +
            '            \"phoneNumber\": \"5559895326\",' +
            '            \"address\": {' +
            '              \"line1\": \"10380 Bren Road West\",' +
            '              \"city\": \"Minnetonka\",' +
            '              \"state\": \"MN\",' +
            '              \"country\": \"US\",' +
            '              \"postalCode\": \"55343\"' +
            '            },' +
            '            \"email\": \"jdoe@yahoo.com\"' +
            '          },' +
            '          \"token\": \"1111222233334444\"' +
            '        },' +
            '        \"klarnaCreditRecurring\": {' +
            '          \"returnUrl\": \"https://example.org/return\",' +
            '          \"cancelUrl\": \"https://example.org/cancel\"' +
            '        },' +
            '        \"konbini\": {' +
            '          \"storeId\": \"33334444\",' +
            '          \"receiptNumber\": \"8675309\",' +
            '          \"printableInvoiceUrl\": \"https://printableinvoice.com\",' +
            '          \"storeName\": \"Seven Eleven\",' +
            '          \"localizedStoreName\": \"Test Store\",' +
            '          \"storeLogoUrl\": \"https://storelogo.com\"' +
            '        },' +
            '        \"bankTransfer\": {},' +
            '        \"flow\": \"standard\",' +
            '        \"state\": \"chargeable\",' +
            '        \"metadata\": {' +
            '          \"coupon\": \"iOS\"' +
            '        },' +
            '        \"customerId\": \"5823594809\",' +
            '        \"paymentSessionId\": \"8cecaa32-f692-44cc-b103-4cf24dc93913\",' +
            '        \"liveMode\": false' +
            '      }' +
            '    ],' +
            '    \"charges\": [' +
            '      {' +
            '        \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '        \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '        \"drCurrency\": \"USD\",' +
            '        \"amount\": 1180.26,' +
            '        \"state\": \"pending\",' +
            '        \"orderId\": \"9986340012\",' +
            '        \"sourceId\": \"9986340012\",' +
            '        \"failureCode\": \"a failure code\",' +
            '        \"failureMessage\": \"a failure message\",' +
            '        \"paymentSessionId\": \"8cecaa32-f692-44cc-b103-4cf24dc93913\",' +
            '        \"cancels\": [' +
            '          {' +
            '            \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '            \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"updatedTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"amount\": 1180.26,' +
            '            \"state\": \"pending\",' +
            '            \"failureCode\": \"string\",' +
            '            \"failureMessage\": \"string\"' +
            '          }' +
            '        ],' +
            '        \"captures\": [' +
            '          {' +
            '            \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '            \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"updatedTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"amount\": 1180.26,' +
            '            \"state\": \"pending\",' +
            '            \"failureCode\": \"string\",' +
            '            \"failureMessage\": \"string\"' +
            '          }' +
            '        ],' +
            '        \"captured\": false,' +
            '        \"refunds\": [' +
            '          {' +
            '            \"id\": \"a6809a63-e6a9-4016-abbc-f33d19fccb5b\",' +
            '            \"createdTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"updatedTime\": \"2018-04-25T20:36:00Z\",' +
            '            \"amount\": 1180.26,' +
            '            \"state\": \"pending\",' +
            '            \"failureCode\": \"string\",' +
            '            \"failureMessage\": \"string\"' +
            '          }' +
            '        ],' +
            '        \"refunded\": false,' +
            '        \"type\": \"customer_initiated\",' +
            '        \"liveMode\": true' +
            '      }' +
            '    ],' +
            '    \"session\": {' +
            '      \"id\": \"5823594809\",' +
            '      \"amountContributed\": 10.5,' +
            '      \"amountRemainingToBeContributed\": 5.5,' +
            '      \"clientSecret\": \"f93b4a5a-6971-4a50-b752-58636f9cfa07_35436acd-7d47-41df-8e5\",' +
            '      \"state\": \"requires_confirmation\"' +
            '    }' +
            '  },' +
            '  \"liveMode\": false,' +
            '  \"metadata\": {' +
            '    \"coupon\": \"iOS\"' +
            '  },' +
            '  \"upstreamId\": \"7765374748\"' +
            '}';
        DRB2B_CreateCheckoutResponseModel r = DRB2B_CreateCheckoutResponseModel.parse(json);
        System.assert(r != null);
        System.assert(r.id != null);
        System.assert(r.importerOfRecordTax != null);
        System.assert(r.items != null);
        System.assert(r.liveMode != null);
        System.assert(r.createdTime != null);
        System.assert(r.updatedTime != null);
        System.assert(r.customerId != null);
        System.assert(r.drCurrency != null);
        System.assert(r.email != null);
        System.assert(r.browserIp != null);
        System.assert(r.applicationId != null);
        System.assert(r.shipTo != null);
        System.assert(r.billTo != null);
        System.assert(r.subtotal != null);
        System.assert(r.totalTax != null);
        System.assert(r.totalFees != null);
        System.assert(r.totalDuty != null);
        System.assert(r.totalDiscount != null);
        System.assert(r.totalShipping != null);
        System.assert(r.totalAmount != null);
        System.assert(r.discount != null);
        System.assert(r.taxIdentifiers != null);
        System.assert(r.purchaseLocation != null);
        System.assert(r.customerType != null);
        System.assert(r.sellingEntity != null);
        System.assert(r.shippingChoice != null);
        System.assert(r.metadata != null);
        System.assert(r.upstreamId != null);
        System.assert(r.locale != null);
        System.assert(r.totalImporterTax != null);

        DRB2B_CreateCheckoutResponseModel.Address address = r.shipFrom.address;
        System.assert(address != null);
        System.assert(address.city != null);
        System.assert(address.state != null);
        System.assert(address.country != null);
        System.assert(address.line1 != null);
        System.assert(address.postalCode != null);
        DRB2B_CreateCheckoutResponseModel.Owner owner = r.payment.sources[0].owner;
        System.assert(owner != null);
        System.assert(owner.email != null);
        System.assert(owner.firstName != null);
        System.assert(owner.lastName != null);
        System.assert(owner.organization != null);
        System.assert(owner.upstreamId != null);
        System.assert(owner.address != null);
        System.assert(owner.additionalAddressInfo != null);
        DRB2B_CreateCheckoutResponseModel.Discount discount = r.discount;
        System.assert(discount.amountOff != null);
        System.assert(discount.percentOff != null);
        System.assert(discount.quantity != null);
        DRB2B_CreateCheckoutResponseModel.Metadata metadata = r.metadata;
        System.assert(metadata.coupon != null);
        DRB2B_CreateCheckoutResponseModel.SubscriptionInfo subscriptionInfo = r.items[0].subscriptionInfo;
        System.assert(subscriptionInfo != null);
        System.assert(subscriptionInfo.autoRenewal != null);
        System.assert(subscriptionInfo.billingAgreementId != null);
        System.assert(subscriptionInfo.endTime != null);
        System.assert(subscriptionInfo.freeTrial != null);
        System.assert(subscriptionInfo.startTime != null);
        System.assert(subscriptionInfo.terms != null);
        System.assert(subscriptionInfo.subscriptionId != null);
        DRB2B_CreateCheckoutResponseModel.Tax tax = r.items[0].tax;
        System.assert(tax.rate != null);
        System.assert(tax.amount != null);
        DRB2B_CreateCheckoutResponseModel.SellingEntity sellingEntity = r.sellingEntity;
        System.assert(sellingEntity != null);
        System.assert(sellingEntity.id != null);
        System.assert(sellingEntity.name != null);

        DRB2B_CreateCheckoutResponseModel.OnlineBanking onlineBanking = r.payment.sources[0].OnlineBanking;
        System.assert(onlineBanking != null);
        System.assert(onlineBanking.bankCode != null);
        DRB2B_CreateCheckoutResponseModel.ImporterTax importerTax = r.items[0].ImporterTax;
        System.assert(importerTax != null);
        System.assert(importerTax.amount != null);
        DRB2B_CreateCheckoutResponseModel.Duties duties = r.items[0].Duties;
        System.assert(duties.amount != null);
        DRB2B_CreateCheckoutResponseModel.KlarnaCreditRecurring klarnaCreditRecurring = r.payment.sources[0]
            .KlarnaCreditRecurring;
        System.assert(klarnaCreditRecurring.returnUrl != null);
        System.assert(klarnaCreditRecurring.cancelUrl != null);
        DRB2B_CreateCheckoutResponseModel.BPay BPay = r.payment.sources[0].BPay;
        System.assert(BPay.accountHolder != null);
        System.assert(BPay.bankName != null);
        System.assert(BPay.billId != null);
        System.assert(BPay.city != null);
        System.assert(BPay.country != null);
        System.assert(BPay.referenceId != null);
        System.assert(BPay.accountNumber != null);
        System.assert(BPay.customerPaymentReference != null);
        System.assert(BPay.swiftCode != null);
        DRB2B_CreateCheckoutResponseModel.Item item = r.items[0];
        System.assert(item.Id != null);
        System.assert(item.skuId != null);
        System.assert(item.fees != null);
        System.assert(item.quantity != null);
        System.assert(item.availableToRefundAmount != null);
        System.assert(item.importerTax != null);
        System.assert(item.duties != null);
        System.assert(item.discount != null);
        System.assert(item.shipFrom != null);
        System.assert(item.metadata != null);
        System.assert(item.amount != null);
        DRB2B_CreateCheckoutResponseModel.Charge charge = r.payment.charges[0];
        System.assert(charge != null);
        System.assert(charge.id != null);
        System.assert(charge.createdTime != null);
        System.assert(charge.drCurrency != null);
        System.assert(charge.state != null);
        System.assert(charge.amount != null);
        System.assert(charge.orderId != null);
        System.assert(charge.sourceId != null);
        System.assert(charge.failureCode != null);
        System.assert(charge.failureMessage != null);
        System.assert(charge.paymentSessionId != null);
        System.assert(charge.cancels != null);
        System.assert(charge.captured != null);
        System.assert(charge.captures != null);
        System.assert(charge.refunded != null);
        System.assert(charge.refunds != null);
        System.assert(charge.type != null);
        System.assert(charge.liveMode != null);
        DRB2B_CreateCheckoutResponseModel.Shipping shipping = r.payment.sources[0].KlarnaCredit.shipping;
        System.assert(shipping != null);
        System.assert(shipping.email != null);
        System.assert(shipping.address != null);
        System.assert(shipping.phoneNumber != null);
        System.assert(shipping.recipient != null);
        DRB2B_CreateCheckoutResponseModel.Cancels cancels = r.payment.charges[0].Cancels[0];
        System.assert(cancels != null);
        System.assert(cancels.id != null);
        System.assert(cancels.createdTime != null);
        System.assert(cancels.updatedTime != null);
        System.assert(cancels.amount != null);
        System.assert(cancels.state != null);
        System.assert(cancels.failureCode != null);
        System.assert(cancels.failureMessage != null);
        DRB2B_CreateCheckoutResponseModel.PayPal payPal = r.payment.sources[0].PayPal;
        System.assert(payPal != null);
        System.assert(payPal.directDebit != null);
        System.assert(payPal.redirect != null);
        DRB2B_CreateCheckoutResponseModel.KlarnaCredit klarnaCredit = r.payment.sources[0].klarnaCredit;
        System.assert(klarnaCredit != null);
        System.assert(klarnaCredit.shipping != null);
        System.assert(klarnaCredit.token != null);
        DRB2B_CreateCheckoutResponseModel.WireTransfer wireTransfer = r.payment.sources[0].WireTransfer;
        System.assert(wireTransfer != null);
        System.assert(wireTransfer.bankName != null);
        System.assert(wireTransfer.accountHolder != null);
        System.assert(wireTransfer.city != null);
        System.assert(wireTransfer.country != null);
        System.assert(wireTransfer.iban != null);
        System.assert(wireTransfer.accountNumber != null);
        System.assert(wireTransfer.additionalBankInformation != null);
        System.assert(wireTransfer.referenceId != null);
        DRB2B_CreateCheckoutResponseModel.AdditionalAddressInfo additionalAddressInfo = r.shipFrom.additionalAddressInfo;
        System.assert(additionalAddressInfo != null);
        System.assert(additionalAddressInfo.division != null);
        System.assert(additionalAddressInfo.neighborhood != null);
        System.assert(additionalAddressInfo.phoneticName != null);

        DRB2B_CreateCheckoutResponseModel.ShippingChoice shippingChoice = r.shippingChoice;
        System.assert(shippingChoice != null);
        System.assert(shippingChoice.taxAmount != null);
        System.assert(shippingChoice.serviceLevel != null);
        System.assert(shippingChoice.description != null);
        System.assert(shippingChoice.amount != null);
        DRB2B_CreateCheckoutResponseModel.Redirect redirect = r.payment.sources[0].PayPal.redirect;
        System.assert(redirect != null);
        System.assert(redirect.returnUrl != null);
        System.assert(redirect.redirectUrl != null);
        System.assert(redirect.cancelUrl != null);
        DRB2B_CreateCheckoutResponseModel.Fees fees = r.items[0].Fees;
        System.assert(fees != null);
        System.assert(fees.taxAmount != null);
        System.assert(fees.amount != null);
        System.assert(fees.details != null);
        DRB2B_CreateCheckoutResponseModel.Source source = r.payment.sources[0];
        System.assert(source != null);
        System.assert(source.id != null);
        System.assert(source.createdTime != null);
        System.assert(source.clientSecret != null);
        System.assert(source.type != null);
        System.assert(source.drCurrency != null);
        System.assert(source.amount != null);
        System.assert(source.reusable != null);
        System.assert(source.creditCard != null);
        System.assert(source.googlePay != null);
        System.assert(source.payPalBilling != null);
        System.assert(source.flow != null);
        System.assert(source.state != null);
        System.assert(source.metadata != null);
        System.assert(source.customerId != null);
        System.assert(source.payPalBilling != null);
        System.assert(source.paymentSessionId != null);
        System.assert(source.liveMode != null);
        System.assert(source.payPalCredit != null);
        System.assert(source.bankTransfer != null);
        DRB2B_CreateCheckoutResponseModel.CreditCard creditCard = r.payment.sources[0].CreditCard;
        System.assert(creditCard != null);
        System.assert(creditCard.brand != null);
        System.assert(creditCard.expirationMonth != null);
        System.assert(creditCard.expirationYear != null);
        System.assert(creditCard.fundingSource != null);
        System.assert(creditCard.lastFourDigits != null);
        DRB2B_CreateCheckoutResponseModel.Konbini konbini = r.payment.sources[0].Konbini;
        System.assert(konbini != null);
        System.assert(konbini.localizedStoreName != null);
        System.assert(konbini.storeId != null);
        System.assert(konbini.storeLogoUrl != null);
        System.assert(konbini.receiptNumber != null);
        System.assert(konbini.storeName != null);
        System.assert(konbini.printableInvoiceUrl != null);
        DRB2B_CreateCheckoutResponseModel.PurchaseLocation purchaseLocation = r.purchaseLocation;
        System.assert(purchaseLocation != null);
        System.assert(purchaseLocation.country != null);
        System.assert(purchaseLocation.postalCode != null);
        System.assert(purchaseLocation.state != null);
        DRB2B_CreateCheckoutResponseModel.Details details = r.items[0].fees.details[0];
        System.assert(details != null);
        System.assert(details.type != null);
        System.assert(details.amount != null);
        System.assert(details.perUnitAmount != null);
        System.assert(details.id != null);
        DRB2B_CreateCheckoutResponseModel.DirectDebit directDebit = r.payment.sources[0].directDebit;
        System.assert(directDebit != null);
        System.assert(directDebit.token != null);
        System.assert(directDebit.redirect != null);
        DRB2B_CreateCheckoutResponseModel.TaxIdentifier taxIdentifier = r.taxIdentifiers[0];
        System.assert(taxIdentifier != null);
        System.assert(taxIdentifier.id != null);
        System.assert(taxIdentifier.createdTime != null);
        System.assert(taxIdentifier.customerId != null);
        System.assert(taxIdentifier.type != null);
        System.assert(taxIdentifier.value != null);
        System.assert(taxIdentifier.state != null);
        System.assert(taxIdentifier.value != null);
        System.assert(taxIdentifier.verifiedAddress != null);
        System.assert(taxIdentifier.verifiedName != null);
        System.assert(taxIdentifier.updatedTime != null);
        DRB2B_CreateCheckoutResponseModel.ShipTo shipTo = r.shipTo;
        System.assert(shipTo != null);
        System.assert(shipTo.additionalAddressInfo != null);
        System.assert(shipTo.address != null);
        System.assert(shipTo.email != null);
        System.assert(shipTo.name != null);
        System.assert(shipTo.organization != null);
        System.assert(shipTo.phone != null);
        DRB2B_CreateCheckoutResponseModel.Session session = r.payment.session;
        System.assert(session != null);
        System.assert(session.id != null);
        System.assert(session.amountContributed != null);
        System.assert(session.amountRemainingToBeContributed != null);
        System.assert(session.clientSecret != null);
        System.assert(session.state != null);
    }
}
