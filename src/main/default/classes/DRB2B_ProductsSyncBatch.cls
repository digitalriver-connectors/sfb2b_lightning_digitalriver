global with sharing class DRB2B_ProductsSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.PRODUCT_SYNC);
    private static final Stringifier stringifier = new Stringifier();
    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    public static final String WITH_SECURITY_ENFORCED = ' WITH SECURITY_ENFORCED ';

    public List<Product2> allProcessedProducts = new List<Product2>();
    Map<String, String> taxCodeMap = new Map<String, String>();
    List<Digital_River_Tax_Mapping__c> taxCodesList = new List<Digital_River_Tax_Mapping__c>();

    Map<String, String> upadtedSKUMap = new Map<String, String>();
    public Set<String> failureProductIds = new Set<String>();
    Boolean isErrorExistsInJob = false; //To check if something failed in Job

    @TestVisible
    private DRB2B_DigitalRiverTaxMappingSelector taxMappingSelector = new DRB2B_DigitalRiverTaxMappingSelector();

    global DRB2B_ProductsSyncBatch() {
        try {
            this.taxCodesList = taxMappingSelector.getAll();
            if (taxCodesList.size() > 0) {
                for (Digital_River_Tax_Mapping__c taxCodes : taxCodesList) {
                    taxCodeMap.put(taxCodes.DR_Tax_Group__c + '#' + taxCodes.DR_Tax_Type__c, taxCodes.DR_Tax_Code__c);
                }
            }
        } catch (Exception e) {
            isErrorExistsInJob = true;
            logger.error(e);
        } finally {
            logger.flush();
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator queryLocator;
        try {
            String queryString = 'Select Id, IsActive, DR_SKU_Group__c,DR_Part_Number__c, Date_Last_Synced_to_DR__c, DR_ECCN__c, DR_HS_Code__c, DR_Product_Country_Origin__c, DR_TAXGROUP__c, DR_TAXTYPE__c, ProductCode, Name, Type, StockKeepingUnit, Sync_Product_to_DR__c,DR_Product_Weight__c,DR_Unit_of_Weight__c,DR_Managed_Fulfillment__c,DR_Manufacturer_Id__c,DR_ECCN__r.Name from Product2 ';
            String whereClause = ' where IsActive = true AND Sync_Product_to_DR__c = true AND ((DR_SKU_Group__c!=null) OR(DR_ECCN__c != null AND DR_TAXTYPE__c != null AND DR_TAXGROUP__c != null AND DR_Product_Country_Origin__c != null))';
            DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
            String orderAndLimitString;
            if (Test.isRunningTest()) {
                orderAndLimitString = ' LIMIT 1 ';
            } else {
                //orderAndLimitString = ' LIMIT 100 ';
                orderAndLimitString = 'LIMIT ' + configurationSelector.getProductSyncJobQueryLimit();
            }

            String finalQuery = queryString + whereClause + WITH_SECURITY_ENFORCED + orderAndLimitString;
            logger.info('FinalQuery: ' + finalQuery);
            queryLocator = Database.getQueryLocator(finalQuery);
            logger.debug('Query from query locator: ' + queryLocator.getQuery());
        } catch (Exception e) {
            isErrorExistsInJob = true;
            logger.error(e);
        } finally {
            logger.flush();
        }
        return queryLocator;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        allProcessedProducts.addAll((List<Product2>) scope);
        logger.info('All products: ' + String.valueOf(allProcessedProducts));

        HttpResponse drproductSyncResponse;
        String httpBody;

        try {
            for (Product2 products : allProcessedProducts) {
                String taxCode = '';
                if (taxCodeMap.containsKey(products.DR_TAXGROUP__c + '#' + products.DR_TAXTYPE__c)) {
                    taxCode = taxCodeMap.get(products.DR_TAXGROUP__c + '#' + products.DR_TAXTYPE__c);
                }

                DRB2B_ProductService productService = new DRB2B_ProductService();
                DRB2B_ProductSyncUpsertSkuResponse drProductSyncResponseObj = productService.upsertProduct(
                    products.Id,
                    taxCode
                );

                logger.debug(httpBody);
                if (!drProductSyncResponseObj.isSuccess) {
                    isErrorExistsInJob = true;
                    failureProductIds.add(products.Id);
                }
            }
        } catch (Exception e) {
            isErrorExistsInJob = true;
            logger.error(e);
        } finally {
            logger.flush();
        }
    }

    global void finish(Database.BatchableContext bc) {
        try {
            if (allProcessedProducts.size() > 0) {
                List<Product2> productListForUpdating = new List<Product2>();
                for (Product2 products : allProcessedProducts) {
                    if (failureProductIds.size() > 0 && failureProductIds.contains(products.Id)) {
                        continue;
                    }
                    products.Date_Last_Synced_to_DR__c = DateTime.now();
                    products.Sync_Product_to_DR__c = false;
                    productListForUpdating.add(products);
                }
                DmlManager.updateAsUser(productListForUpdating);
            }
            Integer scheduleTime = configurationSelector.getBatchScheduleTime();
            String jobName = 'DR Product Sync Batch';
            Set<String> jobStatusSet = new Set<String>{ 'COMPLETE', 'DEBUG', 'DELETED', 'BLOCKED' };
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
                LIMIT 1
            ];
            if (crnTriggerObjList != null && crnTriggerObjList.size() > 0) {
                CronTrigger crnTriggerObj = crnTriggerObjList.get(0);
                if (jobStatusSet.contains(crnTriggerObj.State.toUpperCase())) {
                    System.scheduleBatch(new DRB2B_ProductsSyncBatch(), 'DR Product Sync Batch', scheduleTime);
                }
            } else {
                System.scheduleBatch(new DRB2B_ProductsSyncBatch(), 'DR Product Sync Batch', scheduleTime);
            }
            //Send Email if Anything get Failed
            if (isErrorExistsInJob) {
                String emailToSend = configurationSelector.getConnectorNotificationEmail();
                DCM_EmailUtil.sendMail(
                    'Product Sync Job Failed',
                    'Product Sync Job Failed. Please check DCM Application logs for more information.',
                    emailToSend,
                    ''
                );
            }
        } catch (Exception e) {
            isErrorExistsInJob = true;
            logger.error(e);
        } finally {
            logger.flush();
        }
    }
}
