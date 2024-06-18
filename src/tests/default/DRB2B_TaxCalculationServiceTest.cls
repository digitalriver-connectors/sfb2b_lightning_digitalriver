@isTest
public class DRB2B_TaxCalculationServiceTest {
	
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

            //Physical-----
            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
            cart.WebStoreId = store.Id;
            cart.AccountId = acc.Id;
            cart.Name = 'Physical';
            cart.DR_CartItemStructure__c = '2914';
            //cart.DR_Checkout_Type__c = 'Physical';
            insert cart;
            
            CartDeliveryGroup CartDeliveryGroupRecord = new CartDeliveryGroup();//(CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
            CartDeliveryGroupRecord.Name = 'Cart Delivery Group';
            CartDeliveryGroupRecord.CartId = cart.Id;
            CartDeliveryGroupRecord.Name = 'Cart Delivery Group';
            CartDeliveryGroupRecord.DeliverToStreet = '9625 West 76th St';
            CartDeliveryGroupRecord.DeliverToCountry = 'US';
            CartDeliveryGroupRecord.DeliverToState = 'MN';
            CartDeliveryGroupRecord.DeliverToPostalCode = '55344';
            
            CartDeliveryGroupRecord.DeliverToCountry = 'US';
            if(DRB2B_Utility.isCountryStateEnabled() == true){
                CartDeliveryGroupRecord.DeliverToCountry= 'United States';
                CartDeliveryGroupRecord.DeliverToState = 'Minnesota';
            }
            
            insert CartDeliveryGroupRecord;
            
            result = ATK.prepare(CartItem.SObjectType, 1).build(EntityBuilderFactory.cartItemBuilder).save(false);
            CartItem cartItm = (CartItem) result.get(CartItem.SObjectType)[0];
            cartItm.CartId = cart.Id;
            cartItm.CartDeliveryGroupId = CartDeliveryGroupRecord.Id;
            cartItm.Type = 'Charge';
            insert cartItm;
            // End Physical
            //Start Digital
            result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);
            WebStore store2 = (WebStore) result.get(WebStore.SObjectType)[0];
            insert store2;
            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cartDiggital = (WebCart) result.get(WebCart.SObjectType)[0];
            cartDiggital.WebStoreId = store2.Id;
            cartDiggital.AccountId = acc.Id;
            cartDiggital.Name = 'Digital';
            cartDiggital.DR_Checkout_Type__c = 'Digital';
            insert cartDiggital;
            
            
            CartDeliveryGroup CartDeliveryGroupDigital = new CartDeliveryGroup();//(CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
            CartDeliveryGroupDigital.Name = 'Cart Delivery Group';
            CartDeliveryGroupDigital.CartId = cartDiggital.Id;
            CartDeliveryGroupDigital.DeliverToStreet = '9625 West 76th St';
            CartDeliveryGroupDigital.DeliverToCountry = 'US';
            CartDeliveryGroupDigital.DeliverToState = 'MN';
            CartDeliveryGroupDigital.DeliverToPostalCode = '55344';
            if(DRB2B_Utility.isCountryStateEnabled() == true){
                CartDeliveryGroupDigital.DeliverToCountry= 'United States';
                CartDeliveryGroupDigital.DeliverToState = 'Minnesota';
            }
            insert CartDeliveryGroupDigital;
            
            result = ATK.prepare(CartItem.SObjectType, 1).build(EntityBuilderFactory.cartItemBuilder).save(false);
            CartItem cartItmDigital = (CartItem) result.get(CartItem.SObjectType)[0];
            cartItmDigital.CartId = cartDiggital.Id;
            cartItmDigital.CartDeliveryGroupId = CartDeliveryGroupDigital.Id;
            cartItmDigital.Type = 'Product';
            cartItmDigital.Free_Subscription_Trial__c = true;
            cartItmDigital.Subscription_Id__c = 'tstId';
            cartItmDigital.Subscription_End_Time__c = System.now().addDays(1);
            cartItmDigital.Recurring_Line_Item__c = true;
            insert cartItmDigital;
            
            // End Digital 
            // Non- Digital Product Test
            result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);
            WebStore store3 = (WebStore) result.get(WebStore.SObjectType)[0];
            insert store3;
            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cartNonDigital = (WebCart) result.get(WebCart.SObjectType)[0];
            cartNonDigital.WebStoreId = store3.Id;
            cartNonDigital.AccountId = acc.Id;
            cartNonDigital.Name = 'Non-Digital';
            cartNonDigital.DR_Checkout_Type__c = 'Non-Digital';
            insert cartNonDigital;
            
            CartDeliveryGroup CartDeliveryGroupNonDigital = new CartDeliveryGroup();//(CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
            CartDeliveryGroupNonDigital.Name = 'Cart Delivery Group';
            CartDeliveryGroupNonDigital.CartId = cartNonDigital.Id;
            CartDeliveryGroupNonDigital.Name = 'Cart Delivery Group';
            CartDeliveryGroupNonDigital.DeliverToStreet = '9625 West 76th St';
            CartDeliveryGroupNonDigital.DeliverToCountry = 'US';
            CartDeliveryGroupNonDigital.DeliverToState = 'MN';
            CartDeliveryGroupNonDigital.DeliverToPostalCode = '55344';
            if(DRB2B_Utility.isCountryStateEnabled() == true){
                CartDeliveryGroupNonDigital.DeliverToCountry= 'United States';
                CartDeliveryGroupNonDigital.DeliverToState = 'Minnesota';
            }
            insert CartDeliveryGroupNonDigital;
            
            result = ATK.prepare(CartItem.SObjectType, 1).build(EntityBuilderFactory.cartItemBuilder).save(false);
            CartItem cartItmNonDigital = (CartItem) result.get(CartItem.SObjectType)[0];
            cartItmNonDigital.CartId = cartNonDigital.Id;
            cartItmNonDigital.CartDeliveryGroupId = CartDeliveryGroupNonDigital.Id;
            cartItmNonDigital.Type = 'Charge';
            insert cartItmNonDigital;
        }
    }
    
    
    @isTest
    static void TaxCalculationPhysicalTest(){
       	// Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('GetTaxesResource');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.startTest();
            // Associate the callout with a mock response.
            Test.setMock(HttpCalloutMock.class, mock);
            
            WebCart webCartId = [SELECT Id,DR_Checkout_Type__c FROM WebCart WHERE Name = 'Physical' LIMIT 1];
            cartItem cartItemId = [SELECT Id, Type FROM CartItem WHERE CartId = :webCartId.id LIMIT 1];
            List<Id> webCarts = new List<Id>{ webCartId.id };
            DRB2B_SyncTax.syncTax(webCarts);
            // Verify: the integration executed successfully
            // and the new CartTax record is inserted.
            List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemId.id];
            System.assertEquals(0, cartTaxesForCartItem.size());
            Test.stopTest();
        }
    }
    
    @isTest
    static void TaxCalculationDigitalTest(){
       	// Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('GetTaxesResource');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.startTest();
            // Associate the callout with a mock response.
            Test.setMock(HttpCalloutMock.class, mock);
            
            WebCart webCartId = [SELECT Id,DR_Checkout_Type__c FROM WebCart WHERE Name = 'Digital' LIMIT 1];
            cartItem cartItemId = [SELECT Id, Type FROM CartItem WHERE CartId = :webCartId.id LIMIT 1];
            List<Id> webCarts = new List<Id>{ webCartId.id };
            DRB2B_SyncTax.syncTax(webCarts);
            // Verify: the integration executed successfully
            // and the new CartTax record is inserted.
            List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemId.id];
            System.assertEquals(0, cartTaxesForCartItem.size());
            Test.stopTest();
        }
    }
    
    @isTest
    static void TaxCalculationNonDigitalTest(){
       	// Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('GetTaxesResource');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.startTest();
            // Associate the callout with a mock response.
            Test.setMock(HttpCalloutMock.class, mock);
            
            WebCart webCartId = [SELECT Id,DR_Checkout_Type__c FROM WebCart WHERE Name = 'Non-Digital' LIMIT 1];
            cartItem cartItemId = [SELECT Id, Type FROM CartItem WHERE CartId = :webCartId.id LIMIT 1];
            List<Id> webCarts = new List<Id>{ webCartId.id };
            DRB2B_SyncTax.syncTax(webCarts);
            // Verify: the integration executed successfully
            // and the new CartTax record is inserted.
            List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemId.id];
            System.assertEquals(0, cartTaxesForCartItem.size());
            Test.stopTest();
        }
    }
    @isTest
    public static void updateCartWithItemStructureTest(){
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
       
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Test.startTest();
            WebCart webCartId = [SELECT Id,DR_Checkout_Type__c FROM WebCart LIMIT 1];
            DRB2B_TaxCalculationService.updateCartWithItemStructure(webCartId.Id, '2914');
            Test.stopTest();
        }
    }
}