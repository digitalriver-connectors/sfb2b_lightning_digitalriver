public without sharing class DRB2B_CartItemSelector {
    public DRB2B_CartItemSelector() {
    }

    public CartItem getById(Id cartItemId, Set<String> fields) {
        return (CartItem) new DCM_Query('CartItem')
            .selectFields(new List<String>(fields))
            .addConditionEq('Id', cartItemId)
            .run()[0];
    }

    public List<CartItem> getByForeignKey(String foreignKey, Set<String> fields, Set<id> foreignValues) {
        return (List<CartItem>) new DCM_Query(CartItem.sObjectType)
            .selectFields(new List<String>(fields))
            .addConditionEq(foreignKey, foreignValues)
            .debug()
            .run();
    }

    public List<CartItem> getRecurringItemByForeignKey(String foreignKey, Set<String> fields, Set<id> foreignValues) {
        return (List<CartItem>) new DCM_Query(CartItem.sObjectType)
            .selectFields(new List<String>(fields))
            .addConditionEq(foreignKey, foreignValues)
            .addConditionEq('Recurring_Line_Item__c', true)
            .debug()
            .run();
    }
}
