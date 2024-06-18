@IsTest
private class DRB2B_WebhookExceptionTest {
    @IsTest
    @SuppressWarnings('PMD.MethodNamingConventions')
    static void webHookException_Test() {
        DRB2B_WebhookException webHookException = new DRB2B_WebhookException('TestMethod', 'Exception Test');
        System.assertEquals('TestMethod', webHookException.methodName, 'Method Name dose not match');
    }
}
