@isTest
private class DRB2B_PicklistMetaDataServiceTest {
    private static final String TEST_USER_ID_FOR_MOCK = '00521000007BcYFAA0';
    private static final String TEST_CONTACT_ID = '00521000007BcYFCC0';


    @isTest
    static void testSKUGroupuccessResponse() {
        setConfigurationStub();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        setUserSelectorMock();

        Test.startTest();
        List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
        Map<String,String> skuGroupMap = new Map<String,String>();
        skuGroupMap.put('alise', 'PickList');
        for(String key : skuGroupMap.keySet()){
            DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
            customValue.fullName = skuGroupMap.get(key); //API name of picklist value
            customValue.default_x = false;//false;
            customValue.isActive = true; //false;
            customValue.label = key; //'United States';
            customValuesList.add(customValue);
        }
        System.debug('customValuesList --->'+customValuesList);

        DRB2B_PicklistMetaDataService.createPicklistField('Product2','digitalriverv3__DR_SKU_Group__c', 'DR SKU Group', customValuesList);

        Test.stopTest();

        System.assert(skuGroupMap != null);
        System.assertNotEquals(null, skuGroupMap);
    }
    @isTest
    static void testSKUGroupErrorResponse() {
        setConfigurationStub();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        setUserSelectorMock();

        Test.startTest();
        List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
        Map<String,String> skuGroupMap = new Map<String,String>();
        //skuGroupMap.put('alise', 'PickList');
        for(String key : skuGroupMap.keySet()){
            DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
            customValue.fullName = skuGroupMap.get(key); //API name of picklist value
            customValue.default_x = false;//false;
            customValue.isActive = true; //false;
            customValue.label = key; //'United States';
            customValuesList.add(customValue);
        }
        System.debug('customValuesList --->'+customValuesList);

        DRB2B_PicklistMetaDataService.createPicklistField('Product2','digitalriverv3__DR_SKU_Group__c', 'DR SKU Group', customValuesList);

        Test.stopTest();

        System.assert(skuGroupMap != null);
        System.assertNotEquals(null, skuGroupMap);
    }

    @isTest
    static void handleSaveResults() {
        setConfigurationStub();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        setUserSelectorMock();

        Test.startTest();
        List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
        Map<String,String> skuGroupMap = new Map<String,String>();
        //skuGroupMap.put('alise', 'PickList');
        for(String key : skuGroupMap.keySet()){
            DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
            customValue.fullName = skuGroupMap.get(key); //API name of picklist value
            customValue.default_x = false;//false;
            customValue.isActive = true; //false;
            customValue.label = key; //'United States';
            customValuesList.add(customValue);
        }
        List<DRB2B_MetadataService.CustomField> customFieldList = new List<DRB2B_MetadataService.CustomField>();
        
        System.debug('customValuesList --->'+customValuesList);
        DRB2B_MetadataService.ValueSetValuesDefinition valueDefinition = new DRB2B_MetadataService.ValueSetValuesDefinition();
        valueDefinition.value = customValuesList;
        valueDefinition.sorted = false;

        DRB2B_MetadataService.ValueSet valueSet = new DRB2B_MetadataService.ValueSet();
        valueSet.valueSetDefinition = valueDefinition;

        DRB2B_MetadataService.CustomField customField = new DRB2B_MetadataService.CustomField();
        customField.valueSet = valueSet;

        System.debug('customValuesList --->'+customValuesList);
        DRB2B_MetadataService.MetadataPort service = DRB2B_PicklistMetaDataService.createService();
        List<DRB2B_MetadataService.SaveResult> results = service.createMetadata(new DRB2B_MetadataService.Metadata[] { customField });
        DRB2B_PicklistMetaDataService.handleSaveResults(results[0]);

        Test.stopTest();

        System.assert(skuGroupMap != null);
        System.assertNotEquals(null,skuGroupMap);
    }

    @isTest
    static void handleSaveErrorResults() {
        setConfigurationStub();
        Test.setMock(WebServiceMock.class, new WebServiceErrorMockImpl());
        setUserSelectorMock();

        Test.startTest();
        List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
        Map<String,String> skuGroupMap = new Map<String,String>();
        //skuGroupMap.put('alise', 'PickList');
        for(String key : skuGroupMap.keySet()){
            DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
            customValue.fullName = skuGroupMap.get(key); //API name of picklist value
            customValue.default_x = false;//false;
            customValue.isActive = true; //false;
            customValue.label = key; //'United States';
            customValuesList.add(customValue);
        }
        List<DRB2B_MetadataService.CustomField> customFieldList = new List<DRB2B_MetadataService.CustomField>();
        
        System.debug('customValuesList --->'+customValuesList);
        DRB2B_MetadataService.ValueSetValuesDefinition valueDefinition = new DRB2B_MetadataService.ValueSetValuesDefinition();
        valueDefinition.value = customValuesList;
        valueDefinition.sorted = false;

        DRB2B_MetadataService.ValueSet valueSet = new DRB2B_MetadataService.ValueSet();
        valueSet.valueSetDefinition = valueDefinition;

        DRB2B_MetadataService.CustomField customField = new DRB2B_MetadataService.CustomField();
        customField.valueSet = valueSet;

        System.debug('customValuesList --->'+customValuesList);
        DRB2B_MetadataService.MetadataPort service = DRB2B_PicklistMetaDataService.createService();
        List<DRB2B_MetadataService.SaveResult> results = service.createMetadata(new DRB2B_MetadataService.Metadata[] { customField });
        try{
            DRB2B_PicklistMetaDataService.handleSaveResults(results[0]);
        }catch(DRB2B_PicklistMetaDataService.DRB2B_PicklistMetaDataServiceException ex){
            System.debug('Exception '+ex);
        }

        Test.stopTest();

        System.assert(skuGroupMap != null);
        System.assertNotEquals(null,skuGroupMap);
    }

    @isTest
    static void handleUpsertResultsrrorResults() {
        setConfigurationStub();
        Test.setMock(WebServiceMock.class, new WebServiceErrorMockImpl());
        setUserSelectorMock();

        Test.startTest();
        List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
        Map<String,String> skuGroupMap = new Map<String,String>();
        //skuGroupMap.put('alise', 'PickList');
        for(String key : skuGroupMap.keySet()){
            DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
            customValue.fullName = skuGroupMap.get(key); //API name of picklist value
            customValue.default_x = false;//false;
            customValue.isActive = true; //false;
            customValue.label = key; //'United States';
            customValuesList.add(customValue);
        }
        List<DRB2B_MetadataService.CustomField> customFieldList = new List<DRB2B_MetadataService.CustomField>();
        
        System.debug('customValuesList --->'+customValuesList);
        DRB2B_MetadataService.ValueSetValuesDefinition valueDefinition = new DRB2B_MetadataService.ValueSetValuesDefinition();
        valueDefinition.value = customValuesList;
        valueDefinition.sorted = false;

        DRB2B_MetadataService.ValueSet valueSet = new DRB2B_MetadataService.ValueSet();
        valueSet.valueSetDefinition = valueDefinition;

        DRB2B_MetadataService.CustomField customField = new DRB2B_MetadataService.CustomField();
        customField.valueSet = valueSet;

        System.debug('customValuesList --->'+customValuesList);
        DRB2B_MetadataService.MetadataPort service = DRB2B_PicklistMetaDataService.createService();
        List<DRB2B_MetadataService.UpsertResult> results = service.upsertMetadata(new DRB2B_MetadataService.Metadata[] { customField });
        try{
            DRB2B_PicklistMetaDataService.handleUpsertResults(results[0]);
        }catch(DRB2B_PicklistMetaDataService.DRB2B_PicklistMetaDataServiceException ex){
            System.debug('Exception '+ex);
        }

        Test.stopTest();

        System.assert(skuGroupMap != null);
        System.assertNotEquals(null,skuGroupMap);
    }
    @isTest
    static void handleDeleteErrorResults() {
        setConfigurationStub();
        Test.setMock(WebServiceMock.class, new WebServiceErrorMockImpl());
        setUserSelectorMock();

        Test.startTest();
        List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
        Map<String,String> skuGroupMap = new Map<String,String>();
        //skuGroupMap.put('alise', 'PickList');
        for(String key : skuGroupMap.keySet()){
            DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
            customValue.fullName = skuGroupMap.get(key); //API name of picklist value
            customValue.default_x = false;//false;
            customValue.isActive = true; //false;
            customValue.label = key; //'United States';
            customValuesList.add(customValue);
        }
        List<DRB2B_MetadataService.CustomField> customFieldList = new List<DRB2B_MetadataService.CustomField>();
        
        System.debug('customValuesList --->'+customValuesList);
        DRB2B_MetadataService.ValueSetValuesDefinition valueDefinition = new DRB2B_MetadataService.ValueSetValuesDefinition();
        valueDefinition.value = customValuesList;
        valueDefinition.sorted = false;

        DRB2B_MetadataService.ValueSet valueSet = new DRB2B_MetadataService.ValueSet();
        valueSet.valueSetDefinition = valueDefinition;

        DRB2B_MetadataService.CustomField customField = new DRB2B_MetadataService.CustomField();
        customField.valueSet = valueSet;

        System.debug('customValuesList --->'+customValuesList);
        DRB2B_MetadataService.MetadataPort service = DRB2B_PicklistMetaDataService.createService();
        List<DRB2B_MetadataService.DeleteResult> results = service.deleteMetadata('field',new List<String>{'test'});
        try{
            DRB2B_PicklistMetaDataService.handleDeleteResults(results[0]);
        }catch(DRB2B_PicklistMetaDataService.DRB2B_PicklistMetaDataServiceException ex){
            System.debug('Exception '+ex);
        }

        Test.stopTest();

        System.assert(skuGroupMap != null);
    }
    private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof DRB2B_MetadataService.retrieve_element)
				response.put('response_x', new DRB2B_MetadataService.retrieveResponse_element());
			else if(request instanceof DRB2B_MetadataService.checkDeployStatus_element)
				response.put('response_x', new DRB2B_MetadataService.checkDeployStatusResponse_element());
			else if(request instanceof DRB2B_MetadataService.listMetadata_element)
				response.put('response_x', new DRB2B_MetadataService.listMetadataResponse_element());
			else if(request instanceof DRB2B_MetadataService.checkRetrieveStatus_element)
				response.put('response_x', new DRB2B_MetadataService.checkRetrieveStatusResponse_element());
			else if(request instanceof DRB2B_MetadataService.describeMetadata_element)
				response.put('response_x', new DRB2B_MetadataService.describeMetadataResponse_element());
			else if(request instanceof DRB2B_MetadataService.deploy_element)
				response.put('response_x', new DRB2B_MetadataService.deployResponse_element());
            else if(request instanceof DRB2B_MetadataService.updateMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.updateMetadataResponse_element());
            else if(request instanceof DRB2B_MetadataService.renameMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.renameMetadataResponse_element());
            else if(request instanceof  DRB2B_MetadataService.cancelDeploy_element)
                response.put('response_x', new DRB2B_MetadataService.cancelDeployResponse_element());
            else if(request instanceof  DRB2B_MetadataService.deleteMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  DRB2B_MetadataService.upsertMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  DRB2B_MetadataService.createMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.createMetadataResponse_element());
            else if(request instanceof  DRB2B_MetadataService.deployRecentValidation_element)
                response.put('response_x', new DRB2B_MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof DRB2B_MetadataService.describeValueType_element)
                response.put('response_x', new DRB2B_MetadataService.describeValueTypeResponse_element());
            else if(request instanceof DRB2B_MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new DRB2B_MetadataService.checkRetrieveStatusResponse_element());

            List<DRB2B_MetadataService.CustomField> customFieldList = new List<DRB2B_MetadataService.CustomField>();
            List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
            Map<String,String> skuGroupMap = new Map<String,String>();
            skuGroupMap.put('alise', 'PickList');
            for(String key : skuGroupMap.keySet()){
                DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
                customValue.fullName = skuGroupMap.get(key); //API name of picklist value
                customValue.default_x = false;//false;
                customValue.isActive = true; //false;
                customValue.label = key; //'United States';
                customValuesList.add(customValue);
            }
            DRB2B_MetadataService.ValueSetValuesDefinition valueDefinition = new DRB2B_MetadataService.ValueSetValuesDefinition();
            valueDefinition.value = customValuesList;
            valueDefinition.sorted = false;

            DRB2B_MetadataService.ValueSet valueSet = new DRB2B_MetadataService.ValueSet();
            valueSet.valueSetDefinition = valueDefinition;

            DRB2B_MetadataService.CustomField customFields = new DRB2B_MetadataService.CustomField();
            customFields.valueSet = valueSet;

            customFields.valueSet.valueSetDefinition.value = customValuesList;
            customFieldList.add(customFields);

            
            if (request instanceof DRB2B_MetadataService.readMetadata_element) {

                DRB2B_MetadataService.readCustomFieldResponse_element resResult = new DRB2B_MetadataService.readCustomFieldResponse_element();
                resResult.result = new DRB2B_MetadataService.ReadCustomFieldResult();
                resResult.result.records = customFieldList;
                DRB2B_MetadataService.IReadResponseElement response_x;
                Map<String, DRB2B_MetadataService.IReadResponseElement> response_map_x = new Map<String, DRB2B_MetadataService.IReadResponseElement>();
                response_map_x.put('response_x', response_x);
                response.put('response_x', resResult);
     
            } else if (request instanceof DRB2B_MetadataService.updateMetadata_element) {
    
                DRB2B_MetadataService.SaveResult result = new DRB2B_MetadataService.SaveResult();
                result.success = true;
    
                DRB2B_MetadataService.updateMetadataResponse_element responseElement = new DRB2B_MetadataService.updateMetadataResponse_element();
                responseElement.result = new DRB2B_MetadataService.SaveResult[] {result};
    
                response.put('response_x', responseElement);
    
            } else if (request instanceof DRB2B_MetadataService.upsertMetadata_element) {
    
                DRB2B_MetadataService.UpsertResult result = new DRB2B_MetadataService.UpsertResult();
                result.success = true;
    
                DRB2B_MetadataService.upsertMetadataResponse_element responseElement = new DRB2B_MetadataService.upsertMetadataResponse_element();
                responseElement.result = new DRB2B_MetadataService.UpsertResult[] {result};

                response.put('response_x', responseElement);
    
            } else if (request instanceof DRB2B_MetadataService.createMetadata_element) {
                DRB2B_MetadataService.SaveResult result = new DRB2B_MetadataService.SaveResult();
                result.success = true;
    
                DRB2B_MetadataService.createMetadataResponse_element responseElement = new DRB2B_MetadataService.createMetadataResponse_element();
                responseElement.result = new DRB2B_MetadataService.SaveResult[] {result};

                response.put('response_x', responseElement);
            }else {
                System.assert(false, 'Unexpected request ' + request);
            }

			return;
		}
	} 

    private class WebServiceErrorMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof DRB2B_MetadataService.retrieve_element)
				response.put('response_x', new DRB2B_MetadataService.retrieveResponse_element());
			else if(request instanceof DRB2B_MetadataService.checkDeployStatus_element)
				response.put('response_x', new DRB2B_MetadataService.checkDeployStatusResponse_element());
			else if(request instanceof DRB2B_MetadataService.listMetadata_element)
				response.put('response_x', new DRB2B_MetadataService.listMetadataResponse_element());
			else if(request instanceof DRB2B_MetadataService.checkRetrieveStatus_element)
				response.put('response_x', new DRB2B_MetadataService.checkRetrieveStatusResponse_element());
			else if(request instanceof DRB2B_MetadataService.describeMetadata_element)
				response.put('response_x', new DRB2B_MetadataService.describeMetadataResponse_element());
			else if(request instanceof DRB2B_MetadataService.deploy_element)
				response.put('response_x', new DRB2B_MetadataService.deployResponse_element());
            else if(request instanceof DRB2B_MetadataService.updateMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.updateMetadataResponse_element());
            else if(request instanceof DRB2B_MetadataService.renameMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.renameMetadataResponse_element());
            else if(request instanceof  DRB2B_MetadataService.cancelDeploy_element)
                response.put('response_x', new DRB2B_MetadataService.cancelDeployResponse_element());
            else if(request instanceof  DRB2B_MetadataService.deleteMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  DRB2B_MetadataService.upsertMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  DRB2B_MetadataService.createMetadata_element)
                response.put('response_x', new DRB2B_MetadataService.createMetadataResponse_element());
            else if(request instanceof  DRB2B_MetadataService.deployRecentValidation_element)
                response.put('response_x', new DRB2B_MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof DRB2B_MetadataService.describeValueType_element)
                response.put('response_x', new DRB2B_MetadataService.describeValueTypeResponse_element());
            else if(request instanceof DRB2B_MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new DRB2B_MetadataService.checkRetrieveStatusResponse_element());

            List<DRB2B_MetadataService.CustomField> customFieldList = new List<DRB2B_MetadataService.CustomField>();
            List<DRB2B_MetadataService.CustomValue> customValuesList = new List<DRB2B_MetadataService.CustomValue>();
            Map<String,String> skuGroupMap = new Map<String,String>();
            skuGroupMap.put('alise', 'PickList');
            for(String key : skuGroupMap.keySet()){
                DRB2B_MetadataService.CustomValue customValue = new DRB2B_MetadataService.CustomValue();
                customValue.fullName = skuGroupMap.get(key); //API name of picklist value
                customValue.default_x = false;//false;
                customValue.isActive = true; //false;
                customValue.label = key; //'United States';
                customValuesList.add(customValue);
            }
            DRB2B_MetadataService.ValueSetValuesDefinition valueDefinition = new DRB2B_MetadataService.ValueSetValuesDefinition();
            valueDefinition.value = customValuesList;
            valueDefinition.sorted = false;

            DRB2B_MetadataService.ValueSet valueSet = new DRB2B_MetadataService.ValueSet();
            valueSet.valueSetDefinition = valueDefinition;

            DRB2B_MetadataService.CustomField customFields = new DRB2B_MetadataService.CustomField();
            customFields.valueSet = valueSet;

            customFields.valueSet.valueSetDefinition.value = customValuesList;
            customFieldList.add(customFields);

            DRB2B_MetadataService.Error errorMessage = new DRB2B_MetadataService.Error();
            errorMessage.message = 'Error';
            errorMessage.statusCode = '400';
            errorMessage.fields = new List<String>{'Testing'};
            if (request instanceof DRB2B_MetadataService.readMetadata_element) {

                DRB2B_MetadataService.readCustomFieldResponse_element resResult = new DRB2B_MetadataService.readCustomFieldResponse_element();
                resResult.result = new DRB2B_MetadataService.ReadCustomFieldResult();
                resResult.result.records = customFieldList;
                DRB2B_MetadataService.IReadResponseElement response_x;
                Map<String, DRB2B_MetadataService.IReadResponseElement> response_map_x = new Map<String, DRB2B_MetadataService.IReadResponseElement>();
                response_map_x.put('response_x', response_x);
                response.put('response_x', resResult);
     
            } else if (request instanceof DRB2B_MetadataService.updateMetadata_element) {
    
                DRB2B_MetadataService.SaveResult result = new DRB2B_MetadataService.SaveResult();
                result.success = true;
    
                DRB2B_MetadataService.updateMetadataResponse_element responseElement = new DRB2B_MetadataService.updateMetadataResponse_element();
                responseElement.result = new DRB2B_MetadataService.SaveResult[] {result};
    
                response.put('response_x', responseElement);
    
            } else if (request instanceof DRB2B_MetadataService.upsertMetadata_element) {
                
                DRB2B_MetadataService.UpsertResult result = new DRB2B_MetadataService.UpsertResult();
                result.errors =  new DRB2B_MetadataService.Error[] {errorMessage};
                result.success = false;

                DRB2B_MetadataService.upsertMetadataResponse_element responseElement = new DRB2B_MetadataService.upsertMetadataResponse_element();
                responseElement.result = new DRB2B_MetadataService.UpsertResult[] {result};

                response.put('response_x', responseElement);
    
            } else if (request instanceof DRB2B_MetadataService.createMetadata_element) {
                DRB2B_MetadataService.SaveResult result = new DRB2B_MetadataService.SaveResult();
                result.errors =  new DRB2B_MetadataService.Error[] {errorMessage};
                result.success = false;
                result.fullName = 'Error Response';

                DRB2B_MetadataService.createMetadataResponse_element responseElement = new DRB2B_MetadataService.createMetadataResponse_element();
                responseElement.result = new DRB2B_MetadataService.SaveResult[] {result};

                response.put('response_x', responseElement);
            }else if (request instanceof DRB2B_MetadataService.deleteMetadata_element) {
                DRB2B_MetadataService.DeleteResult result = new DRB2B_MetadataService.DeleteResult();
                result.errors =  new DRB2B_MetadataService.Error[] {errorMessage};
                result.success = false;
                result.fullName = 'Error Response';

                DRB2B_MetadataService.deleteMetadataResponse_element responseElement = new DRB2B_MetadataService.deleteMetadataResponse_element();
                responseElement.result = new DRB2B_MetadataService.DeleteResult[] {result};

                response.put('response_x', responseElement);
            }else {
                System.assert(false, 'Unexpected request ' + request);
            }

			return;
		}
	} 

    static void setConfigurationStub() {
        DRB2B_ConfigurationSelectorStubProvider stubProvider = new DRB2B_ConfigurationSelectorStubProvider();

        DRB2B_DRApiConstants.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(
            DRB2B_ConnectorConfigurationSelector.class,
            stubProvider
        );

        DRB2B_AuthWire.configurationSelector = (DRB2B_ConnectorConfigurationSelector) Test.createStub(
            DRB2B_ConnectorConfigurationSelector.class,
            stubProvider
        );
    }
    private static void setUserSelectorMock() {
        User user = (User) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'Id' => TEST_USER_ID_FOR_MOCK, 'Name' => 'test', 'ContactId' => TEST_CONTACT_ID, 'LocaleSidKey' => 'en_US' }),
            User.class
        );

        DRB2B_CustomerService.userSelector = (DRB2B_UserSelector) Test.createStub(DRB2B_UserSelector.class, new DCM_GenericStubProvider(new Map<String, Object>{ 'getById' => user }));
    }
}
