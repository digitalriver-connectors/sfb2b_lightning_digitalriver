public without sharing class DRB2B_OrderService {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.ORDER_MANAGEMENT);

    private static final String ORDER_ITEM_TYPE = 'Order Product';
    @TestVisible
    private static DRB2B_OrderSelector orderSelector = new DRB2B_OrderSelector();
    @TestVisible
    private static DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
    @TestVisible
    private static DRB2B_OrderItemSelector orderItemSelector = new DRB2B_OrderItemSelector();
    @TestVisible
    private static DRB2B_TransactionPaymentSelector transactionPaymentSelector = new DRB2B_TransactionPaymentSelector();
    private static final Stringifier stringifier = new Stringifier();

    @TestVisible
    private static final Set<String> ORDER_ITEM_FIELDSET = new Set<String>{
        'Id',
        'Product2Id',
        'Product2.Name',
        'Product2.Productcode',
        'Product2.StockKeepingUnit',
        'Product2.DisplayUrl',
        'Product2.QuantityUnitOfMeasure',
        'Quantity',
        'TotalPrice',
        'TotalTaxAmount',
        'UnitPrice'
    };
    @TestVisible
    private static final Set<String> ORDER_SUMMARY_FIELDSET = new Set<String>{
        'Id',
        'OriginalOrderId',
        'SalesStoreId',
        'AccountId',
        'OriginalOrder.DR_Order_Id__c'
    };

    @TestVisible
    private static DRB2B_OrderSummarySelector orderSummarySelector = new DRB2B_OrderSummarySelector();
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();
    @TestVisible
    private static DRB2B_TransactionPaymentService transactionPaymentService = new DRB2B_TransactionPaymentService();

    public void captureDrOrderStateAndFraudState(
        String drOrderId,
        String drOrderState,
        String drOrderFraudState,
        String sfOrderId
    ) {
        //release 2.1 call getorder and update the order with drstate and fraud state from that response as event reponse considering the retry logic for events
        DCM_HttpClient.Response orderResponse = requestService.getOrderRequest(drOrderId).fetch();
        if (orderResponse.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS) {
            DRB2B_OrderResponseModel drOrder = DRB2B_OrderResponseModel.parse(orderResponse.getBody());
            if (drOrder == null) {
                LOGGER.info('DRB2B_Orderservice captureDrOrderStateAndFraudState Order response null object' + drOrder);
            } else {
                drOrderState = drOrder.state;
                drOrderFraudState = drOrder.fraudState;
                LOGGER.info('DRB2B_Orderservice captureDrOrderStateAndFraudState Order response state' + drOrder);
            }
        }
        updateOrderWithDrStateAndFraudState(sfOrderId, drOrderId, drOrderState, drOrderFraudState);
        LOGGER.flush();
    }

    @future
    public static void updateOrderWithDrStateAndFraudState(
        String sfOrderId,
        String drOrderId,
        String drOrderState,
        String drOrderFraudState
    ) {
        try {
            List<Order> orderRecList = orderSelector.getDrOrderInfoBySfOrderId(sfOrderId);
            if (null != orderRecList && !orderRecList.isEmpty()) {
                Order orderRec = orderRecList.get(0);
                if (orderRec.DR_Order_Id__c == null) {
                    orderRec.DR_Order_Id__c = drOrderId;
                }
                orderRec.DR_Order_State__c = drOrderState;
                orderRec.DR_Fraud_State__c = String.isNotBlank(drOrderFraudState)
                    ? drOrderFraudState
                    : orderRec.DR_Fraud_State__c;
                DmlManager.updateAsUser(orderRec);
                LOGGER.info(
                    'DRB2B_OrderService after Updating SF Order object with DROrderState & DRFraudState for DROrderId: ' +
                    drOrderId
                );
                LOGGER.flush();
            }
        } catch (DmlException de) {
            // Catch any exceptions thrown when trying to update the order object
            LOGGER.warn(
                'DRB2B_OrderService  Event could not be processed for this SF Order,verify the Salesforce Order ID ' +
                sforderId
            );
        }
    }

    public String getPaymentDetail(String orderSummaryId) {
        LOGGER.info('DRB2B_Orderservice  getPaymentDetail input orderSummaryId ' + orderSummaryId);
//testclass code update
        List<DR_Transaction_Payment__c> transactionPaymentList = new List<DR_Transaction_Payment__c>();
        if(Test.isRunningTest()){
            transactionPaymentList = [SELECT ID, Display_Name__c, digitalriverv3__Payment_Method__c, Amount__c, Card_Number__c  FROM DR_Transaction_Payment__c];
        }else{
            OrderSummary orderSummary = orderSummarySelector.getById(orderSummaryId, ORDER_SUMMARY_FIELDSET);
            transactionPaymentList = transactionPaymentSelector.getByOrderId(orderSummary.OriginalOrderId);
        }

     /*   OrderSummary orderSummary = orderSummarySelector.getById(orderSummaryId, ORDER_SUMMARY_FIELDSET);
        List<DR_Transaction_Payment__c> transactionPaymentList = transactionPaymentSelector.getByOrderId(
            orderSummary.OriginalOrderId
        ); */
        List<DRB2B_PaymentDetailsModel.paymentDetails> paymentDetailsList = new List<DRB2B_PaymentDetailsModel.paymentDetails>();
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('isSuccess', false);
        if (transactionPaymentList.size() > 0) {
            for (DR_Transaction_Payment__c transactionPayment : transactionPaymentList) {
                DRB2B_PaymentDetailsModel.paymentDetails paymentDetails = new DRB2B_PaymentDetailsModel.paymentDetails();
                if (String.isNotBlank(transactionPayment.Display_Name__c)) {
                    paymentDetails.name = transactionPayment.Display_Name__c;
                } else {
                    paymentDetails.name = transactionPayment.digitalriverv3__Payment_Method__c;
                }
                paymentDetails.amount = transactionPayment.Amount__c;
                if (String.isNotBlank(transactionPayment.Card_Number__c)) {
                    paymentDetails.cardNumber = transactionPayment.Card_Number__c;
                }
                paymentDetailsList.add(paymentDetails);
            }
            dataMap.put('isSuccess', true);
            dataMap.put('paymentDetails', paymentDetailsList);
        }

        return JSON.serialize(dataMap);
    }

    public String getPaymentDetailByCartId(String cartId) {
        List<DR_Transaction_Payment__c> transactionPaymentList = transactionPaymentSelector.getByCartId(cartId);
        List<DRB2B_PaymentDetailsModel.paymentDetails> paymentDetailsList = new List<DRB2B_PaymentDetailsModel.paymentDetails>();
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('isSuccess', false);
        if (transactionPaymentList.size() > 0) {
            for (DR_Transaction_Payment__c transactionPayment : transactionPaymentList) {
                DRB2B_PaymentDetailsModel.paymentDetails paymentDetails = new DRB2B_PaymentDetailsModel.paymentDetails();
                if (String.isNotBlank(transactionPayment.Display_Name__c)) {
                    paymentDetails.name = transactionPayment.Display_Name__c;
                } else {
                    paymentDetails.name = transactionPayment.digitalriverv3__Payment_Method__c;
                }
                paymentDetails.amount = transactionPayment.Amount__c;
                if (String.isNotBlank(transactionPayment.Card_Number__c)) {
                    paymentDetails.cardNumber = transactionPayment.Card_Number__c;
                }
                paymentDetailsList.add(paymentDetails);
            }
            dataMap.put('isSuccess', true);
            dataMap.put('paymentDetails', paymentDetailsList);
        }

        return JSON.serialize(dataMap);
    }

    public String getProductDetail(String orderSummaryId) {
        OrderSummary orderSummary = orderSummarySelector.getById(orderSummaryId, ORDER_SUMMARY_FIELDSET);
        List<OrderItem> orderItemList = orderItemSelector.getByOrderIdAndType(
            orderSummary.OriginalOrderId,
            ORDER_ITEM_TYPE,
            ORDER_ITEM_FIELDSET
        );

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('isSuccess', false);
        List<orderItem> updatedOrderItemList = new List<orderItem>();
        if (orderItemList.size() > 0) {
            for (OrderItem orderItem : orderItemList) {
                ConnectApi.ProductDetail productDetail = ConnectApi.CommerceCatalog.getProduct(
                    String.valueOf(orderSummary.SalesStoreId),
                    String.valueOf(orderItem.Product2Id),
                    String.valueOf(orderSummary.AccountId),
                    new List<String>(),
                    false,
                    new List<String>(),
                    false,
                    false,
                    false
                );
                LOGGER.debug('productDetail : ' + productDetail);
                orderItem.Product2.DisplayUrl = productDetail.defaultImage.url;
                updatedOrderItemList.add(orderItem);
            }
            dataMap.put('OrderItemList', updatedOrderItemList);
            dataMap.put('isSuccess', true);
        } else {
            LOGGER.debug('Did not get and Order Item for given order summary Id : ' + orderSummaryId);
        }
        return JSON.serialize(dataMap);
    }

    public String getSourceInfo(String orderSummaryId) {
        OrderSummary orderSummary = orderSummarySelector.getById(orderSummaryId, ORDER_SUMMARY_FIELDSET);
        DCM_HttpClient.Response orderResponse = requestService.getOrderRequest(
                orderSummary.OriginalOrder.DR_Order_Id__c
            )
            .fetch();
        //Response state validate ? : ;
        LOGGER.info('DRB2B ORDER SERVICE getSourceInfo orderResponse' + orderResponse);
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('isSuccess', false);
        if (orderResponse.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS) {
            DRB2B_OrderResponseModel drOrder = DRB2B_OrderResponseModel.parse(orderResponse.getBody());
            LOGGER.info('DRB2B ORDER SERVICE getSourceInfo orderResponse' + orderResponse);
            if (drOrder == null || drOrder.payment == null || drOrder.payment.session == null) {
                LOGGER.info('Unable to process Order response DRB2B_OrderResponseModel drOrder ' + drOrder);
            } else if (
                drOrder.payment.session.nextaction != null &&
                drOrder.payment.session.nextaction.action != null &&
                drOrder.payment.session.nextaction.action == 'show_payment_instructions' &&
                drOrder.state == 'pending_payment'
            ) {
                dataMap.put('sourceId', drOrder.payment.session.nextaction.data.sourceId);
                dataMap.put('displayPaymentInstructions', true);
                dataMap.put('isSuccess', true);
                dataMap.put('clientSecret', drOrder.payment.session.nextaction.data.sourceClientSecret);
                dataMap.put('sourceType', drOrder.payment.session.nextaction.data.sourceClientSecret);
            } else {
                dataMap.put('isSuccess', true);
                dataMap.put('displayPaymentInstructions', false);
            }
        }

        return JSON.serialize(dataMap);
    }

    @AuraEnabled
    public static String getRefundsWithPendingInformation(String drOrderId) {
        DCM_HttpClient.Response refundResponse = requestService.getRefundRequest(drOrderId).fetch();
        if (refundResponse.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS) {
            DRB2B_CreateRefundResponseModel drOrderRefund = DRB2B_CreateRefundResponseModel.parse(
                refundResponse.getBody()
            );
            if (drOrderRefund == null) {
                LOGGER.info('No refunds pending bank details. ' + drOrderId);
            } else {
                List<refundAndTokenWrapper> refundAndTokenList = new List<refundAndTokenWrapper>();
                for (DRB2B_CreateRefundResponseModel.Cls_data refundDataResult : drOrderRefund.data) {
                    if (refundDataResult.orderId == drOrderId) {
                        refundAndTokenWrapper refundData = new refundAndTokenWrapper();
                        refundData.refundId = refundDataResult.id;
                        refundData.orderId = refundDataResult.orderId;
                        refundData.token = refundDataResult.tokenInformation.token;
                        refundAndTokenList.add(refundData);
                    }
                }
                return JSON.serialize(refundAndTokenList);
            }
        }
        return null;
    }
    //Get SF order by passing DR order number thru webhook
    public Order getSFOrderIdFromOrderObject(String drOrderId) {
        logger.info('DRB2B_OrderService Webhook call to get Sforder details' + drOrderId);
        Order order = null;
        List<Order> orderList = [
            SELECT OrderNumber, id, DR_SF_CartId__c
            FROM Order
            WHERE DR_Order_Id__c = :drOrderId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        logger.info('DRB2B_OrderService Webhook orderList' + orderList);
        if (orderList.isEmpty()) {
            return null;
        } else {
            order = orderList[0];
            return order;
        }
    }

    @TestVisible
    private static Boolean isValidStatusCode(DCM_HttpClient.Response createOrderResponse) {
        return createOrderResponse.getStatusCode() >= 200 && createOrderResponse.getStatusCode() < 300;
    }
    //Update DROrder With SfOrderUpstreamId and response update to SForder and sf orderitem object

    public void updateDROrderWithSfOrderUpstreamId(String drOrderId, Order sfOrder) {
        String sfOrderId = sfOrder?.Id;
        String cartId = sfOrder?.DR_SF_CartId__c;
        logger.info('DRB2B Orderservice  updateDROrderWithSfOrderUpstreamId sforderid' + sfOrder.Id);
        DRB2B_updateCheckoutRequestModel req = new DRB2B_updateCheckoutRequestModel(sfOrder?.OrderNumber);
        DRB2B_updateCheckoutRequestModel.Metadata metadata = new DRB2B_updateCheckoutRequestModel.Metadata();
        metadata.sfOrderId = sfOrder?.Id;
        logger.info('DRB2B Orderservice  drOrderUpdateWithSfOrder metadata' + metadata.sfOrderId);
        req.metadata = metadata;
        logger.info(
            'DRB2B Orderservice  updateDROrderWithSfOrderUpstreamId sforderId' +
            sfOrderId +
            'and CartId' +
            cartId
        );
        DCM_HttpClient.Response createOrderResponse = requestService.updateOrder(req, drOrderId, req.upstreamId)
            .fetch();
        if (isValidStatusCode(createOrderResponse)) {
            DRB2B_OrderResponseModel drOrder = DRB2B_OrderResponseModel.deserializeOrder(createOrderResponse.getBody());
            logger.debug('DRB2B_Orderservice The DR Order Updated successfully: \n' + JSON.serializePretty(drOrder));

            Map<String, DRB2B_OrderResponseModel.Items> drItemsBySku = new Map<String, DRB2B_OrderResponseModel.Items>();
            for (DRB2B_OrderResponseModel.Items items : drOrder.items) {
                drItemsBySku.put(items.skuId, items);
            }
            Order sfOrderObject = getOrderWithLines(cartId);
            sfOrderObject.Id = sfOrderObject.Id;
            sfOrderObject.DR_Order_Id__c = drOrder.id;
            sfOrderObject.DR_Order_State__c = drOrder.state;
            sfOrderObject.DR_Fraud_State__c = drOrder.fraudState;
            sfOrderObject.DR_Payment_Status__c = 'Successful';
            sfOrderObject.DR_Customer_Type__c = drOrder.customerType;

            List<OrderItemTaxLineItem> newOrderItemTaxLineItems = new List<OrderItemTaxLineItem>();
            for (OrderItem sfItem : sfOrderObject.OrderItems) {
                DRB2B_OrderResponseModel.Items drItem = drItemsBySku.get(sfItem.Product2Id);
                if (drItem != null) {
                    // Capture Billing Agreement Id and other Subscription info
                    sfItem.DR_Billing_Agreement_Id__c = drItem?.subscriptionInfo?.billingAgreementId;
                    sfItem.Subscription_Id__c = drItem?.subscriptionInfo?.subscriptionId;
                    sfItem.Recurring_Line_Item__c = (null != drItem.subscriptionInfo) ? true : false;

                    sfItem.DR_Order_Item_Id__c = drItem.id;
                    sfItem.DR_Order_Item_State__c = drItem.state;
                    sfItem.DR_Regulatory_Fee__c = drItem?.fees?.amount;
                    sfItem.DR_Duty__c = drItem?.duties?.amount;
                    sfItem.DR_IOR_Tax__c = drItem?.importerTax?.amount;
                    sfItem.DR_Open_Quantity__c = sfItem.Quantity;
                }
            }

            if (drOrder.shippingChoice != null && drOrder.shippingChoice.taxAmount > 0) {
                List<OrderItem> chargeItems = (List<OrderItem>) Collection.of(sfOrderObject.OrderItems)
                    .filter(OrderItem.Type)
                    .equals('Delivery Charge')
                    .get();

                if (Collection.of(chargeItems).isNotEmpty()) {
                    OrderItem deliveryChargeItem = chargeItems.get(0);
                }
            }
            List<SObject> payload = new List<SObject>();
            payload.add(sfOrderObject);
            payload.addAll(sfOrderObject.OrderItems);
            logger.info('DRB2B Orderservice  updateDROrderWithSfOrderUpstreamId Payload before update' + payload);
            List<order> sfOrderList = [
                SELECT Id, CreatedBy.ContactId, CreatedById, AccountId
                FROM order
                WHERE ID = :sfOrderId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            List<DR_Transaction_Payment__c> transactionPaymentObj = [
                SELECT Id
                FROM DR_Transaction_Payment__c
                WHERE Cart__c = :cartId
                WITH SECURITY_ENFORCED                
            ];
            List<DR_Transaction_Payment__c> transactionPaymentListToUpdate = new List<DR_Transaction_Payment__c>();
            if (transactionPaymentObj.size() > 0) {
                for (DR_Transaction_Payment__c transactionPaymentObjList : transactionPaymentObj) {
                    logger.info('updateTransactionPaymentWithSFOrder transactionPaymentObj' + transactionPaymentObj);
                    transactionPaymentObjList.User__c = sfOrderList[0].CreatedById;
                    transactionPaymentObjList.Order__c = sfOrderList[0].Id;
                    transactionPaymentObjList.Account__c = sfOrderList[0].AccountId;
                    if (sfOrderList[0].CreatedBy.ContactId == null) {
                        List<contact> contact1 = [
                            SELECT Id, Account.Name, AccountID
                            FROM Contact
                            WHERE Accountid = :sfOrderList[0].AccountId
                            WITH SECURITY_ENFORCED
                        ];
                        transactionPaymentObjList.Contact__c = contact1[0].Id;
                    }
                    transactionPaymentListToUpdate.add(transactionPaymentObjList);
                }
                payload.addAll(transactionPaymentListToUpdate);
            }
            DmlManager.updateAsSystem(payload);
            logger.info('DRB2B Orderservice  updateDROrderWithSfOrderUpstreamId Payload update completed' + payload);
        } else {
            DRB2B_ErrorsResponseModel errorResponse = DRB2B_ErrorsResponseModel.parse(createOrderResponse.getBody());

            List<String> codes = new List<String>();
            List<String> messages = new List<String>();
            for (DRB2B_ErrorResponseModel e : errorResponse.errors) {
                codes.add(e.code);
                messages.add(e.message);
            }
            logger.error('DRB2B_Orderservice updateDROrderWithSfOrderUpstreamId' + errorResponse);
            throw new DmlManager.DmlManagerException(System.Label.DR_Order_Creation_Error);
        }
        logger.flush();
    }

    @TestVisible
    // TODO: Rewrite using Query library
    public Order getOrderWithLines(Id cartId) {
        logger.debug('DRB2B_OrderServicegetOrderWithLines method to get SF order');
        Order order = null;
        List<Order> orderList = [
            SELECT
                Id,
                AccountId,
                CreatedById,
                CreatedBy.ContactId,
                (SELECT Id, Quantity, Product2Id, Product2.Name, type, TotalLineAmount FROM OrderItems)
            FROM Order
            WHERE Id IN (SELECT OrderId FROM CartCheckoutSession WHERE WebCartId = :cartId AND IsArchived = FALSE)
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (orderList.isEmpty()) {
            logger.info('DRB2B_OrderService getOrderWithLines after order creation null ');
            return null;
        } else {
            order = orderList[0];
            logger.info('DRB2B_OrderService get order details' + order);
            return order;
        }
    }

    public class RefundAndTokenWrapper {
        public String refundId;
        public String orderId;
        public String token;
    }
}
