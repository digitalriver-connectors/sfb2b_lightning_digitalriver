@IsTest
private class DRB2B_CountryPicklistTest {
    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getValues_Test() {
        DRB2B_CountryPicklist countryPickList = new DRB2B_CountryPicklist();
        Test.startTest();
        Picklist.Entry allCountryValues = countryPickList.getEntry('US');
        System.assertEquals('United States', allCountryValues.label, 'Country Name Dose not Match');
        Test.stopTest();
    }
    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getISO_Test() {
        DRB2B_CountryPicklist countryPickList = new DRB2B_CountryPicklist();
        Test.startTest();
        Picklist.Entry allCountryValues = countryPickList.getEntry('United States');
        System.assertEquals('US', allCountryValues.value, 'Country ISO Code Dose not Match');
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getLabels_Test() {
        DRB2B_CountryPicklist countryPickList = new DRB2B_CountryPicklist();
        Test.startTest();
        String getLabels = countryPickList.getLabel('US');
        System.assertEquals('United States', getLabels, 'Country Name Dose not Match');
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void getEntries_Test() {
        DRB2B_CountryPicklist countryPickList = new DRB2B_CountryPicklist();
        Test.startTest();
        List<Picklist.Entry> getLabels = countryPickList.getEntries();
        System.assertNotEquals(null, getLabels);
        Test.stopTest();
    }
}
