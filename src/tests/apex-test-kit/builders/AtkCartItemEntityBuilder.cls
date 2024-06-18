public with sharing class AtkCartItemEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity cartItemEntity, Integer size) {
        cartItemEntity
            .field(CartItem.Name)
            .index('Product {0000}')
            .field(CartItem.Type)
            .repeat('Product')
            .field(CartItem.Sku)
            .repeat('Product {0000}')
            .field(CartItem.Quantity)
            .repeat(1)
            .field(CartItem.ListPrice)
            .repeat(100.00)
            .field(CartItem.TotalListPrice)
            .repeat(100.00)
            .field(CartItem.SalesPrice)
            .repeat(100.00)
            .field(CartItem.TotalLineAmount)
            .repeat(100.00)
            .field(CartItem.AdjustmentAmount)
            .repeat(0)
            .field(CartItem.TotalPrice)
            .repeat(100.00)
            .field(CartItem.Price_Includes_DR_Surcharge__c)
            .repeat(false)
            .field(CartItem.Total_Price_Excluding_DR_Surcharge__c)
            .repeat(0.00);
    }
}
