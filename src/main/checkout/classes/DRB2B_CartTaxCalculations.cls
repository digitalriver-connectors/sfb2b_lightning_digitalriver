global with sharing class DRB2B_CartTaxCalculations implements sfdc_checkout.CartTaxCalculations {
 
  private final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CHECKOUT_FLOW);

  global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
      sfdc_checkout.IntegrationStatus integrationStatus = new sfdc_checkout.IntegrationStatus();
      DRB2B_TaxCalculationService.ResponseModel response =  DRB2B_TaxCalculationService.startCartProcessAsync(cartId, jobInfo);
         if(response != null && response.status =='Error'){
           integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
         }else{
          integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
         }
      return integrationStatus;
  }
}