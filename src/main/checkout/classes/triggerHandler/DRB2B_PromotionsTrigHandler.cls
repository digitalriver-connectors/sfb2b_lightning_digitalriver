public with sharing class DRB2B_PromotionsTrigHandler implements TriggerHandler.Logic, TriggerHandler.Parameterizable {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);
    Map<String, Object> inputParameterMap = new Map<String, Object>();
    List<String> cartIds = new List<String>();
    private static DRB2B_CartService cartService = new DRB2B_CartService();

    public void setParameters(String parameters) {
        this.inputParameterMap = (Map<String, Object>) JSON.deserializeUntyped(parameters);
        LOGGER.debug('DRB2b_PromotionsTrigHandler--> Input Parameter Map: ' + this.inputParameterMap);
    }

    public void execute(List<SObject> records, TriggerContext ctx) {
        try{
            Boolean cancelCheckoutSession = inputParameterMap.containsKey('cancelCheckoutSession') ? Boolean.valueOf(inputParameterMap.get('cancelCheckoutSession')) : false;
            if(cancelCheckoutSession){
                if(ctx.isAfter && ctx.isUpdate){   
                    for (SObject cartRec : Trigger.new) {
                        if (ctx.isChanged(cartRec, WebCart.TotalAdjustmentAmount)) {
                            cartIds.add((String)cartRec.Id);
                        }
                    }
                    if(cartIds.size()>0){
                        cartService.cancelActiveCartSession(cartIds);
                    }
                }
            }
        }catch(Exception e){
            LOGGER.error(e);
        }finally{
            LOGGER.flush();
        }
    }
}
