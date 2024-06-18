public without sharing class DRB2B_CartService {
    @TestVisible
    private static DCM_Logger logger = DCM_Logger.getInstance();

    @TestVisible
    private DRB2B_DigitalRiverTaxMappingSelector taxMappingSelector = new DRB2B_DigitalRiverTaxMappingSelector();

    @TestVisible
    private DRB2B_CartItemSelector cartItemSelector = new DRB2B_CartItemSelector();

    @TestVisible
    private static final String FOREIGN_KEY = 'CartId';

    @TestVisible
    private static final String PHYSICAL = 'Physical';

    @TestVisible
    private static final String PHYSICAL_VAL = 'Non-Digital';

    @TestVisible
    private static final String DIGITAL = 'Digital';

    @TestVisible
    private static final Set<String> FIELDSET = new Set<String>{
        'Product2.DR_TAXGROUP__c',
        'Product2.DR_TAXTYPE__c',
        'Product2.DR_IS_DIGITAL_PRODUCT__c',
        'CartId',
        'Cart.DR_Checkout_Type__c',
        'Type'
    };

    @TestVisible
    private DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();

    @TestVisible
    private DRB2B_RegulatoryFeeSelector feeSelector = new DRB2B_RegulatoryFeeSelector();

    @TestVisible
    public static Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();

    @AuraEnabled
    public static void setIpAddress(String ipaddress, String cartId) {
        WebCart wcart = [SELECT id, DR_Guest_IpAddress__c FROM WebCart WHERE id = :cartId];
        wCart.DR_Guest_IpAddress__c = ipaddress;
        Boolean isGuestUser = Auth.CommunitiesUtil.isGuestUser();
        if (isGuestUser) {
            DmlManager.updateAsSystem(wCart);
        }
    }

    /**
     * Used to identify cart Type based on Cart Items
     *
     * @param cartId - Cart Id to determine a type
     *
     * @return A type of the cart PHYSICAL and DIGITAL
     */
    public String getCheckoutType(Id cartId) {
        return this.getCheckoutType(new Set<Id>{ cartId }).get(cartId);
    }

    /**
     * Used to identify cart Type based on carts Items
     *
     * @param cartIds - Cart Ids to determine a type of each
     *
     * @return Map where key is cart Id and possible value is PHYSICAL and DIGITAL
     */
    public Map<String, String> getCheckoutType(Set<Id> cartIds) {
        Map<String, String> response = new Map<String, String>();
        Map<String, String> taxTypeMap = getTaxTypeMap();

        logger.info('Tax Type Map ' + JSON.serialize(taxTypeMap));

        List<CartItem> cartItems = cartItemSelector.getByForeignKey(FOREIGN_KEY, FIELDSET, cartIds);
        for (CartItem item : cartItems) {
            if (!isChargeType(item)) {
                /*if (isCheckoutTypeResolved(response, item)) {
                    continue;
                } else if (isCheckoutTypePhysical(taxTypeMap, item)) {
                    response.put(item.CartId, PHYSICAL_VAL);
                } else if (isCheckoutTypeDigital(response, item)) {
                    response.put(item.CartId, DIGITAL);
                }*/
                if(item.Product2.DR_IS_DIGITAL_PRODUCT__c==true){
                    response.put(item.CartId,DIGITAL);
                }
                else
                {
                    response.put(item.CartId,PHYSICAL_VAL);
                }
            }
        }
        return response;
    }

    private Boolean isCheckoutTypeDigital(Map<String, String> response, CartItem item) {
        return !response.containsKey(item.CartId);
    }

    private Boolean isCheckoutTypePhysical(Map<String, String> taxTypeMap, CartItem item) {
        return PHYSICAL.equalsIgnoreCase(
            taxTypeMap.get(item.Product2.DR_TAXGROUP__c + '#' + item.Product2.DR_TAXTYPE__c)
        );
    }

    private Boolean isChargeType(CartItem cartItem) {
        return cartItem.Type == 'Charge';
    }

    private Boolean isCheckoutTypeResolved(Map<String, String> response, CartItem item) {
        return response.containsKey(item.CartId) && PHYSICAL.equalsIgnoreCase(response.get(item.CartId));
    }

    public Map<String, String> getTaxTypeMap() {
        Map<String, String> taxTypeMap = new Map<String, String>();
        List<Digital_River_Tax_Mapping__c> taxCodesList = taxMappingSelector.getAll();
        for (Digital_River_Tax_Mapping__c taxCodes : taxCodesList) {
            taxTypeMap.put(taxCodes.DR_Tax_Group__c + '#' + taxCodes.DR_Tax_Type__c, taxCodes.DR_Product_Type__c);
        }
        return taxTypeMap;
    }

    public DRB2B_CartModel getCartTaxAndFee(Id cartId) {
        Webcart cart = cartSelector.getById(
            cartId,
            new Set<String>{
                'Has_Landed_Cost__c',
                'DR_Total_IOR_Tax__c',
                'DR_Total_Fees__c',
                'DR_Total_Duty__c',
                'TotalProductAmount',
                'GrandTotalAmount',
                'TotalChargeTaxAmount',
                'TotalChargeAmount',
                'TotalTaxAmount',
                'DR_Source_Id__c',
                'DR_Amount_Contributed__c',
                'DR_Amount_Remaining_to_be_Contributed__c',
                'TotalAdjustmentAmount',
                'DR_Checkout_Id__c'
            }
        );
        DRB2B_CartModel cartModel = new DRB2B_CartModel(getRegulatoryFeeByCarId(cartId));
        cartModel.wrap(cart);
        return cartModel;
    }

    public List<DRB2B_RegulatoryFeeModal> getRegulatoryFeeByCarId(Id cartId) {
        List<CartItem> cartItems = cartItemSelector.getByForeignKey(
            FOREIGN_KEY,
            new Set<String>{ 'CartId', 'Name' },
            new Set<Id>{ cartId }
        );
        Set<Id> cartitemsIds = (new Map<Id, SObject>(cartItems)).keySet();
        list<DR_Regulatory_Fee__c> feeList = feeSelector.getByCartItemId(
            new Set<String>{ 'Fee_Type__c', 'Name', 'Amount__c', 'Id', 'Cart_Item_Id__c' },
            cartitemsIds
        );
        return (List<DRB2B_RegulatoryFeeModal>) Collection.of(feeList).wrap(DRB2B_RegulatoryFeeModal.class).get();
    }

    public DRB2B_CartModel getCartAsWrapper(Webcart cart) {
        DRB2B_CartModel cartModel = new DRB2B_CartModel();
        cartModel.wrap(cart);
        return cartModel;
    }

    public void clearAddress(Set<string> cartIds) {
        List<SObject> payload = new List<SObject>();
        for (string id : cartIds) {
            webcart cart = new webcart();
            cart.Id = id;
            cart.BillingState = '';
            cart.BillingCountry = '';
            cart.BillingPostalCode = '';
            cart.BillingCity = '';
            cart.BillingStreet = '';
            cart.DR_Selling_Entity__c = '';
            payload.add(cart);
        }

        for (CartDeliveryGroup deliveryGroup : [
            SELECT DeliverToCity, DeliverToState, DeliverToStreet, DeliverToCountry, DeliverToPostalCode
            FROM CartDeliveryGroup
            WHERE CartId IN :cartIds
            WITH SECURITY_ENFORCED
        ]) {
            deliveryGroup.DeliverToCity = '';
            deliveryGroup.DeliverToState = '';
            deliveryGroup.DeliverToStreet = '';
            deliveryGroup.DeliverToCountry = '';
            deliveryGroup.DeliverToPostalCode = '';
            payload.add(deliveryGroup);
        }

        if (!isGuestUser) {
            DMLManager.updateAsUser(payload);
        } else {
            DMLManager.updateAsSystem(payload);
        }
    }

    public void clearDataRelatedToDr(Set<string> cartIds) {
        List<Sobject> payload = new List<Sobject>();
        for (String id : cartIds) {
            webcart cart = new webcart();
            cart.Id = id;
            cart.DR_Source_Id__c = '';
            cart.DR_Tax_Identifiers__c = '';
            cart.DR_Payment_Session_Id__c = '';
            cart.Has_Landed_Cost__c = false;
            cart.DR_Customer_Type__c = 'individual';
            cart.DR_Amount_Contributed__c = null;
            cart.DR_Amount_Remaining_to_be_Contributed__c = null;
            cart.DR_CartItemStructure__c = '';
            payload.add(cart);
        }

        if (!isGuestUser) {
            DMLManager.updateAsUser(payload);
        } else {
            DMLManager.updateAsSystem(payload);
        }
    }

    /**
     * Cancel Checkout if DR order failed
     */
    public void cancelCartSession(String cartId) {
        DRB2B_CartCheckoutSessionSelector cartCheckoutSessionSelector = new DRB2B_CartCheckoutSessionSelector();
        CartCheckoutSession session = cartCheckoutSessionSelector.getActiveSessionForCart(
            cartId,
            new Set<String>{ 'Id', 'IsArchived' }
        );
        session.IsArchived = true;
        DmlManager.updateAssystem(session);
    }

    /**
     * Cancel Checkout if Promotion Is added/removed
     */

    public void cancelActiveCartSession(List<String> cartIds) {
        DRB2B_CartCheckoutSessionSelector cartCheckoutSessionSelector = new DRB2B_CartCheckoutSessionSelector();
        List<CartCheckoutSession> session = cartCheckoutSessionSelector.getListOfActiveSessionForCart(
            cartIds,
            new Set<String>{ 'Id', 'IsArchived' }
        );
        if (session.size() != 0) {
            session[0].IsArchived = true;
            DmlManager.updateAssystem(session);
        }
    }

    @AuraEnabled
    public static void clearAllDataLWR(String cartId) {
        try {
            if (cartId != null) {
                List<Id> cartIdList = new List<Id>();
                cartIdList.add(Id.valueOf(cartId));
                DRB2B_ClearData.clearDataLWR(cartIdList);
            }
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static void clearCartItemStructure(String cartId) {
        try{
            logger.info('drb2b_cartService clearCartItemStructure cartId' + cartId);
            if (cartId != null) {
            List<Sobject> payload = new List<Sobject>();
            webcart cart = new webcart();
            cart.Id = cartId;
            cart.DR_CartItemStructure__c = '';
            payload.add(cart);
            logger.info('drb2b_cartService clearCartItemStructure payload' + payload);
        if (!isGuestUser) {
            DMLManager.updateAsUser(payload);
        } else {
            DMLManager.updateAsSystem(payload);
        }
    }
    }
    catch(Exception e) {
        logger.error('drb2b_cartService clearCartItemStructure failure for the cart' + cartId);
    } 
}

}