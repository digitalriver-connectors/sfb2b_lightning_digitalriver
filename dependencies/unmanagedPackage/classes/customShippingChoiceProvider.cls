global class customShippingChoiceProvider implements digitalriverv3.DRB2B_ShippingChoiceProvider {
    global digitalriverv3.DRB2B_ShippingChoiceInfo getShippingChoiceInfo(digitalriverv3.DRB2B_CheckoutContext context) {
        Id cartId = context.cartId;
        Id deliveryMethodId = [SELECT DeliveryMethodId FROM CartDeliveryGroup where CartId =:cartId WITH SECURITY_ENFORCED][0].DeliveryMethodId;
        OrderDeliveryMethod orderDeliveryRec = [SELECT Description,Carrier FROM OrderDeliveryMethod where Id =: deliveryMethodId];
        digitalriverv3.DRB2B_ShippingChoiceInfo shippingChoiceInfo = new digitalriverv3.DRB2B_ShippingChoiceInfo();
        shippingChoiceInfo.serviceLevel = orderDeliveryRec.Carrier;
        shippingChoiceInfo.description = orderDeliveryRec.Description;       
        return shippingChoiceInfo;
    }
}
