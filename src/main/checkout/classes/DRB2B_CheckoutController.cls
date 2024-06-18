public without sharing class DRB2B_CheckoutController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

    private static DRB2B_CheckoutService checkoutService = new DRB2B_CheckoutServiceImpl();

    @TestVisible
    private static DRB2B_TransactionPaymentService transactionPaymentService = new DRB2B_TransactionPaymentService();

    @AuraEnabled
    public static void attachSource(Id cartId, String sourceString) {
        try {
            DRB2B_CreateCheckoutResponseModel.Source source = (DRB2B_CreateCheckoutResponseModel.Source) JSON.deserialize(
                DRB2B_Utility.modifyJSON(sourceString, new Map<String, String>{ 'currency' => 'drCurrency' }),
                DRB2B_CreateCheckoutResponseModel.Source.class
            );
            checkoutService.attachSource(cartId, source);
        } catch (Exception e) {
            logger.error('Error from Checkout controller attach source method ', +e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static boolean attachSourceLWR(Id cartId, String sourceString) {
        try {
            DRB2B_CreateCheckoutResponseModel.Source source = (DRB2B_CreateCheckoutResponseModel.Source) JSON.deserialize(
                DRB2B_Utility.modifyJSON(sourceString, new Map<String, String>{ 'currency' => 'drCurrency' }),
                DRB2B_CreateCheckoutResponseModel.Source.class
            );
            return checkoutService.attachSourceLWR(cartId, source);
        } catch (Exception e) {
            logger.error('Error from Checkout controller attach source method' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static void convertToOrder(Id cartId) {
        try {
            checkoutService.convertToOrder(cartId);
        } catch (DmlManager.DmlManagerException e) {
            logger.error('Digitalriver order creation failed' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            logger.error('Digitalriver order creation failed' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static string convertToOrderLWR(Id cartId) {
        String result;
        try {
            result = checkoutService.convertToOrderLWR(cartId);
        } catch (DmlManager.DmlManagerException e) {
            logger.error('Digitalriver order creation failed' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            logger.error('Digitalriver order creation failed' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static void refreshCartBasedOnDrRecord(Id cartId) {
        try {
            checkoutService.refreshCartBasedOnDrRecord(cartId);
        } catch (Exception e) {
            logger.error('Inside checkout controller refreshCartBasedOnDrRecord method error' + e.getMessage());
            logger.error(cartId, e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }
    @AuraEnabled
    public static string getOrderDetail(Id cartId) {
        try {
            return JSON.serialize(
                [
                    SELECT OrderId, order.orderNumber
                    FROM CartCheckoutSession
                    WHERE WebCartId = :cartId AND IsArchived = FALSE
                ]
            );
        } catch (Exception e) {
            logger.error(cartId, e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static string attachSourceWithCustomer(String jsonString) {
        String result;
        try {
            logger.debug('Into method attachSourceWithCustomer');
            result = new DRB2B_MyWalletService().attachSourceWithCustomer(jsonString);
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            Boolean isSuccess = (Boolean) resultMap.get('isSuccess');
            String errorMessage = (String) resultMap.get('message');
            if (!isSuccess) {
                Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                Id cartId = (Id) inputMap.get('cartId');
                new DRB2B_CheckoutServiceImpl().updatePaymentFailureStateOnOrder(errorMessage, cartId);
            }
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
    
    @AuraEnabled
    public static void sfFailedCancelOrder (String  drOrderId) {        
        checkoutService.sfFailedcancelDROrder(drOrderId);      
    } 
}
