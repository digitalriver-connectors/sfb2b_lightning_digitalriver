public without sharing class DCM_HttpClient {
    public static final String HTTP_REQUEST_KEY_VALUE_SEPARATOR = '=';
    public static final String HTTP_REQUEST_PARAMETER_SEPARATOR = '&';
    public static final String HTTP_REQUEST_PARAMETER_PREFIX = '?';
    public static final String HTTP_REQUEST_CONTENT_TYPE = 'Content-Type';
    public static final String ENCODING_SCHEME = 'UTF-8';
    public static final String PATH_SEPARATOR = '/';

    public static final String POST = 'POST';
    public static final String GET = 'GET';
    public static final String PUT = 'PUT';
    public static final String REMOVE = 'DELETE';

    private CommercePayments.PaymentsHttp paymentHttp;

    public void setCalle(CommercePayments.PaymentsHttp http) {
        this.paymentHttp = http;
    }

    public static Request request() {
        return new BaseRequest();
    }

    public static Request paymentRequest() {
        return new BaseRequest(new PaymentWire());
    }

    public interface Request {
        HttpRequest getOrigin();
        Request body(String body);
        Request bodyAsBlob(Blob body);
        Request bodyDocument(Dom.Document document);
        Request clientCertificateName(String certDevName);
        Request compressed(Boolean isCompressed);
        Request endpoint(String endpoint);
        Request path(String path);
        Request path(List<String> path);
        Request header(String key, String value);
        Request headers(Map<String, String> headers);
        Request contentType(String contentType);
        Request parameter(String key, Object value);
        Request parameters(Map<String, Object> parameters);
        Request method(String method);
        Request timeout(Integer timeout);
        Request through(Wire wire);

        HttpRequest compose();
        Response fetch();
    }

    public interface Response {
        String getBody();
        Blob getBodyAsBlob();
        Dom.Document getBodyDocument();
        String getHeader(String key);
        List<String> getHeaderKeys();
        String getStatus();
        Integer getStatusCode();
        XmlStreamReader getXmlStreamReader();
        Object asType(Type jsonType);
        HttpResponse getHttpResponse();
    }

    public abstract class Wire {
        private Wire origin;

        public abstract Response send(HttpRequest request, Map<String, Object> parameters);

        protected Wire setOrigin(Wire origin) {
            this.origin = origin;
            return this;
        }

        protected Wire getOrigin() {
            return this.origin;
        }
    }

    public without sharing virtual class BaseResponse implements Response {
        private HttpResponse response;

        public BaseResponse(HttpResponse response) {
            this.response = response;
        }

        public virtual String getBody() {
            return this.response.getBody();
        }

        public virtual Blob getBodyAsBlob() {
            return this.response.getBodyAsBlob();
        }

        public virtual Dom.Document getBodyDocument() {
            return this.response.getBodyDocument();
        }

        public virtual String getHeader(String key) {
            return this.response.getHeader(key);
        }

        public virtual List<String> getHeaderKeys() {
            return this.response.getHeaderKeys();
        }

        public virtual String getStatus() {
            return this.response.getStatus();
        }

        public virtual Integer getStatusCode() {
            return this.response.getStatusCode();
        }

        public virtual XmlStreamReader getXmlStreamReader() {
            return this.response.getXmlStreamReader();
        }

        public virtual Object asType(Type jsonType) {
            return JSON.deserialize(this.getBody(), jsonType);
        }

        public virtual HttpResponse getHttpResponse() {
            return this.response;
        }
    }

    public without sharing virtual class BaseRequest implements Request {
        @TestVisible
        private HttpRequest httpRequest = new HttpRequest();

        @TestVisible
        private Map<String, Object> parameters = new Map<String, Object>();

        @TestVisible
        private List<String> pathElements = new List<String>();

        private Wire baseWire;

        public BaseRequest(Wire wire) {
            this.baseWire = wire;
        }

        public BaseRequest() {
            this(new BaseWire());
        }

        public virtual HttpRequest getOrigin() {
            return this.httpRequest;
        }

        public virtual Request body(String body) {
            this.httpRequest.setBody(body);

            return this;
        }

        public virtual Request bodyAsBlob(Blob body) {
            this.httpRequest.setBodyAsBlob(body);

            return this;
        }

        public virtual Request bodyDocument(Dom.Document document) {
            this.httpRequest.setBodyDocument(document);

            return this;
        }

        public virtual Request clientCertificateName(String certDevName) {
            this.httpRequest.setClientCertificateName(certDevName);

            return this;
        }

        public virtual Request compressed(Boolean isCompressed) {
            this.httpRequest.setCompressed(isCompressed);

            return this;
        }

        public virtual Request endpoint(String endpoint) {
            this.httpRequest.setEndpoint(endpoint);

            return this;
        }

        public virtual Request path(String path) {
            this.pathElements.add(path);

            return this;
        }

        public virtual Request path(List<String> path) {
            this.pathElements.addAll(path);

            return this;
        }

        public virtual Request header(String key, String value) {
            this.httpRequest.setHeader(key, value);

            return this;
        }

        public virtual Request headers(Map<String, String> headers) {
            if (!DCM_BaseUtilities.isNullOrEmpty(headers)) {
                for (String key : headers.keySet()) {
                    this.httpRequest.setHeader(key, headers.get(key));
                }
            }

            return this;
        }

        public virtual Request contentType(String contentType) {
            this.httpRequest.setHeader(HTTP_REQUEST_CONTENT_TYPE, contentType);

            return this;
        }

        public virtual Request parameter(String key, Object value) {
            this.parameters.put(key, value);

            return this;
        }

        public virtual Request parameters(Map<String, Object> parameters) {
            this.parameters.putAll(parameters);

            return this;
        }

        public virtual Request method(String method) {
            this.httpRequest.setMethod(method);

            return this;
        }

        public Request timeout(Integer timeout) {
            this.httpRequest.setTimeout(timeout);

            return this;
        }

        public virtual Request through(Wire wire) {
            this.baseWire = wire.setOrigin(this.baseWire);

            return this;
        }

        public virtual HttpRequest compose() {
            if (!pathElements.isEmpty() && !String.isEmpty(this.httpRequest.getEndpoint())) {
                String endpoint = this.httpRequest.getEndpoint();
                endpoint = (!endpoint.endsWith(PATH_SEPARATOR)) ? endpoint + PATH_SEPARATOR : endpoint;
                endpoint += String.join(this.pathElements, PATH_SEPARATOR);

                this.httpRequest.setEndpoint(endpoint);
            }

            return this.httpRequest;
        }

        public virtual Response fetch() {
            if (!pathElements.isEmpty() && !String.isEmpty(this.httpRequest.getEndpoint())) {
                String endpoint = this.httpRequest.getEndpoint();
                endpoint = (!endpoint.endsWith(PATH_SEPARATOR)) ? endpoint + PATH_SEPARATOR : endpoint;
                endpoint += String.join(this.pathElements, PATH_SEPARATOR);

                this.httpRequest.setEndpoint(endpoint);
            }
            return this.baseWire.send(this.httpRequest, this.parameters);
        }
    }

    private virtual class BaseWire extends Wire {
        public override Response send(HttpRequest request, Map<String, Object> parameters) {
            if (!DCM_BaseUtilities.isNullOrEmpty(parameters) && !parameters.isEmpty()) {
                request.setEndpoint(this.addParametersToEndpoint(request.getEndpoint(), parameters));
            }

            return send(request);
        }

        private String addParametersToEndpoint(String baseUrl, Map<String, Object> parameters) {
            List<String> pairs = new List<String>();
            for (String key : parameters.keySet()) {
                String encodedKey = EncodingUtil.urlEncode(key, ENCODING_SCHEME);
                String encodedValue = EncodingUtil.urlEncode(String.valueOf(parameters.get(key)), ENCODING_SCHEME);
                pairs.add(encodedKey + HTTP_REQUEST_KEY_VALUE_SEPARATOR + encodedValue);
            }

            return baseUrl + HTTP_REQUEST_PARAMETER_PREFIX + String.join(pairs, HTTP_REQUEST_PARAMETER_SEPARATOR);
        }

        protected virtual Response send(HttpRequest request) {
            return new BaseResponse(new Http().send(request));
        }
    }

    public without sharing class PaymentWire extends BaseWire {
        protected override Response send(HttpRequest request) {
            return new BaseResponse(new CommercePayments.PaymentsHttp().send(request));
        }
    }
}
