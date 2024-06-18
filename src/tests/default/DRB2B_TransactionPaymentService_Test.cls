@IsTest
private class DRB2B_TransactionPaymentService_Test {
    private static final String DR_ORDER_ID = '190296100336';
    private static final String DR_RETRY_ORDER_ID = '190296101336';
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';
    private static final String TEST_SOURCE_ID = '0052123230007BcYFCC0';
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

            ATK.SaveResult result = ATK.prepare(User.SObjectType, 1)
                .build(EntityBuilderFactory.userBuilder)
                .save(false);
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
            insert orderItem;

            DR_Transaction_Payment__c transactionPaymentObj = new DR_Transaction_Payment__c();
            transactionPaymentObj.Account__c = acc.Id;
            transactionPaymentObj.Amount__c = 12.01;
            transactionPaymentObj.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            transactionPaymentObj.Card_Type__c = 'Visa';
            transactionPaymentObj.Payment_Method__c = 'creditCard';
            transactionPaymentObj.Token__c = TEST_SOURCE_ID;
            transactionPaymentObj.Contact__c = con.Id;
            transactionPaymentObj.User__c = shopper.Id;
            transactionPaymentObj.CurrencyISOCode__c = 'USD';
            transactionPaymentObj.Order__c = sfOrder.Id;
            transactionPaymentObj.Cart__c = webCart.Id;
            transactionPaymentObj.Transaction_Type__c = 'AUTH'; // this will be AUTH and after funds are captured it will be CAPTURE
            insert transactionPaymentObj;
        }
    }

    @IsTest
    static void deleteDRTransactionPayment_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        List<DR_Transaction_Payment__c> transactionPaymentObj1 = [
            SELECT id, Amount__c
            FROM DR_Transaction_Payment__c
            WHERE Token__c = :TEST_SOURCE_ID
            LIMIT 1
        ];
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Boolean isDeleted = new DRB2B_TransactionPaymentService().deleteDRTransactionPayment(TEST_SOURCE_ID);
            Test.startTest();
            System.assertEquals(true, isDeleted, 'DR Transaction Payment not deleted');
            Test.stopTest();
        }
    }

    @IsTest
    static void createTrasactionPaymentRecord_Test() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        List<DR_Transaction_Payment__c> transactionPaymentObj = [
            SELECT id, Amount__c
            FROM DR_Transaction_Payment__c
            WHERE Token__c = :TEST_SOURCE_ID
            LIMIT 1
        ];
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name, CreatedById, AccountId, CreatedBy.ContactId FROM Order LIMIT 1];
            WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
            DRB2B_CreateCheckoutResponseModel.Source sourceInfo = new DRB2B_CreateCheckoutResponseModel.Source();
            DRB2B_CreateCheckoutResponseModel.CreditCard creditCardInfo = new DRB2B_CreateCheckoutResponseModel.CreditCard();
            creditCardInfo.brand = 'Visa';

            creditCardInfo.lastFourDigits = '1111';
            creditCardInfo.expirationYear = 2039;
            creditCardInfo.expirationMonth = 7;

            sourceInfo.amount = 12.01;
            sourceInfo.type = 'creditCard';
            sourceInfo.creditCard = creditCardInfo;
            sourceInfo.id = TEST_SOURCE_ID;
            sourceInfo.drCurrency = 'USD';

            DR_Transaction_Payment__c drTransactionPayment = new DRB2B_TransactionPaymentService()
                .createTrasactionPaymentRecord(sfOrder, sourceInfo, webCart.Id);
            Test.startTest();
            System.assertEquals(TEST_SOURCE_ID, drTransactionPayment.Token__c, 'Source Id did not match');
            Test.stopTest();
        }
    }

    @IsTest
    static void createTrasactionPaymentRecord_TestWF() {
        // Given
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );
        List<DR_Transaction_Payment__c> transactionPaymentObj = [
            SELECT id, Amount__c
            FROM DR_Transaction_Payment__c
            WHERE Token__c = :TEST_SOURCE_ID
            LIMIT 1
        ];
        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            Order sfOrder = [SELECT id, Name, CreatedById, AccountId, CreatedBy.ContactId FROM Order LIMIT 1];
            WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
            DRB2B_CreateCheckoutResponseModel.Source sourceInfo = new DRB2B_CreateCheckoutResponseModel.Source();
            DRB2B_CreateCheckoutResponseModel.WireTransfer wireTransferInfo = new DRB2B_CreateCheckoutResponseModel.WireTransfer();
            wireTransferInfo.accountHolder = 'Global Collect BV';
            wireTransferInfo.bankName = 'Rabobank N.A.';
            wireTransferInfo.referenceId = '890701505439';
            wireTransferInfo.accountNumber = '0487369908';

            sourceInfo.amount = 12.01;
            sourceInfo.type = 'wireTransfer';
            sourceInfo.wireTransfer = wireTransferInfo;
            sourceInfo.id = TEST_SOURCE_ID;
            sourceInfo.drCurrency = 'USD';

            DR_Transaction_Payment__c drTransactionPayment = new DRB2B_TransactionPaymentService()
                .createTrasactionPaymentRecord(sfOrder, sourceInfo, webCart.Id);
            Test.startTest();
            System.assertEquals(TEST_SOURCE_ID, drTransactionPayment.Token__c, 'Source Id did not match');
            Test.stopTest();
        }
    }
}
