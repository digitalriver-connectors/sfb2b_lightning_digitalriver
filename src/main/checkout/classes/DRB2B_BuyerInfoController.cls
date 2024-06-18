public with sharing class DRB2B_BuyerInfoController {
    @TestVisible
    private static final DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();

    @TestVisible
    private static final DRB2B_AccountService accountService = new DRB2B_AccountService();

    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance();

    private static DRB2B_TaxCalculationService taxCalculationService = new DRB2B_TaxCalculationService();
    public static Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();

    @AuraEnabled(cacheable=true)
    public static Map<String, object> getcountryPicklistIsEnabled() {
        Map<String, object> result = new Map<String, object>();
        result.put('isCountryStateEnabled', DRB2B_Utility.isCountryStateEnabled());
        return result;
    }

    @AuraEnabled
    public static String getAddresses(Id CartId) {
        String result;
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        try {
            Map<String, String> response = new Map<String, String>();
            if (!isGuestUser) {
                response.put('contactPointAddress', JSON.serialize(accountService.getCurrentUserAddresses()));
                response.put(
                    'organizationName',
                    cartSelector.getById(CartId, new Set<String>{ 'Account.Name' })?.Account.Name
                );
            }
            response.put(
                'cartType',
                cartSelector.getById(CartId, new Set<String>{ 'DR_Checkout_Type__c' })?.DR_Checkout_Type__c
            );
            response.put(
                'customerType',
                cartSelector.getById(CartId, new Set<String>{ 'DR_Customer_Type__c' })?.DR_Customer_Type__c
            );
            result = JSON.serialize(response);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled
    public static String getCartId() {
        try {
            User u = [SELECT id, accountId FROM user WHERE id = :UserInfo.getUserId()][0];
            return String.valueOf(
                [SELECT id FROM WebCart WHERE CreatedById = :u.Id AND status IN ('active', 'checkout') LIMIT 1]
                .id
            );
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static void updateCart(string cart) {
        try {
            WebCart wcart = (WebCart) JSON.deserialize(cart, WebCart.class);
             if (isGuestUser) {
                logger.info('DRB2B_BuyerInfoController guest user cart data' + wcart);
                DMLManager.updateAsSystem(wcart);
            } else {
                logger.info('DRB2B_BuyerInfoController Auth user cart data' + wcart);
                DMLManager.updateAsUser(wcart);
            }
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static void updateCartDeliveryGroup(string cartdelivery) {
        try {
            CartDeliveryGroup cartDeliveryGroup = (CartDeliveryGroup) JSON.deserialize(
                cartdelivery,
                CartDeliveryGroup.class
            );
            string cartId = cartDeliveryGroup.CartId;
            string cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId][0].Id;
            cartDeliveryGroup.Id =  cartDeliveryGroupId;
            if(isGuestUser){
                DMLManager.updateAsSystem(cartDeliveryGroup);
            }
            else{
                DMLManager.updateAsUser(cartDeliveryGroup);
            }           
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static String startTaxCalc(string cartId) {
        String result;
        try {
            DRB2B_TaxCalculationService.ResponseModel response = DRB2B_TaxCalculationService.startCartProcessAsync(
                cartId,
                null
            );
            if (response != null && response.status == 'Error') {
                saveCartValidationOutputError(response.message, cartId);
                result = JSON.serialize(response);
                logger.debug('Drb2b BuyerInfo Controller Tax calculation result' + result);
                return result;
            }
        } catch (Exception e) {
            logger.error('Drb2b BuyerInfo Controller Tax calculation Error' + e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.debug('buyer controller tax calc finally ');
            logger.flush();
        }
        return result;
    }

    private static void saveCartValidationOutputError(String errorMessage, Id cartId) {
        CartValidationOutput cartValidationError = new CartValidationOutput(
            CartId = cartId,
            Level = 'Error',
            Message = errorMessage.left(255),
            Name = (String) cartId,
            RelatedEntityId = cartId,
            Type = 'Taxes'
        );
        insert (cartValidationError);
    }
}
