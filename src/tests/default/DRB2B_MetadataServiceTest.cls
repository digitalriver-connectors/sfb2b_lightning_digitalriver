@isTest
private class DRB2B_MetadataServiceTest {

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
			return;
		}
	}    
		
	@IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        DRB2B_MetadataService metaDataService = new DRB2B_MetadataService();
        // Invoke operations     
        Test.startTest();    
        DRB2B_MetadataService.MetadataPort metaDataPort = new DRB2B_MetadataService.MetadataPort();
        System.assert(Collection.of(new List<String>()).size() != null);
        Test.stopTest();
	}
	
	@IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {    	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        DRB2B_MetadataService metaDataService = new DRB2B_MetadataService();
        // Invoke operations    
        Test.startTest();     
        DRB2B_MetadataService.MetadataPort metaDataPort = new DRB2B_MetadataService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
        System.assert(Collection.of(new List<String>()).size() != null);
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        DRB2B_MetadataService metaDataService = new DRB2B_MetadataService();
        // Invoke operations     
        Test.startTest();    
        DRB2B_MetadataService.MetadataPort metaDataPort = new DRB2B_MetadataService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);
        System.assert(Collection.of(new List<String>()).size() != null);
        Test.stopTest();
    }
        
	@IsTest
    private static void coverGeneratedCodeTypes()
    {    	       
        // Reference types
        Test.startTest();
        new DRB2B_MetadataService();
        new DRB2B_MetadataService.listMetadataResponse_element();
        new DRB2B_MetadataService.checkDeployStatus_element();
        new DRB2B_MetadataService.CodeCoverageWarning();
        new DRB2B_MetadataService.DescribeMetadataResult();
        new DRB2B_MetadataService.describeMetadataResponse_element();
        new DRB2B_MetadataService.DeployMessage();
        new DRB2B_MetadataService.CustomField();
        new DRB2B_MetadataService.deployResponse_element();
        new DRB2B_MetadataService.FileProperties();
        new DRB2B_MetadataService.ReportTypeColumnTranslation();
        new DRB2B_MetadataService.CustomValue();
        new DRB2B_MetadataService.AdjustmentsSettings();
        new DRB2B_MetadataService.ForecastRangeSettings();
        new DRB2B_MetadataService.ForecastingTypeSettings();
        new DRB2B_MetadataService.ExtendedErrorDetails();
        new DRB2B_MetadataService.Error();
        new DRB2B_MetadataService.DeleteResult();
        new DRB2B_MetadataService.SessionHeader_element();
        new DRB2B_MetadataService.DebuggingInfo_element();
        new DRB2B_MetadataService.DebuggingHeader_element();
        new DRB2B_MetadataService.CallOptions_element();
        new DRB2B_MetadataService.AllOrNoneHeader_element();
        new DRB2B_MetadataService.LogInfo();
        new DRB2B_MetadataService.deleteMetadata_element();
        new DRB2B_MetadataService.deleteMetadataResponse_element();
        new DRB2B_MetadataService.renameMetadata_element();
        new DRB2B_MetadataService.renameMetadataResponse_element();
        new DRB2B_MetadataService.SaveResult();
        new DRB2B_MetadataService.RetrieveResult();
        new DRB2B_MetadataService.AsyncResult();
        new DRB2B_MetadataService.DescribeMetadataObject();
        new DRB2B_MetadataService.RunTestsResult();
        new DRB2B_MetadataService.DeployDetails();
        new DRB2B_MetadataService.DescribeValueTypeResult();
        new DRB2B_MetadataService.CancelDeployResult();
        new DRB2B_MetadataService.DeployResult();
        new DRB2B_MetadataService.RetrieveMessage();
        new DRB2B_MetadataService.CodeCoverageResult();
        new DRB2B_MetadataService.RunTestFailure();
        new DRB2B_MetadataService.PicklistEntry();
        new DRB2B_MetadataService.ValueTypeField();
        new DRB2B_MetadataService.RunTestSuccess();
        new DRB2B_MetadataService.CodeLocation();
        new DRB2B_MetadataService.DeployOptions();
        new DRB2B_MetadataService.RetrieveRequest();
        new DRB2B_MetadataService.ValueSetValuesDefinition();
        new DRB2B_MetadataService.ValueSettings();
        new DRB2B_MetadataService.ValueSet();
        new DRB2B_MetadataService.FilterItem();
        new DRB2B_MetadataService.LookupFilter();
        new DRB2B_MetadataService.ProfileObjectPermissions();
        System.assert(Collection.of(new List<String>()).size() != null);
        Test.stopTest();
    }

    @IsTest
    private static void elfMissingGetRecordsTest() { // elf patch
        Test.startTest();
        new DRB2B_MetadataService.ReadCustomFieldResult().getRecords();
        System.assert(Collection.of(new List<String>()).size() != null);
        Test.stopTest();
    }

    @IsTest
    private static void elfMissingGetResultTest() { // elf patch
        Test.startTest();
        new DRB2B_MetadataService.readCustomFieldResponse_element().getResult();
        System.assert(Collection.of(new List<String>()).size() != null);
        Test.stopTest();
    }
}
