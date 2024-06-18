global without sharing class DRB2B_ClearData {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

    @TestVisible
    private static DRB2B_CartService cartService = new DRB2B_CartService();

    @InvocableMethod
    global static void clearData(List<Id> cartIdList) {
        LOGGER.info('Clear Data');
        try {
            Set<Id> cartIds = new Set<Id>();
            List<SObject> deletePayload = new List<SObject>();
            if (!cartIdList.isEmpty()) {
                for (Id cartId : cartIdList) {
                    cartIds.add(cartId);
                }

                //Update Total Price on Cart Items to remove Landed Costs and Regulatory Fees
                DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();
                cartItemService.removeLandedCostsAndRegulatoryFeesFromTotalPrice(cartIds);

                Set<String> cartIdsSet = (Set<String>) JSON.deserialize(JSON.serialize(cartIds), Set<String>.class);
                cartService.clearAddress(cartIdsSet);

                /**
                 * Whenever a Shopper cancels an existing checkout, then we need to remove data related to DR from cart
                 */
                cartService.clearDataRelatedToDr(cartIdsSet);

                //Delete transaction payment details
                List<DR_Transaction_Payment__c> transactionDetails = [
                    SELECT Id
                    FROM DR_Transaction_Payment__c
                    WHERE Cart__c IN :cartIds
                    WITH SECURITY_ENFORCED
                ];
                if (!transactionDetails.isEmpty()) {
                    for (DR_Transaction_Payment__c transactionDetail : transactionDetails) {
                        deletePayload.add(transactionDetail);
                    }
                }

                // Delete Taxes and fee
                Set<Id> cartItemIds = cartItemService.getCartItemIdByCart(cartIds);
                List<CartTax> taxes = [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds WITH SECURITY_ENFORCED];
                if (!taxes.isEmpty()) {
                    for (CartTax tax : taxes) {
                        deletePayload.add(tax);
                    }
                }

                DRB2B_RegulatoryFeeSelector feeSelector = new DRB2B_RegulatoryFeeSelector();
                list<DR_Regulatory_Fee__c> fee = feeSelector.getByCartItemId(new Set<String>{ 'Id' }, cartItemIds);
                if (!fee.isEmpty()) {
                    for (DR_Regulatory_Fee__c feeData : fee) {
                        deletePayload.add(feeData);
                    }
                }

                if (!deletePayload.isEmpty()) {
                    LOGGER.info('Delete Fee/taxes/TransactionPayment' + JSON.serialize(deletePayload));
                    deleteRecords(deletePayload);
                }
            }
        } catch (exception e) {
            LOGGER.error(e);
        } finally {
            LOGGER.flush();
        }
    }

    global static void clearDataLWR(List<Id> cartIdList) {
        try {
            Set<Id> cartIds = new Set<Id>();
            List<SObject> deletePayload = new List<SObject>();
            if (!cartIdList.isEmpty()) {
                for (Id cartId : cartIdList) {
                    cartIds.add(cartId);
                }

                //Update Total Price on Cart Items to remove Landed Costs and Regulatory Fees
                DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();
                //cartItemService.removeLandedCostsAndRegulatoryFeesFromTotalPriceLWR(cartIds); // todo remove this line if checkout summary is working nicely after going back and added new product

                Set<String> cartIdsSet = (Set<String>) JSON.deserialize(JSON.serialize(cartIds), Set<String>.class);
                //cartService.clearAddress(cartIdsSet);

                /**
                 * Whenever a Shopper cancels an existing checkout, then we need to remove data related to DR from cart
                 */
                cartService.clearDataRelatedToDr(cartIdsSet);

                //Delete transaction payment details
                List<DR_Transaction_Payment__c> transactionDetails = [
                    SELECT Id
                    FROM DR_Transaction_Payment__c
                    WHERE Cart__c IN :cartIds
                    WITH SECURITY_ENFORCED
                ];
                if (!transactionDetails.isEmpty()) {
                    for (DR_Transaction_Payment__c transactionDetail : transactionDetails) {
                        deletePayload.add(transactionDetail);
                    }
                }

                // Delete Taxes and fee
                Set<Id> cartItemIds = cartItemService.getCartItemIdByCart(cartIds);
                if (
                    CartTax.SObjectType.getDescribe().isAccessible() &&
                    Schema.SObjectType.CartTax.fields.Id.isAccessible()
                ) {
                    List<CartTax> taxes = [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds];
                    if (!taxes.isEmpty()) {
                        for (CartTax tax : taxes) {
                            deletePayload.add(tax);
                        }
                    }
                }

                DRB2B_RegulatoryFeeSelector feeSelector = new DRB2B_RegulatoryFeeSelector();
                list<DR_Regulatory_Fee__c> fee = feeSelector.getByCartItemId(new Set<String>{ 'Id' }, cartItemIds);
                if (!fee.isEmpty()) {
                    for (DR_Regulatory_Fee__c feeData : fee) {
                        deletePayload.add(feeData);
                    }
                }

                if (!deletePayload.isEmpty()) {
                    LOGGER.info('Delete Fee/taxes/TransactionPayment' + JSON.serialize(deletePayload));
                    deleteRecords(deletePayload);
                }
            }
        } catch (exception e) {
            LOGGER.error(e);
        } finally {
            LOGGER.flush();
        }
    }

    public static void deleteRecords(List<SObject> records) {
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        if (!records.isEmpty()) {
            if (!isGuestUser) {
                DmlManager.deleteAsUser(records);
            } else {
                DmlManager.deleteAsSystem(records);
            }
        }
    }

    // Clear all transaction related to the specific salesforce Cart

    @AuraEnabled
    public static void clearTransactionPaymentData(String cartId) {
        String result;
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        try {
            List<DR_Transaction_Payment__c> transactionDetails = [
                SELECT Id
                FROM DR_Transaction_Payment__c
                WHERE Cart__c = :cartId
                WITH SECURITY_ENFORCED
            ];
            if (!transactionDetails.isEmpty()) {
                for (DR_Transaction_Payment__c transactionDetail : transactionDetails) {
                    if (!isGuestUser) {
                        DmlManager.deleteAsUser(transactionDetail);
                    } else {
                        DmlManager.deleteAsSystem(transactionDetail);
                    }
                }
            }
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }
}
