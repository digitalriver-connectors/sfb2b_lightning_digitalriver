@IsTest
private class DRB2B_OrderItemSelectorTest {
    private static final String DR_ORDER_ID = '190296100336';
    private static final String ORDER_ITEM_TYPE = 'Order Product';

    @TestSetup
    static void setupData() {
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
            orderItem.OrderId = sfOrder.Id;
            orderItem.Type = ORDER_ITEM_TYPE;
            orderItem.Quantity = 1;
            insert orderItem;
        }
    }

    @IsTest
    static void getByOrderIdsAndOrderItemType_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name FROM Order LIMIT 1];
            List<OrderItem> orderItem = new DRB2B_OrderItemSelector()
                .getByOrderIdsAndOrderItemType(new List<Id>{ sfOrder.Id }, ORDER_ITEM_TYPE);
            Test.startTest();
            System.assertEquals(sfOrder.Id, orderItem.get(0).OrderId, 'Order Id are not equal');
            Test.stopTest();
        }
    }

    @IsTest
    static void getByOrderIdAndType_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name FROM Order LIMIT 1];
            List<OrderItem> orderItem = new DRB2B_OrderItemSelector()
                .getByOrderIdAndType(sfOrder.Id, ORDER_ITEM_TYPE, new Set<String>{ 'Type', 'OrderId' });
            Test.startTest();
            System.assertEquals(sfOrder.Id, orderItem.get(0).OrderId, 'Order Id are not equal');
            Test.stopTest();
        }
    }

    @IsTest
    static void getQuantityFieldsByIds_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name FROM Order LIMIT 1];
            OrderItem orderItem = [SELECT id, Quantity FROM OrderItem LIMIT 1];
            List<OrderItem> orderItemList = new DRB2B_OrderItemSelector()
                .getQuantityFieldsByIds(new Set<Id>{ orderItem.Id });
            Test.startTest();
            System.assertEquals(orderItem.Quantity, orderItemList.get(0).Quantity, 'Order quantity dose not match');
            Test.stopTest();
        }
    }

    @IsTest
    static void getQuantityFieldsByIds_StringParamTest() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name FROM Order LIMIT 1];
            OrderItem orderItem = [SELECT id, Quantity FROM OrderItem LIMIT 1];
            List<OrderItem> orderItemList = new DRB2B_OrderItemSelector()
                .getQuantityFieldsByIds(new Set<String>{ orderItem.Id });
            Test.startTest();
            System.assertEquals(orderItem.Quantity, orderItemList.get(0).Quantity, 'Order quantity dose not match');
            Test.stopTest();
        }
    }

    @IsTest
    static void getDRFieldsByOrderItemIds_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name FROM Order LIMIT 1];
            OrderItem orderItem = [SELECT id, Quantity FROM OrderItem LIMIT 1];
            List<OrderItem> orderItemList = new DRB2B_OrderItemSelector()
                .getDRFieldsByOrderItemIds(new Set<Id>{ orderItem.Id });
            Test.startTest();
            System.assertEquals(orderItem.Quantity, orderItemList.get(0).Quantity, 'Order quantity dose not match');
            Test.stopTest();
        }
    }

    @IsTest
    static void getDRFieldsByOrderItemIds_StringParamTest() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name FROM Order LIMIT 1];
            OrderItem orderItem = [SELECT id, Quantity FROM OrderItem LIMIT 1];
            List<OrderItem> orderItemList = new DRB2B_OrderItemSelector()
                .getDRFieldsByOrderItemIds(new Set<String>{ orderItem.Id });
            Test.startTest();
            System.assertEquals(orderItem.Quantity, orderItemList.get(0).Quantity, 'Order quantity dose not match');
            Test.stopTest();
        }
    }

    @IsTest
    static void getQuantityFieldsByOrderIds_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name FROM Order LIMIT 1];
            OrderItem orderItem = [SELECT id, Quantity FROM OrderItem LIMIT 1];
            List<OrderItem> orderItemList = new DRB2B_OrderItemSelector()
                .getQuantityFieldsByOrderIds(new Set<Id>{ sfOrder.Id });
            Test.startTest();
            System.assertEquals(orderItem.Quantity, orderItemList.get(0).Quantity, 'Order quantity dose not match');
            Test.stopTest();
        }
    }
}
