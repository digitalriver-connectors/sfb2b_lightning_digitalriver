@isTest
public with sharing class DRB2B_CartItemTrigger_Test {
    @TestSetup
    static void setupData() {
        ATK.SaveResult result = ATK.prepare(Account.SObjectType, 1)
            .build(EntityBuilderFactory.accountBuilder)
            .save(false);
        Account acc = (Account) result.get(Account.SObjectType)[0];
        insert acc;

        result = ATK.prepare(WebStore.SObjectType, 1).build(EntityBuilderFactory.webStoreBuilder).save(false);
        WebStore store = (WebStore) result.get(WebStore.SObjectType)[0];
        insert store;

        result = ATK.prepare(WebCart.SObjectType, 1).build(EntityBuilderFactory.webCartBuilder).save(false);
        WebCart cart = (WebCart) result.get(WebCart.SObjectType)[0];
        cart.WebStoreId = store.Id;
        cart.AccountId = acc.Id;
        insert cart;

        result = ATK.prepare(CartDeliveryGroup.SObjectType, 1)
            .build(EntityBuilderFactory.cartDeliveryGroupBuilder)
            .save(false);
        CartDeliveryGroup deliveryGroup = (CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType)[0];
        deliveryGroup.CartId = cart.Id;
        insert deliveryGroup;

        result = ATK.prepare(Digital_River_Tax_Mapping__c.SObjectType, 1)
            .build(EntityBuilderFactory.drTaxMappingBuilder)
            .save(false);
        Digital_River_Tax_Mapping__c drTaxMapping = (Digital_River_Tax_Mapping__c) result.get(
            Digital_River_Tax_Mapping__c.SObjectType
        )[0];
        insert drTaxMapping;

        result = ATK.prepare(Product2.SObjectType, 1).build(EntityBuilderFactory.productBuilder).save(false);
        Product2 product = (Product2) result.get(Product2.SObjectType)[0];
        product.DR_TAXGROUP__c = drTaxMapping.DR_Tax_Group__c;
        product.DR_TAXTYPE__c = drTaxMapping.DR_Tax_Type__c;
        product.DR_Part_Number__c = 'abc12345';
        product.DR_Product_Country_Origin__c = 'US';
        product.Sync_Product_to_DR__c = true;
        insert product;
    }
    @isTest
    static void populateTest() {
        product2 product = [SELECT id FROM Product2 LIMIT 1];
        CartDeliveryGroup cartDeliveryGroup = [SELECT id FROM CartDeliveryGroup LIMIT 1];
        ATK.SaveResult result = ATK.prepare(cartItem.SObjectType, 1)
            .build(EntityBuilderFactory.cartItemBuilder)
            .save(false);
        cartItem item = (cartItem) result.get(cartItem.SObjectType)[0];
        item.product2Id = product.id;
        item.CartDeliveryGroupId = cartDeliveryGroup.id;
        Item.cartId = [SELECT Id FROM Webcart LIMIT 1]?.Id;
        insert item;
        System.assertEquals(product.Id, item.product2Id, 'Product Id should be Same ');
    }
}
