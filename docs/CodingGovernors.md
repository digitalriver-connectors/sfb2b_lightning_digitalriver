# Coding Governors

This is the document that provides the high-level overview of all rules that developers should respect while implementation process.

## Best Practices

### Apex

-   No SOQL or SOSL queries inside loops (CRITICAL)
-   No DML statements inside loops (CRITICAL)
-   No Async (@future, Queueable) methods inside loops (CRITICAL)
-   Never, never, never hard-code an ID inside code. (CRITICAL)
-   Avoid hitting governor limits. (CRITICAL)
-   Do not write unit tests dependent on dynamic data, configurations (FieldSets, CMD records) - mock records using ATK library (CRITICAL)
-   Use addError() to manage DML errors inside of classes and triggers. (CRITICAL)
-   Anticipate governor limit errors and add code to manage them before they happen - you cannot trap a governor limit error in a try-catch block. (CRITICAL)
-   Avoid HTTP callouts within a loop. (CRITICAL)
-   Avoid SOQL queries without WHERE clause or LIMIT (CRITICAL)
-   Use appropriate data sharing rule (with/without/inherited sharing) with the class. It's important to remember the context in which the Apex code will be executed. Do not use default sharing (CRITICAL)
-   Don't hardcode object names, field names, fieldset names, etc in the code, use SObjectType namespace to get the names. e.g. SObjectType.SampleOrder**c.Name and SObjectType.SampleOrder**c.fields.Status\_\_c.Name (CRITICAL)
-   Comment your code. (HIGH)
-   Always include try-catch block in callee class methods (Controllers, Batches, Schedules, REST Handlers, etc). (HIGH)
-   Throw your own custom exceptions.(HIGH)
-   Don't include more fields on your SOQL queries than you actually need. (HIGH)
-   When querying RecordType, never use RecordType.Name; always use RecordType.DeveloperName and RecordType.SobjectType. (MEDIUM)
-   Make error messages polite and conversation - not "Missing required field" but more like "Sorry, but you have to supply a value for the Status field to save this record." (MEDIUM)
-   Define decoupled classes (controller, service, selector) to have an ability to mock instances and write clear, understandable unit tests (HIGH)
-   Use Asynchronous Apex (Queueable) for logic that does not need to be executed synchronous.(HIGH)
-   When creating a new object in the database, the program must check if the used has CRUD/FLS permissions to insert this object. (MEDIUM)
-   Use 4 spaces for indentation. (MEDIUM)
-   Don't use names that don't mean anything to anyone but you. (TRIVIAL)
-   SOQL's keywords are upper-cased. (TRIVIAL)

##### Commons

###### DML

-   Use have to use `DMLManager` to execute all DML operations (CRITICAL)
    -   there are overloaded versions of insert/update/upsert/delete that take either a single SObject or a List
    -   `DMLManager.CRUDException` is raised for respective CRUD permission failures
    -   `DMLManager.FLSException` is raised for respective FLS permission problems

```
List<Contact> contactList = [SELECT Id, FirstName, LastName FROM Contact];

//Manipulate the contactList
...

//Instead of calling "update contactList", use:
DMLManager.updateAsUser(contactList);
```

###### Query

-   Use have to use `DCM_Query` where possible (CRITICAL)
-   By default FLS checks enforced
-   If there is a need to disable FLS checks for business calculations you can call the method `DCM_Query.enforceSecurity(false)`
-   If you disable FLS checks it is required to comment the code in the header of the class where you done that with False-Positive notes

```
new DCM_Query('User')
  .selectFields(new List<String>(fields))
  .addConditionEq('Id', userId)
  .run()[0];
```

###### `DCM_Constants`

Description:

-   The class holds sObject/Custom Settings/Custom Metadata Types related static information:
    -   business constants (DRB2B_Constants.Product2.GLOBAL_MARKET)
    -   record type names (DRB2B_Constants.Product2.DETAIL)
    -   picklist option values (DRB2B_Constants.Account.STATUS_ACTIVE)
    -   field api names (DRB2B_Constants.Account.ALLOCATED)
    -   runtime related constants (DRB2B_Constants.SortOrder.ASCENDING)
    -   base literal constants (DRB2B_Constants.Base.UNDERSCORE)

Features:

-   Reusability - one place to manage constants
-   Schema - reduce the amount of code duplicates to get object/field name
-   Performance - information accessed by properties, Apex doesn't initialize all static information ahead of time - only when accessed

Convention:

-   Every type (sObject/Custom Settings/Custom Metadata Types) has its own inner class as a holder of the related constants
-   sObject/Custom Settings must inherit SObjectType inner class
-   Custom Metadata Type must inherit CustomMetadataType inner class
-   Define any static literal constant without get; property
-   Define any schema/dynamic constant with get; property to enable lazy loading
-   Define parent-related fields with three steps - <parent*name>\_REFERENCE, <parent_name>\_REFERENCE_PERIOD, <parent_name>*<field_name>, see the Contact class and Account reference
-   Define child relationship name as a static literal constant (Constants.Contact.ACCOUNTS)
-   Define an instance of the inner class holder as a static property of the Constants class using get; public and set; private properties

###### ATK

-   Use ATK library to generate record for unit test

```
ATK.SaveResult result = ATK.prepare(Account.SObjectType, 200)
    .field(Account.Name).index('Name-{0000}')
    .withChildren(Contact.SObjectType, Contact.AccountId, 400)
        .field(Contact.LastName).index('Name-{0000}')
        .field(Contact.Email).index('test.user+{0000}@email.com')
        .field(Contact.MobilePhone).index('+86 186 7777 {0000}')
        .withChildren(OpportunityContactRole.SObjectType, OpportunityContactRole.ContactId, 400)
            .field(OpportunityContactRole.Role).repeat('Business User', 'Decision Maker')
            .withParents(Opportunity.SObjectType, OpportunityContactRole.OpportunityId, 400)
                .field(Opportunity.Name).index('Name-{0000}')
                .field(Opportunity.ForecastCategoryName).repeat('Pipeline')
                .field(Opportunity.Probability).repeat(0.9, 0.8)
                .field(Opportunity.StageName).repeat('Prospecting')
                .field(Opportunity.CloseDate).addDays(Date.newInstance(2020, 1, 1), 1)
                .field(Opportunity.TotalOpportunityQuantity).add(1000, 10)
                .withParents(Account.SObjectType, Opportunity.AccountId)
    .also(4)
    .withChildren(Order.SObjectType, Order.AccountId, 400)
        .field(Order.Name).index('Name-{0000}')
        .field(Order.EffectiveDate).addDays(Date.newInstance(2020, 1, 1), 1)
        .field(Order.Status).repeat('Draft')
        .withParents(Contact.SObjectType, Order.BillToContactId)
        .also()
        .withParents(Opportunity.SObjectType, Order.OpportunityId)
    .save();
```

###### Logger

-   Use `DCM_Logger` to log messages and exceptions (CRITICAL)
-   It is mandatory to log all exceptions

###### HTTP Client

-   Use `DCM_HttpClient` for all HTTP requests in Apex

```
DCM_HttpClient.request()
  .through(new DRB2B_AuthWire())
  .through(new DRB2B_GenericErrorWire())
  .endpoint(DRB2B_DRApiConstants.END_POINT)
  .headers(DRB2B_DRApiConstants.DEFAULT_HEADERS)
  .timeout(DRB2B_DRApiConstants.REQUEST_TIMEOUT);
  .path(DRB2B_DRApiConstants.CREATE_CUSTOMER_PATH)
  .method(DCM_HttpClient.POST)
  .body(JSON.serialize(customerRequestModel));
```
