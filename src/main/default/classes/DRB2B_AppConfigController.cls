/**
 * :
 *
 * @author : Devanshu Sood
@group             :
@last modified on  : 04-09-2021
@last modified by  : Arun Sood
Modifications Log
Ver   Date         Author          Modification
1.0   03-31-2021   Devanshu Sood   Initial Version
 **/
public with sharing class DRB2B_AppConfigController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.APP_CONFIG);
    private static final DRB2B_CustomerService customerService = new DRB2B_CustomerService();
    @AuraEnabled
    public static String getTabsAndConfiguration() {
        String result;

        try {
            result = DRB2B_AppConfigService.getTabsAndConfiguration();
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return result;
    }

    @AuraEnabled
    public static Boolean updateBulkMetadata(String jsonString) {
        Boolean result;

        try {
            result = DRB2B_AppConfigService.updateBulkMetadata(jsonString);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return result;
    }

    @AuraEnabled
    public static String syncProducts(String jsonString) {
        String result;

        try {
            result = DRB2B_ProductSyncUtil.syncProducts(jsonString);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return result;
    }

    @AuraEnabled
    public static String checkConnection(String userid) {
        String result;
        logger.info(userid, 'create customer at DR ');
        try {
            DRB2B_FileLinkService fs= new DRB2B_FileLinkService();
            result = JSON.serialize(fs.getFileLink(userid, ''));
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return result;
    }
}
