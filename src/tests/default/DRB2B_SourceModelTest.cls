@IsTest
private class DRB2B_SourceModelTest {
    static testMethod void testParse() {
        String json =
            '{' +
            '            \"id\": \"a09f45a5-b9a7-46a1-937a-32bfbec272a1\",' +
            '            \"createdTime\": \"2021-06-11T15:07:27Z\",' +
            '            \"type\": \"creditCard\",' +
            '            \"reusable\": true,' +
            '            \"state\": \"cancelled\",' +
            '            \"amount\": 10,' +
            '            \"owner\": {' +
            '                \"firstName\": \"eng\",' +
            '                \"lastName\": \"Coe\",' +
            '                \"email\": \"bthomas@digitalriver.com\",' +
            '                \"address\": {' +
            '                    \"line1\": \"123 test\",' +
            '                    \"city\": \"eagan\",' +
            '                    \"postalCode\": \"55234\",' +
            '                    \"state\": \"IL\",' +
            '                    \"country\": \"US\"' +
            '                }' +
            '            },' +
            '            \"clientSecret\": \"a09f45a5-b9a7-46a1-937a-32bfbec272a1_16e0e8a6-28ca-4035-a9f8-ad4353d726a0\",' +
            '            \"creditCard\": {' +
            '                \"brand\": \"Visa\",' +
            '                \"expirationMonth\": 12,' +
            '                \"expirationYear\": 2030,' +
            '                \"lastFourDigits\": \"1111\",' +
            '                \"fundingSource\": \"Dr\"' +
            '            }' +
            '        }';
        DRB2B_SourceModel obj = DRB2B_SourceModel.parse(json);
        System.assert(obj != null);
        System.assert(obj.id != null);
        System.assert(obj.amount != null);
        System.assert(obj.creditCard != null);
        System.assert(obj.owner != null);
        System.assert(obj.type != null);
        System.assert(obj.state != null);
        System.assert(obj.clientSecret != null);
        System.assert(obj.createdTime != null);
        System.assert(obj.reusable != null);
        DRB2B_SourceModel.CreditCard creditCard = obj.creditCard;
        System.assert(creditCard != null);
        System.assert(creditCard.brand != null);
        System.assert(creditCard.expirationMonth != null);
        System.assert(creditCard.expirationYear != null);
        System.assert(creditCard.lastFourDigits != null);
        System.assert(creditCard.fundingSource != null);
        DRB2B_SourceModel.Owner owner = obj.owner;
        System.assert(owner != null);
        System.assert(owner.firstName != null);
        System.assert(owner.lastName != null);
        System.assert(owner.email != null);
        System.assert(owner.address != null);
        DRB2B_SourceModel.Address address = obj.owner.address;
        System.assert(address != null);
        System.assert(address.state != null);
        System.assert(address.postalCode != null);
        System.assert(address.line1 != null);
        System.assert(address.country != null);
        System.assert(address.city != null);
    }
}
