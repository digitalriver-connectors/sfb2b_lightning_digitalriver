public with sharing class DRB2B_TermsController {
    
    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance();

    @TestVisible
    private static final DRB2B_CheckoutServiceImpl checkoutService = new DRB2B_CheckoutServiceImpl();

    @AuraEnabled
    public static void updateCheckoutWithTerms(id cartId , string terms) {
        try {
            
            checkoutService.updateCheckoutReq(cartId,terms);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }
}
