public without sharing class DRB2B_TransactionPaymentService {
    private static final DCM_Logger logger = DCM_Logger.getInstance(
        DRB2B_Constants.Module.DigitalRiver_TRANSACTION_PAYMENTS
    );

    @TestVisible
    private static DRB2B_TransactionPaymentSelector transactionPaymentSelector = new DRB2B_TransactionPaymentSelector();

    public static Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();

    public static string responseBody = '';

    public String getSourceInfo(String sourceType) {
        String paymentInstruction = '';
        if (sourceType == 'wireTransfer') {
            paymentInstruction = responseBody.substringBetween('"wireTransfer":', '"session"');
        } else if (sourceType == 'konbini') {
            paymentInstruction = responseBody.substringBetween('"konbini":', '"session"');
        }
        if (paymentInstruction != null) {
            paymentInstruction = paymentInstruction.removeEnd('}],');
        }
        return paymentInstruction;
    }

    public Boolean deleteDRTransactionPayment(String sourceId) {
        Boolean finalResult = false;
        try {
            List<DR_Transaction_Payment__c> transactionPaymentList = transactionPaymentSelector.getBySourceId(sourceId);
            if (transactionPaymentList.size() > 0) {
                DmlManager.deleteAsUser(transactionPaymentList);
                finalResult = true;
            } else {
                logger.Info('Did not found any DR Transaction Payments record with this source Id.');
            }
        } catch (Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
        return finalResult;
    }

    public DR_Transaction_Payment__c createTrasactionPaymentRecord(
        Order sfOrder,
        DRB2B_CreateCheckoutResponseModel.Source sourceInfo,
        String cartId
    ) {
        logger.debug('Inside createTrasactionPaymentRecord input');
        DR_Transaction_Payment__c transactionPaymentObj = new DR_Transaction_Payment__c();
        transactionPaymentObj.Amount__c = sourceInfo.amount;
        if (sourceInfo.type != 'customerCredit') {
            String label = System.label.DR_PaymentMethod + sourceInfo.type;
            String value = DRB2B_StoredPayments.getLabel(label);
            logger.debug('value in transaction creation record ' + value);
            Map<String, Object> mapOfCustomData = (Map<String, Object>) JSON.deserializeUntyped(value);
            if (mapOfCustomData.containsKey('value')) {
                if (String.isNotBlank(String.valueOf(mapOfCustomData.get('value')))) {
                    transactionPaymentObj.Display_Name__c = String.valueOf(mapOfCustomData.get('value'));
                }
            }
        }

        if (sourceInfo.type == 'creditCard') {
            transactionPaymentObj.Card_Number__c = 'xxxx-xxxx-xxxx-' + sourceInfo.creditCard.lastFourDigits;
            transactionPaymentObj.Card_Type__c = sourceInfo.creditCard.brand;
        } else if (sourceInfo.type == 'wireTransfer' || sourceInfo.type == 'konbini') {
            transactionPaymentObj.Payment_Instructions__c = getSourceInfo(sourceInfo.type);
        }
        transactionPaymentObj.Payment_Method__c = sourceInfo.type;
        transactionPaymentObj.Token__c = sourceInfo.id;
        transactionPaymentObj.CurrencyISOCode__c = sourceInfo.drCurrency;
        transactionPaymentObj.Cart__c = cartId;
        transactionPaymentObj.Transaction_Type__c = 'AUTH'; // this will be AUTH and after funds are captured it will be CAPTURE
        if (sfOrder != null) {
            transactionPaymentObj.Contact__c = sfOrder.CreatedBy.ContactId;
            transactionPaymentObj.User__c = sfOrder.CreatedById;
            transactionPaymentObj.Order__c = sfOrder.Id;
            transactionPaymentObj.Account__c = sfOrder.AccountId;
        }
        return transactionPaymentObj;
    }
}
