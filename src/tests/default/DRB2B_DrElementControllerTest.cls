/**
 * @description       :
 * @author            : Devanshu Sood
 * @last modified on  : 04-16-2021
 * @last modified by  : Devanshu Sood
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-16-2021   Devanshu Sood   Initial Version
 **/
@isTest
private with sharing class DRB2B_DrElementControllerTest {
    private static final String DR_SECRET_KEY_RECORD_DEV_NAME = 'DR_Secret_Key';
    private static final String DR_JS_RESOURCE_RECORD_DEV_NAME = 'DR_JS_Static_Resource';
    private static final String DR_CSS_RESOURCE_RECORD_DEV_NAME = 'DR_CSS_Static_Resource';
    private static final String DR_DEFAULT_ENTITY_RECORD_DEV_NAME = 'DR_Default_Entity';
    private static final String DR_PUBLIC_KEY_RECORD_DEV_NAME = 'DR_Public_Key';

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
        }
    }

    @IsTest
    static void verifyAllConfigs() {
        DRB2B_DrElementController instance = new DRB2B_DrElementController();
        Map<String, DR_Connector_Configuration__mdt> config = DR_Connector_Configuration__mdt.getAll();
        System.assertEquals(config.get(DR_DEFAULT_ENTITY_RECORD_DEV_NAME).key__c, instance.getDefaultEntity);
        System.assertEquals(config.get(DR_PUBLIC_KEY_RECORD_DEV_NAME).key__c, instance.getPublicKey);
        System.assertEquals(UserInfo.getLocale(), instance.getUserLocale);
    }

    @IsTest
    static void getDefaultEntity() {
        User shopper = [Select Id, Username from User where Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER Limit 1];
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            shopper,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(shopper) {
            ATK.SaveResult result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
            cart.DR_Selling_Entity__c = 'Digital River, Inc.';
            cart.WebStoreId = [SELECT id FROM WebStore]?.Id;
            cart.AccountId = [SELECT id FROM Account]?.Id;
            insert cart;

            string cartJson = DRB2B_DrElementController.getCartEntity(cart.Id);
            Map<String, Object> cartDetails = (Map<String, Object>)JSON.deserializeUntyped(cartJson);
            system.assertEquals('Digital River, Inc.', cartDetails.get('digitalriverv3__DR_Selling_Entity__c'));

           
        }
    }
    @isTest
    private static void testComplianceAddressPositive(){
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id,BillingCountry='US');
        if(DRB2B_Utility.isCountryStateEnabled() == true){
            cart.BillingCountry= 'United States';
        }
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery',DeliverToCountry = 'US');
        if(DRB2B_Utility.isCountryStateEnabled() == true){
            cartDeliveryGroup.DeliverToCountry= 'United States';
        }
        insert cartDeliveryGroup;
        insertCartItem(cart.Id, cartDeliveryGroup.Id);
        try{
        string cartComplianceJson = DRB2B_DrElementController.getComplianceAddress(cart.Id);
    }catch(Exception e){}
    }
     @isTest
    private static void testComplianceAddressNegative(){
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id, BillingCountry = 'US');
        if(DRB2B_Utility.isCountryStateEnabled() == true){
            cart.BillingCountry= 'United States';
        }
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery',DeliverToCountry = 'United States');
        insert cartDeliveryGroup;
        
        insertCartItem(cart.Id, cartDeliveryGroup.Id);
        string cartComplianceJson ;
        try{
            cartComplianceJson = DRB2B_DrElementController.getComplianceAddress(cart.Id);
        }catch(Exception e){}
        
    }
    static void insertCartItem(String cartId, String cartDeliveryGroupId) {
        CartItem cartItem = new CartItem(
            CartId=cartId,  
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroupId
        );
        insert cartItem;
    }
 }