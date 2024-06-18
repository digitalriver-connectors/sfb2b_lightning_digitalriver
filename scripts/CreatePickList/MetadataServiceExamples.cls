/**
 * @description       : 
 * @author            : Arun Sood
 * @group             : 
 * @last modified on  : 04-08-2021
 * @last modified by  : Arun Sood
 * Modifications Log 
 * Ver   Date         Author      Modification
 * 1.0   09-22-2020   Arun Sood   Initial Version
**/
public with sharing class MetadataServiceExamples
{
    public static void createPicklistField(String objectName,String fieldName,String objectLabel,List<MetadataService.CustomValue> customValuesList)
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = objectName + '.' + fieldName;
        customField.label = objectLabel;
        customField.type_x = 'Picklist';
        List<MetadataService.CustomValue> values = new List<MetadataService.CustomValue>();
        MetadataService.CustomField customFieldNew = (MetadataService.CustomField) service.readMetadata('CustomField', new String[] { 'Product2.digitalriverv3__DR_Product_Country_Origin__c'}).getRecords()[0];
        System.debug('customFieldNew---->'+customFieldNew);
        for(MetadataService.CustomValue CustomValue : customFieldNew.ValueSet.valueSetDefinition.value ){
            values.add(CustomValue);
        }
        System.debug('values---->'+values);
		//For each ValueSet, we have either ValueSetValuesDefinition or ValueSettings and some other attributes
		MetadataService.ValueSetValuesDefinition valueDefinition = new MetadataService.ValueSetValuesDefinition();

        for(MetadataService.CustomValue customValues : customValuesList){
            MetadataService.CustomValue customValue1 = new MetadataService.CustomValue();
            customValue1.fullName = customValues.fullName; //API name of picklist value
            customValue1.default_x = customValues.default_x;//false;
            customValue1.description = customValues.description;
            customValue1.isActive = customValues.isActive; //false;
            customValue1.label = customValues.label;
            values.add(customValue1);
        }
		
		//It will be list of CustomValue
		valueDefinition.value = values;
		valueDefinition.sorted = false; //true;

        MetadataService.ValueSet picklistValueSet = new MetadataService.ValueSet();
        
        picklistValueSet.valueSetDefinition = valueDefinition;

		customField.valueSet = picklistValueSet ;
        List<MetadataService.UpsertResult> results =
            service.upsertMetadata(
                new MetadataService.Metadata[] { customField });
        handleUpsertResults(results[0]);
        /*List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);*/
    }
    public class MetadataServiceExamplesException extends Exception { }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
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
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }

    /**
     * Example helper method to interpret a UpsertResult, throws an exception if errors are found
     **/
    public static void handleUpsertResults(MetadataService.UpsertResult upsertResult)
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
            for(MetadataService.Error error : upsertResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!upsertResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
}