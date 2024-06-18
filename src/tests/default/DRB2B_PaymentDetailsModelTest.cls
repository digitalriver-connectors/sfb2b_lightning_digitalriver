@IsTest
public with sharing class DRB2B_PaymentDetailsModelTest {
    static testMethod void testParse() {
        String json =
        '{' +
        '      \"name\": \"creditCard\",' +
        '      \"amount\": \"4000\",' +
        '      \"cardNumber\": \"5454545454545454\"' +
        '        }' ;
        DRB2B_PaymentDetailsModel.paymentDetails paymentDetails = new  DRB2B_PaymentDetailsModel.paymentDetails();
        paymentDetails.name = 'creditCard';
        paymentDetails.amount = 2000;
        paymentDetails.cardNumber = '5454545454545454';

        DRB2B_PaymentDetailsModel paymentMethod = new DRB2B_PaymentDetailsModel();
        paymentMethod.parse(json);
       
        System.assert(paymentDetails != null);
       
    }
}
