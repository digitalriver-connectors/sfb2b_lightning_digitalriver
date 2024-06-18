@isTest
public class DRB2B_MockResponseOrderServiceTest implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        system.debug('req.getEndpoint()::>> '+req.getEndpoint());
        string endpoint = 'https://api.digitalriver.com/refunds?orderId=260234230336&state=pending_information';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String Body;
        if(endpoint == req.getEndpoint()){
            System.assertEquals(endpoint, req.getEndpoint());
            res.setBody('{"hasMore":true,"data":[{"orderId":260234230336,"id":"id123","tokenInformation":{"token":"token1234"}}]}');
        }else{
            res.setBody(Body);
        }
        System.assertEquals('GET', req.getMethod());
        res.setStatusCode(200);
        return res;
    }
}