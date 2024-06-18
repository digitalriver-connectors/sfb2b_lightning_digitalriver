public with sharing class DRB2B_UpsertSkuModelService {
    
    private static final Set<String> PRODUCT_FIELDS_NAMES = new Set<String>{
        'Id',
        'Name',
        'DR_TAXTYPE__c',
        'DR_TAXGROUP__c',
        'StockKeepingUnit',
        'DR_ECCN__r.Name',
        'DR_Product_Country_Origin__c',
        'DR_HS_Code__c',
        'DR_Part_Number__c', 
        'DR_Product_Weight__c',
        'DR_Unit_of_Weight__c',
        'DR_Managed_Fulfillment__c',
        'DR_Manufacturer_Id__c',
        'DR_SKU_Group__c'
    };

    public final String WEIGHT_UNIT = 'oz';

    @TestVisible
    private static DRB2B_ProductSelector productSelector = new DRB2B_ProductSelector();

    public DRB2B_ProductSyncUpsertSkuRequest getUpsertProductRequestModel(Id productId, String taxCode) {
        Product2 product = productSelector.getById(
            productId,
            PRODUCT_FIELDS_NAMES
        );

        DRB2B_ProductSyncUpsertSkuRequest model = new DRB2B_ProductSyncUpsertSkuRequest();
        DRB2B_ProductSyncUpsertSkuRequest.Metadata productMataObj = new DRB2B_ProductSyncUpsertSkuRequest.Metadata();
        productMataObj.taxType = product.DR_TAXTYPE__c;
        productMataObj.taxGroup = product.DR_TAXGROUP__c;
        productMataObj.sku = product.StockKeepingUnit;

        model.eccn =  product.DR_ECCN__r.Name;
        model.name = product.Name;
        model.countryOfOrigin = product.DR_Product_Country_Origin__c;
        model.fulfill =false;
        model.hsCode  = product.DR_HS_Code__c;
        model.partNumber = product.DR_Part_Number__c;
        model.metadata = productMataObj;  
        model.skuGroupId = product.DR_SKU_Group__c;
        
        if(product.DR_Product_Weight__c != null){
            model.weight = product.DR_Product_Weight__c;
            if(product.DR_Unit_of_Weight__c != null){
                model.weightUnit = product.DR_Unit_of_Weight__c;
            }else{
                model.weightUnit = WEIGHT_UNIT;
            }
        }
        if(product.DR_Managed_Fulfillment__c != null){
            model.managedFulfillment = product.DR_Managed_Fulfillment__c;
        }
        if(product.DR_Manufacturer_Id__c != null){
            model.manufacturerId = product.DR_Manufacturer_Id__c;
        }
        if(String.isNotBlank(taxCode))
        {
            model.taxCode = taxCode;
        }
        return model; 
    }
}
