@isTest
private with sharing class DRB2B_UpdateCartItemPriceTrigHdlrTest {

    @TestSetup
    static void setupData() {
        System.runAs(DRB2B_TestEnvironment.portalAccountOwner) {
            ATK.SaveResult resultAccount = ATK.prepare(Account.SObjectType, 1)
                .build(EntityBuilderFactory.accountBuilder)
                .save(false);
            Account acc = (Account) resultAccount.get(Account.SObjectType)[0];
            insert acc;

            ATK.SaveResult resultWebStore = ATK.prepare(WebStore.SObjectType, 1)
                .build(EntityBuilderFactory.webStoreBuilder)
                .save(false);
            WebStore store = (WebStore) resultWebStore.get(WebStore.SObjectType)[0];
            insert store;

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

            ATK.SaveResult resultCart = ATK.prepare(WebCart.SObjectType, 1)
                .build(EntityBuilderFactory.webCartBuilder)
                .save(false);
            WebCart cart = (WebCart) resultCart.get(WebCart.SObjectType)[0];
            cart.WebStoreId = store.Id;
            cart.AccountId = acc.Id;
            cart.Name = 'Test Cart';
            insert cart;

            ATK.SaveResult resultCartDeliveryGroup = ATK.prepare(CartDeliveryGroup.SObjectType, 1)
                .build(EntityBuilderFactory.cartDeliveryGroupBuilder)
                .save(false);
            CartDeliveryGroup cartDeliveryGroup = (CartDeliveryGroup) resultCartDeliveryGroup.get(
                CartDeliveryGroup.SObjectType
            )[0];
            cartDeliveryGroup.CartId = cart.Id;
            insert cartDeliveryGroup;

            // Create Cart Item
            ATK.SaveResult resultCartItem = ATK.prepare(CartItem.SObjectType, 1)
                .build(EntityBuilderFactory.cartItemBuilder)
                .save(false);
            CartItem cartItemRec = (CartItem) resultCartItem.get(CartItem.SObjectType)[0];
            cartItemRec.CartId = cart.Id;
            cartItemRec.CartDeliveryGroupId = cartDeliveryGroup.Id;
            insert cartItemRec;

            ATK.SaveResult resultCartTax = ATK.prepare(CartTax.SObjectType, 1)
                .build(EntityBuilderFactory.cartTaxBuilder)
                .save(false);
            CartTax cartTaxRec = (CartTax) resultCartTax.get(CartTax.SObjectType)[0];
            cartTaxRec.CartItemId = cartItemRec.Id;
            insert cartTaxRec;
        }
    }

    @isTest
    static void beforeInsert_totalPriceExcludingDrSurchargeEqualsTotalPrice_Test() {
        // Create Cart Item
        CartDeliveryGroup cartDeliveryGroup = [SELECT Id, CartId FROM CartDeliveryGroup LIMIT 1];
        ATK.SaveResult resultCartItem = ATK.prepare(CartItem.SObjectType, 1)
            .build(EntityBuilderFactory.cartItemBuilder)
            .save(false);
        CartItem cartItemRec = (CartItem) resultCartItem.get(CartItem.SObjectType)[0];
        cartItemRec.CartId = cartDeliveryGroup.CartId;
        cartItemRec.CartDeliveryGroupId = cartDeliveryGroup.Id;
        insert cartItemRec;
        String cartItemId = cartItemRec.Id;

        Test.startTest();
        CartItem cartItemRecord = [
            SELECT Id, TotalPrice, Total_Price_Excluding_DR_Surcharge__c
            FROM CartItem
            WHERE Id = :cartItemId
        ];
        System.assertEquals(
            true,
            cartItemRecord.TotalPrice == cartItemRecord.Total_Price_Excluding_DR_Surcharge__c,
            'Total Price Excluding DR Surcharge should match Total Price of Cart Item'
        );
        Test.stopTest();
    }

    @isTest
    static void beforeUpdate_updateTotalPriceWithDrSurcharge_TotalPriceUpdatedBecauseOfCoupons_Test() {
        CartItem cartItemRec = [
            SELECT
                Id,
                Total_Price_Excluding_DR_Surcharge__c,
                Total_DR_Surcharge__c,
                TotalPrice,
                Price_Includes_DR_Surcharge__c
            FROM CartItem
            WHERE Name = 'Product 0001'
        ];
        String cartItemId = cartItemRec.Id;
        Decimal oldTotalPriceExcludingDrSurcharge = cartItemRec.Total_Price_Excluding_DR_Surcharge__c;
        Decimal oldTotalPrice = cartItemRec.TotalPrice;
        cartItemRec.Price_Includes_DR_Surcharge__c = false;
        cartItemRec.TotalPrice = cartItemRec.TotalPrice - cartItemRec.Total_DR_Surcharge__c + 1.00;
        update cartItemRec;

        Test.startTest();
        CartItem cartItemUpdatedRec = [
            SELECT Id, TotalPrice, Total_Price_Excluding_DR_Surcharge__c
            FROM CartItem
            WHERE Id = :cartItemId
        ];
        System.assertEquals(
            cartItemUpdatedRec.Total_Price_Excluding_DR_Surcharge__c,
            cartItemUpdatedRec.TotalPrice,
            'Total Price Excluding DR Surcharge should match new Total Price'
        );
        Test.stopTest();
    }

    @isTest
    static void beforeUpdate_updateTotalPriceWithDrSurcharge_priceIncludesDrSurcharge_Test() {
        Decimal additionalDuty = 1.00;
        CartItem cartItemRec = [SELECT Id, Total_DR_Surcharge__c, TotalPrice FROM CartItem WHERE Name = 'Product 0001'];
        String cartItemId = cartItemRec.Id;
        Decimal oldDrSurchargeValue = cartItemRec.Total_DR_Surcharge__c;
        Decimal oldTotalPrice = cartItemRec.TotalPrice;
        CartTax cartTaxRec = [
            SELECT Id, DR_Duty__c, DR_IOR_Tax__c, DR_Regulatory_Fee__c
            FROM CartTax
            WHERE CartItemId = :cartItemId
        ];
        if(null != cartTaxRec.DR_Duty__c) {
            cartTaxRec.DR_Duty__c = cartTaxRec.DR_Duty__c + additionalDuty;
        }
        else {
            cartTaxRec.DR_Duty__c = additionalDuty;
        }
        update cartTaxRec;

        Test.startTest();
        CartItem cartItemUpdatedRec = [SELECT Id, TotalPrice FROM CartItem WHERE Id = :cartItemId];
        System.assertEquals(
            oldTotalPrice + additionalDuty,
            cartItemUpdatedRec.TotalPrice,
            'Total Price should include updated DR Surcharge amount'
        );
        Test.stopTest();
    }
}
