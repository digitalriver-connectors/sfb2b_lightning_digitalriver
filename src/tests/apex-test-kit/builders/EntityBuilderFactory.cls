/**
 * @description       :
 * @author            : Arun Sood
 * @group             :
 * @last modified on  : 04-19-2021
 * @last modified by  : Arun Sood
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   04-19-2021   Arun Sood   Initial Version
 **/
public with sharing class EntityBuilderFactory {
    public static AtkAccountEntityBuilder accountBuilder = new AtkAccountEntityBuilder();
    public static AtkCartDeliveryGroupEntityBuilder cartDeliveryGroupBuilder = new AtkCartDeliveryGroupEntityBuilder();
    public static AtkCartItemEntityBuilder cartItemBuilder = new AtkCartItemEntityBuilder();
    public static AtkContactEntityBuilder contactBuilder = new AtkContactEntityBuilder();
    public static AtkContactPointAddressEntityBuilder contactPointAddressBuilder = new AtkContactPointAddressEntityBuilder();
    public static AtkOrderEntityBuilder orderBuilder = new AtkOrderEntityBuilder();
    public static AtkOrderItemEntityBuilder orderItemEBuilder = new AtkOrderItemEntityBuilder();
    public static AtkPricebook2EntityBuilder pricebookBuilder = new AtkPricebook2EntityBuilder();
    public static AtkProduct2EntityBuilder productBuilder = new AtkProduct2EntityBuilder();
    public static AtkUserEntityBuilder userBuilder = new AtkUserEntityBuilder();
    public static AtkWebCartEntityBuilder webCartBuilder = new AtkWebCartEntityBuilder();
    public static AtkWebStoreEntityBuilder webStoreBuilder = new AtkWebStoreEntityBuilder();
    public static AtkDRECCNLookupEntityBuilder drECCNLookupBuilder = new AtkDRECCNLookupEntityBuilder();
    public static AtkDigitalRiverTaxMappingEntityBuilder drTaxMappingBuilder = new AtkDigitalRiverTaxMappingEntityBuilder();
    public static AtkCartTaxEntityBuilder cartTaxBuilder = new AtkCartTaxEntityBuilder();
    public static AtkDRTransactionPaymentEntityBuilder drTransactionPaymentBuilder = new AtkDRTransactionPaymentEntityBuilder();
    public static AtkPricebookEntryEntityBuilder pricebookEntryBuilder = new AtkPricebookEntryEntityBuilder();
    public static AtkDRFulfillmentEntityBuilder drFulfillmentBuilder = new AtkDRFulfillmentEntityBuilder();
    public static AtkDRLineItemFulfillmentEntityBuilder drLineItemFulfillmentBuilder = new AtkDRLineItemFulfillmentEntityBuilder();
    public static AtkRegulatoryFeeEntityBuilder regulatoryFeeBuilder = new AtkRegulatoryFeeEntityBuilder();
    public static AtkDRInvoiceCreditMemoEntityBuilder drInvocieCreditMemoBuilder = new AtkDRInvoiceCreditMemoEntityBuilder();
    public static AtkDRFulfillmentRequestLogEntityBuilder fulfillmentRequestLogBuilder = new AtkDRFulfillmentRequestLogEntityBuilder();
}
