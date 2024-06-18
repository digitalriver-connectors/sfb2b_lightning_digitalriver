public without sharing class DRB2B_DropinController {
    @TestVisible
    private static final DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();

    @TestVisible
    private static final DRB2B_CartService cartService = new DRB2B_CartService();

    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

    private static final Set<String> CART_FIELDS = new Set<String>{
        'digitalriverv3__DR_Payment_Session_Id__c',
        'digitalriverv3__DR_Checkout_Id__c',
        'digitalriverv3__DR_Amount_Contributed__c',
        'digitalriverv3__DR_Amount_Remaining_to_be_Contributed__c',
        'digitalriverv3__Recurring_Line_Item_Count__c'
    };

    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();

    public static Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();

    @AuraEnabled
    public static Map<String, object> getCart(Id cartId) {
        Map<String, object> result = new Map<String, object>();
        try {
            Webcart cart = cartSelector.getById(
                cartId,
                new Set<String>{
                    'DR_Payment_Session_Id__c',
                    'Buyer_Email__c',
                    'BillingAddress',
                    'Buyer_Phone__c',
                    'Buyer_Name__c',
                    'DR_Checkout_Id__c',
                    'DR_Checkout_Type__c',
                    'GrandTotalAmount',
                    'Recurring_Line_Item_Count__c',
                    'DR_Amount_Remaining_to_be_Contributed__c',
                    'DR_Source_Id__c'
                }
            );
            result.put('cart', cartService.getCartAsWrapper(cart));
            result.put('isCountryStateEnabled', DRB2B_Utility.isCountryStateEnabled());
            logger.debug('dropin controller get cart method call' + result);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static Boolean deattachAllSourcesFromCheckout(String inputData) {
        Boolean isSuccess = false;
        try {
            Map<String, Object> data = (Map<String, Object>) json.deserializeUntyped(inputData);
            Id cartId = (Id) data.get('cartId');
            DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
            WebCart cart = cartSelector.getById(cartId, CART_FIELDS);
            String checkoutId = cart.digitalriverv3__DR_Checkout_Id__c;
            DRB2B_TransactionPaymentSelector paymentSelector = new DRB2B_TransactionPaymentSelector();
            List<DR_Transaction_Payment__c> paymentList = paymentSelector.getBycartId(
                cartId,
                new List<String>{ 'Token__c', 'Id' }
            );
            list<DR_Transaction_Payment__c> deletePayamentRecList = new List<DR_Transaction_Payment__c>();
            logger.info('drb2b dropin controller paymentList' + JSON.serialize(paymentList));
            logger.info('drb2b dropin controller deletePayamentRecList' + JSON.serialize(deletePayamentRecList));
            if (!paymentList.isEmpty()) {
                for (DR_Transaction_Payment__c payment : paymentList) {
                    DCM_HttpClient.Response response = requestService.deletePaymentSourceFromCheckout(
                            checkoutId,
                            payment.Token__c,
                            cartId
                        )
                        .fetch();
                    if (response.getStatusCode() == 204) {
                        deletePayamentRecList.add(payment);
                        isSuccess = true;
                    } else {
                        isSuccess = false;
                    }
                }
                if(!Test.isRunningTest()){
                    DRB2B_CustomerCreditService.getAmountRemainingforCheckout(inputData);
                }
                logger.info('Delete DR payment transaction record' + JSON.serialize(deletePayamentRecList));
                if (!deletePayamentRecList.isEmpty()) {
                    if (!isGuestUser) {
                        DmlManager.deleteAsUser(deletePayamentRecList);
                    } else {
                        DmlManager.deleteAsSystem(deletePayamentRecList);
                    }
                }
            } else {
                isSuccess = true;
            }
        } catch (exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

        return isSuccess;
    }
}
