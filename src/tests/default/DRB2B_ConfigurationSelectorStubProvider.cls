@IsTest
public with sharing class DRB2B_ConfigurationSelectorStubProvider implements System.StubProvider {
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, System.Type returnType, List<System.Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
        switch on stubbedMethodName {
            when 'getSecretKey' {
                return 'testKey';
            }
            when 'getApiEndpoint' {
                return 'https://api.digitalriver.com';
            }
            when 'getApiTimeout' {
                return 120000;
            }
            when else {
                return null;
            }
        }
    }
}
