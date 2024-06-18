public without sharing class DRB2B_UpdateCartItemTotalPriceTrigHdlr implements TriggerHandler.Logic {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.TRIGGER_HANDLER);

    @TestVisible
    private DRB2B_CartItemService cartItemService = new DRB2B_CartItemService();

    public void execute(List<SObject> records, TriggerContext ctx) {
        logger.info('DRB2B_UpdateCartItemTotalPriceTrigHdlr is executing');
        DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
        List<CartItem> cartItemRecords = (List<CartItem>) records;
        // Capture Initial CartItem TotalPrice field value before adding DR Surcharge
        if (ctx.isBefore && ctx.isInsert) {
            cartItemService.setTotalPriceExcludingDrSurchargeToTotalPrice(cartItemRecords);
            if (configurationSelector.getDRShipFromAddressConfiguration().equalsIgnoreCase('Item-level')) {
                logger.info('DRB2B_UpdateCartItemTotalPriceTrigHdlr is executing1');
                this.updateCartItem(cartItemRecords);
            }
        } else if (ctx.isBefore && ctx.isUpdate) {
            // Add DR Surcharge to TotalPrice
            updateTotalPriceWithDrSurcharge(cartItemRecords, ctx);
        }
        LOGGER.flush();
    }

    /**
     * Add Landed Costs (Duty and IOR Tax) and Regulatory Fees to TotalPrice field on Cart Item.
     * Set the field Price_Includes_DR_Surcharge__c to true if TotalPrice field includes Landed Costs
     * and Regulatory Fees.
     * DR Surcharge = Landed Costs + Regulatory Fees
     */
    public void updateTotalPriceWithDrSurcharge(List<CartItem> cartItemRecords, TriggerContext ctx) {
        for (CartItem cartItemRec : cartItemRecords) {
            if (cartItemRec.Price_Includes_DR_Surcharge__c) {
                // Add the latest DR Surcharge amount to TotalPrice (after removing the old surcharge amount)
                if (ctx.isChanged(cartItemRec, CartItem.Total_DR_Surcharge__c)) {
                    Decimal oldDrSurchargeValue = ((CartItem) ctx.getOld(cartItemRec)).Total_DR_Surcharge__c;
                    cartItemRec.TotalPrice =
                        cartItemRec.TotalPrice -
                        oldDrSurchargeValue +
                        cartItemRec.Total_DR_Surcharge__c;
         // 2.1 fix 
                    cartItemRec.TotalLineAmount  = cartItemRec.TotalPrice;
                    //addition from 2.1 release for landed cost and fee
                    // cartItemRec.TotalLineAmount = cartItemRec.TotalPrice - oldDrSurchargeValue + cartItemRec.Total_DR_Surcharge__c;
                    logger.info(
                        'DRB2B_UpdateCartItemTotalPriceTrigHdlr1 cartItemRecTotalLineAmount' +
                        cartItemRec.TotalLineAmount
                    );
                }
            } else {
                // In the scenario where some promotions are added, update Total_Price_Excluding_DR_Surcharge__c to the Latest Total Price
                if (cartItemRec.Total_Price_Excluding_DR_Surcharge__c != cartItemRec.TotalPrice) {
                    cartItemRec.Total_Price_Excluding_DR_Surcharge__c = cartItemRec.TotalPrice;
                }

                // The field Price_Includes_DR_Surcharge__c changes from true to false when the shopper cancels an existing checkout
                if (!ctx.isChangedFromTo(cartItemRec, CartItem.Price_Includes_DR_Surcharge__c, true, false)) {
                    if (ctx.isChanged(cartItemRec, CartItem.Total_DR_Surcharge__c)) {
                        cartItemRec.TotalPrice = cartItemRec.TotalPrice + cartItemRec.Total_DR_Surcharge__c;
                        //addition from 2.1 release below ne caused the defect on landed cost so updated now
                        //    cartItemRec.TotalLineAmount = cartItemRec.TotalPrice + cartItemRec.Total_DR_Surcharge__c;
                        cartItemRec.TotalLineAmount = cartItemRec.TotalPrice;
                        cartItemRec.Price_Includes_DR_Surcharge__c = true;
                        LOGGER.info(
                            'Added Landed Costs and Regulatory Fees to TotalPrice for CartItem Id: ' + cartItemRec.Id
                        );
                    }
                }
            }
        }
    }

    private void updateCartItem(List<cartItem> records) {
        DRB2B_CartService cartService = new DRB2B_CartService();
        Map<String, String> taxTypeMap = cartService.getTaxTypeMap();
        Set<String> productRecordSet = new Set<String>();
        Map<String, Boolean> productMap = new Map<String, Boolean>();
        logger.info('DRB2B_UpdateCartItemTotalPriceTrigHdlr updateCartItem is executing');
        String PHYSICAL = 'Physical';
        String PHYSICAL_VAL = 'Non-Digital';
        String DIGITAL = 'Digital';
        for (cartItem item : records) {
            if (item.Product2Id != null) {
                productRecordSet.add(item.Product2Id);
            }
        }
        Boolean IS_GUEST_USER = Auth.CommunitiesUtil.isGuestUser();
        if (IS_GUEST_USER) {
            for (Product2 prod : [
                SELECT id, DR_TAXGROUP__c, DR_TAXTYPE__c,DR_IS_DIGITAL_PRODUCT__c
                FROM Product2
                WHERE id IN :productRecordSet
            ]) {
                productMap.put(prod.id, prod.DR_IS_DIGITAL_PRODUCT__c);
            }
        } else {
            for (Product2 prod : [
                SELECT id, DR_TAXGROUP__c, DR_TAXTYPE__c,DR_IS_DIGITAL_PRODUCT__c
                FROM Product2
                WHERE id IN :productRecordSet
                WITH SECURITY_ENFORCED
            ]) {
                productMap.put(prod.id, prod.DR_IS_DIGITAL_PRODUCT__c);
            }
        }
        for (cartItem item : records) {
            if (item.Product2Id != null) {
                /*if (PHYSICAL.equalsIgnoreCase(taxTypeMap.get(productMap.get(item.Product2Id)))) {
                    item.DR_Item_TaxType__c = PHYSICAL_VAL;

                    logger.info(
                        'DRB2B_UpdateCartItemTotalPriceTrigHdlr DR_Item_TaxType__c is ' + item.DR_Item_TaxType__c
                    );
                } else {
                    item.DR_Item_TaxType__c = DIGITAL;
                    logger.info(
                        'DRB2B_UpdateCartItemTotalPriceTrigHdlr DR_Item_TaxType__c is ' + item.DR_Item_TaxType__c
                    );
                }*/
                if(productMap.get(item.Product2Id)==true)
                {
                    item.DR_Item_TaxType__c = DIGITAL;
                   
                }
                else
                {
                    item.DR_Item_TaxType__c = PHYSICAL_VAL;
                    
                }
                logger.info(
                    'DRB2B_UpdateCartItemTotalPriceTrigHdlr DR_Item_TaxType__c is' + item.DR_Item_TaxType__c
                );
            }
        }
    }
}