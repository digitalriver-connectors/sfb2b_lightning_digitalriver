@isTest
private class DRB2B_ProductsSyncBatchTest {
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
            List<DR_ECCN_Lookup__c> drEccnLookupList = [Select Id,Name,DR_Notes__c from DR_ECCN_Lookup__c where Name = 'EAR99'];
            List<Digital_River_Tax_Mapping__c> taxMappingLookupList = [Select Id, Name, DR_Tax_Group__c, DR_Tax_Type__c, DR_Tax_Code__c, DR_Product_Type__c from Digital_River_Tax_Mapping__c where DR_Tax_Code__c = '4512.1'];
            List<Product2> productDetails = [Select Id, Name, ISActive, StockKeepingUnit,DR_ECCN__c,DR_TAXGROUP__c,DR_TAXTYPE__c, DR_Part_Number__c, DR_Product_Country_Origin__c, Sync_Product_to_DR__c from Product2 where  DR_Part_Number__c =: 'abc12345'];
            productDetails[0].DR_TAXGROUP__c = 'Downloadable Goods (Non-Software)';
            productDetails[0].DR_TAXTYPE__c = 'Digital Image';
            update productDetails;

            setUpsertModelService();
            setConfigurationStub();
    
            Test.setMock(HttpCalloutMock.class, new DRUpsertSKUSuccessMock());
    
            Test.startTest();
            DRB2B_ProductSyncUpsertSkuResponse drProductSyncResponseObj = new DRB2B_ProductService().upsertProduct(PRODUCT_ID, SKU_TAX_CODE);
            DRB2B_ProductsSyncBatch productSyncBatch = new DRB2B_ProductsSyncBatch();
            try{
                Id batchJobId = Database.executeBatch(productSyncBatch, 1);
                System.abortJob(batchJobId);
            }catch(Exception e){

            }
            Test.stopTest();
    
            System.assert(drProductSyncResponseObj != null);
            System.assertEquals(true, drProductSyncResponseObj.isSuccess,'Product Sync Failed');
        }
    }

    @isTest
    static void testUpsertProductNegativeResponse() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.portalAccountOwner,
            DRB2B_Constants.PermissionSet.ADMIN
        );

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            List<DR_ECCN_Lookup__c> drEccnLookupList = [Select Id,Name,DR_Notes__c from DR_ECCN_Lookup__c where Name = 'EAR99'];
            List<Digital_River_Tax_Mapping__c> taxMappingLookupList = [Select Id, Name, DR_Tax_Group__c, DR_Tax_Type__c, DR_Tax_Code__c, DR_Product_Type__c from Digital_River_Tax_Mapping__c where DR_Tax_Code__c = '4512.1'];
            List<Product2> productDetails = [Select Id, Name, ISActive, StockKeepingUnit,DR_ECCN__c,DR_TAXGROUP__c,DR_TAXTYPE__c, DR_Part_Number__c, DR_Product_Country_Origin__c, Sync_Product_to_DR__c from Product2 where  DR_ECCN__c=: drEccnLookupList.get(0).Id];
            productDetails[0].DR_TAXGROUP__c = 'Downloadable Goods (Non-Software)';
            productDetails[0].DR_TAXTYPE__c = 'Digital Image';
            update productDetails;

            setUpsertModelService();
            setConfigurationStub();
    
            Test.setMock(HttpCalloutMock.class, new DRUpsertSKUErrorMock());
    
            Test.startTest();
            DRB2B_ProductSyncUpsertSkuResponse drProductSyncResponseObj = new DRB2B_ProductService().upsertProduct(PRODUCT_ID, SKU_TAX_CODE);
            DRB2B_ProductsSyncBatch productSyncBatch = new DRB2B_ProductsSyncBatch();
            Id batchJobId = Database.executeBatch(productSyncBatch, 1);
            System.abortJob(batchJobId);
            Test.stopTest();
    
            System.assert(drProductSyncResponseObj != null);
            System.assertEquals(false, drProductSyncResponseObj.isSuccess,'Product Sync Failed');
        }
    }

    private class DRUpsertSKUSuccessMock extends HttpCalloutMockRouter {
        public DRUpsertSKUSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerEndpointVariable('id', '([0-9a-zA-Z]{15,18})');
            this.registerJsonMock(
                'Create SKU',
                'PUT',
                '{{endpoint}}/' + DRB2B_DRApiConstants.CREATE_SKU_PATH + 
                '/{{id}}',
                DRB2B_DRApiConstants.UPSERT_SUCCESS_STATUS,
                'Created',
                getUpsertSKUSuccessResponseModel()
            );
        }
    }

    private static DRB2B_ProductSyncUpsertSkuResponse getUpsertSKUSuccessResponseModel() {
        DRB2B_ProductSyncUpsertSkuResponse responseModel = new DRB2B_ProductSyncUpsertSkuResponse();
        DRB2B_ProductSyncUpsertSkuResponse.Metadata productMataObj = new DRB2B_ProductSyncUpsertSkuResponse.Metadata();
        productMataObj.taxType = SKU_TAX_TYPE;
        productMataObj.taxGroup = SKU_TAX_GROUP;
        productMataObj.sku = TEST_SKU_VALUE;

        responseModel.Id = SKU_ID;
        responseModel.Name = SKU_NAME;
        responseModel.eccn = SKU_ECCN;
        responseModel.taxCode = SKU_TAX_CODE;
        responseModel.countryOfOrigin = SKU_COUNTRY_OF_ORIGIN;
        responseModel.fulfill = SKU_FULLFILL;
        responseModel.metadata = productMataObj; 
        return responseModel;
    }
    private static void setUpsertModelService() {
        DRB2B_ProductSyncUpsertSkuRequest model = new DRB2B_ProductSyncUpsertSkuRequest();
        DRB2B_ProductSyncUpsertSkuRequest.Metadata productMataObj = new DRB2B_ProductSyncUpsertSkuRequest.Metadata();
        productMataObj.taxType = SKU_TAX_TYPE;
        productMataObj.taxGroup = SKU_TAX_GROUP;
        productMataObj.sku = TEST_SKU_VALUE;

        model.eccn =  SKU_ECCN;
        model.taxCode = SKU_TAX_CODE;
        model.name = SKU_NAME;
        model.countryOfOrigin = SKU_COUNTRY_OF_ORIGIN;
        model.fulfill =false;
        model.metadata = productMataObj;

        DRB2B_ProductService.productSyncUpsertRequest = (DRB2B_UpsertSkuModelService) Test.createStub(
            DRB2B_UpsertSkuModelService.class,
            new DCM_GenericStubProvider(new Map<String, Object>{ 'getUpsertProductRequestModel' => model })
        );
    }

    static void setConfigurationStub() {
        DRB2B_ConfigurationSelectorStubProvider stubProvider = new DRB2B_ConfigurationSelectorStubProvider();

        DRB2B_DRApiConstants.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(DRB2B_ConnectorConfigurationSelector.class, stubProvider);

        DRB2B_AuthWire.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(DRB2B_ConnectorConfigurationSelector.class, stubProvider);
    }

    private class DRUpsertSKUErrorMock extends HttpCalloutMockRouter {
        public DRUpsertSKUErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerEndpointVariable('id', '([0-9a-zA-Z]{15,18})');
            this.registerJsonMock(
            'Create SKU', 
            'PUT',
            '{{endpoint}}/' + DRB2B_DRApiConstants.CREATE_SKU_PATH + 
            '/{{id}}',
            404,
            'Error', 
            getUpsertSkuErrorResponseModel());
        }
    }

    private static DRB2B_ErrorResponse getUpsertSkuErrorResponseModel() {
        
        DRB2B_ErrorResponse.Errors  errorResponseModel = new DRB2B_ErrorResponse.Errors();
        errorResponseModel.code = 'testCode';
        errorResponseModel.message = 'testMessage';
        errorResponseModel.parameter = 'testParameter';

        DRB2B_ErrorResponse responseModel = new DRB2B_ErrorResponse();
        responseModel.type = 'bad_request';
        responseModel.errors = new List<DRB2B_ErrorResponse.Errors>{ errorResponseModel };
        return responseModel;
    }
}
