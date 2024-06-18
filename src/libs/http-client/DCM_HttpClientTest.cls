@IsTest
private class DCM_HttpClientTest {
    @IsTest
    private static void baseResponseTest() {
        //Given
        String testBody = 'testBody';
        Integer testStatusCode = 200;
        String testStatus = 'SUCCESS';
        String testHeaderKey = 'testKey';
        String testHeaderValue = 'testValue';

        HttpResponse response = new HttpResponse();
        response.setBody(testBody);
        response.setStatusCode(testStatusCode);
        response.setStatus(testStatus);
        response.setHeader(testHeaderKey, testHeaderValue);

        //When
        Test.startTest();
        DCM_HttpClient.Response testResponse = new DCM_HttpClient.BaseResponse(response);
        Test.stopTest();

        //Then
        System.assertEquals(testBody, testResponse.getBody());
        System.assertEquals(testStatusCode, testResponse.getStatusCode());
        System.assertEquals(testStatus, testResponse.getStatus());
        System.assertEquals(new List<String>{ testHeaderKey }, testResponse.getHeaderKeys());
        System.assertEquals(testHeaderValue, testResponse.getHeader(testHeaderKey));
    }

    @IsTest
    private static void baseResponseBlobBodyTest() {
        //Given
        Blob testBody = Blob.valueOf('testBodyBlob');
        HttpResponse response = new HttpResponse();
        response.setBodyAsBlob(testBody);

        //When
        Test.startTest();
        DCM_HttpClient.Response testResponse = new DCM_HttpClient.BaseResponse(response);
        Test.stopTest();

        //Then
        System.assertEquals(testBody, testResponse.getBodyAsBlob());
    }

    @IsTest
    private static void baseResponseDocumentBodyTest() {
        //Given
        String testDocumentBody = '<body></body>';
        HttpResponse response = new HttpResponse();
        response.setBody(testDocumentBody);
        Dom.Document expectedDocument = response.getBodyDocument();
        XmlStreamReader expectedReader = response.getXmlStreamReader();

        //When
        Test.startTest();
        DCM_HttpClient.Response testResponse = new DCM_HttpClient.BaseResponse(response);
        Dom.Document actualDocument = testResponse.getBodyDocument();
        XmlStreamReader actualReader = testResponse.getXmlStreamReader();
        Test.stopTest();

        //Then
        System.assert(String.isNotEmpty(actualDocument.toXmlString()));
        System.assert(String.isNotEmpty(actualReader.toString()));
        System.assertEquals(expectedDocument.toXmlString(), actualDocument.toXmlString());
        System.assertEquals(expectedReader.toString(), actualReader.toString());
    }

    @IsTest
    private static void baseResponseAsTypeTest() {
        //Given
        ResponseBodyMock expectedBody = new ResponseBodyMock('test', 1);
        HttpResponse response = new HttpResponse();
        response.setBody(JSON.serialize(expectedBody));

        //When
        Test.startTest();
        DCM_HttpClient.Response testResponse = new DCM_HttpClient.BaseResponse(response);
        ResponseBodyMock actualBody = (ResponseBodyMock) testResponse.asType(ResponseBodyMock.class);
        Test.stopTest();

        //Then
        System.assertEquals(expectedBody, actualBody);
    }

    @IsTest
    private static void baseRequestTest() {
        //Given
        String testBody = 'testBody';
        String testEndpoint = getSafeUrl();
        String testPath = 'login';
        String singleHeaderKey = 'testHeader';
        String singleHeaderValue = 'testValue';
        Map<String, String> testHeaders = new Map<String, String>{
            'Authorization' => 'Bearer 1',
            'Accept' => 'application/json'
        };
        String singleParamKey = 't';
        String singleParamValue = '18m10s';
        Map<String, String> testParams = new Map<String, String>{ 'v' => 'testId', 'source' => 'testSource' };
        String testHttpMethod = 'POST';
        String testContentType = 'application/json';
        Integer testTimeout = 1000;
        Boolean isCompressed = true;
        WireParamMock testWire = new WireParamMock();

        String expectedEndpoint = testEndpoint + '/' + testPath;

        //When
        Test.startTest();
        DCM_HttpClient.Request testRequest = new DCM_HttpClient.BaseRequest(testWire)
            .body(testBody)
            .endpoint(testEndpoint)
            .path(testPath)
            .header(singleHeaderKey, singleHeaderValue)
            .headers(testHeaders)
            .contentType(testContentType)
            .parameter(singleParamKey, singleParamValue)
            .parameters(testParams)
            .method(testHttpMethod)
            .timeout(testTimeout)
            .compressed(isCompressed);

        testRequest.fetch();
        Test.stopTest();

        //Then
        HttpRequest actualRequest = testWire.request;
        Map<String, Object> actualParameters = testWire.parameters;

        System.assertEquals(testBody, actualRequest.getBody());
        System.assertEquals(expectedEndpoint, actualRequest.getEndpoint());
        System.assertEquals(singleHeaderValue, actualRequest.getHeader(singleHeaderKey));
        System.assertEquals(testHeaders.get('Authorization'), actualRequest.getHeader('Authorization'));
        System.assertEquals(testHeaders.get('Accept'), actualRequest.getHeader('Accept'));
        System.assertEquals(testContentType, actualRequest.getHeader(DCM_HttpClient.HTTP_REQUEST_CONTENT_TYPE));
        System.assertEquals(singleParamValue, actualParameters.get(singleParamKey));
        System.assertEquals(testParams.get('v'), actualParameters.get('v'));
        System.assertEquals(testParams.get('source'), actualParameters.get('source'));
        System.assertEquals(testHttpMethod, actualRequest.getMethod());
        System.assertEquals(isCompressed, actualRequest.getCompressed());
    }

    @IsTest
    private static void baseRequestBlobBodyTest() {
        //Given
        Blob testBody = Blob.valueOf('blobBody');
        WireParamMock testWire = new WireParamMock();

        //When
        Test.startTest();
        DCM_HttpClient.Request testRequest = new DCM_HttpClient.BaseRequest(testWire).bodyAsBlob(testBody);
        testRequest.fetch();
        Test.stopTest();

        //Then
        Blob actualRequestBody = testWire.request.getBodyAsBlob();

        System.assertEquals(testBody, actualRequestBody);
    }

    @IsTest
    private static void baseRequestPathTest() {
        //Given
        List<String> testPath = new List<String>{ 'element1', 'element2', 'element3' };
        String baseUrl = getSafeUrl();
        WireParamMock testWire = new WireParamMock();
        String expectedEndpoint = getSafeUrl() + '/element1/element2/element3';

        //When
        Test.startTest();
        DCM_HttpClient.Request testRequest = new DCM_HttpClient.BaseRequest(testWire).endpoint(baseUrl).path(testPath);
        testRequest.fetch();
        Test.stopTest();

        //Then
        String actualEndpoint = testWire.request.getEndpoint();
        System.assertEquals(expectedEndpoint, actualEndpoint);
    }

    @IsTest
    private static void baseRequestBodyDocumentTest() {
        //Given
        String xml = '<body></body>';
        Dom.Document expectedDocument = new Dom.Document();
        expectedDocument.load(xml);
        WireParamMock testWire = new WireParamMock();

        //When
        Test.startTest();
        DCM_HttpClient.Request testRequest = new DCM_HttpClient.BaseRequest(testWire).bodyDocument(expectedDocument);

        testRequest.fetch();
        Test.stopTest();

        //Then
        Dom.Document actualDocument = testWire.request.getBodyDocument();
        System.assert(String.isNotEmpty(actualDocument.toXmlString()));
        System.assertEquals(expectedDocument.toXmlString(), actualDocument.toXmlString());
    }

    @IsTest
    private static void baseRequestThroughTest() {
        //Given
        WireThroughMock testMock = new WireThroughMock();

        //When
        Test.startTest();
        DCM_HttpClient.Request testRequest = DCM_HttpClient.request().through(testMock);
        testRequest.fetch();
        System.assert(testRequest != null);
        Test.stopTest();
    }

    @IsTest
    private static void baseWireMock() {
        //Given
        ResponseBodyMock responseBody = new ResponseBodyMock('1', 1);
        String baseUrl = getSafeUrl();
        String path = 'auth';
        String method = 'GET';
        Map<String, String> params = new Map<String, String>{ 'key1' => 'value1', 'key2' => 'value2' };
        String expectedEndpoint = baseUrl + '/' + path + '?key1=value1&key2=value2';
        Test.setMock(HttpCalloutMock.class, new RequestMock(responseBody, expectedEndpoint));

        //When
        Test.startTest();
        DCM_HttpClient.Request testRequest = DCM_HttpClient.request()
            .endpoint(baseUrl)
            .path(path)
            .method(method)
            .parameters(params);
        DCM_HttpClient.Response actualResponse = testRequest.fetch();
        ResponseBodyMock actualResponseBody = (ResponseBodyMock) actualResponse.asType(ResponseBodyMock.class);
        Test.stopTest();

        //Then
        System.assertEquals(200, actualResponse.getStatusCode());
        System.assertEquals(responseBody, actualResponseBody);
    }

    private static String getSafeUrl() {
        String strUrl = URL.getOrgDomainUrl().toExternalForm();
        PageReference newUrl = new PageReference(strUrl);
        newURL.setRedirect(true);
        return newURL.GetUrl();
    }

    private class ResponseBodyMock {
        public String firstField;
        public Integer secondField;

        public ResponseBodyMock(String firstField, Integer secondField) {
            this.firstField = firstField;
            this.secondField = secondField;
        }

        private Boolean equals(Object obj) {
            if (obj instanceof ResponseBodyMock) {
                ResponseBodyMock compared = (ResponseBodyMock) obj;

                return (this.firstField == compared.firstField && this.secondField == compared.secondField);
            }
            return false;
        }
    }

    private class WireParamMock extends DCM_HttpClient.Wire {
        public HttpRequest request;
        public Map<String, Object> parameters;

        public override DCM_HttpClient.Response send(HttpRequest request, Map<String, Object> parameters) {
            this.request = request;
            this.parameters = parameters;

            return null;
        }
    }

    private class WireThroughMock extends DCM_HttpClient.Wire {
        public override DCM_HttpClient.Response send(HttpRequest request, Map<String, Object> parameters) {
            DCM_HttpClient.Wire origin = this.getOrigin();
            System.assertNotEquals(null, origin);

            return null;
        }
    }

    private class RequestMock implements HttpCalloutMock {
        private ResponseBodyMock body;
        private String endpoint;

        public RequestMock(ResponseBodyMock body, String endpoint) {
            this.body = body;
            this.endpoint = endpoint;
        }

        public HttpResponse respond(HttpRequest request) {
            System.assertEquals(this.endpoint, request.getEndpoint());

            HttpResponse response = new HttpResponse();
            response.setBody(JSON.serialize(this.body));
            response.setStatusCode(200);

            return response;
        }
    }
}
