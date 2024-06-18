public with sharing class DRB2B_ConnectorConfigurationSelector {
    private static final String DR_SECRET_KEY_RECORD_DEV_NAME = 'DR_Secret_Key';
    private static final String DR_API_ENDPOINT_RECORD_DEV_NAME = 'DR_Api_Endpoint';
    private static final String DR_API_TIMEOUT_RECORD_DEV_NAME = 'DR_Api_Timeout';
    private static final String DR_BATCH_SCHEDULE_TIME_RECORD_DEV_NAME = 'Batch_Schedule_Time';
    private static final String DR_PRODUCT_BATCH_SIZE_RECORD_DEV_NAME = 'Product_Batch_Size';
    private static final String DR_CONNECTOR_NOTIFICATION_EMAIL_RECORD_DEV_NAME = 'Connector_Notification_Email';
    private static final String DR_JS_RESOURCE_RECORD_DEV_NAME = 'DR_JS_Static_Resource';
    private static final String DR_CSS_RESOURCE_RECORD_DEV_NAME = 'DR_CSS_Static_Resource';
    private static final String DR_DEFAULT_ENTITY_RECORD_DEV_NAME = 'DR_Default_Entity';
    private static final String DR_PUBLIC_KEY_RECORD_DEV_NAME = 'DR_Public_Key';
    private static final String DR_SHIP_FROM_ADDRESS_COUNTRY = 'DR_Ship_From_Address_Country';
    private static final String DR_SHIP_FROM_ADDRESS_STATE = 'DR_Ship_From_Address_State';
    private static final String DR_SHIP_FROM_ADDRESS_POSTAL_CODE = 'DR_Ship_From_Address_PostalCode';
    private static final String DR_SHIP_FROM_ADDRESS_CITY = 'DR_Ship_From_Address_City';
    private static final String DR_SHIP_FROM_ADDRESS_LINE = 'DR_Ship_From_Address_Line';
    private static final String DR_SHIP_FROM_ADDRESS_PROVIDER_NAME = 'DR_Ship_From_Address_Provider_Name';
    private static final String DR_ENVIRONMENT_NAME = 'DR_Environment_Name';
    private static final String DR_WEBHOOK_RETRY_INTERVAL = 'DR_Webhook_Retry_Interval';
    private static final String DR_FULFILLMENT_RETRY_LIMIT = 'Fulfillment_Retry_Limit';
    private static final String DR_ORDER_FULFILLMENT_JOB_QUERY_LIMIT = 'Order_Fulfillment_Job_Query_Limit';
    private static final String DR_CONNECTOR_FROM_ADDRESS_EMAIL = 'From_Address_for_System_Emails';
    private static final String DR_CONNECTOR_STOREFRONT_BASE_URL_MAPPING = 'Storefronts_Base_URL_Mapping';
    private static final String DR_STORED_PAYMENTS = 'DR_Stored_Payments';
    private static final String DR_SHIPPING_CHOICE_INFO_PROVIDER_NAME = 'Shipping_Choice_Info_Provider_Name';
    private static final String Client_CSS_RESOURCE_RECORD_DEV_NAME = 'Client_Custom_CSS_Static_Resource';
    private static final String DR_VERSION_NUMBER = 'Connector_Version';
    private static final String DR_BATCH_FULFILLMENTS = 'Batch_Fulfillments';
    private static final String DR_SHIP_FROM_ADDRESS_CONFIGURATION = 'DR_Ship_From_Address_Configuration';
    private static final String DR_BATCH_FULFILLMENTS_TIME_PERIOD = 'Batch_Fulfillments_Time_Period'; // this is in minutes
    private static final string DR_PRODUCT_SYNC_JOB_QUERY_LIMIT = 'Product_Sync_Job_Query_Limit';
    private static final string DR_SKUGROUP_SYNC_JOB_QUERY_LIMIT = 'SkuGroup_Sync_Job_Query_Limit';
    
    private static Map<String, DR_Connector_Configuration__mdt> configByDeveloperName {
        get {
            if (configByDeveloperName == null) {
                configByDeveloperName = DR_Connector_Configuration__mdt.getAll();
            }
            return configByDeveloperName;
        }
        set;
    }

    public String getSecretKey() {
        return configByDeveloperName.get(DR_SECRET_KEY_RECORD_DEV_NAME)?.Key__c;
    }

    public String getApiEndpoint() {
        return configByDeveloperName.get(DR_API_ENDPOINT_RECORD_DEV_NAME)?.Key__c;
    }

    public Integer getApiTimeout() {
        return String.isNotEmpty(configByDeveloperName.get(DR_API_TIMEOUT_RECORD_DEV_NAME)?.Key__c)
            ? Integer.valueOf(configByDeveloperName.get(DR_API_TIMEOUT_RECORD_DEV_NAME).Key__c)
            : 120000;
    }

    public Integer getBatchScheduleTime() {
        return Integer.valueOf(configByDeveloperName.get(DR_BATCH_SCHEDULE_TIME_RECORD_DEV_NAME)?.Key__c);
    }

    public String getBatchSize() {
        return configByDeveloperName.get(DR_PRODUCT_BATCH_SIZE_RECORD_DEV_NAME)?.Key__c;
    }

    public String getConnectorNotificationEmail() {
        return configByDeveloperName.get(DR_CONNECTOR_NOTIFICATION_EMAIL_RECORD_DEV_NAME)?.Key__c;
    }

    public String getJSResource() {
        return configByDeveloperName.get(DR_JS_RESOURCE_RECORD_DEV_NAME)?.Key__c;
    }

    public String getCSSresource() {
        return configByDeveloperName.get(DR_CSS_RESOURCE_RECORD_DEV_NAME)?.Key__c;
    }

    public String getClientCSSresource() {
        return configByDeveloperName.get(Client_CSS_RESOURCE_RECORD_DEV_NAME)?.Key__c;
    }

    public String getDefaultEntity() {
        return configByDeveloperName.get(DR_DEFAULT_ENTITY_RECORD_DEV_NAME)?.Key__c;
    }

    public String getpublicKey() {
        return configByDeveloperName.get(DR_PUBLIC_KEY_RECORD_DEV_NAME)?.Key__c;
    }

    public String getShipFromCountry() {
        return configByDeveloperName.get(DR_SHIP_FROM_ADDRESS_COUNTRY)?.Key__c;
    }

    public String getShipFromState() {
        return configByDeveloperName.get(DR_SHIP_FROM_ADDRESS_STATE)?.Key__c;
    }

    public String getShipFromPostalCode() {
        return configByDeveloperName.get(DR_SHIP_FROM_ADDRESS_POSTAL_CODE)?.Key__c;
    }

    public String getShipFromCity() {
        return configByDeveloperName.get(DR_SHIP_FROM_ADDRESS_CITY)?.Key__c;
    }

    public String getShipFromLine() {
        return configByDeveloperName.get(DR_SHIP_FROM_ADDRESS_LINE)?.Key__c;
    }

    public String getEnvironmentName() {
        return configByDeveloperName.get(DR_ENVIRONMENT_NAME)?.Key__c;
    }

    public String getWebhookRetryInterval() {
        return configByDeveloperName.get(DR_WEBHOOK_RETRY_INTERVAL)?.Key__c;
    }

    public String getFromAddressProviderName() {
        String providerName = configByDeveloperName.get(DR_SHIP_FROM_ADDRESS_PROVIDER_NAME)?.Key__c;
        return String.isBlank(providerName) || configByDeveloperName.get(DR_SHIP_FROM_ADDRESS_CONFIGURATION)?.Key__c=='None'
        ? DRB2B_DefaultCheckoutFromAddressProvider.class.getName() : providerName;
    }

    public String getFulfillmentRetryLimit() {
        return configByDeveloperName.get(DR_FULFILLMENT_RETRY_LIMIT)?.Key__c;
    }

    public String getOrderFulfillmentJobQueryLimit() {
        return configByDeveloperName.get(DR_ORDER_FULFILLMENT_JOB_QUERY_LIMIT)?.Key__c;
    }

    public String getEmailFromAddress(){
        return configByDeveloperName.get(DR_CONNECTOR_FROM_ADDRESS_EMAIL)?.Key__c;
    }

    public String getStorefrontBaseURL(){
        return configByDeveloperName.get(DR_CONNECTOR_STOREFRONT_BASE_URL_MAPPING)?.Key__c;
    }
    public String getDRStoredPayments(){
        return configByDeveloperName.get(DR_STORED_PAYMENTS)?.Key__c;
    }
    public String getShippingChoiceInfoProviderName() {
        String providerName = configByDeveloperName.get(DR_SHIPPING_CHOICE_INFO_PROVIDER_NAME)?.Key__c;
        return String.isBlank(providerName) ? DRB2B_DefaultShippingChoiceProvider.class.getName() : providerName;
    }
    public String getDRConnectorVersion(){
        return configByDeveloperName.get(DR_VERSION_NUMBER)?.Key__c;
    }

    public String getDRBatchFulfillments(){
        return configByDeveloperName.get(DR_BATCH_FULFILLMENTS)?.Key__c;
    }

    public String getDRBatchFulfillmentsTimePeriod(){
        return configByDeveloperName.get(DR_BATCH_FULFILLMENTS_TIME_PERIOD)?.Key__c;
    }

    public String getDRShipFromAddressConfiguration() {
        return configByDeveloperName.get(DR_SHIP_FROM_ADDRESS_CONFIGURATION)?.Key__c;
    }

    public String getProductSyncJobQueryLimit() {
        return configByDeveloperName.get(DR_PRODUCT_SYNC_JOB_QUERY_LIMIT)?.Key__c;
    }

    public String getSkuGroupSyncJobQueryLimit() {
        return configByDeveloperName.get(DR_SKUGROUP_SYNC_JOB_QUERY_LIMIT)?.Key__c;
    }
}