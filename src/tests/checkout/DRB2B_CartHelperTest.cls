@isTest
private with sharing class DRB2B_CartHelperTest {

    @TestSetup
    static void setupData() {
        ATK.SaveResult result;
        Account acc;
        WebStore store;
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            result = ATK.prepare(Account.SObjectType, 1)
                                        .build(EntityBuilderFactory.accountBuilder)
                                        .save(false);
            acc = (Account) result.get(Account.SObjectType)[0];
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
            store = (WebStore) result.get(WebStore.SObjectType)[0];
            insert store;

            
        }
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
            WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
            cart.WebStoreId = store.Id;
            cart.AccountId = acc.Id;
            cart.Name = 'Cart';
            insert cart;
        }
        
    }
           
    @isTest
    static void getCartTest() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
           String cartId = DRB2B_CartHelper.getCartId();
           Assert.isNotNull(cartId, 'CartId Should Not Null');
        }
    }
    // for getCartIdWithCommunityId() method, we need NetworkId at SetupData 
    // and we cannot create data for Network.
     
    @isTest
    static void getCartIdWithCommunityIdTest() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            try{
                String cartId = DRB2B_CartHelper.getCartIdWithCommunityId('isTest');
                Assert.isNotNull(cartId, 'CartId Should Not Null');
                cartId = DRB2B_CartHelper.getCartIdWithCommunityId('Exception');
            }catch(exception e){
                Assert.areEqual('Script-thrown exception', e.getMessage(), 'Should be same');
            }
        }
    }      
}