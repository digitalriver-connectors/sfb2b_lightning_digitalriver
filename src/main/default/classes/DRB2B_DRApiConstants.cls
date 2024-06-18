public without sharing class DRB2B_DRApiConstants {
    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    //endpoints
    public static final String END_POINT {
        get {
            if (END_POINT == null) {
                END_POINT = configurationSelector.getApiEndpoint();
            }
            return END_POINT;
        }
        set;
    }
    //SKU Group Max Limit
    public static final String DR_QUERY_MAX_LIMIT = 'limit=100';
    //SKU startingAfter and endingBefore
    public static final String DR_QUERY_STARTING_PARAMETER = 'startingAfter';
    public static final String DR_QUERY_ENDING_PARAMETER = 'endingBefore';

    //path
    public static final String CREATE_CUSTOMER_PATH = 'customers';
    public static final String GET_FILE_LINK_PATH = 'file-links';
    public static final String TAX_IDENTIFIER = 'tax-identifiers';
    public static final String FILES = 'files';
    public static final String CREATE_SKU_PATH = 'skus';
    public static final String CUSTOMERS_PATH = 'customers';
    public static final String SOURCE_PATH = 'sources';
    public static final String CHECKOUT_PATH = 'checkouts';
    public static final String ORDER_PATH = 'orders';
    public static final String FULFILLMENT_PATH = 'fulfillments';
    public static final String PAYMENT_PATH = 'payments';
    public static final String SKU_GROUP_PATH = 'sku-groups';

    //headers
    public static final Map<String, String> DEFAULT_HEADERS = new Map<String, String>{
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'upstream-application-id' => 'SFB2bLightning/' + configurationSelector.getDRConnectorVersion(),
        'upstream-id' => DRB2B_Utility.generateUUID()
    };

    public static final String AUTH_HEADER_NAME = 'Authorization';
    public static final String BEARER = 'Bearer';

    //others
    public static final Integer REQUEST_TIMEOUT {
        get {
            if (REQUEST_TIMEOUT == null) {
                REQUEST_TIMEOUT = configurationSelector.getApiTimeout();
            }
            return REQUEST_TIMEOUT;
        }
        set;
    }

    //statuses
    public static final Integer SUCCESS_STATUS = 200;
    public static final Integer CREATE_CUSTOMER_ALREADY_EXISTS_STATUS = 409;
    public static final Integer UPSERT_SUCCESS_STATUS = 201;
    public static final Integer DELETE_SUCCESS_STATUS = 204;
    public static final Integer NOT_FOUND_STATUS = 404;
    public static final Integer ERROR_RESPONSE_CODE = 400;

    //customer types
    public static final String CUSTOMER_TYPE_BUSINESS = 'business';
    public static final String CUSTOMER_TYPE_INDIVIDUAL = 'individual';

    public static final String NOT_FOUND = 'not_found';

    // for offline refund refund
    public static final String REFUND_PATH = 'refunds';
    public static final String DR_QUERY_ORDERID = 'orderId';
    public static final String REFUND_STATE = 'state';
    public static final String REFUND_STATE_PENDING_INFO = 'pending_information';
}
