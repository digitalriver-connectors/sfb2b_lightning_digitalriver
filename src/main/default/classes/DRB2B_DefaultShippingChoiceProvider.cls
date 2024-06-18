public without sharing class DRB2B_DefaultShippingChoiceProvider implements DRB2B_ShippingChoiceProvider {
    public DRB2B_ShippingChoiceInfo getShippingChoiceInfo(DRB2B_CheckoutContext context) {
        Id cartId = context.cartId;

        DRB2B_ShippingChoiceInfo shippingChoiceInfo = new DRB2B_ShippingChoiceInfo();
        shippingChoiceInfo.serviceLevel = '';
        shippingChoiceInfo.description = '';
        return shippingChoiceInfo;
    }
}
