public inherited sharing class DRB2B_ContactPointAddressSelector {

    @TestVisible
    private static final Set<String> FIELDSET = new Set<String>{
        'Country',
        'IsDefault',
        'PostalCode',
        'State',
        'City',
        'Street',
        'Name',
        'Id'
    };


    public List<ContactPointAddress> getByForeignKey(String foreignKey, Set<String> fields, Id foreignValues) {
        return (List<ContactPointAddress>) new DCM_Query(ContactPointAddress.sObjectType)
            .selectFields(new List<String>(fields))
            .addConditionEq(foreignKey, foreignValues)
            .debug()
            .run();
    }

    public List<ContactPointAddress> getAllBillingContactPointAddressByAddressType(String addressType) {
        if(DRB2B_Utility.isCountryStateEnabled()){
            FIELDSET.add('StateCode');
            FIELDSET.add('CountryCode');
        }

        Set<String> userAccountField = new Set<String>();
        userAccountField.add('AccountId');
        List<User> userDataForContactId =  new DCM_Query(User.sObjectType)
                                                .selectFields(new List<String>(userAccountField))
                                                .addConditionEq('id', UserInfo.getUserId())
                                                .run();


        return new DCM_Query(ContactPointAddress.sObjectType)
        .selectFields(new List<String>(FIELDSET))
            .addConditionEq('AddressType', addressType)
            .addConditionEq('parentId', userDataForContactId[0].AccountId)
            .setLimit(2000)
            .run();
    }
}