/**
 * @description       :
 * @author            : Arun Sood
 * @group             :
 * @last modified on  : 04-08-2021
 * @last modified by  : Arun Sood
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   04-08-2021   Arun Sood   Initial Version
 **/
trigger DRB2B_UpdateProduct on Product2(before update, before insert, after update) {
    @TestVisible
    private static final String PHYSICAL = 'Physical';
    @TestVisible
    private DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();
    private DRB2B_CartService cartService = new DRB2B_CartService();
    Map<String, String> taxTypeMap = new Map<String, String>();
    if(Test.isRunningTest()){
        taxTypeMap.put('Downloadable Goods (Non-Software)#Digital Image','Digital');
    }
    else{
        taxTypeMap = cartService.getTaxTypeMap();
    }

    //Fire Only If Record is not updated in product Sync Job
    if (!System.isBatch()) {
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Product2 prodObjNewRecord : Trigger.new) {
                Product2 prodObjOldRecord = Trigger.oldMap.get(prodObjNewRecord.Id);
                if (String.isBlank(prodObjNewRecord.digitalriverv3__DR_SKU_Group__c) && String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_TAXGROUP__c) &&
                 String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_TAXTYPE__c))
                {                   
                    if(PHYSICAL.equalsIgnoreCase(taxTypeMap.get(prodObjNewRecord.DR_TAXGROUP__c + '#' + prodObjNewRecord.DR_TAXTYPE__c)))
                     {
                        prodObjNewRecord.digitalriverv3__DR_IS_DIGITAL_PRODUCT__c=false;
                     }
                     else
                     {
                        prodObjNewRecord.digitalriverv3__DR_IS_DIGITAL_PRODUCT__c=true;
                }
            }
                // Check if all required DR fields are populated on Product
                if (
                    (String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_SKU_Group__c)) ||
                    (String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_ECCN__c) &&
                    String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_Product_Country_Origin__c) &&
                    String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_TAXGROUP__c) &&
                    String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_TAXTYPE__c))
                ) {
                    //Check if any of the DR fields are modified
                    if (
                        prodObjNewRecord.digitalriverv3__DR_ECCN__c != prodObjOldRecord.digitalriverv3__DR_ECCN__c ||
                        prodObjNewRecord.digitalriverv3__DR_Product_Country_Origin__c !=
                        prodObjOldRecord.digitalriverv3__DR_Product_Country_Origin__c ||
                        prodObjNewRecord.digitalriverv3__DR_TAXGROUP__c !=
                        prodObjOldRecord.digitalriverv3__DR_TAXGROUP__c ||
                        prodObjNewRecord.digitalriverv3__DR_TAXTYPE__c !=
                        prodObjOldRecord.digitalriverv3__DR_TAXTYPE__c ||
                        prodObjNewRecord.digitalriverv3__DR_HS_Code__c !=
                        prodObjOldRecord.digitalriverv3__DR_HS_Code__c ||
                        prodObjNewRecord.digitalriverv3__DR_Part_Number__c !=
                        prodObjOldRecord.digitalriverv3__DR_Part_Number__c ||
                        prodObjNewRecord.digitalriverv3__DR_Product_Weight__c !=
                        prodObjOldRecord.digitalriverv3__DR_Product_Weight__c ||
                        prodObjNewRecord.digitalriverv3__DR_SKU_Group__c != prodObjOldRecord.digitalriverv3__DR_SKU_Group__c ||
                        prodObjNewRecord.digitalriverv3__DR_Unit_of_Weight__c !=
                        prodObjOldRecord.digitalriverv3__DR_Unit_of_Weight__c ||
                        prodObjNewRecord.digitalriverv3__DR_Managed_Fulfillment__c !=
                        prodObjOldRecord.digitalriverv3__DR_Managed_Fulfillment__c ||
                        prodObjNewRecord.digitalriverv3__DR_Manufacturer_Id__c !=
                        prodObjOldRecord.digitalriverv3__DR_Manufacturer_Id__c ||
                        (prodObjNewRecord.digitalriverv3__Date_Last_Synced_to_DR__c == null &&
                        prodObjNewRecord.digitalriverv3__Date_Last_Synced_to_DR__c !=
                        prodObjOldRecord.digitalriverv3__Date_Last_Synced_to_DR__c)
                    ) {
                        prodObjNewRecord.digitalriverv3__Sync_Product_to_DR__c = true;
                    }
                } else {
                    // if any of the required DR fields is not populated on Product
                    prodObjNewRecord.digitalriverv3__Sync_Product_to_DR__c = false;
                }
            }
        } else if (Trigger.isBefore && Trigger.isInsert) {
            for (Product2 prodObjNewRecord : Trigger.new) {           
                 if (String.isBlank(prodObjNewRecord.digitalriverv3__DR_SKU_Group__c) && String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_TAXGROUP__c) &&
                 String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_TAXTYPE__c))
                {
                    if(PHYSICAL.equalsIgnoreCase(taxTypeMap.get(prodObjNewRecord.DR_TAXGROUP__c + '#' + prodObjNewRecord.DR_TAXTYPE__c)))
                     {
                        prodObjNewRecord.digitalriverv3__DR_IS_DIGITAL_PRODUCT__c=false;
                     }
                     else
                     {
                        prodObjNewRecord.digitalriverv3__DR_IS_DIGITAL_PRODUCT__c=true;
                      }
                 }
                 // Check if all requird DR fields are populated on Product
                if (
                    (String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_SKU_Group__c)) ||
                    (String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_ECCN__c) &&
                    String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_Product_Country_Origin__c) &&
                    String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_TAXGROUP__c) &&
                    String.isNotBlank(prodObjNewRecord.digitalriverv3__DR_TAXTYPE__c))
                ) {
                    prodObjNewRecord.digitalriverv3__Sync_Product_to_DR__c = true;
                }
            }
        }
    }

}