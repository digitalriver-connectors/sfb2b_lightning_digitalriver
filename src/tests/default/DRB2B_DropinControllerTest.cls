@IsTest
public with sharing class DRB2B_DropinControllerTest {

    @TestSetup
    static void setupData() {
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult result = ATK.prepare(Account.SObjectType, 1)
                .build(EntityBuilderFactory.accountBuilder)
                .save(false);
            Account acc = (Account) result.get(Account.SObjectType)[0];
            insert acc;

            result = ATK.prepare(Contact.SObjectType, 1).build(EntityBuilderFactory.contactBuilder).save(false);
            Contact con = (Contact) result.get(Contact.SObjectType)[0];
            con.AccountId = acc.Id;
            insert con;

            result = ATK.prepare(User.SObjectType, 1).build(EntityBuilderFactory.userBuilder).save(false);
            User shopper = (User) result.get(User.SObjectType)[0];
            Profile shopperProfile = [SELECT Id FROM Profile WHERE Name = :DRB2B_Constants.Profile.DR_SHOPPER LIMIT 1];
            shopper.ProfileId = shopperProfile.Id;
            shopper.ContactId = con.Id;
            insert shopper;

            result = ATK.prepare(ContactPointAddress.SObjectType, 1)
                .build(EntityBuilderFactory.contactPointAddressBuilder)
                .save(false);
            ContactPointAddress conPointAddress = (ContactPointAddress) result.get(ContactPointAddress.SObjectType)[0];
            conPointAddress.ParentId = acc.id;
            insert conPointAddress;

            result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);
            WebStore store = (WebStore) result.get(WebStore.SObjectType)[0];
            insert store;

            result = ATK.prepare(Digital_River_Tax_Mapping__c.SObjectType, 1).build(EntityBuilderFactory.drTaxMappingBuilder).save(false);
            Digital_River_Tax_Mapping__c digitalRiverTaxMapping = (Digital_River_Tax_Mapping__c) result.get(Digital_River_Tax_Mapping__c.SObjectType)[0];
            insert digitalRiverTaxMapping;

            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
            cart.WebStoreId = [SELECT id FROM WebStore]?.Id;
            cart.AccountId = [SELECT id FROM Account]?.Id;
            cart.DR_Payment_Session_Id__c = 'c8bf8640-58ad-4bf0-b6aa-d2a91f8880b9';
            cart.Buyer_Email__c = 'test@yopmail.com';
            cart.Buyer_Phone__c = '8886778565';
            cart.Buyer_Name__c = 'tester';
            cart.DR_Checkout_Type__c = 'Non-Digital';
            cart.DR_Checkout_Id__c = '7961f628-8f2a-41f5-9aa0-12150c77680f';
            insert cart;
            
            DR_Transaction_Payment__c drTransactioPayment = new DR_Transaction_Payment__c();
            drTransactioPayment.Cart__c = cart.Id;
            drTransactioPayment.Amount__c = 20.99;
            drTransactioPayment.Card_Type__c = 'Visa';
            drTransactioPayment.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            drTransactioPayment.CurrencyISOCode__c = 'USD';
            drTransactioPayment.Payment_Method__c = 'creditCard';
            drTransactioPayment.Transaction_Type__c = 'AUTH';
            insert drTransactioPayment;
            
        }
    }

    @IsTest
    static void getCart_Test(){
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(shopper) {
            Id cartId = [SELECT id FROM WebCart]?.Id;

            Test.startTest();
                DRB2B_CartModel cartModel =(DRB2B_CartModel) DRB2B_DropinController.getCart(cartId).get('cart');
                system.assertEquals('c8bf8640-58ad-4bf0-b6aa-d2a91f8880b9', cartModel.cart.get('DR_Payment_Session_Id__c'));
                system.assertEquals('test@yopmail.com', cartModel.cart.get('Buyer_Email__c'));
                system.assertEquals('8886778565', cartModel.cart.get('Buyer_Phone__c'));
                system.assertEquals('tester', cartModel.cart.get('Buyer_Name__c'));
                system.assertEquals('Non-Digital', cartModel.cart.get('DR_Checkout_Type__c'));
                system.assertEquals('7961f628-8f2a-41f5-9aa0-12150c77680f', cartModel.cart.get('DR_Checkout_Id__c'));
            Test.stopTest();
        }
    }
    
        @IsTest
    static void deattachAllSourcesFromCheckout_Test(){
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(shopper) {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Id cartId = [SELECT id FROM WebCart]?.Id;
			Map<String, Object> mapOfInputData = new Map<String, Object>();
			mapOfInputData.put('cartId', cartId);
            Test.startTest();
                Boolean Result = DRB2B_DropinController.deattachAllSourcesFromCheckout(JSON.serialize(mapOfInputData));
                
            Test.stopTest();
        }
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(204);
            return res;
        }
    }

}