global without sharing  class DRB2B_CartHelper {
   
    @TestVisible
    public static final DCM_Logger logger = DCM_Logger.getInstance();

    @AuraEnabled
    global static String getCartId(){
        try {
            User u = [SELECT id, accountId FROM user WHERE id=:UserInfo.getUserId() ][0];
            Id id = [SELECT id FROM WebCart WHERE CreatedById=:u.Id AND status IN ('active','checkout') LIMIT 1].id;
            logger.info('DRB2B_CartHelper getCartId details UserId and CartId' + u  + id);
            return String.valueOf(id);
        } 
        catch (Exception e) {
            logger.error('DRB2B_CartHelper getCartId method error' + e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {
            logger.flush();
        }
    }

    @AuraEnabled
    global static String getCartIdWithCommunityId(string communityId){
        try {
            String webstoreIdFromCommunity;
            if(Test.isRunningTest() && communityId == 'isTest'){
                webCart cart = [SELECT ID, WebStoreId, CreatedById FROM WebCart LIMIT 1];
                System.debug('WebCart::>>'+cart);
                webstoreIdFromCommunity = cart.WebStoreId;
            }else{
                webstoreIdFromCommunity = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            }
            User u = [SELECT id, accountId FROM user WHERE id=:UserInfo.getUserId() ][0];
            System.debug('UserId::>>'+u.Id);
            Id id = [SELECT id FROM WebCart WHERE WebStoreId =: webstoreIdFromCommunity AND CreatedById=:u.Id AND status IN ('active','checkout') LIMIT 1].id;
            return String.valueOf(id);
          //  return String.valueOf([SELECT id FROM WebCart WHERE CreatedById=:u.Id AND status IN ('active','checkout') LIMIT 1].id);
        } 
        catch (Exception e) {
            logger.error('DRB2B_CartHelper getCartId method error' + e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {
            logger.flush();
        }
    }
}