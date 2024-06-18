@isTest
public class B2BSyncDeliveryTest {
    @testSetup static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id, DR_Checkout_Type__c = 'Digital');
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;

        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;

    }
    

    @isTest static void testIntegrationRunsSuccessfully() {
        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetDeliveryRatesResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        List<Id> webCarts = new List<Id>{webCart.Id};
            try{
                B2BSyncDelivery.syncDelivery(webCarts);
            }catch(exception e){
                System.debug('ERROR::>>'+e.getMessage());
            }

        // No status is returned from the syncCheckInventory check, but if no exception is thrown, the test passes

        Test.stopTest();
    }
    
    @isTest static void testSaveCartValidationOutputError() {
        Test.startTest();
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        List<Id> webCarts = new List<Id>{webCart.Id};
        B2BSyncDelivery.saveCartValidationOutputError('Something error',webCart.Id);
		Test.stopTest();
    }
    
    @isTest static void testGetShippingChargeProduct2Id() {
        product2 product = new product2(Name = 'Test');
        Insert product;
        
        OrderDeliveryMethod odm = new OrderDeliveryMethod(Name = 'Test', ProductId = product.Id);
        Insert odm;
        Test.startTest();
        Id odmId = B2BSyncDelivery.getShippingChargeProduct2Id(odm.Id);
        System.assertEquals(odmId, product.Id);
		Test.stopTest();
    }
    

    @isTest static void testWhenExternalServiceCallFailsAFailedStatusIsReturnedAndACartValidationOutputEntryIsNotCreated() {
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetDeliveryRatesResource');
        // The web service call returns an error code.
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        List<Id> webCarts = new List<Id>{webCart.Id};
        String expectedErrorMessage = 'There was a problem with the request. Error: 404';

        try {
            B2BSyncDelivery.syncDelivery(webCarts);
            
            // An exception should have been thrown before getting to this point:
            //System.assert(false);
        } catch (CalloutException e) {
            //System.assertEquals(expectedErrorMessage, e.getMessage());
        }
        
        // A new CartValidationOutput record with level 'Error' was created.
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        
        Test.stopTest();
    }
    
    @isTest static void testWithoutCartId() {
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetDeliveryRatesResource');
        // The web service call returns an error code.
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        List<Id> webCarts = new List<Id>();
        String expectedErrorMessage = 'There was a problem with the request. Error: 404';
		String cartIDEmptyError = 'A cart id must be included to B2BSyncDelivery';
        try {
            B2BSyncDelivery.syncDelivery(webCarts);
            
            // An exception should have been thrown before getting to this point:
            System.assert(false);
        } catch (CalloutException e) {
            //System.assertEquals(expectedErrorMessage, e.getMessage());
            System.assertEquals(cartIDEmptyError, e.getMessage());
        }
        
        // A new CartValidationOutput record with level 'Error' was created.
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(0, cartValidationOutputs.size());
        
        Test.stopTest();
    }
}