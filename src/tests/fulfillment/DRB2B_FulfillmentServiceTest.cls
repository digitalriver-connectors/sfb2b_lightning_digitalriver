@isTest
private class DRB2B_FulfillmentServiceTest {
    private static final String SF_ORDER_ID = '8015e000123cXuEAAU';
    private static final String DR_ORDER_ID = '12345678';
    private static final String DR_ORDER_ID_2 = '123434323';
    private static final String DR_ORDER_ITEM_ID_1 = '9738378237';
    private static final String DR_ORDER_ITEM_ID_2 = '9733322237';
    private static final String DR_ORDER_STATE = 'accepted';
    private static final String DR_ORDER_FULFILLMENT_OPEN_STATUS = 'Open';
    private static final String CREATED = 'Created';
    private static final String CONFLICT = 'Conflict';

    @TestSetup
    static void setup() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult resultAccount = ATK.prepare(Account.SObjectType, 1)
                .build(EntityBuilderFactory.accountBuilder)
                .save(false);
            Account acc = (Account) resultAccount.get(Account.SObjectType)[0];
            acc.OwnerId = DRB2B_TestEnvironment.portalAccountOwner.Id;
            insert acc;

            ATK.SaveResult resultContact = ATK.prepare(Contact.SObjectType, 1)
                .build(EntityBuilderFactory.contactBuilder)
                .save(false);
            Contact con = (Contact) resultContact.get(Contact.SObjectType)[0];
            con.AccountId = acc.Id;
            insert con;

            ATK.SaveResult result = ATK.prepare(User.SObjectType, 1).build(EntityBuilderFactory.userBuilder).save(false);
            User usr1 = (User) result.get(User.SObjectType)[0];
            Profile shopperProfile = [SELECT Id FROM Profile WHERE Name = :DRB2B_Constants.Profile.DR_SHOPPER LIMIT 1];
            usr1.ProfileId = shopperProfile.Id;
            usr1.ContactId = con.Id;
            insert usr1;

            result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);

            WebStore webStore = (WebStore) result.get(WebStore.SObjectType)[0];
            insert webStore;

            result = ATK.prepare(Pricebook2.SObjectType, 1).build(EntityBuilderFactory.pricebookBuilder).save(false);

            Pricebook2 priceBook = (Pricebook2) result.get(Pricebook2.SObjectType)[0];
            priceBook.IsActive = true;
            insert priceBook;

            result = ATK.prepare(ContactPointAddress.SObjectType, 1)
                .build(EntityBuilderFactory.contactPointAddressBuilder)
                .save(false);

            ContactPointAddress conPointAddress = (ContactPointAddress) result.get(ContactPointAddress.SObjectType)[0];
            insert conPointAddress;

            result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product = (Product2) result.get(Product2.SObjectType)[0];
            insert product;

            result = ATK.prepare(PricebookEntry.SObjectType, 1)
                .build(EntityBuilderFactory.pricebookEntryBuilder)
                .save(false);

            PricebookEntry standardPriceBookEntry = (PricebookEntry) result.get(PricebookEntry.SObjectType)[0];
            standardPriceBookEntry.Pricebook2Id = Test.getStandardPricebookId();
            standardPriceBookEntry.Product2Id = product.Id;
            standardPriceBookEntry.UnitPrice = 20;
            insert standardPriceBookEntry;

            ATK.SaveResult resultP = ATK.prepare(PricebookEntry.SObjectType, 1)
                .build(EntityBuilderFactory.pricebookEntryBuilder)
                .save(false);

            PricebookEntry priceBookEntry = (PricebookEntry) resultP.get(PricebookEntry.SObjectType)[0];
            priceBookEntry.Pricebook2Id = priceBook.Id;
            priceBookEntry.Product2Id = product.Id;
            priceBookEntry.UnitPrice = 20.99;
            insert priceBookEntry;

            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);

            WebCart webCart = (WebCart) result.get(WebCart.SObjectType)[0];
            webCart.AccountId = acc.Id;
            webcart.webStoreId = webStore.Id;
            insert WebCart;

            result = ATK.prepare(Order.SObjectType, 1).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder = (Order) result.get(Order.SObjectType)[0];
            sfOrder.AccountId = webCart.AccountId;
            sfOrder.Pricebook2Id = priceBook.Id;
            sfOrder.DR_Order_Id__c = DR_ORDER_ID;
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.DR_Order_Item_Id__c = DR_ORDER_ITEM_ID_1;
            orderItem.OrderId = sfOrder.Id;
            orderItem.DR_Open_Quantity__c = orderItem.Quantity;
            orderItem.Type = 'Order Product';
            insert orderItem;
        }
    }

    @isTest
    static void createDRFulfillmentObject_WithMinimalInfo_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Boolean isDRFulfillmentObjectCreated;
        Map<String, String> orderDataMap = new Map<String, String>();
        orderDataMap.put('drOrderId', DR_ORDER_ID);
       Map<String, Map<String, String>> orderMap = new Map<String, Map<String, String>>();
       orderMap.put(DR_ORDER_ID, orderDataMap);
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
               isDRFulfillmentObjectCreated = fulfillmentService.createDRFulfillmentObject(orderMap);
            Test.stopTest();
           System.assertEquals(true, isDRFulfillmentObjectCreated, 'DR Order Fulfillment record must be created');
        }
    }

    @isTest
    static void createDRFulfillmentObject_WithAllInfo_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Boolean isDRFulfillmentObjectCreated;
        Map<String, String> orderDataMap = new Map<String, String>();
        orderDataMap.put('drOrderId', DR_ORDER_ID);
        orderDataMap.put('drOrderState', DR_ORDER_STATE);
        orderDataMap.put('Order_Id__c', SF_ORDER_ID);
        orderDataMap.put('fulfillmentStatus', DR_ORDER_FULFILLMENT_OPEN_STATUS);
        orderDataMap.put('isOrderAcceptedEventRecieved', 'true');
        orderDataMap.put('isOrderCompleteEventReceived', 'false');
        orderDataMap.put('Message__c', 'Received order.accepted Event from DR');

      	Map<String, Map<String, String>> orderMap = new Map<String, Map<String, String>>();
       	orderMap.put(DR_ORDER_ID, orderDataMap);

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                isDRFulfillmentObjectCreated = fulfillmentService.createDRFulfillmentObject(orderMap);
            Test.stopTest();
           System.assertEquals(true, isDRFulfillmentObjectCreated, 'DR Order Fulfillment record should be created');
        }
    }

    @isTest
    static void createDRFulfillmentObject_NoPermissionOnFulfillmentObject_Test() {
        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Boolean isDRFulfillmentObjectCreated;
        Map<String, String> orderDataMap = new Map<String, String>();
        orderDataMap.put('drOrderId', DR_ORDER_ID);
      	Map<String, Map<String, String>> orderMap = new Map<String, Map<String, String>>();
       	orderMap.put(DR_ORDER_ID, orderDataMap);
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
                isDRFulfillmentObjectCreated = fulfillmentService.createDRFulfillmentObject(orderMap);
            Test.stopTest();
            System.assertEquals(false, isDRFulfillmentObjectCreated, 'DR Order Fulfillment record should not be created as User does not have permission');
        }
    }

    @isTest
    static void createOrUpdateDrFulfillmentRecord_CreateFulfillmentRecord_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Boolean drFulfillmentCreated;
        Map<String, String> orderDataMap = new Map<String, String>();
        orderDataMap.put('drOrderId', DR_ORDER_ID);
      	Map<String, Map<String, String>> orderMap = new Map<String, Map<String, String>>();
       	orderMap.put(DR_ORDER_ID, orderDataMap);
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            Test.startTest();
               drFulfillmentCreated = fulfillmentService.createOrUpdateDrFulfillmentRecord(orderMap);
            Test.stopTest();
            System.assertEquals(true, drFulfillmentCreated, 'DR Order Fulfillment record should be created');
        }
    }

    @isTest
    static void createOrUpdateDrFulfillmentRecord_UpdateFulfillmentRecord_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Boolean drFulfillmentUpdated;
        Map<String, String> orderDataMap = new Map<String, String>();
        orderDataMap.put('drOrderId', DR_ORDER_ID);
        orderDataMap.put('isOrderAcceptedEventRecieved', 'true');

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            ATK.SaveResult result = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.drFulfillmentBuilder)
                                        .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) result.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
           // drFulfillmentRec.Order_Cancelled__c = true;
            insert drFulfillmentRec;
            
            Map<String, Map<String, String>> orderMap = new Map<String, Map<String, String>>();
             orderMap.put(DR_ORDER_ID, orderDataMap);

            Test.startTest();
                drFulfillmentUpdated = fulfillmentService.createOrUpdateDrFulfillmentRecord(orderMap);
            Test.stopTest();
            System.assertEquals(true, drFulfillmentUpdated, 'DR Order Fulfillment record should be updated');
            List<DR_Fulfillment__c> drFulfillmentRecList = new DRB2B_FulfillmentSelector().getByDROrderId(DR_ORDER_ID);
            System.assertEquals(true, drFulfillmentRecList.get(0).Eligible_For_Fulfillment__c, 'DR Fulfillment record should be updated');
        }
    }

    @isTest
    static void updateDrFulfillmentRecord_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Boolean drFulfillmentRecUpdated;
        Map<String, String> orderDataMap = new Map<String, String>();
        orderDataMap.put('drOrderId', DR_ORDER_ID);
        orderDataMap.put('drOrderState', DR_ORDER_STATE);
        orderDataMap.put('Order_Id__c', SF_ORDER_ID);
        orderDataMap.put('fulfillmentStatus', DR_ORDER_FULFILLMENT_OPEN_STATUS);
        orderDataMap.put('isOrderAcceptedEventRecieved', 'true');
        orderDataMap.put('isOrderCompleteEventReceived', 'false');
        orderDataMap.put('Message__c', 'Received order.accepted Event from DR');
        
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            ATK.SaveResult result = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.drFulfillmentBuilder)
                                        .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) result.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            insert drFulfillmentRec;
            Map<DR_Fulfillment__c , Map<String, String>> fulfillmentToUpdate = new Map<DR_Fulfillment__c , Map<String, String>> ();
            fulfillmentToUpdate.put(drFulfillmentRec,orderDataMap);
            Test.startTest();
                drFulfillmentRecUpdated = fulfillmentService.updateDrFulfillmentRecord(drFulfillmentRec, orderDataMap);
            Test.stopTest();
            System.assertEquals(true, drFulfillmentRecUpdated, 'DR Order Fulfillment record should be updated');
            List<DR_Fulfillment__c> drFulfillmentRecList = new DRB2B_FulfillmentSelector().getByDROrderId(DR_ORDER_ID);
            System.assertEquals(true, drFulfillmentRecList.get(0).Eligible_For_Fulfillment__c, 'DR Fulfillment record should be updated');
        }
    }

    @isTest
    static void getOrdersWhichReceivedOrderAcceptedEvent_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        List<Order> ordersWhichReceivedAcceptedEvent;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            List<Order> orders = [Select Id, DR_Order_Id__c from Order];
            //Create DR Fulfillment Record
            ATK.SaveResult fulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.drFulfillmentBuilder)
                                        .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) fulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            Test.startTest();
                ordersWhichReceivedAcceptedEvent = fulfillmentService.getOrdersWhichReceivedOrderAcceptedEvent(orders);
            Test.stopTest();
            System.assertEquals(true, DCM_BaseUtilities.isNotNullOrEmpty(ordersWhichReceivedAcceptedEvent), 'There should be Order(s) which received order.accepted event');
        }
    }

    @isTest
    static void getOrderFulfillmentRecsByDrOrderId_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            //Create 2 DR Fulfillment Records
            ATK.SaveResult fulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 2)
                                        .build(EntityBuilderFactory.drFulfillmentBuilder)
                                        .save(false);
            DR_Fulfillment__c drFulfillmentRec1 = (DR_Fulfillment__c) fulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec1.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec1.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec1;

            DR_Fulfillment__c drFulfillmentRec2 = (DR_Fulfillment__c) fulfillmentResult.get(DR_Fulfillment__c.SobjectType)[1];
            drFulfillmentRec2.DR_Order_Id__c = DR_ORDER_ID_2;
            drFulfillmentRec2.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec2;


            Test.startTest();
                orderFulfillmentRecByDrOrderId = fulfillmentService.getOrderFulfillmentRecsByDrOrderId(new Set<String> {DR_ORDER_ID, DR_ORDER_ID_2});
            Test.stopTest();
            System.assertEquals(true, !orderFulfillmentRecByDrOrderId.isEmpty(), 'There should be Order(s) which received order.accepted event');
            System.assertEquals(true, orderFulfillmentRecByDrOrderId.get(DR_ORDER_ID) != null, 'There should be a DR Fulfillment record for this DR Order Id');
            System.assertEquals(true, orderFulfillmentRecByDrOrderId.get(DR_ORDER_ID_2) != null, 'There should be a DR Fulfillment record for this DR Order Id');
        }
    }

    @isTest
    static void createdOrUpdateDrOrderFulfillmentRecs_Create_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Get Order Item Id and Order Id
            OrderItem orderItem = [Select Id, OrderId, Order.DR_Order_Id__c, DR_Open_Quantity__c from OrderItem][0];

            //Create DR Fulfillment Record
            ATK.SaveResult drOrderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                            .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                            .save(false);
            DR_Fulfillment__c drFulfillmentRec1 = (DR_Fulfillment__c) drOrderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec1.DR_Order_Id__c = orderItem.Order.DR_Order_Id__c;
            drFulfillmentRec1.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec1;

            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 1)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec.OrderId__c = orderItem.OrderId;
            drFulfillmentReqLogRec.OrderItem_Id__c = orderItem.Id;
            drFulfillmentReqLogRec.Fulfill_Quantity__c = orderItem.DR_Open_Quantity__c;
            drFulfillmentReqLogRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentReqLogRec.DR_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            insert drFulfillmentReqLogRec;
            requestLogRecList.add(drFulfillmentReqLogRec);

            Test.startTest();
                fulfillmentService.createdOrUpdateDrOrderFulfillmentRecs(requestLogRecList, new Set<String> {DR_ORDER_ID});
            Test.stopTest();
            List<DR_Fulfillment__c> drFulfillmentRecs = [Select Id, DR_Order_Id__c from DR_Fulfillment__c];
            Set<String> drOrderIds = (Set<String>) Collection.of(drFulfillmentRecs).setOf(DR_Fulfillment__c.DR_Order_Id__c);
            System.assertEquals(true, drOrderIds.contains(DR_ORDER_ID), 'There should a DR Fulfillment Record with this DR Order Id');
        }
    }

    @isTest
    static void createdOrUpdateDrOrderFulfillmentRecs_Update_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Get Order Item Id and Order Id
            OrderItem orderItem = [Select Id, OrderId, DR_Open_Quantity__c from OrderItem][0];

            // Create DR Fulfillment record
            ATK.SaveResult fulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) fulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec.OrderId__c = orderItem.OrderId;
            drFulfillmentReqLogRec.OrderItem_Id__c = orderItem.Id;
            drFulfillmentReqLogRec.Fulfill_Quantity__c = orderItem.DR_Open_Quantity__c;
            drFulfillmentReqLogRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentReqLogRec.DR_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            insert drFulfillmentReqLogRec;
            requestLogRecList.add(drFulfillmentReqLogRec);

            Test.startTest();
                fulfillmentService.createdOrUpdateDrOrderFulfillmentRecs(requestLogRecList, new Set<String> {DR_ORDER_ID});
            Test.stopTest();
            List<DR_Fulfillment__c> drFulfillmentRecs = [Select Id, DR_Order_Id__c from DR_Fulfillment__c];
            Set<String> drOrderIds = (Set<String>) Collection.of(drFulfillmentRecs).setOf(DR_Fulfillment__c.DR_Order_Id__c);
            System.assertEquals(true, drOrderIds.contains(DR_ORDER_ID), 'There should a DR Fulfillment Record with this DR Order Id');
        }
    }

    @isTest
    static void createdDrLineItemFulfillmentRecs_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        Map<String, DR_Fulfillment__c> orderFulfillmentRecByDrOrderId;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Get Order Item Id and Order Id
            OrderItem orderItem = [Select Id, OrderId, DR_Open_Quantity__c from OrderItem][0];

            // Create DR Fulfillment record
            ATK.SaveResult fulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) fulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec.OrderId__c = orderItem.OrderId;
            drFulfillmentReqLogRec.OrderItem_Id__c = orderItem.Id;
            drFulfillmentReqLogRec.Fulfill_Quantity__c = orderItem.DR_Open_Quantity__c;
            drFulfillmentReqLogRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentReqLogRec.DR_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            insert drFulfillmentReqLogRec;
            requestLogRecList.add(drFulfillmentReqLogRec);

            Test.startTest();
                fulfillmentService.createdDrLineItemFulfillmentRecs(requestLogRecList, new Set<String> {DR_ORDER_ID});
            Test.stopTest();
            List<DR_Line_Item_Fulfillment__c> drLineItemFulfillmentRecs = [Select Id, Digital_River_OrderItem_Id__c from DR_Line_Item_Fulfillment__c];
            Set<String> drOrderItemIds = (Set<String>) Collection.of(drLineItemFulfillmentRecs).setOf(DR_Line_Item_Fulfillment__c.Digital_River_OrderItem_Id__c);
            System.assertEquals(true, drOrderItemIds.contains(DR_ORDER_ITEM_ID_1), 'There should a DR Line Item Fulfillment Record with this DR Order Item Id');
        }
    }

    @isTest
    static void getFulfillmentRequestToSubmitToDR_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        String fulfillmentRequestJson;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Create DR Fulfillment record
            ATK.SaveResult orderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) orderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            //Create DR Line Item Fulfillment Record
            ATK.SaveResult lineItemFulfillmentResult = ATK.prepare(DR_Line_Item_Fulfillment__c.SObjectType, 1)
                                                            .build(EntityBuilderFactory.drLineItemFulfillmentBuilder)
                                                            .save(false);
            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[0];
            drLineItemFulfillmentRec.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            drLineItemFulfillmentRec.Fulfill_Quantity__c = 1;
            drLineItemFulfillmentRec.Cancel_Quantity__c = 0;
            drLineItemFulfillmentRec.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec;

            DRB2B_FulfillmentResult fulfillmentResult = new DRB2B_FulfillmentResult(drFulfillmentRec, new List<DR_Line_Item_Fulfillment__c> {drLineItemFulfillmentRec});
            Test.startTest();
                fulfillmentRequestJson = fulfillmentService.getFulfillmentRequestToSubmitToDR(fulfillmentResult);
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(fulfillmentRequestJson), 'Fulfillment Request cannot be NULL');
        }
    }

    @isTest
    static void sendFulfillmentRequestToDR_Success_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        String fulfillmentRequestJson;
        DRB2B_FulfillmentResult fulfillmentResult;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Create DR Fulfillment record
            ATK.SaveResult orderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) orderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            //Create DR Line Item Fulfillment Record
            ATK.SaveResult lineItemFulfillmentResult = ATK.prepare(DR_Line_Item_Fulfillment__c.SObjectType, 1)
                                                            .build(EntityBuilderFactory.drLineItemFulfillmentBuilder)
                                                            .save(false);
            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[0];
            drLineItemFulfillmentRec.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            drLineItemFulfillmentRec.Fulfill_Quantity__c = 1;
            drLineItemFulfillmentRec.Cancel_Quantity__c = 0;
            drLineItemFulfillmentRec.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec;

            fulfillmentResult = new DRB2B_FulfillmentResult(drFulfillmentRec, new List<DR_Line_Item_Fulfillment__c> {drLineItemFulfillmentRec});
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SubmitFulfillmentToDRSuccessMock());
                fulfillmentService.sendFulfillmentRequestToDR(fulfillmentResult);
            Test.stopTest();
            System.assertEquals(true, fulfillmentResult.isSuccess, 'Submit Fulfillment request to DR must be successful');
        }
    }

    @isTest
    static void sendFulfillmentRequestToDR_EmptyLineItemRecords_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        String fulfillmentRequestJson;
        DRB2B_FulfillmentResult fulfillmentResult;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Create DR Fulfillment record
            ATK.SaveResult orderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) orderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            fulfillmentResult = new DRB2B_FulfillmentResult(drFulfillmentRec);
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SubmitFulfillmentToDRSuccessMock());
                fulfillmentService.sendFulfillmentRequestToDR(fulfillmentResult);
            Test.stopTest();
            System.assertEquals(false, fulfillmentResult.isSuccess, 'Submit Fulfillment request to DR should fail as Line Item Fulfillment records are not present');
        }
    }

    @isTest
    static void sendFulfillmentRequestToDR_Error_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        String fulfillmentRequestJson;
        DRB2B_FulfillmentResult fulfillmentResult;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Create DR Fulfillment record
            ATK.SaveResult orderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) orderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            //Create DR Line Item Fulfillment Record
            ATK.SaveResult lineItemFulfillmentResult = ATK.prepare(DR_Line_Item_Fulfillment__c.SObjectType, 1)
                                                            .build(EntityBuilderFactory.drLineItemFulfillmentBuilder)
                                                            .save(false);
            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[0];
            drLineItemFulfillmentRec.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            drLineItemFulfillmentRec.Fulfill_Quantity__c = 1;
            drLineItemFulfillmentRec.Cancel_Quantity__c = 0;
            drLineItemFulfillmentRec.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec;

            fulfillmentResult = new DRB2B_FulfillmentResult(drFulfillmentRec, new List<DR_Line_Item_Fulfillment__c> {drLineItemFulfillmentRec});
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SubmitFulfillmentToDRErrorMock());
                fulfillmentService.sendFulfillmentRequestToDR(fulfillmentResult);
            Test.stopTest();
            System.assertEquals(false, fulfillmentResult.isSuccess, 'Submit Fulfillment request to DR should fail');
        }
    }

    @isTest
    static void sendFulfillmentRequestToDR_ConflictError_ItemFulfilled_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        String fulfillmentRequestJson;
        DRB2B_FulfillmentResult fulfillmentResult;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Create DR Fulfillment record
            ATK.SaveResult orderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) orderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            //Create DR Line Item Fulfillment Records
            List<DR_Line_Item_Fulfillment__c> lineItemFulfillmentRecList = new List<DR_Line_Item_Fulfillment__c>();
            ATK.SaveResult lineItemFulfillmentResult = ATK.prepare(DR_Line_Item_Fulfillment__c.SObjectType, 2)
                                                            .build(EntityBuilderFactory.drLineItemFulfillmentBuilder)
                                                            .save(false);
            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec1 = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[0];
            drLineItemFulfillmentRec1.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            drLineItemFulfillmentRec1.Fulfill_Quantity__c = 1;
            drLineItemFulfillmentRec1.Cancel_Quantity__c = 0;
            drLineItemFulfillmentRec1.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec1;
            lineItemFulfillmentRecList.add(drLineItemFulfillmentRec1);

            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec2 = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[1];
            drLineItemFulfillmentRec2.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_2;
            drLineItemFulfillmentRec2.Fulfill_Quantity__c = 0;
            drLineItemFulfillmentRec2.Cancel_Quantity__c = 1;
            drLineItemFulfillmentRec2.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec2;
            lineItemFulfillmentRecList.add(drLineItemFulfillmentRec2);

            fulfillmentResult = new DRB2B_FulfillmentResult(drFulfillmentRec, lineItemFulfillmentRecList);
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SubmitFulfillmentToDRConflictErrorItemFulfilledMock());
                fulfillmentService.sendFulfillmentRequestToDR(fulfillmentResult);
            Test.stopTest();
            System.assertEquals(true, fulfillmentResult.isSuccess, 'Submit Fulfillment request to DR should be successful as one of the Line Items is already fulfilled');
        }
    }

    @isTest
    static void sendFulfillmentRequestToDR_ConflictError_OrderFulfilled_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        String fulfillmentRequestJson;
        DRB2B_FulfillmentResult fulfillmentResult;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Create DR Fulfillment record
            ATK.SaveResult orderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) orderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            //Create DR Line Item Fulfillment Records
            List<DR_Line_Item_Fulfillment__c> lineItemFulfillmentRecList = new List<DR_Line_Item_Fulfillment__c>();
            ATK.SaveResult lineItemFulfillmentResult = ATK.prepare(DR_Line_Item_Fulfillment__c.SObjectType, 2)
                                                            .build(EntityBuilderFactory.drLineItemFulfillmentBuilder)
                                                            .save(false);
            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec1 = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[0];
            drLineItemFulfillmentRec1.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            drLineItemFulfillmentRec1.Fulfill_Quantity__c = 1;
            drLineItemFulfillmentRec1.Cancel_Quantity__c = 0;
            drLineItemFulfillmentRec1.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec1;
            lineItemFulfillmentRecList.add(drLineItemFulfillmentRec1);

            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec2 = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[1];
            drLineItemFulfillmentRec2.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_2;
            drLineItemFulfillmentRec2.Fulfill_Quantity__c = 0;
            drLineItemFulfillmentRec2.Cancel_Quantity__c = 1;
            drLineItemFulfillmentRec2.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec2;
            lineItemFulfillmentRecList.add(drLineItemFulfillmentRec2);

            fulfillmentResult = new DRB2B_FulfillmentResult(drFulfillmentRec, lineItemFulfillmentRecList);
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SubmitFulfillmentToDRConflictErrorOrderFulfilledMock());
                fulfillmentService.sendFulfillmentRequestToDR(fulfillmentResult);
            Test.stopTest();
            System.assertEquals(true, fulfillmentResult.isSuccess, 'Submit Fulfillment request to DR should be successful as the Order is already fulfilled');
        }
    }

    @isTest
    static void sendFulfillmentRequestToDR_ConflictError_QuantityTooLarge_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentService fulfillmentService = new DRB2B_FulfillmentService();
        String fulfillmentRequestJson;
        DRB2B_FulfillmentResult fulfillmentResult;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            // Create DR Fulfillment record
            ATK.SaveResult orderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                    .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                    .save(false);
            DR_Fulfillment__c drFulfillmentRec = (DR_Fulfillment__c) orderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec.DR_Order_Id__c = DR_ORDER_ID;
            drFulfillmentRec.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec;

            //Create DR Line Item Fulfillment Records
            List<DR_Line_Item_Fulfillment__c> lineItemFulfillmentRecList = new List<DR_Line_Item_Fulfillment__c>();
            ATK.SaveResult lineItemFulfillmentResult = ATK.prepare(DR_Line_Item_Fulfillment__c.SObjectType, 2)
                                                            .build(EntityBuilderFactory.drLineItemFulfillmentBuilder)
                                                            .save(false);
            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec1 = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[0];
            drLineItemFulfillmentRec1.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_1;
            drLineItemFulfillmentRec1.Fulfill_Quantity__c = 1;
            drLineItemFulfillmentRec1.Cancel_Quantity__c = 0;
            drLineItemFulfillmentRec1.Retry_Attempts_Made__c = 99;
            drLineItemFulfillmentRec1.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec1;
            lineItemFulfillmentRecList.add(drLineItemFulfillmentRec1);

            DR_Line_Item_Fulfillment__c drLineItemFulfillmentRec2 = (DR_Line_Item_Fulfillment__c) lineItemFulfillmentResult.get(DR_Line_Item_Fulfillment__c.SobjectType)[1];
            drLineItemFulfillmentRec2.Digital_River_OrderItem_Id__c = DR_ORDER_ITEM_ID_2;
            drLineItemFulfillmentRec2.Fulfill_Quantity__c = 0;
            drLineItemFulfillmentRec2.Cancel_Quantity__c = 1;
            drLineItemFulfillmentRec2.Retry_Attempts_Made__c = 99;
            drLineItemFulfillmentRec2.DR_Order_Fulfillment__c = drFulfillmentRec.Id;
            insert drLineItemFulfillmentRec2;
            lineItemFulfillmentRecList.add(drLineItemFulfillmentRec2);

            fulfillmentResult = new DRB2B_FulfillmentResult(drFulfillmentRec, lineItemFulfillmentRecList);
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SubmitFulfillmentToDRConflictErrorQuantityTooLargeMock());
                fulfillmentService.sendFulfillmentRequestToDR(fulfillmentResult);
            Test.stopTest();
            System.assertEquals(false, fulfillmentResult.isSuccess, 'Submit Fulfillment request to DR should fail as the quantity to fulfill/cancel cannot exceed purchase quantity');
        }
    }

    private class SubmitFulfillmentToDRSuccessMock extends HttpCalloutMockRouter {
        private SubmitFulfillmentToDRSuccessMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Submit Fulfillment Request',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.FULFILLMENT_PATH,
                DRB2B_Constants.Base.FULFILLMENT_SUCCESS_RESPONSE_CODE,
                CREATED,
                getFulfillmentResponseModel()
            );
        }
    }

    private class SubmitFulfillmentToDRErrorMock extends HttpCalloutMockRouter {
        private SubmitFulfillmentToDRErrorMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Submit Fulfillment Request',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.FULFILLMENT_PATH,
                DRB2B_Constants.Base.ERROR_RESPONSE_CODE,
                '',
                getFulfillmentErrorResponseModel()
            );
        }
    }

    private class SubmitFulfillmentToDRConflictErrorItemFulfilledMock extends HttpCalloutMockRouter {
        private SubmitFulfillmentToDRConflictErrorItemFulfilledMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Submit Fulfillment Request',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.FULFILLMENT_PATH,
                DRB2B_Constants.Base.CONFLICT_RESPONSE_CODE,
                CONFLICT,
                getFulfillmentConflictErrorItemFulfilledResponseModel()
            );
        }
    }

    private class SubmitFulfillmentToDRConflictErrorOrderFulfilledMock extends HttpCalloutMockRouter {
        private SubmitFulfillmentToDRConflictErrorOrderFulfilledMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Submit Fulfillment Request',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.FULFILLMENT_PATH,
                DRB2B_Constants.Base.CONFLICT_RESPONSE_CODE,
                CONFLICT,
                getFulfillmentConflictErrorOrderFulfilledResponseModel()
            );
        }
    }

    private class SubmitFulfillmentToDRConflictErrorQuantityTooLargeMock extends HttpCalloutMockRouter {
        private SubmitFulfillmentToDRConflictErrorQuantityTooLargeMock() {
            this.registerEndpointVariable('endpoint', DRB2B_DRApiConstants.END_POINT);
            this.registerJsonMock(
                'Submit Fulfillment Request',
                'POST',
                '{{endpoint}}/' + DRB2B_DRApiConstants.FULFILLMENT_PATH,
                DRB2B_Constants.Base.CONFLICT_RESPONSE_CODE,
                CONFLICT,
                getFulfillmentConflictErrorQuantityTooLargeResponseModel()
            );
        }
    }

    private static DRB2B_CreateFulfillmentResponseModel getFulfillmentResponseModel() {
        DRB2B_CreateFulfillmentResponseModel fulfillmentResponseModel = new DRB2B_CreateFulfillmentResponseModel();
        fulfillmentResponseModel.createdTime = '2021-06-17T16:13:23Z';
        fulfillmentResponseModel.id = 'ful_4ab14a38-0bb2-4410-bf2e-521ba35fc5';
        fulfillmentResponseModel.liveMode = false;
        fulfillmentResponseModel.orderId = DR_ORDER_ID;

        List<DRB2B_CreateFulfillmentResponseModel.Items> lineItems = new List<DRB2B_CreateFulfillmentResponseModel.Items>();
        DRB2B_CreateFulfillmentResponseModel.Items lineItem1 = new DRB2B_CreateFulfillmentResponseModel.Items();
        lineItem1.itemId = DR_ORDER_ITEM_ID_1;
        lineItem1.quantity = 1;
        lineItem1.cancelQuantity = 0;
        lineItems.add(lineItem1);

        fulfillmentResponseModel.items = lineItems;
        return fulfillmentResponseModel;
    }

    private static DRB2B_ErrorResponse getFulfillmentErrorResponseModel() {
        DRB2B_ErrorResponse errorResponseModel = new DRB2B_ErrorResponse();
        errorResponseModel.type = 'error';

        List<DRB2B_ErrorResponse.Errors> errorList = new List<DRB2B_ErrorResponse.Errors>();
        DRB2B_ErrorResponse.Errors error = new DRB2B_ErrorResponse.Errors();
        error.code = 'error_code';
        error.parameter = 'itemId';
        error.message = 'Test Error message';
        errorList.add(error);

        errorResponseModel.errors = errorList;
        return errorResponseModel;
    }

    private static DRB2B_ErrorResponse getFulfillmentConflictErrorItemFulfilledResponseModel() {
        DRB2B_ErrorResponse errorResponseModel = new DRB2B_ErrorResponse();
        errorResponseModel.type = 'conflict';

        List<DRB2B_ErrorResponse.Errors> errorList = new List<DRB2B_ErrorResponse.Errors>();
        DRB2B_ErrorResponse.Errors error = new DRB2B_ErrorResponse.Errors();
        error.code = 'item_fulfilled';
        error.parameter = 'itemId';
        error.message = 'Resource \'' + DR_ORDER_ITEM_ID_1 + '\'  is already fulfilled';
        errorList.add(error);

        errorResponseModel.errors = errorList;
        return errorResponseModel;
    }

    private static DRB2B_ErrorResponse getFulfillmentConflictErrorOrderFulfilledResponseModel() {
        DRB2B_ErrorResponse errorResponseModel = new DRB2B_ErrorResponse();
        errorResponseModel.type = 'conflict';

        List<DRB2B_ErrorResponse.Errors> errorList = new List<DRB2B_ErrorResponse.Errors>();
        DRB2B_ErrorResponse.Errors error = new DRB2B_ErrorResponse.Errors();
        error.code = 'order_complete';
        error.parameter = 'orderId';
        error.message = 'Resource \'' + DR_ORDER_ID + '\'  is already complete.';
        errorList.add(error);

        errorResponseModel.errors = errorList;
        return errorResponseModel;
    }

    private static DRB2B_ErrorResponse getFulfillmentConflictErrorQuantityTooLargeResponseModel() {
        DRB2B_ErrorResponse errorResponseModel = new DRB2B_ErrorResponse();
        errorResponseModel.type = 'conflict';

        List<DRB2B_ErrorResponse.Errors> errorList = new List<DRB2B_ErrorResponse.Errors>();
        DRB2B_ErrorResponse.Errors error = new DRB2B_ErrorResponse.Errors();
        error.code = 'quantity_too_large';
        error.parameter = 'quantity';
        error.message = 'Sum of quantity and cancelQuantity may not exceed sku quantity of the order.';
        errorList.add(error);

        errorResponseModel.errors = errorList;
        return errorResponseModel;
    }

}
