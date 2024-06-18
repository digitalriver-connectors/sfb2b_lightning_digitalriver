@IsTest
private class DRB2B_TransactionPaymentSelectorTest {
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
            //sfOrder.OriginalOrderId = orderSummary.Id;
            insert sfOrder;

            result = ATK.prepare(OrderItem.SObjectType, 1).build(EntityBuilderFactory.orderItemEBuilder).save(false);

            OrderItem orderItem = (OrderItem) result.get(OrderItem.SObjectType)[0];
            orderItem.Product2Id = product.Id;
            orderItem.PricebookEntryId = priceBookEntry.Id;
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.ListPrice = priceBookEntry.UnitPrice;
            orderItem.OrderId = sfOrder.Id;
            insert orderItem;
        }
    }

    @isTest
    static void getByOrderId_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT Id, AccountId FROM Order LIMIT 1];

            ATK.SaveResult result = ATK.prepare(DR_Transaction_Payment__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.drTransactionPaymentBuilder)
                                        .save(false);

            DR_Transaction_Payment__c drTransactionPayment = (DR_Transaction_Payment__c) result.get(
                DR_Transaction_Payment__c.SobjectType
            )[0];
            drTransactionPayment.Order__c = sfOrder.Id;
            drTransactionPayment.Account__c = sfOrder.AccountId;
            drTransactionPayment.Amount__c = 20.99;
            drTransactionPayment.Card_Type__c = 'Visa';
            drTransactionPayment.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            drTransactionPayment.User__c = DRB2B_TestEnvironment.shopperUser.Id;
            drTransactionPayment.CurrencyISOCode__c = 'USD';
            drTransactionPayment.Payment_Method__c = 'creditCard';
            drTransactionPayment.Transaction_Type__c = 'AUTH';
            insert drTransactionPayment;

            Test.startTest();
                List<DR_Transaction_Payment__c> transactionPaymentList = new DRB2B_TransactionPaymentSelector()
                    .getByOrderId(sfOrder.Id);
                System.debug('Transaction Payments: ' + transactionPaymentList);
                System.assertEquals(sfOrder.Id, transactionPaymentList.get(0).Order__c, 'Order Id Does not match');
            Test.stopTest();
        }
    }

    @isTest
    static void getByCartId_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT Id, AccountId FROM Order LIMIT 1];
            webCart cart = [SELECT Id FROM webCart LIMIT 1];

            ATK.SaveResult result = ATK.prepare(DR_Transaction_Payment__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.drTransactionPaymentBuilder)
                                        .save(false);

            DR_Transaction_Payment__c drTransactionPayment = (DR_Transaction_Payment__c) result.get(
                DR_Transaction_Payment__c.SobjectType
            )[0];
            drTransactionPayment.Order__c = sfOrder.Id;
            drTransactionPayment.Account__c = sfOrder.AccountId;
            drTransactionPayment.Amount__c = 20.99;
            drTransactionPayment.Card_Type__c = 'Visa';
            drTransactionPayment.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            drTransactionPayment.User__c = DRB2B_TestEnvironment.shopperUser.Id;
            drTransactionPayment.CurrencyISOCode__c = 'USD';
            drTransactionPayment.Payment_Method__c = 'creditCard';
            drTransactionPayment.Transaction_Type__c = 'AUTH';
            drTransactionPayment.Cart__c = cart.Id;
            insert drTransactionPayment; 

            Test.startTest();
                List<DR_Transaction_Payment__c> transactionPaymentList = new DRB2B_TransactionPaymentSelector()
                    .getByCartId(cart.Id);
                System.debug('Transaction Payments: ' + transactionPaymentList);
                System.assertEquals(sfOrder.Id, transactionPaymentList.get(0).Order__c, 'Order Id Does not match');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getBycartIdWithSelectedField_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            String token = '70766e4f-d76a-4ec5-99be-826a1ba082ef';
            Order sfOrder = [SELECT Id, AccountId FROM Order LIMIT 1];
            webCart cart = [SELECT Id FROM webCart LIMIT 1];

            ATK.SaveResult result = ATK.prepare(DR_Transaction_Payment__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.drTransactionPaymentBuilder)
                                        .save(false);

            DR_Transaction_Payment__c drTransactionPayment = (DR_Transaction_Payment__c) result.get(
                DR_Transaction_Payment__c.SobjectType
            )[0];
            drTransactionPayment.Order__c = sfOrder.Id;
            drTransactionPayment.Account__c = sfOrder.AccountId;
            drTransactionPayment.Amount__c = 20.99;
            drTransactionPayment.Card_Type__c = 'Visa';
            drTransactionPayment.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            drTransactionPayment.User__c = DRB2B_TestEnvironment.shopperUser.Id;
            drTransactionPayment.CurrencyISOCode__c = 'USD';
            drTransactionPayment.Payment_Method__c = 'creditCard';
            drTransactionPayment.Transaction_Type__c = 'AUTH';
            drTransactionPayment.Cart__c = cart.Id;
            drTransactionPayment.Token__c = token;
            insert drTransactionPayment; 

            Test.startTest();
            DRB2B_TransactionPaymentSelector paymentSelector = new DRB2B_TransactionPaymentSelector();
            List<DR_Transaction_Payment__c> paymentList = paymentSelector.getBycartId(
                cart.Id,
                new List<String>{ 'Token__c', 'Id', 'Order__c' }
            );
            System.debug('Transaction Payments: ' + paymentList);
            System.assertEquals(sfOrder.Id, paymentList.get(0).Order__c, 'Order Id Does not match');
            Test.stopTest();
        }
    }
    
     @isTest
    static void getBySourceId_Test() {
        // Assign DR Shopper Permission Set to User
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            String token = '70766e4f-d76a-4ec5-99be-826a1ba082ef';
            Order sfOrder = [SELECT Id, AccountId FROM Order LIMIT 1];
            webCart cart = [SELECT Id FROM webCart LIMIT 1];

            ATK.SaveResult result = ATK.prepare(DR_Transaction_Payment__c.SObjectType, 1)
                                        .build(EntityBuilderFactory.drTransactionPaymentBuilder)
                                        .save(false);

            DR_Transaction_Payment__c drTransactionPayment = (DR_Transaction_Payment__c) result.get(
                DR_Transaction_Payment__c.SobjectType
            )[0];
            drTransactionPayment.Order__c = sfOrder.Id;
            drTransactionPayment.Account__c = sfOrder.AccountId;
            drTransactionPayment.Amount__c = 20.99;
            drTransactionPayment.Card_Type__c = 'Visa';
            drTransactionPayment.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            drTransactionPayment.User__c = DRB2B_TestEnvironment.shopperUser.Id;
            drTransactionPayment.CurrencyISOCode__c = 'USD';
            drTransactionPayment.Payment_Method__c = 'creditCard';
            drTransactionPayment.Transaction_Type__c = 'AUTH';
            drTransactionPayment.Cart__c = cart.Id;
            drTransactionPayment.Token__c = token;
            insert drTransactionPayment; 

            Test.startTest();
            DRB2B_TransactionPaymentSelector paymentSelector = new DRB2B_TransactionPaymentSelector();
            List<DR_Transaction_Payment__c> paymentList = paymentSelector.getBySourceId(token);
            System.debug('Transaction Payments: ' + paymentList);
            System.assertEquals(token, paymentList.get(0).Token__c, 'Token should Match');
            Test.stopTest();
        }
    }
}