public with sharing class DRB2B_StoredPayments {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.MY_WALLET);

    @TestVisible
    private static final DRB2B_MyWalletService mywalletService = new  DRB2B_MyWalletService();

    @AuraEnabled
    public static string getAllSavedPayments(String jsonString){               
        try {            
        return mywalletService.getAllSavedPayments(jsonString);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static Boolean  deleteSavedPayment(String jsonString){
        Boolean result =false;
        try {
           result = mywalletService.deleteSavedPayment(jsonString);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally {
            logger.flush();
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
     public static String getLabel(String label) {
        logger.debug('entering get Label method in stored payment apex' + label);
        String hostUrl =  URL.getSalesforceBaseUrl().toExternalForm();
        String pathpref =  Site.getPathPrefix();
    // The pathpref will be null for custom URL store
        if (pathpref != null)
        {
         logger.debug('Site Path prefix' + pathpref);
         String networkId = Network.getNetworkId();
         if (networkId != null)
             {
             List<Network> networkUrlPathPrefixList = [Select UrlPathPrefix FROM Network WHERE Id = :networkId WITH SECURITY_ENFORCED];
            logger.debug('networkUrlPathPrefix Path prefix' + networkUrlPathPrefixList);
            // The below check is needed as we need to append networkUrlPathPrefix for LWR stores
            if ((networkUrlPathPrefixList.get(0).UrlPathPrefix).contains('vforcesite'))
                 {
                 hostUrl+= '/' + networkUrlPathPrefixList.get(0).UrlPathPrefix;
                 }
                  // The below condition is specific for non LWR site which has specific store on the URL and not custom URL
                 else {
                    String pathpref1 = pathpref.removeEnd('/s'); 
                    logger.debug('Site Path after removing /s' + pathpref1);
                    hostUrl+= pathpref1;
                 }
            }
        }
        logger.debug('Stored Payment hostUrl with path prefix' + hostUrl);
        String[] str = String.valueOf(Page.DRB2B_dynamicLabel).replace(']','').replace('[',' ').split(' ');
        logger.debug('Stored Payment str' + str);
        hostUrl+= str[1];
        logger.debug('Stored Payment hostUrl final' + hostUrl);
        try{
            logger.debug('Stored Payment pageRef inside try1');
            PageReference pageRef = new PageReference(hostUrl);
            logger.debug('Stored Payment pageRef inside try2');
            pageRef.getParameters().put('label', label);
            logger.debug('Stored Payment pageRef inside try3');
            return pageRef.getContent().toString();
        }catch(Exception e){
          //  logger.debug('Stored Payment Exception' + JSON.serialize(e));
            label ='DR_PaymentMethod_otherPaymentMethod';
            logger.debug('Stored Payment catch' + label);
            PageReference pageRef = new PageReference(hostUrl);
           logger.debug('Stored Payment pageRef1');
            pageRef.getParameters().put('label', label);
            logger.debug('Stored Payment pageRef2');
            if(!Test.isRunningTest())
            {
                return pageRef.getContent().toString();
            }else{
                return '{"value": "test record"}';
            }
        }
        
    }
}