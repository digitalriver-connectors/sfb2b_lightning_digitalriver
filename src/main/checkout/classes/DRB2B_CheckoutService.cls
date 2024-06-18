public interface DRB2B_CheckoutService {
    DRB2B_CreateCheckoutResponseModel createCheckout(DRB2B_CreateCheckoutRequestModel request);
    void attachSource(Id cartId, DRB2B_CreateCheckoutResponseModel.Source source);
    Boolean attachSourceLWR(Id cartId, DRB2B_CreateCheckoutResponseModel.Source source);
    void convertToOrder(Id cartId);
    string convertToOrderLWR(Id cartId);
    void refreshCartBasedOnDrRecord(Id cartId);
    void recalculateTaxesAndFees(WebCart cart, Map<String, CartItem> cartItemsBySkuIds, DRB2B_CreateCheckoutResponseModel createCheckoutResponse);
    DRB2B_CreateCheckoutResponseModel updateCheckoutReqwithoutItems (String checkoutId, DRB2B_updateCheckoutRequestModel req);
    void recalculateTaxesAndFeesCartCalculate(CartExtension.Cart cart, Map<String, CartExtension.CartItem> cartItemsBySkuIds, DRB2B_CreateCheckoutResponseModel createCheckoutResponse);
    void sfFailedcancelDROrder(String drOrderId);
}
