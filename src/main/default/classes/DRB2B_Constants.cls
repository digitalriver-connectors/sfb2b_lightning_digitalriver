public without sharing class DRB2B_Constants {
    public static DRB2B_Constants.Profile Profile {
        get {
            return Profile == null ? (Profile = new DRB2B_Constants.Profile()) : Profile;
        }
        private set;
    }

    public static DRB2B_Constants.UserRole UserRole {
        get {
            return UserRole == null ? (UserRole = new DRB2B_Constants.UserRole()) : UserRole;
        }
        private set;
    }

    public static PermissionSet PermissionSet {
        get {
            return PermissionSet == null ? (PermissionSet = new DRB2B_Constants.PermissionSet()) : PermissionSet;
        }
        private set;
    }

    public static Session Session {
        get {
            return Session == null ? (Session = new Session()) : Session;
        }
        private set;
    }

    public static Cart WebCart {
        get {
            return WebCart == null ? (WebCart = new Cart()) : WebCart;
        }
        private set;
    }

    public static DrOrderState DrOrderState {
        get {
            return DrOrderState == null ? (DrOrderState = new DrOrderState()) : DrOrderState;
        }
        private set;
    }

    public static ConnectorConfiguration ConnectorConfiguration {
        get {
            return ConnectorConfiguration == null
                ? (ConnectorConfiguration = new ConnectorConfiguration())
                : ConnectorConfiguration;
        }
        private set;
    }

    public static Base Base {
        get {
            return Base == null ? (Base = new Base()) : Base;
        }
        private set;
    }

    public static RecordType RecordType {
        get {
            return RecordType == null ? (RecordType = new RecordType()) : RecordType;
        }
        private set;
    }

    public static Module Module {
        get {
            return Module == null ? (Module = new Module()) : Module;
        }
        private set;
    }

    public static WebhookEventType WebhookEventType {
        get {
            return WebhookEventType == null ? (WebhookEventType = new WebhookEventType()) : WebhookEventType;
        }
        private set;
    }

    public static Fulfillment Fulfillment {
        get {
            return Fulfillment == null ? (Fulfillment = new Fulfillment()) : Fulfillment;
        }
        private set;
    }

    public static Checkout Checkout {
        get {
            return Checkout == null ? (Checkout = new Checkout()) : Checkout;
        }
        private set;
    }

    public static Subscription Subscription {
        get {
            return Subscription == null ? (Subscription = new Subscription()) : Subscription;
        }
        private set;
    }

    public static CustomMetadataType CustomMetadataType {
        get {
            return CustomMetadataType == null ? (CustomMetadataType = new CustomMetadataType()) : CustomMetadataType;
        }
        private set;
    }

    public static SObjectType SObjectType {
        get {
            return SObjectType == null ? (SObjectType = new DRB2B_Constants.SObjectType()) : SObjectType;
        }
        private set;
    }

    public class Product2 extends SObjectType {
        private Product2() {
            this.objectType = Schema.Product2.getSObjectType();
        }

        public final String DATE_LAST_SYNCED_TO_DR {
            get {
                return Schema.Product2.Date_Last_Synced_to_DR__c.getDescribe().getName();
            }
        }
    }

    public class UserRole extends SObjectType {
        private UserRole() {
            this.objectType = Schema.UserRole.getSObjectType();
        }

        public final String DR_PORTAL_OWNER_ROLE_NAME = 'DigitalRiver Role';
        public final String DR_PORTAL_OWNER_ROLE_DEVELOPER_NAME = 'DigitalRiverRole';
    }

    public class Profile extends SObjectType {
        private Profile() {
            this.objectType = Schema.Profile.getSObjectType();
        }

        public final String DR_SHOPPER = 'DigitalRiverShopper';
        public final String DR_INTEGRATION = 'Digital River Integration User';

        public final String STANDARD_USER = 'Standard User';
        public final String SYSTEM_ADMIN = 'System Administrator';
        public final String CUSTOMER_COMMUNITY_USER = 'Customer Community User';
        public final String CUSTOMER_COMMUNITY_PLUS_USER = 'Customer Community Plus User';
    }

    public class PermissionSet extends SObjectType {
        private PermissionSet() {
            this.objectType = Schema.PermissionSet.getSObjectType();
        }

        public final String ADMIN = 'DigitalRiverConnectorAdmin';
        public final String SHOPPER = 'DigitalRiverConnectorShopper';
        public final String INTEGRATION = 'DigitalRiver_Connector_Integration';
    }

    public class Session {
        public final String SOURCE_IP = 'SourceIp';
    }

    public class ConnectorConfiguration extends CustomMetadataType {
        private ConnectorConfiguration() {
            this.objectType = DR_Connector_Configuration__mdt.getSObjectType();
        }

        public final String CONFIG_TYPE {
            get {
                return DR_Connector_Configuration__mdt.Config_Type__c.getDescribe().getName();
            }
        }

        public final String DISPLAY_ORDER {
            get {
                return DR_Connector_Configuration__mdt.Display_Order__c.getDescribe().getName();
            }
        }

        public final String HELPER_TEXT {
            get {
                return DR_Connector_Configuration__mdt.Helper_Text__c.getDescribe().getName();
            }
        }

        public final String KEY {
            get {
                return DR_Connector_Configuration__mdt.Key__c.getDescribe().getName();
            }
        }

        public final String MAPPING_FIELDS {
            get {
                return DR_Connector_Configuration__mdt.Mapping_Fields__c.getDescribe().getName();
            }
        }

        public final String VISIBLE {
            get {
                return DR_Connector_Configuration__mdt.Visible__c.getDescribe().getName();
            }
        }
    }

    public class RecordType extends SObjectType {
        private RecordType() {
            this.objectType = Schema.RecordType.getSObjectType();
        }

        public final String DEVELOPER_NAME {
            get {
                return Schema.RecordType.DeveloperName.getDescribe().getName();
            }
        }

        public final String REFERENCE_NAME {
            get {
                return OBJECT_NAME + Base.DOT + NAME;
            }
        }

        public final String REFERENCE_DEVELOPER_NAME {
            get {
                return OBJECT_NAME + Base.DOT + DEVELOPER_NAME;
            }
        }
    }

    public class Base {
        private Base() {
        }

        public final Boolean SUCCESS = true;
        public final Boolean FAILURE = false;

        // Http Status Codes
        public final Integer SUCCESS_RESPONSE_CODE = 200;
        public final Integer FULFILLMENT_SUCCESS_RESPONSE_CODE = 201;
        public final Integer ERROR_RESPONSE_CODE = 400;
        public final Integer CONFLICT_RESPONSE_CODE = 409;

        public final Integer NOT_FOUND = -1;

        public final String ALL = 'All';

        public final String EMPTY = '';
        public final String SPACE = ' ';
        public final String PLUS = '+';
        public final String PERCENT = '%';
        public final String DOLLAR_SIGN = '$';
        public final String DOT = '.';
        public final String DOT_REGEXP = '\\.';
        public final String SLASH = '/';
        public final String COLON = ':';
        public final String SEMICOLON = ';';
        public final String QUOTE = '"';
        public final String DOUBLE_QUOTE = QUOTE + QUOTE;
        public final String COMMA = ',';
        public final String COMMA_SPACE = COMMA + SPACE;
        public final String COLON_SPACE = COLON + SPACE;
        public final String HYPHEN = '-';
        public final String UNDERSCORE = '_';
        public final String VERTICAL_BAR = '|';
        public final String TAB = '\t';
        public final String OPEN_BRACKET = '(';
        public final String CLOSE_BRACKET = ')';
        public final String EMPTY_OBJECT = '{}';
        public final String DOUBLE_UNDERSCORE = UNDERSCORE + UNDERSCORE;
        public final String DOUBLE_UNDERSCORE_R = DOUBLE_UNDERSCORE + 'r';
        public final String DOUBLE_UNDERSCORE_C = DOUBLE_UNDERSCORE + 'c';
        public final String DOUBLE_UNDERSCORE_MDT = DOUBLE_UNDERSCORE + 'mdt';
        public final String OCE_NAMESPACE_PREFIX = 'OCE';

        public final String ID = 'Id';
        public final String CURRENCY_ISO_CODE = 'CurrencyIsoCode';
        public final String OPERATOR_EQUALS = 'EQUALS';
        public final String SYMBOL_EQUALS = '=';
        public final String SYMBOL_NOT_EQUALS = '!=';
        public final String OPERATOR_IN = 'IN';
        public final String OPERATOR_CONTAINS = 'CONTAINS';
        public final String OPERATOR_GREATER_THAN = '>';
        public final String OPERATOR_GREATER_THAN_OR_EQUALS = '>=';
        public final String OPERATOR_LESS_THAN = '<';
        public final String OPERATOR_LESS_THAN_OR_EQUALS = '<=';
        public final String ATTRIBUTES = 'attributes';
        public final String ATTRIBUTES_TYPE = 'type';
        public final String SOBJECT_TYPE = 'sobjectType';
        public final String AND_STRING = 'and';
        public final String TO_LABEL = 'toLabel({0})';
        public final String RECORD_ID = 'recordId';

        public final String DEFAULT_MEETING_INITIATION_FLOW_NAME = 'MeetingInitiationRecordTypeSelection_V2';
        public final String DEFAULT_AGREEMENT_INITIATION_FLOW_NAME = 'AgreementInitiatingDefaultPath';
        public final String DEFAULT_PLAN_INITIATION_FLOW_NAME = 'PlanInitiationRecordTypeSelection';
        public final String DEFAULT_FMV_ENHANCEMENTS_ENABLED = 'EnableFMVEnhancements';
    }

    public class Module {
        public final String ORG_DEFAULT = 'Org Default';
        public final String PRODUCT_SYNC = 'Product Sync';
        public final String WEBHOOK_EVENT = 'Webhook Event';
        public final String APP_CONFIG = 'App Config';
        public final String FLS_CHECKS = 'FLS Checks';
        public final String MY_WALLET = 'MY Wallet';
        public final String INVOICE_CREDIT_MEMO = 'Invoice & Credit Memo';
        public final String CUSTOMER_MANAGEMENT = 'Customer Management';
        public final String EMAIL = 'Email';
        public final String CHECKOUT_FLOW = 'Checkout Flow';
        public final String TRIGGER_HANDLER = 'Trigger Handler';
        public final String ORDER_CREATED_EVENT = 'Order Created Event';
        public final String ORDER_ACCEPTED_EVENT = 'Order Accepted Event';
        public final String ORDER_CANCELLED_EVENT = 'Order Cancelled Event';
        public final String ORDER_COMPLETED_EVENT = 'Order Completed Event';
        public final String FULFILLMENT = 'Fulfillment';
        public final String BATCH_FULFILLMENT = 'Fulfillment Batch Job';
        public final String ORDER_MANAGEMENT = 'Order Management';
        public final String DigitalRiver_STATIC_RESOURCE = 'Static Resource';
        public final String DigitalRiver_WIRE_TRANSFER_INSTRUCTIONS = 'Wire Transfer Instructions';
        public final String Customer_Credit = 'Customer Credit';
        public final String DigitalRiver_TRANSACTION_PAYMENTS = 'DR Transaction Payments';
        public final String DigitalRiver_SKU_GROUP = 'SKU Group';
    }

    public class WebhookEventType {
        public final String ORDER_INVOICE_CREATED = 'order.invoice.created';
        public final String ORDER_CREDIT_MEMO_CREATED = 'order.credit_memo.created';
    }

    public class DrOrderState {
        public final String PENDING_PAYMENT = 'pending_payment';
        public final String IN_REVIEW = 'in_review';
        public final String ACCEPTED = 'accepted';
        public final String BLOCKED = 'blocked';
        public final String CANCELLED = 'cancelled';
        public final String FULFILLED = 'fulfilled';
        public final String COMPLETE = 'complete';
        public final String RETURNED = 'returned';
        public final String CANCELLED_BY_SF = 'cancelled_by_sf';
        public final String CANCELLED_BY_DR = 'cancelled_by_dr';
    }

    public class Fulfillment {
        public final String FULFILL_STATUS = 'fulfilled';
        public final String CANCEL_STATUS = 'cancelled';
        public final String ORDER_OPEN_STATUS = 'Open';
        public final String ORDER_REPROCESS_STATUS = 'Reprocess';
        public final String ORDER_COMPLETE_STATUS = 'Completed';
        public final String ORDER_FAILED_STATUS = 'Failed';
        public final String LINE_ITEM_OPEN_STATUS = 'Open';
        public final String LINE_ITEM_REPROCESS_STATUS = 'Reprocess';
        public final String LINE_ITEM_COMPLETE_STATUS = 'Completed';
        public final String LINE_ITEM_FAILED_STATUS = 'Failed';
        public final String LINE_ITEM_FULFILLED_STATUS = 'fulfilled';
        public final String LINE_ITEM_PARTIALLY_FULFILLED_STATUS = 'partially_fulfilled';
        public final String LINE_ITEM_CANCELLED_STATUS = 'cancelled';
        public final String LINE_ITEM_PARTIALLY_CANCELLED_STATUS = 'partially_cancelled';
        public final Set<String> ORDER_FULFILL_CANCEL_STATUSES = new Set<String>{ 'fulfilled', 'cancelled' };
        // Http Response status code is 409, but the below error codes can be treated as Order level success
        public final Set<String> FULFILLMENT_ORDER_SUCCESS_CODES = new Set<String>{
            'order_complete',
            'order_cancelled'
        };
        // Http Response status code is 409, but the below error codes can be treated as Line Item level success
        public final Set<String> FULFILLMENT_ORDER_ITEM_SUCCESS_CODES = new Set<String>{
            'item_fulfilled',
            'item_cancelled'
        };
        // Http Response status code is 409, but the below error codes can be treated as success
        public final Set<String> FULFILLMENT_SUCCESS_CODES = new Set<String>{
            'item_fulfilled',
            'item_cancelled',
            'order_complete',
            'order_cancelled'
        };
        // Http Response status code is 409 and we get the below error codes (these are failure codes)
        public final Set<String> FULFILLMENT_ERROR_CODES = new Set<String>{ 'quantity_too_large' };
    }

    public class Checkout {
        public final String CHARGE_TYPE_CUSTOMER_INITIATED = 'customer_initiated';
        public final String CHARGE_TYPE_MERCHANT_INITIATED = 'merchant_initiated';
        public final Set<String> CREATE_CHECKOUT_BAD_RESPONSES = new Set<String>{
            'bad_request',
            'not_found',
            'request_timeout',
            'unauthorized',
            'conflict',
            'internal_server_error',
            'too_many_requests',
            'method_not_allowed',
            'not_acceptable',
            'forbidden',
            'bad_gateway',
            'service_unavailable',
            'gateway_timeout'
        };
    }

    public class Subscription {
        public final String DR_AUTO_RENEWAL_TERMS = 'By checking the box below and completing your purchase, you expressly authorize and permit Digital River to automatically renew your purchased license or subscription for successive renewal terms each equal in length to the initial term specified above, at the purchase price for your initial term (plus taxes and fees, less any applicable discounts) using the payment information you provided for your initial purchase, until you cancel. At least one email will be sent to you to remind you of each upcoming renewal. We may change the renewal price as of the next renewal date if we provide you with prior notice of the change by email (you can elect to cancel automatic renewal as described below if you do not agree to the change). The Digital River <a href="https://store.digitalriver.com/store/defaults/en_US/DisplayDRTermsAndConditionsPage/eCommerceProvider.Digital River Inc." target="_blank" class="dr_termsAndConditions">Terms of Sale</a> and <a href="https://store.digitalriver.com/store/defaults/en_US/DisplayDRPrivacyPolicyPage/eCommerceProvider.Digital River Inc." target="_blank" class="dr_privacyPolicy">Privacy Policy</a> will apply to each renewal transaction. You may cancel your auto-renewal plan at any time by logging into the account interface (access information will be included in your order confirmation email or on the Customer Service Help page), selecting your product, and selecting the option to disable automatic renewal. <br/><br/>I agree that Digital River may store my payment information for future purchases including the processing of any subsequent subscription renewals which may occur following the date of this order.';
    }

    public virtual class CustomMetadataType extends SystemFields {
        protected Schema.SObjectType objectType;

        public final String Id = 'Id';
        public final String QUALIFIED_API_NAME = 'QualifiedApiName';
        public final String DEVELOPER_NAME = 'DeveloperName';
        public final String MASTER_LABEL = 'MasterLabel';
        public final String LABEL = 'Label';
        public final String DESCRIPTION = 'Description';
        public final String NAMESPACE_PREFIX = 'NamespacePrefix';

        public final String OBJECT_NAME {
            get {
                return this.objectType.getDescribe().getName();
            }
        }

        public Schema.SObjectType SOBJECT_TYPE {
            get {
                return this.objectType;
            }
        }
    }

    public virtual class SObjectType extends SystemFields {
        protected Schema.SObjectType objectType;

        public final String Id = 'Id';
        public final String NAME = 'Name';
        public final String RECORD_TYPE_ID = 'RecordTypeId';
        public final String RECORD_TYPE_DEVELOPER_NAME = 'RecordType.DeveloperName';
        public final String RECORD_TYPE_NAME = 'RecordType.Name';
        public final String RECORD_TYPE = 'RecordType';
        public final String OWNER = 'Owner';
        public final String OWNER_ID = 'OwnerId';
        public final String OWNER_NAME = 'Owner.Name';
        public final String LAST_VIEWED_DATE = 'LastViewedDate';

        public Schema.SObjectType SOBJECT_TYPE {
            get {
                return this.objectType;
            }
        }

        public String OBJECT_NAME {
            get {
                return this.objectType.getDescribe().getName();
            }
        }
    }

    public virtual class SystemFields {
        public final String ID = 'Id';
        public final String CREATED_BY = 'CreatedBy';
        public final String CREATED_BY_ID = 'CreatedById';
        public final String CREATED_DATE = 'CreatedDate';
        public final String LAST_MODIFIED_DATE_TIME = 'LastModifiedDate';
        public final String RECORD_TYPE_ID = 'RecordTypeId';
        public final String CURRENCY_ISO_CODE = 'CurrencyIsoCode';
        public final String DEVELOPER_NAME = 'DeveloperName';
        /**
         * ALL SYSTEM SOBJECT FIELDS
         */
    }

    public class Cart extends SObjectType {
        public final String TYPE_PHYSICAL = 'Physical';
        public final String TYPE_NON_DIGITAL = 'Non-Digital';
        public final String TYPE_DIGITAL = 'Digital';

        private Cart() {
            this.objectType = Schema.WebCart.getSObjectType();
        }
    }
}
