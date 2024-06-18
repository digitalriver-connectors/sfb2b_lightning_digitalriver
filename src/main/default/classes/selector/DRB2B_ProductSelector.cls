public inherited sharing class DRB2B_ProductSelector {
    
    public Product2 getById(Id productId, Set<String> fields) {

        return (Product2) new DCM_Query('Product2')
            .selectFields(new List<String>(fields))
            .addConditionEq('Id', productId)
            .run()[0];
    }
}
