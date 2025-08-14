@isTest
private class WhatsAppSender_Test {

    @testSetup static void setup() { /* No setup needed specific to this test */ }

    // Mock HTTP Callout class
    private class WhatsAppCalloutMock implements HttpCalloutMock {
        protected Integer statusCode;
        protected String status;
        protected String body;
        protected Boolean expectValidBody = true;

        public WhatsAppCalloutMock(Integer sc, String st, String b) {
            statusCode = sc;
            status = st;
            body = b;
        }
        public WhatsAppCalloutMock(Integer sc, String st, String b, Boolean expBody) {
            this(sc, st, b); // Call the other constructor
            expectValidBody = expBody;
        }

        public HttpResponse respond(HttpRequest req) {
            System.assertEquals('POST', req.getMethod());
            System.assert(req.getEndpoint().contains('/whatsapp-api/send-whatsapp-template'), 'Endpoint path mismatch in test mock.');

            if(expectValidBody) {
               System.assert(req.getBody() != null, 'Request body should not be null for a valid call.');
               Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(req.getBody());
               System.assert(bodyMap.containsKey('destination'));
               System.assert(bodyMap.containsKey('source'));
               System.assert(bodyMap.containsKey('templateId'));
               System.assert(bodyMap.containsKey('dynamicFieldsObject'));
               System.assert(bodyMap.containsKey('headerlink'));
               System.assert(bodyMap.get('dynamicFieldsObject') instanceof Map<String, Object>);
            }

            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setStatus(status);
            res.setBody(body);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    // Test method for successful call - Statements separated
    @isTest static void testSendWhatsAppSuccess() {
        String messageTextWithNewlines = 'Hello test1,\nThis is dynamic test2.\nRegards.';
        String successResponseBody = JSON.serialize(new Map<String, Object>{
            'data' => new Map<String, Object>{ 'success' => true, 'ans' => new Map<String, Object>{
                    'status' => 'OK: Queued', 'unique' => 'MOCK12345', 'body' => messageTextWithNewlines /* other fields */ } } });
        Test.setMock(HttpCalloutMock.class, new WhatsAppCalloutMock(200, 'OK', successResponseBody));

        WhatsAppSender.FlowInput input = new WhatsAppSender.FlowInput();
        input.destinationNumber = '0501234567';
        input.sourceNumber = '972591112233';
        input.templateId = 'test_template_1';
        input.dynamicField1 = 'test1';
        input.dynamicField2 = 'test2';

        List<WhatsAppSender.FlowInput> inputs = new List<WhatsAppSender.FlowInput>{ input };

        Test.startTest();
        List<WhatsAppSender.FlowOutput> results = WhatsAppSender.sendWhatsAppTemplate(inputs);
        Test.stopTest();

        System.assertEquals(1, results.size());
        WhatsAppSender.FlowOutput output = results[0];
        System.assertEquals(true, output.success);
        System.assertEquals(200, output.status);
        System.assertEquals('OK: Queued', output.reason);
        System.assertEquals(null, output.errorMessage);
        System.assertEquals(messageTextWithNewlines, output.messageBodySent);
    } // This should be line 55 (or around it)

    // Test method for 200 OK response but success:false in body - Statements separated
    @isTest static void testApiSuccessFalseInBody() {
        String errorMsg = 'Insufficient credits';
        String errorResponseBody = JSON.serialize(new Map<String, Object>{
            'data' => new Map<String, Object>{ 'success' => false, 'message' => errorMsg } });
        Test.setMock(HttpCalloutMock.class, new WhatsAppCalloutMock(200, 'OK', errorResponseBody));

        WhatsAppSender.FlowInput input = new WhatsAppSender.FlowInput();
        input.destinationNumber = '0501234567';
        input.sourceNumber = '972591112233';
        input.templateId = 'test_template_1';
        input.dynamicField1 = 'test1';
        input.dynamicField2 = 'test2';

        List<WhatsAppSender.FlowInput> inputs = new List<WhatsAppSender.FlowInput>{ input };

        Test.startTest();
        List<WhatsAppSender.FlowOutput> results = WhatsAppSender.sendWhatsAppTemplate(inputs);
        Test.stopTest();

        System.assertEquals(1, results.size());
        WhatsAppSender.FlowOutput output = results[0];
        System.assertEquals(false, output.success);
        System.assertEquals(200, output.status);
        System.assertEquals(errorMsg, output.reason);
        System.assertEquals('API Error: ' + errorMsg, output.errorMessage);
        System.assertEquals(null, output.messageBodySent);
    }

    // Test method for API returning non-2xx error - Statements separated
    @isTest static void testSendWhatsAppApiError400() {
        String errorResponseBody = '{"success": false, "message": "Invalid template ID", "reason": 40001}';
        Test.setMock(HttpCalloutMock.class, new WhatsAppCalloutMock(400, 'Bad Request', errorResponseBody));

        WhatsAppSender.FlowInput input = new WhatsAppSender.FlowInput();
        input.destinationNumber = '972549876543';
        input.sourceNumber = '972591112233';
        input.templateId = 'invalid_template';

        List<WhatsAppSender.FlowInput> inputs = new List<WhatsAppSender.FlowInput>{ input };

        Test.startTest();
        List<WhatsAppSender.FlowOutput> results = WhatsAppSender.sendWhatsAppTemplate(inputs);
        Test.stopTest();

        System.assertEquals(1, results.size());
        WhatsAppSender.FlowOutput output = results[0];
        System.assertEquals(false, output.success);
        System.assertEquals(400, output.status);
        System.assert(output.reason?.contains('Invalid template ID'));
        System.assert(output.errorMessage?.contains('API call failed'));
        System.assertEquals(null, output.messageBodySent);
    }

    // Test methods for blank inputs - Statements separated
    @isTest static void testBlankDestinationNumberError() {
        WhatsAppSender.FlowInput input = new WhatsAppSender.FlowInput();
        input.destinationNumber = '';
        input.sourceNumber = '972591112233';
        input.templateId = 'any_template';
        List<WhatsAppSender.FlowInput> inputs = new List<WhatsAppSender.FlowInput>{ input };

        Test.startTest();
        List<WhatsAppSender.FlowOutput> results = WhatsAppSender.sendWhatsAppTemplate(inputs);
        Test.stopTest();

        System.assertEquals(1, results.size());
        WhatsAppSender.FlowOutput output = results[0];
        System.assertEquals(false, output.success);
        System.assert(output.errorMessage?.contains('Invalid or blank Destination Phone Number'));
        System.assertEquals(null, output.messageBodySent);
    }

    @isTest static void testBlankSourceNumberError() {
        WhatsAppSender.FlowInput input = new WhatsAppSender.FlowInput();
        input.destinationNumber = '0501234567';
        input.sourceNumber = '';
        input.templateId = 'any_template';
        List<WhatsAppSender.FlowInput> inputs = new List<WhatsAppSender.FlowInput>{ input };

        Test.startTest();
        List<WhatsAppSender.FlowOutput> results = WhatsAppSender.sendWhatsAppTemplate(inputs);
        Test.stopTest();

        System.assertEquals(1, results.size());
        WhatsAppSender.FlowOutput output = results[0];
        System.assertEquals(false, output.success);
        System.assert(output.errorMessage?.contains('Source Phone Number and Template ID are required'));
        System.assertEquals(null, output.messageBodySent);
    }

    @isTest static void testBlankTemplateIdError() {
        WhatsAppSender.FlowInput input = new WhatsAppSender.FlowInput();
        input.destinationNumber = '0501234567';
        input.sourceNumber = '972591112233';
        input.templateId = '';
        List<WhatsAppSender.FlowInput> inputs = new List<WhatsAppSender.FlowInput>{ input };

        Test.startTest();
        List<WhatsAppSender.FlowOutput> results = WhatsAppSender.sendWhatsAppTemplate(inputs);
        Test.stopTest();

        System.assertEquals(1, results.size());
        WhatsAppSender.FlowOutput output = results[0];
        System.assertEquals(false, output.success);
        System.assert(output.errorMessage?.contains('Source Phone Number and Template ID are required'));
        System.assertEquals(null, output.messageBodySent);
    }

    // Test method for phone number formatting
    @isTest static void testPhoneNumberFormatting() {
        System.assertEquals('972501234567', WhatsAppSender.formatPhoneNumber('0501234567'));
        System.assertEquals('972529876543', WhatsAppSender.formatPhoneNumber('+972-52-987-6543'));
        System.assertEquals('447123456789', WhatsAppSender.formatPhoneNumber('00447123456789'));
        System.assertEquals('12345', WhatsAppSender.formatPhoneNumber('00012345'));
        System.assertEquals('0', WhatsAppSender.formatPhoneNumber('000'));
        System.assertEquals(null, WhatsAppSender.formatPhoneNumber(null));
        System.assertEquals(null, WhatsAppSender.formatPhoneNumber('abc-def'));
    }
}