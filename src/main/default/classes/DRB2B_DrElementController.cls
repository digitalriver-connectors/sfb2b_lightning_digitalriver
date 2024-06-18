/**@description:controller for DrElement.page
 * will provide all conig values and information to page
 * ***/

global without sharing class DRB2B_DrElementController {
    @TestVisible
    private static final DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();
    @TestVisible
    private static final DRB2B_AccountService accountService = new DRB2B_AccountService();

    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();
    @TestVisible
    private static final String CONFIG_MISS_MSG = 'Missing Config';
    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.APP_CONFIG);

    global String drJsStaticResourceRelativePath { get; set; }
    global String drCSStaticResourceRelativePath { get; set; }
    global String storeFrontBaseURl { get; set; }
    global String drJSStaticResourceName { get; set; }
    global String drCSSStaticResourceName { get; set; }
    global String clientCSSstaticResourceName { get; set; }
    global String clientCSStaticResourceRelativePath { get; set; }
    global String domainURL { get; set; }
    global DRB2B_DrElementController() {
        String methodName = 'DRB2B_DrElementController';
        try {
            drJsStaticResourceName = configurationSelector.getJSResource();
            drJsStaticResourceRelativePath = DRB2B_Utility.getStaticResourceRelativePath(drJsStaticResourceName);
            drCSSStaticResourceName = configurationSelector.getCSSresource();
            drCSStaticResourceRelativePath = DRB2B_Utility.getStaticResourceRelativePath(drCSSStaticResourceName);
            clientCSSstaticResourceName = configurationSelector.getClientCSSresource();
            clientCSStaticResourceRelativePath = DRB2B_Utility.getStaticResourceRelativePath(
                clientCSSstaticResourceName
            );
            domainURL = 'https://' + Site.getDomain();
        } catch (Exception e) {
            logger.error('Error from DRB2B_DrElementController' + e);
        } finally {
            logger.flush();
        }
    }

    public string getGuestIPAddress {
        get {
            string guestipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            return guestipAddress;
        }
        set;
    }

    public String getDefaultEntity {
        get {
            String result;
            try {
                result = configurationSelector.getDefaultEntity();
                if (null == result) {
                    logger.error(CONFIG_MISS_MSG);
                }
            } catch (Exception e) {
                logger.error('getDefaultEntity' + e);
            } finally {
                logger.flush();
            }
            return result;
        }
        set;
    }

    public String getPublicKey {
        get {
            String result;
            try {
                result = configurationSelector.getpublicKey();
                if (null == result) {
                    logger.error(CONFIG_MISS_MSG);
                }
            } catch (Exception e) {
                logger.error(e);
            } finally {
                logger.flush();
            }
            return result;
        }
        set;
    }

    public String getUserLocale {
        get {
            String result;
            try {
                result = UserInfo.getLocale();
            } catch (Exception e) {
                logger.error(
                    'Error on getUserLocale method in Element controller' +
                    'lineNumber' +
                    e.getLineNumber() +
                    'Type ' +
                    e.getTypeName() +
                    'Message' +
                    e.getMessage()
                );
            } finally {
                logger.flush();
            }
            return result;
        }
        set;
    }

    @AuraEnabled
    public static string getCartEntity(id cartId) {
        string result;
        try {
            DRB2B_CartSelector cart = new DRB2B_CartSelector();
            WebCart wcart = cart.getById(
                cartId,
                new Set<string>{ 'DR_Selling_Entity__c', 'Recurring_Line_Item_Count__c' }
            );
            logger.info('DRB2B_DrElementController getCartEntity method' + cartId + JSON.serialize(cart));
            return JSON.serialize(wcart);
        } catch (Exception e) {
            logger.error(
                'Error on getCartEntity method in Element controller' +
                'lineNumber' +
                e.getLineNumber() +
                'Type ' +
                e.getTypeName() +
                'Message' +
                e.getMessage()
            );
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
    }

    private static final List<String> CART_FIELDS = new List<String>{
        'DR_Checkout_Type__c',
        'BillingCountry',
        'BillingState'
    };

    private static final List<String> CART_ITEMS_FIELDS = new List<String>{
        'Id',
        'CartDeliveryGroupId',
        'CartDeliveryGroup.DeliverToCountry',
        'CartDeliveryGroup.DeliverToState'
    };

    @AuraEnabled
    public static string getComplianceAddress(Id CartId) {
        String result;

        try {
            Map<String, String> response = new Map<String, String>();
            Boolean isCountryPickListEnabled = DRB2B_Utility.isCountryStateEnabled();
            //Adding state and code country field if country picklist is enabled
            if (isCountryPickListEnabled) {
                CART_FIELDS.addAll(new List<String>{ 'BillingCountryCode', 'BillingStateCode' });
                CART_ITEMS_FIELDS.addAll(
                    new List<String>{ 'CartDeliveryGroup.DeliverToStateCode', 'CartDeliveryGroup.DeliverToCountryCode' }
                );
            }
            WebCart cart = cartSelector.getCartWithItemsById(cartId, CART_FIELDS, CART_ITEMS_FIELDS);
            CartDeliveryGroup deliveryGroup = (CartDeliveryGroup) cart.CartItems.get(0)
                .getSObject(CartItem.CartDeliveryGroupId);
            if (cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_NON_DIGITAL)
                response.put(
                    'shipToCountry',
                    isCountryPickListEnabled
                        ? (String) deliveryGroup.get('DeliverToCountryCode')
                        : String.isNotBlank(deliveryGroup.DeliverToCountry)
                              ? new DRB2B_CountryPicklist().getEntry(deliveryGroup.DeliverToCountry).value
                              : null
                );
            if (cart.DR_Checkout_Type__c == DRB2B_Constants.WebCart.TYPE_DIGITAL)
                response.put(
                    'billToCountry',
                    isCountryPickListEnabled
                        ? (String) cart.get('BillingCountryCode')
                        : String.isNotBlank(cart.BillingCountry)
                              ? new DRB2B_CountryPicklist().getEntry(cart.BillingCountry).value
                              : null
                );
            response.put('cartType', cart.DR_Checkout_Type__c);
            response.put(
                'userLanguage',
                userinfo.getLanguage().contains('_') ? userinfo.getLanguage().split('_')[0] : userinfo.getLanguage()
            );
            result = JSON.serialize(response);
        } catch (Exception e) {
            logger.error(
                'Error on getComplianceAddress method in Element controller' +
                'lineNumber' +
                e.getLineNumber() +
                'Type ' +
                e.getTypeName() +
                'Message' +
                e.getMessage()
            );
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
}
