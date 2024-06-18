@isTest
private with sharing class DRB2B_PaymentDetailsTest {
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

            result = ATK.prepare(DR_Transaction_Payment__c.SObjectType, 1)
                .build(EntityBuilderFactory.drTransactionPaymentBuilder)
                .save(false);

            DR_Transaction_Payment__c drTransactioPayment = (DR_Transaction_Payment__c) result.get(
                DR_Transaction_Payment__c.SobjectType
            )[0];
            drTransactioPayment.Order__c = sfOrder.Id;
            drTransactioPayment.Account__c = sfOrder.AccountId;
            drTransactioPayment.Amount__c = 20.99;
            drTransactioPayment.Card_Type__c = 'Visa';
            drTransactioPayment.Card_Number__c = 'xxxx-xxxx-xxxx-1111';
            drTransactioPayment.User__c = shopper.Id;
            drTransactioPayment.CurrencyISOCode__c = 'USD';
            drTransactioPayment.Payment_Method__c = 'creditCard';
            drTransactioPayment.Transaction_Type__c = 'AUTH';
            insert drTransactioPayment;
        }
    }

    @isTest
    static string getPaymentDetail_NegativeTest() {
        List<ContactPointAddress> contactPointadd = [
            SELECT Id, Name, AddressType, Country, City
            FROM ContactPointAddress
        ];
        List<OrderSummary> orderSummary = [SELECT Id, OriginalOrderId FROM OrderSummary];
        Test.startTest();
        try {
            String paymentDetail = DRB2B_PaymentDetails.getPaymentDetail('');
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(paymentDetail);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'For Null Order Summary exception must be thrown');
       
        }
        Test.stopTest();
        return null;
    }
    @IsTest
    static string getPaymentDetail_Test() {
        List<OrderSummary> orderSummary = [SELECT Id, OriginalOrderId FROM OrderSummary];
        Test.startTest();
        try {
            String paymentDetail = DRB2B_PaymentDetails.getPaymentDetail('1Os1D0000004CFaSAM');
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(paymentDetail);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'For Null Order Summary exception must be thrown');
        }
        Test.stopTest();
        return null;
    }
    
      @IsTest
    static string getPaymentDetailByCartId_Test() {
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Test.startTest();
        try {
            String paymentDetail = DRB2B_PaymentDetails.getPaymentDetailByCartId(webCart.Id);
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(paymentDetail);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'For Null cartid exception must be thrown');
        }
        Test.stopTest();
        return null;
    }
    
    @isTest
    static string getPaymentDetailByCartId_NegativeTest() {
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Test.startTest();
        try {
            String paymentDetail = DRB2B_PaymentDetails.getPaymentDetailByCartId('');
            Map<String, Object> requestData2 = (Map<String, Object>) JSON.deserializeUntyped(paymentDetail);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'For Null cartid exception must be thrown');
        }
        Test.stopTest();
         return null;
    }
}