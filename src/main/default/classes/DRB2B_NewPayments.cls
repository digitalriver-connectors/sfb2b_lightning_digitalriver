public with sharing class DRB2B_NewPayments {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.MY_WALLET);

    @AuraEnabled
    public static String getBillingContactPointAddress() {
        String result;

        try {
            result = Json.serialize(new DRB2B_MyWalletService().getBillingContactPointAddress());
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
    public static string attachSourceWithCustomer(String jsonString) {
        String result;
        try {
            result = new DRB2B_MyWalletService().attachSourceWithCustomer(jsonString);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
}
