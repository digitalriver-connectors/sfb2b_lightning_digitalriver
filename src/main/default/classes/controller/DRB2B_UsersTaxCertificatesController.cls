public with sharing class DRB2B_UsersTaxCertificatesController {
    private static final String COUNTRIES = 'countries';
    private static final String STATES = 'states';

    @TestVisible
    private static DRB2B_TaxCertificateService taxcertificateService = new DRB2B_TaxCertificateService();

    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    @TestVisible
    private static DRB2B_CustomerService customerService = new DRB2B_CustomerService();

    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.CUSTOMER_MANAGEMENT);

    @AuraEnabled
    public static Map<String, Object> getCountriesAndStates() {
        try {
            Map<String, Object> result = new Map<String, Object>();
            result.put(COUNTRIES, new Map<String, String>{ 'US' => 'United States' });

            result.put(
                STATES,
                new Map<String, String>{
                    'AL' => 'Alabama',
                    'AK' => 'Alaska',
                    'AZ' => 'Arizona',
                    'AR' => 'Arkansas',
                    'CA' => 'California',
                    'CO' => 'Colorado',
                    'CT' => 'Connecticut',
                    'DE' => 'Delaware',
                    'DC' => 'District Of Columbia',
                    'FL' => 'Florida',
                    'GA' => 'Georgia',
                    'HI' => 'Hawaii',
                    'ID' => 'Idaho',
                    'IL' => 'Illinois',
                    'IN' => 'Indiana',
                    'IA' => 'Iowa',
                    'KS' => 'Kansas',
                    'KY' => 'Kentucky',
                    'LA' => 'Louisiana',
                    'ME' => 'Maine',
                    'MD' => 'Maryland',
                    'MA' => 'Massachusetts',
                    'MI' => 'Michigan',
                    'MN' => 'Minnesota',
                    'MS' => 'Mississippi',
                    'MO' => 'Missouri',
                    'MT' => 'Montana',
                    'NE' => 'Nebraska',
                    'NV' => 'Nevada',
                    'NH' => 'New Hampshire',
                    'NJ' => 'New Jersey',
                    'NM' => 'New Mexico',
                    'NY' => 'New York',
                    'NC' => 'North Carolina',
                    'ND' => 'North Dakota',
                    'OH' => 'Ohio',
                    'OK' => 'Oklahoma',
                    'OR' => 'Oregon',
                    'PA' => 'Pennsylvania',
                    'RI' => 'Rhode Island',
                    'SC' => 'South Carolina',
                    'SD' => 'South Dakota',
                    'TN' => 'Tennessee',
                    'TX' => 'Texas',
                    'UT' => 'Utah',
                    'VT' => 'Vermont',
                    'VA' => 'Virginia',
                    'WA' => 'Washington',
                    'WV' => 'West Virginia',
                    'WI' => 'Wisconsin',
                    'WY' => 'Wyoming'
                }
            );
            return result;
        } catch (Exception exp) {
            logger.error(exp);
            throw new AuraHandledException(exp.getMessage());
        } finally {
            logger.flush();
        }
    }

    

    @AuraEnabled
    public static DRB2B_CreateCustomerResponseModel updateCustomerWithTaxCertificate(DRB2B_TaxCertificateModel taxCertificate, String cartId) {
        try {
            return customerService.updateCustomer(taxCertificate, cartId);
        } catch (Exception exp) {
            logger.error(exp);
            throw new AuraHandledException(exp.getMessage());
        } finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static DRB2B_CreateCustomerResponseModel getCustomer(String cartId) {
        try {
            DRB2B_CreateCustomerResponseModel customerResponse = customerService.getById(UserInfo.getUserId(), cartId);
            if (customerResponse.id == null) {
                customerResponse = customerService.createCustomer(UserInfo.getUserId(), cartId);
            }
            return customerResponse;
        } catch (Exception exp) {
            logger.error(exp);
            throw new AuraHandledException(exp.getMessage());
        } finally {
            logger.flush();
        }
    }
    @AuraEnabled
    public static DRB2B_UploadTaxCertificateResponseModel uploadTaxCertificate(string taxCertificateObject, String cartId) {
        try {
            return taxcertificateService.uploadTaxCertificate(taxCertificateObject, cartId);
        } catch (Exception exp) {
            logger.error(exp);
            throw new AuraHandledException(exp.getMessage());
        } finally {
            logger.flush();
        }
    }
}
