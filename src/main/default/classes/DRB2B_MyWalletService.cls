public with sharing class DRB2B_MyWalletService {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.MY_WALLET);
    private static final Stringifier stringifier = new Stringifier();
    private static final String CONTACT_ID_FIELD = 'ContactId';

    @TestVisible
    private DRB2B_ContactPointAddressSelector contactPointAddressSelector = new DRB2B_ContactPointAddressSelector();
    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    @TestVisible
    private static DRB2B_UserSelector userSelector = new DRB2B_UserSelector();

    @TestVisible
    private static DRB2B_ProductSyncUtil productSyncUtilObj = new DRB2B_ProductSyncUtil();

    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();

    @TestVisible
    private static DRB2B_CartSelector cartSelector = new DRB2B_CartSelector();

    public List<ContactPointAddress> getBillingContactPointAddress() {
        return contactPointAddressSelector.getAllBillingContactPointAddressByAddressType('Billing');
    }

    public String attachSourceWithCustomer(String jsonString) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Map<String, Object> dataMap = new Map<String, Object>();

        try {
            String sourceId = (String) requestMap.get('sourceId');
            String contactId = (String) requestMap.get('contactId');
            String userId = (String) requestMap.get('userId');
            String cartId = (String) requestMap.get('cartId');
            String upStreamSessionId = '';
            if(String.isBlank(cartId)){
                upStreamSessionId = contactId;
            }else{
                upStreamSessionId = cartId;
            }
            DRB2B_CustomerService customerServiceObj = new DRB2B_CustomerService();
            DCM_HttpClient.Response response = customerServiceObj.attachSourceToCustomer(sourceId, contactId, upStreamSessionId);

            DRB2B_AttachSourceToCustomerRes attachSourceToCustomerResponse;
            if (response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS) {
                attachSourceToCustomerResponse = (DRB2B_AttachSourceToCustomerRes) response.asType(
                    DRB2B_AttachSourceToCustomerRes.class
                );
                logger.debug(
                    stringifier.toString(
                        new Map<String, String>{
                            'attachSourceSuccessResponse' => response.getBody(),
                            'attachSourceToCustomerResponse' => JSON.serialize(attachSourceToCustomerResponse)
                        }
                    )
                );
                dataMap.put('isSuccess', true);
            } else if (response.getStatusCode() == DRB2B_DRApiConstants.NOT_FOUND_STATUS) {
                String customerNotFoundErrorMsg = 'Customer \'' + contactId + '\' not found';
                DRB2B_ErrorResponse drAttachSourceErrorObj = (DRB2B_ErrorResponse) response.asType(
                    DRB2B_ErrorResponse.class
                );
                logger.debug(
                    stringifier.toString(
                        new Map<String, String>{
                            'attachSourceToCustomer' => response.getBody(),
                            'attachSourceToCustomerObj' => JSON.serialize(drAttachSourceErrorObj)
                        }
                    )
                );
                if (drAttachSourceErrorObj.errors[0].message.equals(customerNotFoundErrorMsg)) {
                    DRB2B_CreateCustomerResponseModel createCustomerResponse = customerServiceObj.createCustomer(
                        userId,cartId
                    );

                    if (createCustomerResponse.isSuccess) {
                        response = customerServiceObj.attachSourceToCustomer(sourceId, contactId, upStreamSessionId);
                        if (response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS) {
                            attachSourceToCustomerResponse = (DRB2B_AttachSourceToCustomerRes) response.asType(
                                DRB2B_AttachSourceToCustomerRes.class
                            );
                            logger.debug(
                                stringifier.toString(
                                    new Map<String, String>{
                                        'attachSourceSuccessResponse' => response.getBody(),
                                        'attachSourceToCustomerResponse' => JSON.serialize(
                                            attachSourceToCustomerResponse
                                        )
                                    }
                                )
                            );
                            dataMap.put('isSuccess', true);
                        } else {
                            dataMap.put('isSuccess', false);
                            dataMap.put('message', drAttachSourceErrorObj.errors[0].message);
                        }
                    } else {
                        dataMap.put('isSuccess', false);
                        dataMap.put('message', drAttachSourceErrorObj.errors[0].message);

                    }
                } else {
                    dataMap.put('isSuccess', false);
                    
                }
            } else {
                DRB2B_ErrorResponse drAttachSourceErrorObj = (DRB2B_ErrorResponse) response.asType(
                    DRB2B_ErrorResponse.class
                );
                dataMap.put('isSuccess', false);
                dataMap.put('message', drAttachSourceErrorObj.errors[0].message);
            }
        } catch (Exception e) {
            dataMap.put('isSuccess', false);
            dataMap.put('message', e.getMessage());
            logger.error(e);
        } finally {
            logger.flush();
        }
        return JSON.serialize(dataMap);
    }

    public String getAllSavedPayments(String jsonString) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Map<String, Object> dataMap = new Map<String, Object>();
        try {
            String contactId = (String) requestMap.get('contactId');
            String userId = (String) requestMap.get('userId');
            String cartId = (String) requestMap.get('cartId');
            if(String.isBlank(cartId)){
                cartId = contactId;
            }
            DRB2B_CustomerService customerServiceObj = new DRB2B_CustomerService();
            DRB2B_CreateCustomerResponseModel getCustomerResponseModal = customerServiceObj.getById(userId, cartId);
            String storedPaymentToShow = configurationSelector.getDRStoredPayments();
            if (getCustomerResponseModal.isSuccess) {
                dataMap.put('attachedSources', getCustomerResponseModal.sources);
                dataMap.put('isSuccess', true);
                dataMap.put('storedPayments', storedPaymentToShow.split(','));
                
            } else {
                dataMap.put('isSuccess', false);
            }
        } catch (Exception e) {
            dataMap.put('isSuccess', false);
            logger.error(e);
        } finally {
            logger.flush();
        }
        return JSON.serialize(dataMap);
    }

    public Boolean deleteSavedPayment(String jsonString) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Boolean finalResult = false;
        try {
            String sourceId = (String) requestMap.get('sourceId');
            String userId = (String) requestMap.get('userId');
            User usr = userSelector.getById(userId, new Set<String>{ CONTACT_ID_FIELD });

            DCM_HttpClient.Response response = requestService.deletePaymentSource(usr.ContactId, sourceId).fetch();

            finalResult = response.getStatusCode() == DRB2B_DRApiConstants.DELETE_SUCCESS_STATUS;
        } catch (Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
        return finalResult;
    }

    public String getCheckoutAndSourceInfoForSCA(String jsonString) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Map<String, Object> dataMap = new Map<String, Object>();
        try {
            String sourceId = (String) requestMap.get('sourceId');
            String cartId = (String) requestMap.get('cartId');
            DCM_HttpClient.Response response = requestService.getSourceInformation(sourceId, cartId).fetch();
            DRB2B_SourceModel sourceModelResponse;
            if (response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS) {
                sourceModelResponse = (DRB2B_SourceModel) response.asType(DRB2B_SourceModel.class);
                logger.debug(stringifier.toString(new Map<String, String>{ 'sourceResponse' => response.getBody() }));
                dataMap.put('isSuccess', true);
                dataMap.put('sourceInformation', sourceModelResponse);
            }
        } catch (Exception e) {
            dataMap.put('isSuccess', false);
            logger.error(e);
        } finally {
            logger.flush();
        }
        return JSON.serialize(dataMap);
    }

    public Boolean attachSourceToCheckout(String jsonString) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Boolean finalResult = false;
        List<WebCart> webCartList = new List<WebCart>();
        try {
            String sourceId = (String) requestMap.get('sourceId');
            String checkoutId = (String) requestMap.get('checkoutId');
            String cartId = (String) requestMap.get('cartId');
            DCM_HttpClient.Response response = requestService.attachSourceToCheckout(checkoutId, sourceId, cartId).fetch();
            DRB2B_SourceModel sourceModelResponse;
            if (response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS) {
                sourceModelResponse = (DRB2B_SourceModel) response.asType(DRB2B_SourceModel.class);
                WebCart webCart = cartSelector.getByCheckoutId(checkoutId);
                webCart.BillingStreet = sourceModelResponse.owner.address.line1;
                webCart.BillingCity = sourceModelResponse.owner.address.city;
                webcart.BillingPostalCode = sourceModelResponse.owner.address.postalCode;
                if(DRB2B_Utility.isCountryStateEnabled()){
                    webcart.put('BillingCountryCode', sourceModelResponse.owner.address.country);
                    webcart.put('BillingStateCode', sourceModelResponse.owner.address.state);
                }else{
                webcart.BillingCountry = productSyncUtilObj.getCountryISOCodeAndCountryMap()
                    .get(sourceModelResponse.owner.address.country);
                webcart.BillingState = sourceModelResponse.owner.address.state;
                }
                webCartList.add(webcart);

                DmlManager.updateAsUser(webCartList);
                finalResult = response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS;
            }
        } catch (Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
        return finalResult;
    }
}
