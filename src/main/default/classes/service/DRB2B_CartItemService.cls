public with sharing class DRB2B_CartItemService {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance();

    @TestVisible
    private DRB2B_CartItemSelector cartItemSelector = new DRB2B_CartItemSelector();

    /**
     * Store the Cart Item Total Price value before adding DR Landed Costs and Regulatory Fees
     * on the custom field Total_Price_Excluding_DR_Surcharge__c. This will be used to set the Cart Item
     * Total Price field to its original value (i.e., before adding DR Surcharges) when the shopper
     * cancels the existing checkout session
     */
    public void setTotalPriceExcludingDrSurchargeToTotalPrice(List<CartItem> cartItemRecords) {
        LOGGER.info(
            'Updating Total Price Excluding DR Surcharge value to Cart Item Total Price for CartItem Id(s): ' +
            Collection.of(cartItemRecords).listOf(CartItem.Id)
        );
        for (CartItem cartItemRec : cartItemRecords) {
            cartItemRec.Total_Price_Excluding_DR_Surcharge__c = cartItemRec.TotalPrice;
        }
    }

    /**
     * Whenever a Shopper cancels an existing checkout, then we need to remove the DR Surcharge amount from Total Price
     * i.e., we need to set the Total Price on Cart Item to its initial value before adding Landed Costs and Regulatory Fees
     */
    public void removeLandedCostsAndRegulatoryFeesFromTotalPrice(Set<Id> cartIds) {
        List<CartItem> cartItemsToUpdate = new List<CartItem>();
        Set<String> fieldsToQuery = new Set<String>{
            'Id',
            'TotalPrice',
            'Total_Price_Excluding_DR_Surcharge__c',
            'Price_Includes_DR_Surcharge__c',
            'CartId'
        };
        List<CartItem> cartItems = cartItemSelector.getByForeignKey('cartId', fieldsToQuery, cartIds);
        for (CartItem cartItem : cartItems) {
            if (cartItem.Price_Includes_DR_Surcharge__c) {
                cartItem.TotalPrice = cartItem.Total_Price_Excluding_DR_Surcharge__c;
                cartItem.Price_Includes_DR_Surcharge__c = false;
                cartItemsToUpdate.add(cartItem);
            }
        }

        // Update Total Price field on Cart Item to remove Landed Costs and Regulatory Fees on Cancel Checkout
        if (!cartItemsToUpdate.isEmpty()) {
            LOGGER.info(
                'Cart Items Ids to remove Landed Costs and Regulatory Fees from TotalPrice: ' +
                Collection.of(cartItemsToUpdate).listOf(CartItem.Id)
            );
            DmlManager.updateAsUser(cartItemsToUpdate);
        } else {
            LOGGER.info('None of the Cart Items have DR Surcharge (Landed Costs + Regulatory fees) included');
        }
    }


    public Set<Id> getCartItemIdByCart(Set<Id> cartIds) {
        List<CartItem> cartItems = cartItemSelector.getByForeignKey('CartId', new Set<String>{ 'CartId' }, cartIds);
        return (new Map<Id, SObject>(cartItems)).keySet();
    }

    /**
     * Whenever a Shopper cancels an existing checkout, then we need to remove the DR Surcharge amount from Total Price
     * i.e., we need to set the Total Price on Cart Item to its initial value before adding Landed Costs and Regulatory Fees
     */
    // todo remove this method
    public void removeLandedCostsAndRegulatoryFeesFromTotalPriceLWR(Set<Id> cartIds) {
        List<CartItem> cartItemsToUpdate = new List<CartItem>();
        Set<String> fieldsToQuery = new Set<String>{
            'Id',
            'TotalPrice',
            'Total_Price_Excluding_DR_Surcharge__c',
            'Price_Includes_DR_Surcharge__c',
            'CartId'
        };
        List<CartItem> cartItems = cartItemSelector.getByForeignKey('cartId', fieldsToQuery, cartIds);
        for (CartItem cartItem : cartItems) {
            if (cartItem.Price_Includes_DR_Surcharge__c) {
                cartItem.Price_Includes_DR_Surcharge__c = false;
                cartItemsToUpdate.add(cartItem);
            }
        }

        // Update Total Price field on Cart Item to remove Landed Costs and Regulatory Fees on Cancel Checkout
        if (!cartItemsToUpdate.isEmpty()) {
            LOGGER.info(
                'Cart Items Ids to remove Landed Costs and Regulatory Fees from TotalPrice: ' +
                Collection.of(cartItemsToUpdate).listOf(CartItem.Id)
            );
            DmlManager.updateAsUser(cartItemsToUpdate);
        } else {
            LOGGER.info('None of the Cart Items have DR Surcharge (Landed Costs + Regulatory fees) included');
        }
    }
}
