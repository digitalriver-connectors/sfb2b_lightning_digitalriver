global with sharing class DRB2B_PicklistMetaDataService {

    public static void createPicklistField(String objectName,String fieldName,String objectLabel,List<DRB2B_MetadataService.CustomValue> customValuesList)
    {
        DRB2B_MetadataService.MetadataPort service = createService();
        DRB2B_MetadataService.CustomField customField = new DRB2B_MetadataService.CustomField();
        customField.fullName = objectName + '.' + fieldName;
        customField.label = objectLabel;
        customField.type_x = 'Picklist';
        List<DRB2B_MetadataService.CustomValue> values = new List<DRB2B_MetadataService.CustomValue>();
        DRB2B_MetadataService.CustomField customFieldNew = (DRB2B_MetadataService.CustomField) service.readMetadata('CustomField', new String[] { objectName + '.'+fieldName}).getRecords()[0];
        System.debug('customFieldNew---->'+customFieldNew);
        for(DRB2B_MetadataService.CustomValue CustomValue : customFieldNew.ValueSet.valueSetDefinition.value ){
            values.add(CustomValue);
        }
        System.debug('values---->'+values);
		//For each ValueSet, we have either ValueSetValuesDefinition or ValueSettings and some other attributes
		DRB2B_MetadataService.ValueSetValuesDefinition valueDefinition = new DRB2B_MetadataService.ValueSetValuesDefinition();
        List<DRB2B_MetadataService.CustomValue> tempValues = new List<DRB2B_MetadataService.CustomValue>();
        tempValues.addAll(values);
        List<String> pickListValues = new List<String>();
        for(DRB2B_MetadataService.CustomValue cutomValuesOld : tempValues){
            pickListValues.add(cutomValuesOld.fullName);
        }
        System.debug('pickListValues--->'+pickListValues);
        for(DRB2B_MetadataService.CustomValue customValues : customValuesList){
            //for(DRB2B_MetadataService.CustomValue cutomValuesOld : tempValues){
               // System.debug('cutomValuesOld--->'+cutomValuesOld.fullName);
                System.debug('customValues--->'+customValues.fullName);
                System.debug('customValues--------->'+pickListValues.contains(customValues.fullName));
                if(!pickListValues.contains(customValues.fullName)){
                    //System.debug('cutomValuesOld---in>'+cutomValuesOld.fullName);
                    System.debug('customValues---In>'+customValues.fullName);
                    DRB2B_MetadataService.CustomValue customValue1 = new DRB2B_MetadataService.CustomValue();
                    customValue1.fullName = customValues.fullName; //API name of picklist value
                    customValue1.default_x = customValues.default_x;//false;
                    customValue1.description = customValues.description;
                    customValue1.isActive = customValues.isActive; //false;
                    customValue1.label = customValues.label;
                    values.add(customValue1);
                }
           // }
        }
		
		//It will be list of CustomValue
		valueDefinition.value = values;
		valueDefinition.sorted = false; //true;

        DRB2B_MetadataService.ValueSet picklistValueSet = new DRB2B_MetadataService.ValueSet();
        
        picklistValueSet.valueSetDefinition = valueDefinition;

		customField.valueSet = picklistValueSet ;
        List<DRB2B_MetadataService.UpsertResult> results =
            service.upsertMetadata(
                new DRB2B_MetadataService.Metadata[] { customField });
        handleUpsertResults(results[0]);
        /*List<DRB2B_MetadataService.SaveResult> results =
            service.createMetadata(
                new DRB2B_MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);*/
    }
    public class DRB2B_PicklistMetaDataServiceException extends Exception { }

    public static DRB2B_MetadataService.MetadataPort createService()
    {
        DRB2B_MetadataService.MetadataPort service = new DRB2B_MetadataService.MetadataPort();
        service.SessionHeader = new DRB2B_MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleSaveResults(DRB2B_MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            System.debug('saveResult.errors---->'+saveResult.errors);
            System.debug('saveResult.errors---->'+saveResult.errors);
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(DRB2B_MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new DRB2B_PicklistMetaDataServiceException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new DRB2B_PicklistMetaDataServiceException('Request failed with no specified error.');
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleDeleteResults(DRB2B_MetadataService.DeleteResult deleteResult)
    {
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(DRB2B_MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new DRB2B_PicklistMetaDataServiceException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new DRB2B_PicklistMetaDataServiceException('Request failed with no specified error.');
    }

    /**
     * Example helper method to interpret a UpsertResult, throws an exception if errors are found
     **/
    public static void handleUpsertResults(DRB2B_MetadataService.UpsertResult upsertResult)
    {
        // Nothing to see?
        if(upsertResult==null || upsertResult.success)
            return;
        // Construct error message and throw an exception
        if(upsertResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + upsertResult.fullName + '.');
            for(DRB2B_MetadataService.Error error : upsertResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new DRB2B_PicklistMetaDataServiceException(String.join(messages, ' '));
        }
        if(!upsertResult.success)
            throw new DRB2B_PicklistMetaDataServiceException('Request failed with no specified error.');
    }
}
