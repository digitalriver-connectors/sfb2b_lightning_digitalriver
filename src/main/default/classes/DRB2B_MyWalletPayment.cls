public with sharing class DRB2B_MyWalletPayment {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.MY_WALLET);

    @AuraEnabled
    public static string getCheckoutAndSourceInfoForSCA(String jsonString) {
        String result;
        try {
            result = new DRB2B_MyWalletService().getCheckoutAndSourceInfoForSCA(jsonString);
            logger.info('result :' + result);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static Boolean attachSourceToCheckout(String jsonString) {
        Boolean result;
        try {
            result = new DRB2B_MyWalletService().attachSourceToCheckout(jsonString);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
}
