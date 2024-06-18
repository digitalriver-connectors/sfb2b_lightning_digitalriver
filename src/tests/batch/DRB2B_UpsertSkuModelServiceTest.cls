@isTest
public with sharing class DRB2B_UpsertSkuModelServiceTest {
    private static final String SKU_ID = 'productId';
    private static final Id PRODUCT_ID = DCM_IdUtils.generate(User.getSObjectType());
    private static final String SKU_NAME = 'name';
    private static final String SKU_ECCN = 'EAR99';
    private static final String SKU_TAX_CODE = '95.212';
    private static final String SKU_COUNTRY_OF_ORIGIN = 'US';
    private static final Boolean SKU_FULLFILL = false;
    private static final String SKU_TAX_TYPE = 'Optional Warranties - Purchased at Time of Sale of for Consumer Goods Parts & Labor';
    private static final String SKU_TAX_GROUP = 'Warranties';
    private static final String TEST_SKU_VALUE = 'TEST_SKU_VALUE';

    @TestSetup
    static void setupData() {
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult result = ATK.prepare(DR_ECCN_Lookup__c.SObjectType, 1).build(EntityBuilderFactory.drECCNLookupBuilder).save(false);

            DR_ECCN_Lookup__c drECCN = (DR_ECCN_Lookup__c) result.get(DR_ECCN_Lookup__c.SObjectType)[0];
            insert drECCN;

            result = ATK.prepare(Digital_River_Tax_Mapping__c.SObjectType, 1).build(EntityBuilderFactory.drTaxMappingBuilder).save(false);
            Digital_River_Tax_Mapping__c drTaxMapping = (Digital_River_Tax_Mapping__c) result.get(Digital_River_Tax_Mapping__c.SObjectType)[0];
            insert drTaxMapping;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            product.DR_ECCN__c = drECCN.Id;
            product.DR_TAXGROUP__c = drTaxMapping.DR_Tax_Group__c;
            product.DR_TAXTYPE__c = drTaxMapping.DR_Tax_Type__c;
            product.DR_Part_Number__c = 'abc12345';
            product.DR_Product_Country_Origin__c = 'US';
            product.Sync_Product_to_DR__c   = true;
            product.IsActive = true;

            insert product;
        }
    }

    @isTest
    static void testUpsertProductSuccessResponse() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.portalAccountOwner,
            DRB2B_Constants.PermissionSet.ADMIN
        );

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            List<Product2> productDetails = [Select Id, Name, ISActive, StockKeepingUnit,DR_ECCN__c,DR_TAXGROUP__c,DR_TAXTYPE__c, DR_Part_Number__c, DR_Product_Country_Origin__c, Sync_Product_to_DR__c from Product2 where  DR_Part_Number__c =: 'abc12345'];
            productDetails[0].DR_TAXGROUP__c = 'Downloadable Goods (Non-Software)';
            productDetails[0].DR_TAXTYPE__c = 'Digital Image';
            productDetails[0].DR_Product_Weight__c = 20;
            productDetails[0].DR_Unit_of_Weight__c = 'lb';
            productDetails[0].DR_Managed_Fulfillment__c = 'DRGlobalFulfillment';
            productDetails[0].DR_Manufacturer_Id__c = '12341';
            update productDetails;

            setConfigurationStub();
    
    
            Test.startTest();
            DRB2B_UpsertSkuModelService upserttSKUModelService = new DRB2B_UpsertSkuModelService();
            DRB2B_ProductSyncUpsertSkuRequest request = upserttSKUModelService.getUpsertProductRequestModel(productDetails[0].Id, '4512.1');
            Test.stopTest();

            System.assertEquals(20, request.weight);
            System.assertEquals('lb', request.weightUnit);
        }
    }

    static void setConfigurationStub() {
        DRB2B_ConfigurationSelectorStubProvider stubProvider = new DRB2B_ConfigurationSelectorStubProvider();

        DRB2B_DRApiConstants.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(DRB2B_ConnectorConfigurationSelector.class, stubProvider);

        DRB2B_AuthWire.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(DRB2B_ConnectorConfigurationSelector.class, stubProvider);
    }

}
