/**
 * :
 *
 * @author : Devanshu Sood
@group             :
@last modified on  : 04-07-2021
@last modified by  : Devanshu Sood
Modifications Log
Ver   Date         Author          Modification
1.0   03-31-2021   Devanshu Sood   Initial Version
 **/
public with sharing class DRB2B_AppConfigService {
    public static final String CONFIG_TABS = 'DR_App_Tabs';
    public static final String META_NAME = 'DR_Connector_Configuration__mdt';

    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.APP_CONFIG);

    /**
     * :get All tabs and configuration to show on DR APP page
     *
     * @return string
     *
     * @author Devanshu Sood | 04-05-2021
     **/
    public static String getTabsAndConfiguration() {
        //get tabs which need to be displayed in DR App
        String response;

        DR_Application_Configuration__mdt drTabs = DR_Application_Configuration__mdt.getInstance(CONFIG_TABS);
        List<String> visibleTabs = drTabs.Key__c.deleteWhitespace().split(',');
        Map<String, List<Object>> mapTypeConfig = new Map<String, List<Object>>();
        for (DR_Connector_Configuration__mdt mdt : [
            SELECT Id, Label, Helper_Text__c, Key__c, Visible__c, Config_Type__c, Display_Order__c, IsPicklist__c
            FROM DR_Connector_Configuration__mdt
            WHERE Config_Type__c IN :visibleTabs AND Visible__c = TRUE
            WITH SECURITY_ENFORCED
            ORDER BY Display_Order__c ASC
        ]) {
            if (mapTypeConfig.containsKey(mdt.Config_Type__c)) {
                mapTypeConfig.get(mdt.Config_Type__c).add(mdt);
            } else {
                mapTypeConfig.put(mdt.Config_Type__c, new List<Object>{ mdt });
            }
        }

        response = JSON.serialize(mapTypeConfig);

        return response;
    }

    /**
     * :this method supports updating of bulk metadata
     *
     * @param jsonString
     *
     * @return Boolean
     *
     * @author Devanshu Sood | 04-05-2021
     **/
    public static Boolean updateBulkMetadata(String jsonString) {
        Boolean isSuccess = true;
        String NAMESPACE = DRB2B_Utility.nameSpacePrefix();
        try {
            Map<String, Object> metaDataToUpdate = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            for (DR_Connector_Configuration__mdt objMetadata : [
                SELECT Id, DeveloperName, MasterLabel, Label, digitalriverv3__Key__c
                FROM DR_Connector_Configuration__mdt
                WHERE Id IN :metaDataToUpdate.keySet()
            ]) {
                Metadata.CustomMetadata metadataRec = new Metadata.CustomMetadata();
                metadataRec.fullName = NAMESPACE + META_NAME + '.' + NAMESPACE + objMetadata.DeveloperName;
                metadataRec.label = objMetadata.MasterLabel;
                Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
                customFieldtoUpdate.field = DR_Connector_Configuration__mdt.Key__c.getDescribe().getName();
                customFieldtoUpdate.value = metaDataToUpdate.get(objMetadata.Id);
                metadataRec.values.add(customFieldtoUpdate);
                mdContainer.addMetadata(metadataRec);
            }

            DRB2B_CustomMetadataCallbackController callback = new DRB2B_CustomMetadataCallbackController();
            Id jobId;
            if (!Test.isRunningTest()) {
                jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            }
        } catch (Exception e) {
            isSuccess = false;
            logger.error(e);

            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return isSuccess;
    }
}
