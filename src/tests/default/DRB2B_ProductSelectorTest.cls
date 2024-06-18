@IsTest
private class DRB2B_ProductSelectorTest {
    @TestSetup
    static void setupData() {
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult resultAccount = ATK.prepare(Account.SObjectType, 1)
                .build(EntityBuilderFactory.accountBuilder)
                .save(false);
            Account acc = (Account) resultAccount.get(Account.SObjectType)[0];
            insert acc;

            ATK.SaveResult resultContact = ATK.prepare(Contact.SObjectType, 1)
                .build(EntityBuilderFactory.contactBuilder)
                .save(false);
            Contact con = (Contact) resultContact.get(Contact.SObjectType)[0];
            con.AccountId = acc.Id;
            insert con;

            ATK.SaveResult result = ATK.prepare(User.SObjectType, 1).build(EntityBuilderFactory.userBuilder).save(false);
            User shopper = (User) result.get(User.SObjectType)[0];
            Profile shopperProfile = [SELECT Id FROM Profile WHERE Name = :DRB2B_Constants.Profile.DR_SHOPPER LIMIT 1];
            shopper.ProfileId = shopperProfile.Id;
            shopper.ContactId = con.Id;
            insert shopper;

            result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);

            WebStore webStore = (WebStore) result.get(WebStore.SObjectType)[0];
            insert webStore;

            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            insert priceBook;

            result = ATK.prepare(ContactPointAddress.SObjectType, 1)
                .build(EntityBuilderFactory.contactPointAddressBuilder)
                .save(false);

            ContactPointAddress conPointAddress = (ContactPointAddress) result.get(ContactPointAddress.SObjectType)[0];
            insert conPointAddress;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.DR_Product_Country_Origin__c = 'US';
            insert product;
        }
    }

    @isTest
    static void getById_Test() {
        // Assign DR Admin Permission Set to Portal Account Owner user
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.portalAccountOwner,
            DRB2B_Constants.PermissionSet.ADMIN
        );

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            Product2 product = [SELECT Id, DR_Product_Country_Origin__c FROM Product2 LIMIT 1];
            Test.startTest();
                Product2 productReturned = new DRB2B_ProductSelector()
                    .getById(product.Id, new Set<String>{ 'Id,Name,DR_Product_Country_Origin__c' });
                System.assertEquals(
                    product.DR_Product_Country_Origin__c,
                    productReturned.DR_Product_Country_Origin__c,
                    'Product Country Origin dose not match'
                );
            Test.stopTest();
        }
    }

}