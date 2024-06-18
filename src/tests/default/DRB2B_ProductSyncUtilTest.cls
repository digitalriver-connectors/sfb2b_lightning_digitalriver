@isTest
private class DRB2B_ProductSyncUtilTest {
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

            result = ATK.prepare(DR_ECCN_Lookup__c.SObjectType, 1)
                .build(EntityBuilderFactory.drECCNLookupBuilder)
                .save(false);

            DR_ECCN_Lookup__c drECCN = (DR_ECCN_Lookup__c) result.get(DR_ECCN_Lookup__c.SObjectType)[0];
            insert drECCN;

            result = ATK.prepare(Digital_River_Tax_Mapping__c.SObjectType, 1)
                .build(EntityBuilderFactory.drTaxMappingBuilder)
                .save(false);
            Digital_River_Tax_Mapping__c drTaxMapping = (Digital_River_Tax_Mapping__c) result.get(
                Digital_River_Tax_Mapping__c.SObjectType
            )[0];
            insert drTaxMapping;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.DR_ECCN__c = drECCN.Id;
            insert product;
        }
    }

    @isTest
    static void testReSyncProducts() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.portalAccountOwner,
            DRB2B_Constants.PermissionSet.ADMIN
        );

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            List<DR_ECCN_Lookup__c> drEccnLookupList = [
                SELECT Id, Name, DR_Notes__c
                FROM DR_ECCN_Lookup__c
                WHERE Name = 'EAR99'
            ];
            List<Digital_River_Tax_Mapping__c> taxMappingLookupList = [
                SELECT Id, Name, DR_Tax_Group__c, DR_Tax_Type__c, DR_Tax_Code__c, DR_Product_Type__c
                FROM Digital_River_Tax_Mapping__c
                WHERE DR_Tax_Code__c = '4512.1'
            ];
            List<Product2> product2List = [
                SELECT
                    Id,
                    Name,
                    ISActive,
                    StockKeepingUnit,
                    DR_ECCN__c,
                    DR_TAXGROUP__c,
                    DR_TAXTYPE__c,
                    DR_Part_Number__c,
                    DR_Product_Country_Origin__c,
                    Sync_Product_to_DR__c
                FROM Product2
                WHERE DR_ECCN__c = :drEccnLookupList.get(0).Id
            ];
    
            Test.startTest();
            String jsonString = '{"isSyncAll": true, "isSyncProduct": false }';
            String productSyncResponse = DRB2B_ProductSyncUtil.syncProducts(jsonString);
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(productSyncResponse);
            System.debug('requestData2--->' + requestData2);
            System.assertEquals(true, requestData2.get('isSuccess'), 'Product is not updated');
            Test.stopTest();
        }
    }

    @isTest
    static void testIsSyncProducts() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.portalAccountOwner,
            DRB2B_Constants.PermissionSet.ADMIN
        );

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            List<DR_ECCN_Lookup__c> drEccnLookupList = [
                SELECT Id, Name, DR_Notes__c
                FROM DR_ECCN_Lookup__c
                WHERE Name = 'EAR99'
            ];
            List<Digital_River_Tax_Mapping__c> taxMappingLookupList = [
                SELECT Id, Name, DR_Tax_Group__c, DR_Tax_Type__c, DR_Tax_Code__c, DR_Product_Type__c
                FROM Digital_River_Tax_Mapping__c
                WHERE DR_Tax_Code__c = '4512.1'
            ];
            List<Product2> product2List = [
                SELECT
                    Id,
                    Name,
                    ISActive,
                    StockKeepingUnit,
                    DR_ECCN__c,
                    DR_TAXGROUP__c,
                    DR_TAXTYPE__c,
                    DR_Part_Number__c,
                    DR_Product_Country_Origin__c,
                    Sync_Product_to_DR__c
                FROM Product2
                WHERE DR_ECCN__c = :drEccnLookupList.get(0).Id
            ];
    
            Test.startTest();
            String jsonString = '{"isSyncAll": false, "isSyncProduct": true }';
            String productSyncResponse = DRB2B_ProductSyncUtil.syncProducts(jsonString);
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(productSyncResponse);
            System.debug('requestData2--->' + requestData2);
            System.assertEquals(true, requestData2.get('isSuccess'), 'Product is not updated');
            Test.stopTest();
        }
    }

    @isTest
    static void testNegativeUseCaseProducts() {
        User communityUser = [SELECT Id FROM User WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER LIMIT 1];
        List<DR_ECCN_Lookup__c> drEccnLookupList = [
            SELECT Id, Name, DR_Notes__c
            FROM DR_ECCN_Lookup__c
            WHERE Name = 'EAR99'
        ];
        List<Digital_River_Tax_Mapping__c> taxMappingLookupList = [
            SELECT Id, Name, DR_Tax_Group__c, DR_Tax_Type__c, DR_Tax_Code__c, DR_Product_Type__c
            FROM Digital_River_Tax_Mapping__c
            WHERE DR_Tax_Code__c = '4512.1'
        ];

        System.runAs(communityUser) {
            Test.startTest();
            String jsonString = '{"isSyncAll": false, "isSyncProduct": true }';
            String productSyncResponse = DRB2B_ProductSyncUtil.syncProducts(jsonString);
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(productSyncResponse);
            System.debug('requestData2--->' + requestData2);
            System.assertEquals(false, requestData2.get('isSuccess'), 'No Product Found');
            Test.stopTest();
        }
    }
}
