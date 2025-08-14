/**
 * Created by chana.landau on 03/03/2022.
 */

global class CalloutService {

    //CONSTANTS
    private static final String MAP_DELIMITER = '_';
    private static final String ORG_NAME_SERVICE_DELIMITER = ':';
    private static final String ORG_NAME_KEY = 'ORG_NAME';
    private static final String IS_ACTIVE_KEY = 'IS_ACTIVE';

    private static CalloutService thisObj;

    private String orgName;
    private Boolean isActive;
    private Map<String, ServiceSetting> servicesMap = new Map<String, ServiceSetting>();
    private Map<String, ServiceSettings__mdt> serviceSettingsMap = new Map<String, ServiceSettings__mdt>();
    private Map<String, ServiceEnvVar__mdt> serviceEnvVarMap = new Map<String, ServiceEnvVar__mdt>();
    private List<ServiceEndpoint__mdt> serviceEndpointList = new List<ServiceEndpoint__mdt>();
    private Set<String> serviceNameSet = new Set<String>();
    private Map<String, String> contentTypeMap = new Map<String, String>{
            'json' => 'application/json',
            'xml' => 'application/xml',
            'text' => 'text/plain',
            'form' => 'application/x-www-form-urlencoded'
    };
    global Map<String, String> headerMap;

    global static CalloutService getInstance() {
        if (thisObj == null) {
            thisObj = new CalloutService();
        }
        return thisObj;
    }

    private CalloutService() {
        getServiceSettings();
        if (isActive()) {
            getServiceEnvVars();
            getServiceEndpoints();
            populateServiceMap();
        }
    }

    //GLOBAL METHODS
    global ServiceSetting getServiceSetting(String serviceName, String methodName) {
        return this.servicesMap.get(serviceName + MAP_DELIMITER + methodName);
    }

    global ServiceSetting init(String serviceName, String methodName) {
        ServiceSetting settings = this.servicesMap.get(serviceName + MAP_DELIMITER + methodName);
        System.debug('### mdt settings: ' + settings);
        setAuthorization(settings.username, settings.password);
        return settings;
    }

    private void setAuthorization(String username, String password){
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        addHeader('Authorization', authorizationHeader);
    }

    global void addHeader(String key, String value){
        if(this.headerMap == null) this.headerMap = new Map<String, String>();
        this.headerMap.put(key, value);
    }

    global String getOrgName() {
        if (orgName != null) {
            return orgName;
        } else {
            if (this.serviceSettingsMap.get(ORG_NAME_KEY) != null
                    || this.serviceSettingsMap.get(ORG_NAME_KEY).Value__c != null) {
                orgName = this.serviceSettingsMap.get(ORG_NAME_KEY).Value__c;
            } else {
                throw new CalloutServiceException('No ORG_NAME record found for object ServiceSettings__mdt');
            }
        }
        System.debug('### mdt orgName: ' + orgName);
        return orgName;
    }

    global Boolean isActive() {
        if (isActive != null) {
            return isActive;
        } else {
            if (this.serviceSettingsMap.get(IS_ACTIVE_KEY) != null
                    || this.serviceSettingsMap.get(IS_ACTIVE_KEY).Value__c != null) {
                isActive = this.serviceSettingsMap.get(IS_ACTIVE_KEY).Value__c.toLowerCase() == 'true' ? true : false;
            } else {
                throw new CalloutServiceException('No IS_ACTIVE record found for object ServiceSettings__mdt');
            }
        }
        return isActive;
    }

    global HTTPResponse calloutService(String serviceName, String methodName, String payload) {
        ServiceSetting calloutSetting = getServiceSetting(serviceName, methodName);
        system.debug('@@calloutSetting'+calloutSetting);
        system.debug('@@payload'+payload);
        return calloutService(calloutSetting, payload);
    }

    global HTTPResponse calloutService(ServiceSetting calloutSetting, String payload) {
        if (calloutSetting == null) {
            throw new CalloutServiceException('calloutSetting can\'t be null');
        }

        if (payload == null) {
            throw new CalloutServiceException('payload can\'t be null');
        }

        HttpRequest req = new HttpRequest();
        Boolean isGet = calloutSetting.methodType == 'GET' ? true : false;
        req.setMethod(calloutSetting.methodType);

        if (isGet) {
            req.setEndpoint(calloutSetting.url + payload);
        } else {
            if (calloutSetting.isCompressed) {
                req.setCompressed(true);
            }
            String contentTypeFormatted = this.contentTypeMap.get(calloutSetting.contentType);
            if (contentTypeFormatted != null) {
                req.setHeader('Content-Type', contentTypeFormatted);
                System.debug(LoggingLevel.INFO, 'req headers : ' + 'Content-Type' + ':' + req.getHeader('Content-Type'));
            }
            req.setEndpoint(calloutSetting.url);
            req.setBody(payload);
            system.debug('@@req'+req);

        }

        // Specify the required user name and password to access the endpoint
        // As well as the header and header information
        if (calloutSetting.username != null && calloutSetting.username != '' &&
                calloutSetting.password != null && calloutSetting.password != '') {

            String username = calloutSetting.username;
            system.debug('@@username'+username);
            String password = calloutSetting.password;
            system.debug('@@password'+password);

            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' +
                    EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            System.debug(LoggingLevel.INFO, 'req headers : ' + 'Authorization' + ':' + req.getHeader('Authorization'));
        }
        system.debug('@@token'+calloutSetting.token);
        system.debug('@@tokenHeader'+calloutSetting.tokenHeader);

        if (!String.isBlank(calloutSetting.tokenHeader) && !String.isBlank(calloutSetting.token)) {
            String token = calloutSetting.token;
            String tokenHeader = calloutSetting.tokenHeader;


            req.setHeader(tokenHeader, token);
            System.debug(LoggingLevel.INFO, 'req headers : ' + tokenHeader + ':' + req.getHeader(tokenHeader));
        }

        //CUSTOM HEADERS
        if (calloutSetting.headers != null) {
            Map<String, String> headersMap = populateHeaders(calloutSetting);
            for (String key : headersMap.keySet()) {
                req.setHeader(key, headersMap.get(key));
                System.debug(LoggingLevel.INFO, 'req headers : ' + key + ':' + headersMap.get(key));
            }
        }

        //Set timeout
        if (calloutSetting.timeout != null && calloutSetting.timeout >= 1000) {
            req.setTimeout(calloutSetting.timeout);
        }

        // Create a new http object to send the request object
        // A response object is generated as a result of the request
        System.debug('@@@req.getEndpoint()'+req.getEndpoint());
        System.debug('@@@req.getBody()'+req.getBody());
        System.debug('@@@req.getMethod()'+req.getMethod());


        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('@@@REד'+res);
        //System.debug(LoggingLevel.INFO, 'RESPONSE : ' + res.getBody());
        return res;
    }

    //BUILDERS
    private void populateServiceMap() {
        for (ServiceEndpoint__mdt serviceEndpointItem : this.serviceEndpointList) {
            //if no setting Env_Settings found for this method settings
            try {
                ServiceEnvVar__mdt serviceEnvVarItem = this.serviceEnvVarMap.get(serviceEndpointItem.ServiceName__c);
                ServiceSetting mtdSettings = setServiceSettingItem(serviceEnvVarItem, serviceEndpointItem);
                String methodKey = serviceEndpointItem.ServiceName__c + MAP_DELIMITER + serviceEndpointItem.DeveloperName;
                this.servicesMap.put(methodKey, mtdSettings);
                System.debug(LoggingLevel.INFO, 'methodKey: ' + methodKey);
            } catch (Exception ex) {
                System.debug(LoggingLevel.WARN, 'issue in populating : \'' + serviceEndpointItem.Label + '\' service');
                System.debug(LoggingLevel.WARN, ex);
            }
        }
        //System.debug(LoggingLevel.INFO, 'servicesMap: ' + servicesMap);
    }

    private ServiceSetting setServiceSettingItem(ServiceEnvVar__mdt serviceEnvVarItem, ServiceEndpoint__mdt serviceEndpointItem) {
        ServiceSetting srvSetting = new ServiceSetting();
        srvSetting.serviceName = serviceEndpointItem.ServiceName__c;
        srvSetting.methodName = serviceEndpointItem.DeveloperName;
        srvSetting.methodType = serviceEndpointItem.MethodType__c;
        srvSetting.url = serviceEnvVarItem.Domain__c + serviceEndpointItem.ServiceEndpoint__c;
        srvSetting.username = serviceEnvVarItem.Username__c;
        srvSetting.password = serviceEnvVarItem.Password__c;
        srvSetting.token = serviceEnvVarItem.Token__c;
        srvSetting.tokenHeader = serviceEnvVarItem.TokenHeader__c;
        srvSetting.isCompressed = serviceEnvVarItem.isCompressed__c;
        srvSetting.timeout = Integer.valueOf(serviceEnvVarItem.Timeout__c);
        srvSetting.contentType = serviceEndpointItem.ContentType__c;
        srvSetting.certificateName = serviceEnvVarItem.CertificateName__c;
        srvSetting.certificate = serviceEnvVarItem.Certificate__c;
        srvSetting.headers = serviceEndpointItem.Headers__c;
        return srvSetting;
    }

    private Map<String,String> populateHeaders(ServiceSetting serviceSetting) {
        String stringHeaders = serviceSetting.headers;
        Map<String,Object> jsonMap = new Map<String,Object>();
        Map<String,String> headersMap = new Map<String,String>();

        if (String.isNotBlank(stringHeaders)) {
            jsonMap = (Map<String,Object>)JSON.deserializeUntyped(stringHeaders);
            for (String key : jsonMap.keySet()) {
                if (String.isNotBlank(key) && jsonMap.get(key) != null) {
                    headersMap.put(key, String.valueOf(jsonMap.get(key)));
                }
            }
        } else {
            throw new CalloutServiceException('headers in service endpoint is malformd');
        }
        return headersMap;
    }

    //GET CONFIG OBJECTS DATA
    private void getServiceSettings() {
        List<ServiceSettings__mdt> serviceSettingsList = [SELECT DeveloperName, Value__c FROM ServiceSettings__mdt];
        if (serviceSettingsList.isEmpty()) {
            throw new CalloutServiceException('Missing base settings in ServiceSettings__mdt object');
        }
        this.serviceSettingsMap = listToMap(serviceSettingsList);
        //System.debug(LoggingLevel.INFO, 'serviceSettingsMap : ' + serviceSettingsMap);
    }

    private void getServiceEnvVars() {
        String orgNameExp = getOrgName() + '%';
        List<ServiceEnvVar__mdt> serviceEnvVarList = [
                SELECT IsCompressed__C, Label, Domain__c, Username__c, Password__c,
                        Token__c, CertificateName__c, TokenHeader__c, Timeout__c,Certificate__c
                FROM ServiceEnvVar__mdt
                WHERE Label LIKE :orgNameExp
        ];

        if (serviceEnvVarList.isEmpty()) {
            throw new CalloutServiceException('No services found for ServiceSettings__mdt.ORG_NAME : ' + getOrgName());
        }
        this.serviceEnvVarMap = listToMap(serviceEnvVarList);
        //System.debug(LoggingLevel.INFO, 'serviceEnvVarMap : ' + serviceEnvVarMap);


        for (ServiceEnvVar__mdt serviceItem : serviceEnvVarList) {
            this.serviceNameSet.add(getServiceName(serviceItem.Label));
        }
        //System.debug(LoggingLevel.INFO, 'serviceNameSet : ' + serviceNameSet);
    }

    private void getServiceEndpoints() {
        this.serviceEndpointList = [
                SELECT Label, ContentType__C, DeveloperName, ServiceEndpoint__c, MethodType__c, ServiceName__c,Headers__c
                FROM ServiceEndpoint__mdt
                WHERE ServiceName__c IN:serviceNameSet AND isActive__c = true
        ];

        if (this.serviceEndpointList.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'No ServiceEndpoint__mdt records found');
        }
        //System.debug(LoggingLevel.INFO, 'serviceEndpointList : ' + serviceEndpointList);
    }

    //SERVICE OBJECTS
    global Class ServiceSetting {
        public String serviceName;
        public String methodName;
        public String methodType;
        public String url;
        public String username;
        public String password;
        public String headers;
        public String token;
        public String tokenHeader;
        public Integer timeout;
        public Boolean isCompressed;
        public String contentType;
        public String certificate;
        public String certificateName;
        public ServiceSetting() {
        }
    }

    //CONVERTERS
    private Map<String, ServiceSettings__mdt> listToMap(List<ServiceSettings__mdt> obList) {
        Map<String, ServiceSettings__mdt> newMap = new Map<String, ServiceSettings__mdt>();
        for (ServiceSettings__mdt ob : obList) {
            newMap.put(ob.DeveloperName, ob);
        }
        return newMap;
    }

    private Map<String, ServiceEnvVar__mdt> listToMap(List<ServiceEnvVar__mdt> obList) {
        Map<String, ServiceEnvVar__mdt> newMap = new Map<String, ServiceEnvVar__mdt>();
        for (ServiceEnvVar__mdt ob : obList) {
            newMap.put(getServiceName(ob.Label), ob);
        }
        return newMap;
    }

    private String getServiceName(String fullServiceName) {
        return fullServiceName.substringAfter(ORG_NAME_SERVICE_DELIMITER);
    }

    //EXCEPTIONS
    global class CalloutServiceException Extends Exception {}
}