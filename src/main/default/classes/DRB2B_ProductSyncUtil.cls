public with sharing class DRB2B_ProductSyncUtil {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.PRODUCT_SYNC);

    public static Map<String, String> drapplicationConfigMap = DRB2B_Utility.getDRapplicationConfigMap();
    public static Map<String, String> drConnectorConfigMap = DRB2B_Utility.getDRConnectorConfigMap();

    public static String syncProducts(String jsonString) {
        Integer defaultBatchSize = 100; // Cannot make more than 100 Callouts in Execute Method
        Map<String, Object> returnedMap = new Map<String, Object>();
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        Boolean isSyncAllProduct = Boolean.valueOf(requestMap.get('isSyncAll'));
        Boolean isSyncProduct = Boolean.valueOf(requestMap.get('isSyncProduct'));
        List<Product2> productList = new List<Product2>();

        try {
            // TODO: Move all SOQL to Selectors!
            if (isSyncAllProduct) {
                productList = new DCM_Query(Product2.sObjectType)
                    .selectField(Product2.DR_ECCN__c)
                    .selectField(Product2.DR_TAXGROUP__c)
                    .selectField(Product2.DR_Product_Country_Origin__c)
                    .addConditionEq(Product2.IsActive, true)
                    .setLimit(2000)
                    .run();
            } else {
                productList = new DCM_Query(Product2.sObjectType)
                    .selectField(Product2.DR_ECCN__c)
                    .selectField(Product2.DR_TAXGROUP__c)
                    .selectField(Product2.DR_Product_Country_Origin__c)
                    .addConditionEq(Product2.IsActive, true)
                    .addConditionEq(Product2.Sync_Product_to_DR__c, true)
                    .setLimit(2000)
                    .run();
            }
            if (productList.size() > 0) {
                String jobName = 'DR Product Sync Batch';
                List<CronTrigger> crnTriggerObjList = [
                    SELECT
                        Id,
                        CronJobDetailId,
                        CronJobDetail.Name,
                        NextFireTime,
                        PreviousFireTime,
                        State,
                        StartTime,
                        EndTime,
                        CronExpression,
                        TimeZoneSidKey,
                        OwnerId,
                        TimesTriggered
                    FROM CronTrigger
                    WHERE CronJobDetail.Name = :jobName
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (crnTriggerObjList != null && crnTriggerObjList.size() > 0) {
                    System.abortJob(crnTriggerObjList.get(0).Id);
                }

                if (isSyncAllProduct) {
                    for (Product2 product : productList) {
                        product.Date_Last_Synced_to_DR__c = null;
                    }

                    try {
                        logger.debug('Product Update Cleaned Records List: ' + String.valueOf(productList));

                        DmlManager.updateAsUser(productList);
                        returnedMap.put('isSuccess', true);
                        returnedMap.put('msg', 'All products will be re-synchronized.');

                        DRB2B_ProductsSyncBatch batchContext = new DRB2B_ProductsSyncBatch();
                        // Batch Size cannot be more than 100 as we Cannot make more than 100 Callouts in Execute Method.
                        Integer batchSize = defaultBatchSize;
                        Integer configuredBatchSize = Integer.valueOf(drConnectorConfigMap.get('Product_Batch_Size'));
                        if (configuredBatchSize > 0 && configuredBatchSize < defaultBatchSize) {
                            batchSize = configuredBatchSize;
                        }

                        if (!Test.isRunningTest()) {
                            Database.executeBatch(batchContext, batchSize);
                        }
                    } catch (Exception e) {
                        returnedMap.put('isSuccess', false);
                        returnedMap.put('msg', 'Please Add user in permission set.');
                    }
                } else {
                    if (isSyncProduct) {
                        DRB2B_ProductsSyncBatch batchContext = new DRB2B_ProductsSyncBatch();
                        Integer batchSize = String.isNotBlank(drapplicationConfigMap.get('Product_Batch_Size'))
                            ? Integer.valueOf(drapplicationConfigMap.get('Product_Batch_Size'))
                            : defaultBatchSize;
                        if (!Test.isRunningTest()) {
                            Database.executeBatch(batchContext, batchSize);
                        }
                        returnedMap.put('isSuccess', true);
                        returnedMap.put('msg', 'Batch Job has been submitted.');
                    }
                }
            } else {
                returnedMap.put('isSuccess', true);
                returnedMap.put('isWarning', true);
                returnedMap.put('msg', 'No product to Sync.');
            }
        } catch (Exception e) {
            logger.error(e);
            returnedMap.put('isSuccess', false);
            returnedMap.put('msg', 'Product Sync Batch processing failed ');
        } finally {
            logger.flush();
        }

        return JSON.serialize(returnedMap);
    }
    public Map<String, String> getCountryISOCodeAndCountryMap() {
        Picklist p = new Picklist(Product2.DR_Product_Country_Origin__c);
        return p.getEntriesMap();
    }

    public Map<String, String> getCountryAndCountryISOCodeMap() {
        Picklist p = new Picklist(Product2.DR_Product_Country_Origin__c);
        return p.getLabelToValueMap();
    }
}
