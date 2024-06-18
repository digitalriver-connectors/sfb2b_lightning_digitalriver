@isTest
private class DRB2B_FulfillmentRequestLogServiceTest {

    //private static final String SF_ORDER_ID = '8015e000123cXuEAAU';
    private static final String DR_ORDER_ID_1 = '12345678';
    private static final String DR_ORDER_ID_2 = '123434323';
    private static final String DR_ORDER_ITEM_ID_1 = '9738378237';
    private static final String DR_ORDER_ITEM_ID_2 = '9733322237';
    private static final String DR_ORDER_ITEM_ID_3 = '9732343537';
    private static final String DR_ORDER_STATE = 'accepted';

    @TestSetup
    static void setup() {
        // Make sure User is created in a different transaction or else we will run into Mixed DML error
        DRB2B_TestEnvironment.createIntegrationUser();

        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult resultAccount = ATK.prepare(Account.SObjectType, 1)
                                            .build(EntityBuilderFactory.accountBuilder)
                                            .save(false);
            Account acc = (Account) resultAccount.get(Account.SObjectType)[0];
            insert acc;

            ATK.SaveResult resultContact = ATK.prepare(Contact.SObjectType, 1)
                                                .build(EntityBuilderFactory.contactBuilder)
                                                .save(false);
            Contact con = (Contact) resultContact.get(Contact.SObjectType)[0];
            con.AccountId = acc.Id;
            insert con;

            ATK.SaveResult result = ATK.prepare(User.SObjectType, 1).build(EntityBuilderFactory.userBuilder).save(false);
            User shopper = (User) result.get(User.SObjectType)[0];
            Profile shopperProfile = [SELECT Id FROM Profile WHERE Name = :DRB2B_Constants.Profile.DR_SHOPPER LIMIT 1];
            shopper.ProfileId = shopperProfile.Id;
            shopper.ContactId = con.Id;
            insert shopper;

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

            result = ATK.prepare(Product2.SObjectType, 2).build(EntityBuilderFactory.productBuilder).save(false);

            Product2 product1 = (Product2) result.get(Product2.SObjectType)[0];
            insert product1;

            Product2 product2 = (Product2) result.get(Product2.SObjectType)[1];
            insert product2;

            result = ATK.prepare(PricebookEntry.SObjectType, 2)
                        .build(EntityBuilderFactory.pricebookEntryBuilder)
                        .save(false);

            PricebookEntry standardPriceBookEntry1 = (PricebookEntry) result.get(PricebookEntry.SObjectType)[0];
            standardPriceBookEntry1.Pricebook2Id = Test.getStandardPricebookId();
            standardPriceBookEntry1.Product2Id = product1.Id;
            standardPriceBookEntry1.UnitPrice = 20;
            insert standardPriceBookEntry1;

            PricebookEntry standardPriceBookEntry2 = (PricebookEntry) result.get(PricebookEntry.SObjectType)[1];
            standardPriceBookEntry2.Pricebook2Id = Test.getStandardPricebookId();
            standardPriceBookEntry2.Product2Id = product2.Id;
            standardPriceBookEntry2.UnitPrice = 30;
            insert standardPriceBookEntry2;

            ATK.SaveResult resultP = ATK.prepare(PricebookEntry.SObjectType, 2)
                                        .build(EntityBuilderFactory.pricebookEntryBuilder)
                                        .save(false);

            PricebookEntry priceBookEntry1 = (PricebookEntry) resultP.get(PricebookEntry.SObjectType)[0];
            priceBookEntry1.Pricebook2Id = priceBook.Id;
            priceBookEntry1.Product2Id = product1.Id;
            priceBookEntry1.UnitPrice = 20.99;
            insert priceBookEntry1;

            PricebookEntry priceBookEntry2 = (PricebookEntry) resultP.get(PricebookEntry.SObjectType)[1];
            priceBookEntry2.Pricebook2Id = priceBook.Id;
            priceBookEntry2.Product2Id = product2.Id;
            priceBookEntry2.UnitPrice = 30.99;
            insert priceBookEntry2;

            result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);

            WebCart webCart = (WebCart) result.get(WebCart.SObjectType)[0];
            webCart.AccountId = acc.Id;
            webcart.webStoreId = webStore.Id;
            insert WebCart;

            result = ATK.prepare(Order.SObjectType, 2).build(EntityBuilderFactory.orderBuilder).save(false);

            Order sfOrder1 = (Order) result.get(Order.SObjectType)[0];
            sfOrder1.AccountId = webCart.AccountId;
            sfOrder1.Pricebook2Id = priceBook.Id;
            sfOrder1.DR_Order_Id__c = DR_ORDER_ID_1;
            sfOrder1.DR_Order_State__c = 'accepted';
            insert sfOrder1;

            Order sfOrder2 = (Order) result.get(Order.SObjectType)[1];
            sfOrder2.AccountId = webCart.AccountId;
            sfOrder2.Pricebook2Id = priceBook.Id;
            sfOrder2.DR_Order_Id__c = DR_ORDER_ID_2;
            sfOrder2.DR_Order_State__c = 'accepted';
            insert sfOrder2;

            result = ATK.prepare(OrderItem.SObjectType, 3).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem1 = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem1.Product2Id = product1.Id;
            orderItem1.PricebookEntryId = priceBookEntry1.Id;
            orderItem1.UnitPrice = priceBookEntry1.UnitPrice;
            orderItem1.ListPrice = priceBookEntry1.UnitPrice;
            orderItem1.DR_Order_Item_Id__c = DR_ORDER_ITEM_ID_1;
            orderItem1.OrderId = sfOrder1.Id;
            orderItem1.DR_Open_Quantity__c = orderItem1.Quantity;
            orderItem1.Type = 'Order Product';
            insert orderItem1;

            OrderItem orderItem2 = (OrderItem) result.get(OrderItem.SObjectType)[1];
            orderItem2.Product2Id = product2.Id;
            orderItem2.PricebookEntryId = priceBookEntry2.Id;
            orderItem2.UnitPrice = priceBookEntry2.UnitPrice;
            orderItem2.ListPrice = priceBookEntry2.UnitPrice;
            orderItem2.DR_Order_Item_Id__c = DR_ORDER_ITEM_ID_2;
            orderItem2.OrderId = sfOrder1.Id;
            orderItem2.DR_Open_Quantity__c = orderItem2.Quantity;
            orderItem2.Type = 'Order Product';
            insert orderItem2;

            OrderItem orderItem3 = (OrderItem) result.get(OrderItem.SObjectType)[2];
            orderItem3.Product2Id = product2.Id;
            orderItem3.PricebookEntryId = priceBookEntry2.Id;
            orderItem3.UnitPrice = priceBookEntry2.UnitPrice;
            orderItem3.ListPrice = priceBookEntry2.UnitPrice;
            orderItem3.DR_Order_Item_Id__c = DR_ORDER_ITEM_ID_3;
            orderItem3.OrderId = sfOrder2.Id;
            orderItem3.DR_Open_Quantity__c = orderItem3.Quantity;
            orderItem3.Type = 'Order Product';
            insert orderItem3;

            //Create DR Fulfillment Record
            ATK.SaveResult drOrderFulfillmentResult = ATK.prepare(DR_Fulfillment__c.SObjectType, 1)
                                                            .build(EntityBuilderFactory.drFulfillmentBuilder)
                                                            .save(false);
            DR_Fulfillment__c drFulfillmentRec1 = (DR_Fulfillment__c) drOrderFulfillmentResult.get(DR_Fulfillment__c.SobjectType)[0];
            drFulfillmentRec1.DR_Order_Id__c = DR_ORDER_ID_1;
            drFulfillmentRec1.Eligible_For_Fulfillment__c = true;
            insert drFulfillmentRec1;
        }

    }

    @isTest
    static void checkIfOrderItemsBelongToCorrectOrder_RequestLogCreated_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<DR_Fulfillment_Request_Log__c> goodFulfillmentReqLogRecs;
        Order orderRec = [Select Id, DR_Order_Id__c, DR_Order_State__c From Order where DR_Order_Id__c = :DR_ORDER_ID_1][0];
        List<OrderItem> orderItemRecs = [Select Id, OrderId, DR_Order_Item_Id__c, Quantity, DR_Open_Quantity__c From OrderItem where OrderId = :orderRec.Id];

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 1)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec1 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec1.OrderId__c = orderItemRecs.get(0).OrderId;
            drFulfillmentReqLogRec1.OrderItem_Id__c = orderItemRecs.get(0).Id;
            drFulfillmentReqLogRec1.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c;
            drFulfillmentReqLogRec1.Cancel_Quantity__c = 0;
            drFulfillmentReqLogRec1.DR_Order_Id__c = orderRec.DR_Order_Id__c;
            drFulfillmentReqLogRec1.DR_OrderItem_Id__c = orderItemRecs.get(0).DR_Order_Item_Id__c;
            //insert drFulfillmentReqLogRec1;
            requestLogRecList.add(drFulfillmentReqLogRec1);
            //System.debug('DR FulfillmentRequest Log record: ' + drFulfillmentReqLogRec1);

            Test.startTest();
                goodFulfillmentReqLogRecs = fulfillmentReqLogService.checkIfOrderItemsBelongToCorrectOrder(requestLogRecList, false);
            Test.stopTest();
            System.assertEquals(true, goodFulfillmentReqLogRecs.size() == 1, 'DR Fulfillment Request Log Record should be created');
        }
    }

    @isTest
    static void checkIfOrderItemsBelongToCorrectOrder_OrderItemIdDoesNotBelongToOrderSelected_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<DR_Fulfillment_Request_Log__c> goodFulfillmentReqLogRecs;
        Order orderRec = [Select Id, DR_Order_Id__c, DR_Order_State__c From Order where DR_Order_Id__c = :DR_ORDER_ID_2][0];
        List<OrderItem> orderItemRecs = [Select Id, OrderId, DR_Order_Item_Id__c, Quantity, DR_Open_Quantity__c From OrderItem where OrderId 
                                            in (Select Id from Order where DR_Order_Id__c = :DR_ORDER_ID_1)];

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 1)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec1 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec1.OrderId__c = orderRec.Id;
            drFulfillmentReqLogRec1.OrderItem_Id__c = orderItemRecs.get(0).Id;
            drFulfillmentReqLogRec1.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c;
            drFulfillmentReqLogRec1.Cancel_Quantity__c = 0;
            drFulfillmentReqLogRec1.DR_Order_Id__c = orderRec.DR_Order_Id__c;
            drFulfillmentReqLogRec1.DR_OrderItem_Id__c = orderItemRecs.get(0).DR_Order_Item_Id__c;
            //insert drFulfillmentReqLogRec1;
            requestLogRecList.add(drFulfillmentReqLogRec1);
            //System.debug('DR FulfillmentRequest Log record: ' + drFulfillmentReqLogRec1);

            Test.startTest();
                goodFulfillmentReqLogRecs = fulfillmentReqLogService.checkIfOrderItemsBelongToCorrectOrder(requestLogRecList, false);
            Test.stopTest();
            System.assertEquals(true, goodFulfillmentReqLogRecs.size() == 0, 'DR Fulfillment Request Log Record cannot be created as OrderItem Id(s) does not belong to the correct Order');
        }
    }

    @isTest
    static void checkIfOrderItemsBelongToCorrectOrder_RequestedQuantityCannotBeMoreThanOpenQuantity_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<DR_Fulfillment_Request_Log__c> goodFulfillmentReqLogRecs;
        Order orderRec = [Select Id, DR_Order_Id__c, DR_Order_State__c From Order where DR_Order_Id__c = :DR_ORDER_ID_1][0];
        List<OrderItem> orderItemRecs = [Select Id, OrderId, DR_Order_Item_Id__c, Quantity, DR_Open_Quantity__c From OrderItem where OrderId = :orderRec.Id];

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 1)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec1 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec1.OrderId__c = orderItemRecs.get(0).OrderId;
            drFulfillmentReqLogRec1.OrderItem_Id__c = orderItemRecs.get(0).Id;
            drFulfillmentReqLogRec1.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c + 1;
            drFulfillmentReqLogRec1.Cancel_Quantity__c = 0;
            drFulfillmentReqLogRec1.DR_Order_Id__c = orderRec.DR_Order_Id__c;
            drFulfillmentReqLogRec1.DR_OrderItem_Id__c = orderItemRecs.get(0).DR_Order_Item_Id__c;
            //insert drFulfillmentReqLogRec1;
            requestLogRecList.add(drFulfillmentReqLogRec1);
            //System.debug('DR FulfillmentRequest Log record: ' + drFulfillmentReqLogRec1);

            Test.startTest();
                goodFulfillmentReqLogRecs = fulfillmentReqLogService.checkIfOrderItemsBelongToCorrectOrder(requestLogRecList, false);
            Test.stopTest();
            System.assertEquals(true, goodFulfillmentReqLogRecs.size() == 0, 'DR Fulfillment Request Log Record cannot be created as Requested quantity is more than Available/Open Quantity');
        }
    }

    @isTest
    static void checkIfOrderItemsBelongToCorrectOrder_PartialNotSupported_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<DR_Fulfillment_Request_Log__c> goodFulfillmentReqLogRecs;
        Order orderRec = [Select Id, DR_Order_Id__c, DR_Order_State__c From Order where DR_Order_Id__c = :DR_ORDER_ID_1][0];
        List<OrderItem> orderItemRecs = [Select Id, OrderId, DR_Order_Item_Id__c, Quantity, DR_Open_Quantity__c From OrderItem where OrderId = :orderRec.Id];

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 2)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec1 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec1.OrderId__c = orderItemRecs.get(0).OrderId;
            drFulfillmentReqLogRec1.OrderItem_Id__c = orderItemRecs.get(0).Id;
            drFulfillmentReqLogRec1.Fulfill_Quantity__c = 1;
            drFulfillmentReqLogRec1.Cancel_Quantity__c = 1;
            drFulfillmentReqLogRec1.DR_Order_Id__c = orderRec.DR_Order_Id__c;
            drFulfillmentReqLogRec1.DR_OrderItem_Id__c = orderItemRecs.get(0).DR_Order_Item_Id__c;
            requestLogRecList.add(drFulfillmentReqLogRec1);

            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec2 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[1];
            drFulfillmentReqLogRec2.OrderId__c = orderItemRecs.get(1).OrderId;
            drFulfillmentReqLogRec2.OrderItem_Id__c = orderItemRecs.get(1).Id;
            drFulfillmentReqLogRec2.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c - 1;
            drFulfillmentReqLogRec2.Cancel_Quantity__c = 0;
            drFulfillmentReqLogRec2.DR_Order_Id__c = orderRec.DR_Order_Id__c;
            drFulfillmentReqLogRec2.DR_OrderItem_Id__c = orderItemRecs.get(1).DR_Order_Item_Id__c;
            requestLogRecList.add(drFulfillmentReqLogRec2);

            Test.startTest();
                goodFulfillmentReqLogRecs = fulfillmentReqLogService.checkIfOrderItemsBelongToCorrectOrder(requestLogRecList, false);
            Test.stopTest();
            System.assertEquals(true, goodFulfillmentReqLogRecs.size() == 0, 'DR Fulfillment Request Log Record cannot be created as Partial Fulfillment/Cancellation is not supported');
        }
    }

    @isTest
    static void checkIfOrderItemsBelongToCorrectOrder_PartialSupported_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<DR_Fulfillment_Request_Log__c> goodFulfillmentReqLogRecs;
        Order orderRec = [Select Id, DR_Order_Id__c, DR_Order_State__c From Order where DR_Order_Id__c = :DR_ORDER_ID_1][0];
        List<OrderItem> orderItemRecs = [Select Id, OrderId, DR_Order_Item_Id__c, Quantity, DR_Open_Quantity__c From OrderItem where OrderId = :orderRec.Id];

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 2)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec1 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec1.OrderId__c = orderItemRecs.get(0).OrderId;
            drFulfillmentReqLogRec1.OrderItem_Id__c = orderItemRecs.get(0).Id;
            drFulfillmentReqLogRec1.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c - 1;
            drFulfillmentReqLogRec1.Cancel_Quantity__c = 1;
            drFulfillmentReqLogRec1.DR_Order_Id__c = orderRec.DR_Order_Id__c;
            drFulfillmentReqLogRec1.DR_OrderItem_Id__c = orderItemRecs.get(0).DR_Order_Item_Id__c;
            requestLogRecList.add(drFulfillmentReqLogRec1);

            /*DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec2 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[1];
            drFulfillmentReqLogRec2.OrderId__c = orderItemRecs.get(1).OrderId;
            drFulfillmentReqLogRec2.OrderItem_Id__c = orderItemRecs.get(1).Id;
            drFulfillmentReqLogRec2.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c - 1;
            drFulfillmentReqLogRec2.Cancel_Quantity__c = 0;
            drFulfillmentReqLogRec2.DR_Order_Id__c = orderRec.DR_Order_Id__c;
            drFulfillmentReqLogRec2.DR_OrderItem_Id__c = orderItemRecs.get(1).DR_Order_Item_Id__c;
            requestLogRecList.add(drFulfillmentReqLogRec2);*/

            Test.startTest();
                goodFulfillmentReqLogRecs = fulfillmentReqLogService.checkIfOrderItemsBelongToCorrectOrder(requestLogRecList, true);
            Test.stopTest();
            System.assertEquals(true, goodFulfillmentReqLogRecs.size() == 1, 'DR Fulfillment Request Log Record should be created as Partial Fulfillment/Cancellation is supported');
        }
    }

    @isTest
    static void getEligibleRecsForFulfillment_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<DR_Fulfillment_Request_Log__c> eligibleFulfillmentReqLogs;
        List<OrderItem> orderItemRecs = [Select Id, OrderId, Order.DR_Order_Id__c, DR_Order_Item_Id__c, Quantity, DR_Open_Quantity__c From OrderItem];

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            //Create DR Fulfillment Request Log Record
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 3)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec1 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec1.OrderId__c = orderItemRecs.get(0).OrderId;
            drFulfillmentReqLogRec1.OrderItem_Id__c = orderItemRecs.get(0).Id;
            drFulfillmentReqLogRec1.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c;
            drFulfillmentReqLogRec1.Cancel_Quantity__c = 0;
            drFulfillmentReqLogRec1.DR_Order_Id__c = orderItemRecs.get(0).Order.DR_Order_Id__c;
            drFulfillmentReqLogRec1.DR_OrderItem_Id__c = orderItemRecs.get(0).DR_Order_Item_Id__c;
            requestLogRecList.add(drFulfillmentReqLogRec1);

            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec2 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[1];
            drFulfillmentReqLogRec2.OrderId__c = orderItemRecs.get(1).OrderId;
            drFulfillmentReqLogRec2.OrderItem_Id__c = orderItemRecs.get(1).Id;
            drFulfillmentReqLogRec2.Fulfill_Quantity__c = 0;
            drFulfillmentReqLogRec2.Cancel_Quantity__c = orderItemRecs.get(1).DR_Open_Quantity__c;
            drFulfillmentReqLogRec2.DR_Order_Id__c = orderItemRecs.get(1).Order.DR_Order_Id__c;
            drFulfillmentReqLogRec2.DR_OrderItem_Id__c = orderItemRecs.get(1).DR_Order_Item_Id__c;
            requestLogRecList.add(drFulfillmentReqLogRec2);

            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec3 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[2];
            drFulfillmentReqLogRec3.OrderId__c = orderItemRecs.get(2).OrderId;
            drFulfillmentReqLogRec3.OrderItem_Id__c = orderItemRecs.get(2).Id;
            drFulfillmentReqLogRec3.Fulfill_Quantity__c = orderItemRecs.get(2).DR_Open_Quantity__c;
            drFulfillmentReqLogRec3.Cancel_Quantity__c = 0;
            drFulfillmentReqLogRec3.DR_Order_Id__c = orderItemRecs.get(2).Order.DR_Order_Id__c;
            drFulfillmentReqLogRec3.DR_OrderItem_Id__c = orderItemRecs.get(2).DR_Order_Item_Id__c;
            requestLogRecList.add(drFulfillmentReqLogRec3);

            Test.startTest();
                eligibleFulfillmentReqLogs = fulfillmentReqLogService.getEligibleRecsForFulfillment(requestLogRecList);
            Test.stopTest();
            System.assertEquals(true, eligibleFulfillmentReqLogs.size() == 2, 'order.accepted event is received for only one Order');
        }
    }

    @isTest
    static void validateRequestedFulfillAndCancelQuantity_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<OrderItem> orderItemRecs = [Select Id, OrderId, Order.DR_Order_Id__c, DR_Order_Item_Id__c, Quantity, DR_Open_Quantity__c From OrderItem];

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();

            //Create DR Fulfillment Request Log Records
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 3)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec1 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec1.OrderId__c = orderItemRecs.get(0).OrderId;
            drFulfillmentReqLogRec1.OrderItem_Id__c = orderItemRecs.get(0).Id;
            drFulfillmentReqLogRec1.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c;
            drFulfillmentReqLogRec1.Cancel_Quantity__c = 0;
            requestLogRecList.add(drFulfillmentReqLogRec1);

            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec2 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[1];
            drFulfillmentReqLogRec2.OrderId__c = orderItemRecs.get(1).OrderId;
            drFulfillmentReqLogRec2.OrderItem_Id__c = orderItemRecs.get(1).Id;
            drFulfillmentReqLogRec2.Fulfill_Quantity__c = 0;
            drFulfillmentReqLogRec2.Cancel_Quantity__c = orderItemRecs.get(1).DR_Open_Quantity__c + 1;
            requestLogRecList.add(drFulfillmentReqLogRec2);

            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec3 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[2];
            drFulfillmentReqLogRec3.OrderId__c = orderItemRecs.get(2).OrderId;
            drFulfillmentReqLogRec3.OrderItem_Id__c = orderItemRecs.get(2).Id;
            drFulfillmentReqLogRec3.Fulfill_Quantity__c = 0;
            drFulfillmentReqLogRec3.Cancel_Quantity__c = 0;
            requestLogRecList.add(drFulfillmentReqLogRec3);

            Test.startTest();
                fulfillmentReqLogService.validateRequestedFulfillAndCancelQuantity(requestLogRecList);
            Test.stopTest();
            System.assertEquals(false, drFulfillmentReqLogRec1.hasErrors(), 'This Fulfillment Request Log record should not have any errors');
            System.assertEquals(true, drFulfillmentReqLogRec2.hasErrors(), 'This Fulfillment Request Log record should fail as requested cancel quantity is greater than open quantity');
        }
    }

    @isTest
    static void updateOpenQuantityOnOrderItems_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        Order orderRec = [Select Id, DR_Order_Id__c, DR_Order_State__c From Order where DR_Order_Id__c = :DR_ORDER_ID_1][0];
        List<OrderItem> orderItemRecs = [Select Id, OrderId, Order.DR_Order_Id__c, DR_Order_Item_Id__c, Quantity, DR_Open_Quantity__c From OrderItem where OrderId = :orderRec.Id];

        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            List<DR_Fulfillment_Request_Log__c> requestLogRecList = new List<DR_Fulfillment_Request_Log__c>();

            //Create DR Fulfillment Request Log Records
            ATK.SaveResult fulfillmentReqLogResult = ATK.prepare(DR_Fulfillment_Request_Log__c.SObjectType, 2)
                                                        .build(EntityBuilderFactory.fulfillmentRequestLogBuilder)
                                                        .save(false);
            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec1 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[0];
            drFulfillmentReqLogRec1.OrderId__c = orderItemRecs.get(0).OrderId;
            drFulfillmentReqLogRec1.OrderItem_Id__c = orderItemRecs.get(0).Id;
            drFulfillmentReqLogRec1.Fulfill_Quantity__c = orderItemRecs.get(0).DR_Open_Quantity__c;
            drFulfillmentReqLogRec1.Cancel_Quantity__c = 0;
            requestLogRecList.add(drFulfillmentReqLogRec1);

            DR_Fulfillment_Request_Log__c drFulfillmentReqLogRec2 = (DR_Fulfillment_Request_Log__c) fulfillmentReqLogResult.get(DR_Fulfillment_Request_Log__c.SobjectType)[1];
            drFulfillmentReqLogRec2.OrderId__c = orderItemRecs.get(1).OrderId;
            drFulfillmentReqLogRec2.OrderItem_Id__c = orderItemRecs.get(1).Id;
            drFulfillmentReqLogRec2.Fulfill_Quantity__c = 0;
            drFulfillmentReqLogRec2.Cancel_Quantity__c = orderItemRecs.get(1).DR_Open_Quantity__c;
            requestLogRecList.add(drFulfillmentReqLogRec2);

            Test.startTest();
                fulfillmentReqLogService.updateOpenQuantityOnOrderItems(requestLogRecList);
            Test.stopTest();
            List<OrderItem> orderItemUpdatedRecs = [Select Id, DR_Open_Quantity__c From OrderItem where OrderId = :orderRec.Id];
            System.assertEquals(0, orderItemUpdatedRecs.get(0).DR_Open_Quantity__c, 'Open Quantity should be updated to 0');
            System.assertEquals(0, orderItemUpdatedRecs.get(1).DR_Open_Quantity__c, 'Open Quantity should be updated to 0');
        }
    }

    @isTest
    static void createFulfillmentRequestLogRecs_FulfillOrder_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<Id> orderIds;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            List<Order> orderRecs = [Select Id, DR_Order_Id__c, DR_Order_State__c From Order where DR_Order_Id__c = :DR_ORDER_ID_1];
            orderIds = (List<Id>) Collection.of(orderRecs).listOf(Order.Id);
            orderRecs.get(0).DR_Order_State__c = DRB2B_Constants.Fulfillment.FULFILL_STATUS;

            Test.startTest();
                fulfillmentReqLogService.createFulfillmentRequestLogRecs(orderRecs);
            Test.stopTest();
            List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecList = [Select Id, Fulfill_Quantity__c, Cancel_Quantity__c From DR_Fulfillment_Request_Log__c where OrderId__c in :orderIds];
            System.assertEquals(true, fulfillmentRequestLogRecList.size() > 0, 'DR Fulfillment request log records should be created');
            System.assertEquals(true, fulfillmentRequestLogRecList.get(0).Fulfill_Quantity__c > 0, 'Fulfill quantity of DR Fulfillment request log record should be greater than zero');
        }
    }

    @isTest
    static void createFulfillmentRequestLogRecs_CancelOrder_Test() {
        // Assign DR Integration Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.integrationUser,
            DRB2B_Constants.PermissionSet.INTEGRATION
        );

        DRB2B_FulfillmentRequestLogService fulfillmentReqLogService = new DRB2B_FulfillmentRequestLogService();
        List<Id> orderIds;
        System.runAs(DRB2B_TestEnvironment.integrationUser) {
            List<Order> orderRecs = [Select Id, DR_Order_Id__c, DR_Order_State__c From Order where DR_Order_Id__c = :DR_ORDER_ID_1];
            orderIds = (List<Id>) Collection.of(orderRecs).listOf(Order.Id);
            orderRecs.get(0).DR_Order_State__c = DRB2B_Constants.Fulfillment.CANCEL_STATUS;

            Test.startTest();
                fulfillmentReqLogService.createFulfillmentRequestLogRecs(orderRecs);
            Test.stopTest();
            List<DR_Fulfillment_Request_Log__c> fulfillmentRequestLogRecList = [Select Id, Fulfill_Quantity__c, Cancel_Quantity__c From DR_Fulfillment_Request_Log__c where OrderId__c in :orderIds];
            System.assertEquals(true, fulfillmentRequestLogRecList.size() > 0, 'DR Fulfillment request log records should be created');
            System.assertEquals(true, fulfillmentRequestLogRecList.get(0).Cancel_Quantity__c > 0, 'Cancel quantity of DR Fulfillment request log record should be greater than zero');
        }
    }

}