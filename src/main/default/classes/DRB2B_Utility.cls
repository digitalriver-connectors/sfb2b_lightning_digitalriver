public without sharing class DRB2B_Utility {
    public static Map<String, String> drConnectorConfigMap = getDRConnectorConfigMap();

    @TestVisible
    private static final DCM_Logger logger = DCM_Logger.getInstance(
        DRB2B_Constants.Module.DigitalRiver_STATIC_RESOURCE
    );

    /**
     * @description
     * @author Arun Sood | 04-06-2021
     * @return Map<String, String>
     **/
    public static Map<String, String> getDRapplicationConfigMap() {
        Map<String, String> drapplicationConfigMap = new Map<String, String>();
        List<DR_Application_Configuration__mdt> drapplicationConfigList = [
            SELECT Id, DeveloperName, key__c
            FROM DR_Application_Configuration__mdt
            LIMIT 200
        ];
        if (drapplicationConfigList.size() > 0) {
            for (DR_Application_Configuration__mdt drapplicationConfig : drapplicationConfigList) {
                drapplicationConfigMap.put(drapplicationConfig.DeveloperName, drapplicationConfig.Key__c);
            }
        }
        return drapplicationConfigMap;
    }

    /**
     * @description
     * @author Arun Sood | 04-07-2021
     * @param url
     * @param httpMethod
     * @param httpBody
     * @param httpHeaders
     * @return HttpResponse
     **/
    public static HttpResponse getHttpResponse(
        String url,
        String httpMethod,
        String httpBody,
        Map<String, String> httpHeaders
    ) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // Complete URL
        request.setEndpoint(url);
        request.setMethod(httpMethod);
        //Integer callOutReadTimeout = String.isBlank(drConnectorConfigMap.get('DR_Callout_Time')) ? DEFAULT_CALLOUT_READ_TIMEOUT : Integer.valueOf(drConnectorConfigMap.get('DR_Callout_Time'));
        //request.setTimeout(callOutReadTimeout);

        // Add Default Http Headers to Request
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cache-Control', 'no-cache');

        // Override or Add Http Request Headers from Calling method
        if (null != httpHeaders && !httpHeaders.isEmpty()) {
            for (String headerName : httpHeaders.keySet()) {
                request.setHeader(headerName, httpHeaders.get(headerName));
            }
        }

        // Set Body of the Request
        if (String.isNotBlank(httpBody)) {
            request.setBody(httpBody);
        }

        // Get the Response
        HttpResponse response = http.send(request);
        return response;
    }

    /**
     * @description
     * @author Arun Sood | 04-07-2021
     * @return Map<String, String>
     **/
    public static Map<String, String> getDRConnectorConfigMap() {
        Map<String, String> drConnectorConfigMap = new Map<String, String>();
        List<DR_Connector_Configuration__mdt> drConnectorConfigList = [
            SELECT Id, DeveloperName, Key__c
            FROM DR_Connector_Configuration__mdt
            LIMIT 200
        ];
        if (drConnectorConfigList.size() > 0) {
            for (DR_Connector_Configuration__mdt drConnectorConfig : drConnectorConfigList) {
                drConnectorConfigMap.put(drConnectorConfig.DeveloperName, drConnectorConfig.Key__c);
            }
        }
        return drConnectorConfigMap;
    }

    public static string nameSpace() {
        return DCM_IdUtils.class.getName().substringBefore('DCM_IdUtils').removeEnd('.');
    }

    public static string nameSpacePrefix() {
        return nameSpace() + '__';
    }

    public static String modifyJSON(String jsonData, Map<String, String> replacements) {
        // Regex to match the start of the line and the key surrounded by quotes and ending with a colon
        // Regular Expression Used --> (?im)^\s*"{0}"\s*:
        // Example: (?im)^\s*"currency"\s*:
        // (?im) --> makes the regex case insensitive and multi-line mode
        // ^ --> Beginning of line
        // \s --> White space character [ \t\n\x0B\f\r]
        // * --> Matches between zero and unlimited times
        String regexFormat = '(?im)^\\s*"{0}"\\s*:';

        // Replacement format of the new key surrounded by
        // quotes and ending with a colon
        String replacementFormat = '"{0}" :';

        // Since our JSON can come in a format the endpoint wants,
        // we need to format it to a standard we know and can handle
        String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(jsonData));

        // Iterate over all the keys we want to replace
        for (String key : replacements.keySet()) {
            // Generate our regex based on the key
            String regex = String.format(regexFormat, new List<String>{ key });

            // Generate our replacement
            String replacement = String.format(replacementFormat, new List<String>{ replacements.get(key) });

            // Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
        // Send the Formatted Pretty JSON
        formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(formattedJSON));

        return formattedJSON;
    }

    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    //This method will check if country state is enabled in org or not
    public static boolean isCountryStateEnabled() {
        return ContactPointAddress.getSobjectType().getDescribe().fields.getMap().keySet().contains('statecode');
    }
    public static String generateUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid =
            h.SubString(0, 8) +
            '-' +
            h.SubString(8, 12) +
            '-' +
            h.SubString(12, 16) +
            '-' +
            h.SubString(16, 20) +
            '-' +
            h.substring(20);
        return guid;
    }
    public static String getUserIpAddress() {
        String ip = '';

        try {
            AuthSession session = [
                SELECT Id, SourceIp
                FROM AuthSession
                WHERE UsersId = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            ip = session.SourceIp == '::' ? '' : session.SourceIp;
        } catch (Exception e) {
            logger.error(e);
        }

        return ip;
    }
    public static String getStaticResourceRelativePath(String staticResourceName) {
        String methodName = 'getStaticResourceRelativePath';
        String staticResourcePath = '';
        try {
            if (String.isNotBlank(staticResourceName)) {
                List<StaticResource> staticResourceList = [
                    SELECT Id, NamespacePrefix, Name, SystemModstamp
                    FROM StaticResource
                    WHERE Name = :staticResourceName
                ];
                if (staticResourceList != null && staticResourceList.size() > 0) {
                    String staticResourceNamespace = staticResourceList.get(0).NamespacePrefix;
                    if (String.isBlank(staticResourceNamespace)) {
                        staticResourceNamespace = '';
                    } else {
                        staticResourceNamespace = staticResourceNamespace + '__';
                    }
                    staticResourcePath =
                        '/resource/' +
                        staticResourceList.get(0).SystemModstamp.getTime() +
                        '/' +
                        staticResourceNamespace +
                        staticResourceName;
                } else {
                    logger.error(
                        'No Read Access on Static Resource Object OR Static Resource does not exist with name'
                    );
                }
            } else {
                logger.info('DRB2B_Utility Empty staticResourceName Parameter');
            }
        } catch (Exception e) {
            staticResourcePath = '';
            logger.error(e);
        } finally {
            logger.flush();
        }
        return staticResourcePath;
    }
}
