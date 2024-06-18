global with sharing class DRB2B_RetrieveSkuGroup implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.DigitalRiver_SKU_GROUP);

    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();
    public static final String WITH_SECURITY_ENFORCED = ' WITH SECURITY_ENFORCED ';
    public Boolean hasMoreData = false;
    public String lastRecordOfList = '';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator queryLocator;
        try {
            String queryString = 'Select Id, IsActive, digitalriverv3__DR_SKU_Group__c, Name, Type from Product2 ';
            String whereClause = ' where IsActive = true ';
            DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
            String orderAndLimitString;
            if (Test.isRunningTest()) {
                orderAndLimitString = ' LIMIT 1 ';
            } else {
               // orderAndLimitString = ' LIMIT 2000 ';
               orderAndLimitString = ' LIMIT '+ configurationSelector.getSkuGroupSyncJobQueryLimit();
            }

            String finalQuery = queryString + whereClause + WITH_SECURITY_ENFORCED + orderAndLimitString;
            logger.info('FinalQuery: ' + finalQuery);
            queryLocator = Database.getQueryLocator(finalQuery);
            logger.debug('Query from query locator: ' + queryLocator.getQuery());
            LOGGER.flush();
        }catch (Exception e) {
            //isErrorExistsInJob = true;
            logger.error(e);
        }finally {
            logger.flush();
        }
        return queryLocator;
    }

    global void execute(Database.BatchableContext bc, List<Product2> objectList) {
        List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
        try {
            Map<String,String> skuGroupMap = getSKUGroup();
            if(skuGroupMap != null){
                for(String key : skuGroupMap.keySet()){
                    DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
                    customValue.fullName = skuGroupMap.get(key); //API name of picklist value
                    customValue.default_x = false;//false;
                    customValue.isActive = true; //false;
                    customValue.label = key; //'United States';
                    customValuesList.add(customValue);
                }
                System.debug('customValuesList --->'+customValuesList);
                DRB2B_PicklistMetaDataService.createPicklistField('Product2','digitalriverv3__DR_SKU_Group__c', 'DR SKU Group', customValuesList);
            }else{
                LOGGER.error('Did not get any SKU group');
            }
        }catch(Exception e) { // TODO: Handle Exceptions properly
            System.debug('Exception -->'+e);
            LOGGER.error(e);
        }finally {
            LOGGER.flush();
        }
    }
    global void finish(Database.BatchableContext bc) {
    }

    public Map<String,String> getSKUGroup(String lastRecordOfList, List<DRB2B_SKUGroupModel.Data> skuGroupDataList){
        Map<String,String> skuGroupMap = new Map<String,String>();
        DCM_HttpClient.Response skuGroupResponse = requestService.getSKUGroupRequest(lastRecordOfList).fetch();
        System.debug('skuGroupResponse --->'+skuGroupResponse);
        if(skuGroupResponse.getStatusCode() == 200){
            DRB2B_SKUGroupModel skuGroup = DRB2B_SKUGroupModel.parse(skuGroupResponse.getBody());
            skuGroupDataList.addAll(skuGroup.data);
            System.debug('skuGroup.hasMore------poaram->'+skuGroup.hasMore);
            lastRecordOfList = skuGroupDataList.get(skuGroupDataList.size() -1).id;
            if(Test.isRunningTest()){
                skuGroup.hasMore = false;
            }
            if(skuGroup.hasMore){
                skuGroupMap = getSKUGroup(lastRecordOfList, skuGroupDataList);
            }else{
                System.debug('skuGroupDataList --->'+skuGroupDataList);
                for(DRB2B_SKUGroupModel.Data skuGroupData: skuGroupDataList){
                    skuGroupMap.put(skuGroupData.alias, skuGroupData.id);
                }
            }
        }else{
            DRB2B_ErrorResponse errorMessages = (DRB2B_ErrorResponse) skuGroupResponse.asType(DRB2B_ErrorResponse.class);
            LOGGER.error(System.Label.DR_API_Error + errorMessages.Errors[0].message);
        }
        return skuGroupMap;
    }
    public Map<String,String> getSKUGroup(){
        Map<String,String> skuGroupMap = new Map<String,String>();
        DCM_HttpClient.Response skuGroupResponse = requestService.getSKUGroupRequest().fetch();
        if(skuGroupResponse.getStatusCode() == 200){
            DRB2B_SKUGroupModel skuGroup = DRB2B_SKUGroupModel.parse(skuGroupResponse.getBody());
            List<DRB2B_SKUGroupModel.Data> skuGroupDataList = skuGroup.data;
            lastRecordOfList = skuGroupDataList.get(skuGroupDataList.size() -1).id;
            if(skuGroup.hasMore){
                skuGroupMap = getSKUGroup(lastRecordOfList, skuGroupDataList);
            }else{
                for(DRB2B_SKUGroupModel.Data skuGroupData: skuGroupDataList){
                    skuGroupMap.put(skuGroupData.alias, skuGroupData.id);
                }
            }
        }else{
            DRB2B_ErrorResponse errorMessages = (DRB2B_ErrorResponse) skuGroupResponse.asType(DRB2B_ErrorResponse.class);
            LOGGER.error(System.Label.DR_API_Error + errorMessages.Errors[0].message);
        }
        return skuGroupMap;
    }
}