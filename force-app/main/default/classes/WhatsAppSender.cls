/**
 * @description Apex class to send WhatsApp template messages via the 019sms API using Named/External Credentials.
 * Extracts message body on success, provides error details from response body on failure.
 * Callable from Salesforce Flow. Handles number formatting and API callout.
 * @date 2025-05-07
 */
public class WhatsAppSender {

    // Inner class FlowInput remains the same
    public class FlowInput {
        @InvocableVariable(label='Destination Phone Number' description='The recipient\'s phone number.' required=true)
        public String destinationNumber;
        @InvocableVariable(label='Source Phone Number' description='Your WhatsApp Business API source number.' required=true)
        public String sourceNumber;
        @InvocableVariable(label='WhatsApp Template ID' description='The ID of the WhatsApp template to use.' required=true)
        public String templateId;
        @InvocableVariable(label='Dynamic Field 1 Value' description='Value for dynamic field key "1".')
        public String dynamicField1;
        @InvocableVariable(label='Dynamic Field 2 Value' description='Value for dynamic field key "2".')
        public String dynamicField2;
        @InvocableVariable(label='Dynamic Field 3 Value' description='Value for dynamic field key "3".')
        public String dynamicField3;
        @InvocableVariable(label='Dynamic Field 4 Value' description='Value for dynamic field key "4".')
        public String dynamicField4;
        @InvocableVariable(label='Dynamic Field 5 Value' description='Value for dynamic field key "5".')
        public String dynamicField5;
        @InvocableVariable(label='Header Link URL' description='URL for the headerlink field.')
        public String headerLink;
    }

    // Inner class FlowOutput remains the same
    public class FlowOutput {
        @InvocableVariable(label='Success' description='Indicates if the overall operation was successful (based on API response).')
        public Boolean success;
        @InvocableVariable(label='Status Code' description='HTTP status code returned by the API.')
        public Integer status;
        @InvocableVariable(label='Response Body' description='Raw response body from the API.')
        public String responseBody;
        @InvocableVariable(label='Reason' description='Reason phrase from the API response (parsed from JSON if available, otherwise HTTP status).')
        public String reason;
        @InvocableVariable(label='Error Message' description='Error details if the operation failed.')
        public String errorMessage;
        @InvocableVariable(label='Message Body Sent' description='The text content of the message sent (if successful, includes newlines).')
        public String messageBodySent;
    }

    // Main Method - Handles success:false in 200 OK response
    @InvocableMethod(label='Send WhatsApp Template Message (019sms - V6 Final)' description='Sends a WhatsApp template message via 019sms API using External Credentials.' category='WhatsApp')
    public static List<FlowOutput> sendWhatsAppTemplate(List<FlowInput> inputs) {

        List<FlowOutput> results = new List<FlowOutput>();
        Integer timeoutSeconds = 60;

        for (FlowInput input : inputs) {
            FlowOutput output = new FlowOutput();
            HttpRequest request = new HttpRequest();
            Http http = new Http();

            try {
                // Format Destination Number
                String formattedDestinationNumber = formatPhoneNumber(input.destinationNumber);
                if (formattedDestinationNumber == null) { throw new CalloutException('Invalid or blank Destination Phone Number provided.'); }
                 if (String.isBlank(input.sourceNumber) || String.isBlank(input.templateId)) { throw new CalloutException('Source Phone Number and Template ID are required.'); }

                // Prepare Request Body
                Map<String, Object> requestBodyMap = new Map<String, Object>();
                requestBodyMap.put('source', input.sourceNumber); requestBodyMap.put('destination', formattedDestinationNumber); requestBodyMap.put('templateId', input.templateId);
                Map<String, String> dynamicFieldsMap = new Map<String, String>();
                dynamicFieldsMap.put('1', String.isBlank(input.dynamicField1) ? '' : input.dynamicField1); dynamicFieldsMap.put('2', String.isBlank(input.dynamicField2) ? '' : input.dynamicField2);
                dynamicFieldsMap.put('3', String.isBlank(input.dynamicField3) ? '' : input.dynamicField3); dynamicFieldsMap.put('4', String.isBlank(input.dynamicField4) ? '' : input.dynamicField4);
                dynamicFieldsMap.put('5', String.isBlank(input.dynamicField5) ? '' : input.dynamicField5);
                requestBodyMap.put('dynamicFieldsObject', dynamicFieldsMap); requestBodyMap.put('headerlink', String.isBlank(input.headerLink) ? '' : input.headerLink);

                // Serialize JSON Body
                String requestBodyJsonString = '';
                 try { requestBodyJsonString = JSON.serialize(requestBodyMap); }
                 catch (Exception jsonEx) {
                     System.debug(LoggingLevel.ERROR, 'Failed to serialize request body map: ' + jsonEx.getMessage());
                     output.errorMessage = 'ERROR: Failed to serialize request body map: ' + jsonEx.getMessage(); output.success = false;
                     results.add(output); continue;
                 }

                // Configure HTTP Request
                String endpointUrl = 'callout:WhatsApp_019SMS_API/whatsapp-api/send-whatsapp-template';
                request.setEndpoint(endpointUrl); request.setMethod('POST'); request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setBody(requestBodyJsonString); request.setTimeout(timeoutSeconds * 1000);
                System.debug(LoggingLevel.INFO, 'Sending WhatsApp request via Named Credential: ' + request.getEndpoint());

                // Send Request
                HttpResponse response = http.send(request);
                System.debug(LoggingLevel.INFO, 'WhatsApp API Response Status Code: ' + response.getStatusCode()); System.debug(LoggingLevel.DEBUG, 'WhatsApp API Response Body: ' + response.getBody());

                // Process Response
                output.status = response.getStatusCode(); output.responseBody = response.getBody(); output.reason = response.getStatus(); // Default reason
                String responseBodyString = response.getBody();

                if (String.isNotBlank(responseBodyString)) {
                    if (response.getStatusCode() == 403 && responseBodyString.contains('_Incapsula_Resource')) { // WAF Block
                         output.success = false; output.errorMessage = 'API call failed (403 Forbidden - Blocked by WAF). Status: ' + output.status + '. Reason: ' + output.reason; output.reason = 'Forbidden (WAF Block)';
                    } else if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) { // Success HTTP status
                        try { // Try parsing response body
                            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBodyString);
                            Boolean responseSuccess = true; // Assume success unless data.success says otherwise
                            String responseReason = output.reason; // Keep HTTP reason unless overridden
                            String responseMessage = null; // Store potential error message from JSON

                            // Check for standard structure: data -> success
                            if (responseMap.containsKey('data')) {
                                Object dataObj = responseMap.get('data');
                                if(dataObj instanceof Map<String, Object>){
                                    Map<String, Object> dataMap = (Map<String, Object>)dataObj;
                                    // Determine actual success from JSON payload
                                    if (dataMap.containsKey('success') && dataMap.get('success') instanceof Boolean) {
                                        responseSuccess = (Boolean) dataMap.get('success');
                                    }
                                    // Extract potential message/reason if success is false
                                    if (!responseSuccess) {
                                        if (dataMap.containsKey('message') && dataMap.get('message') instanceof String) {
                                            responseMessage = (String)dataMap.get('message');
                                            responseReason = responseMessage; // Use API message as reason
                                        } else {
                                             responseMessage = 'API indicated failure but provided no specific message.';
                                             responseReason = 'API Error (Unknown)';
                                        }
                                    } else { // Success is true, try to extract message body and specific 'OK' reason
                                         if (dataMap.containsKey('ans')){
                                            Object ansObj = dataMap.get('ans');
                                            if(ansObj instanceof Map<String, Object>){
                                                Map<String, Object> ansMap = (Map<String, Object>)ansObj;
                                                if(ansMap.containsKey('body') && ansMap.get('body') instanceof String){
                                                    output.messageBodySent = (String)ansMap.get('body'); // Preserve newlines
                                                }
                                                // Update reason from ans.status ONLY on successful processing
                                                if(ansMap.containsKey('status') && ansMap.get('status') instanceof String){
                                                    responseReason = (String)ansMap.get('status');
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // Assign final outputs based on parsing
                            output.success = responseSuccess;
                            output.reason = responseReason;
                            if (!responseSuccess) {
                                // *** CORRECTED LINE: Prefix the error message ***
                                output.errorMessage = 'API Error: ' + responseMessage;
                            }

                         } catch (Exception parseException) { // Handle JSON parsing failure of successful response
                             System.debug(LoggingLevel.WARN, 'Successfully called API (Status ' + output.status + ') but failed to parse response body: ' + parseException.getMessage());
                             output.success = true; // Still considered success based on status code
                             output.reason = output.reason + ' (Warning: Response body parsing failed)';
                             output.errorMessage = 'API call succeeded, but response parsing failed: ' + parseException.getMessage();
                         }
                    } else { // Handle other non-2xx/non-WAF errors
                        output.success = false;
                         try {
                             Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(responseBodyString);
                             if (errorMap.containsKey('reason') && errorMap.get('reason') instanceof String) { output.reason = (String) errorMap.get('reason'); }
                             else if (errorMap.containsKey('message') && errorMap.get('message') instanceof String) { output.reason = (String) errorMap.get('message'); }
                             output.errorMessage = 'API call failed. Status: ' + output.status + '. Reason: ' + output.reason;
                         } catch (Exception parseException) { output.errorMessage = 'API call failed. Status: ' + output.status + '. Reason: ' + output.reason + '. (Failed to parse error response body)'; }
                    }
                } else { // Handle blank response body
                     output.success = (response.getStatusCode() >= 200 && response.getStatusCode() < 300);
                     if (!output.success) { output.errorMessage = 'API call failed. Status: ' + output.status + '. Reason: ' + output.reason + '. (No response body)'; }
                }

            } catch (System.CalloutException ce) { // Catch Callout Errors
                System.debug(LoggingLevel.ERROR, 'Callout Error sending WhatsApp message: ' + ce.getMessage() + ' Stack: ' + ce.getStackTraceString());
                output.success = false; if (String.isBlank(output.errorMessage)) { if (ce.getMessage().contains('access the credential(s)')) { output.errorMessage = 'Callout Error: Could not access credentials. Verify Named Credential setup, External Credential parameters, and Principal permissions. Details: ' + ce.getMessage(); } else { output.errorMessage = 'Callout Error: ' + ce.getMessage(); } } output.status = null; output.reason = null;
            } catch (Exception e) { // Catch other unexpected errors
                System.debug(LoggingLevel.ERROR, 'General Error sending WhatsApp message: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
                output.success = false; if (String.isBlank(output.errorMessage)) { output.errorMessage = 'Error: ' + e.getMessage(); } output.status = null; output.reason = null;
            } finally {
                 if (String.isNotBlank(output.errorMessage) && output.success == null) { output.success = false; } // Ensure success is false if error message exists
                 results.add(output);
            }
        } // End of loop through inputs
        return results;
    }

    // formatPhoneNumber method remains the same
    @TestVisible
    private static String formatPhoneNumber(String phoneNumber) {
        if (String.isBlank(phoneNumber)) { return null; } String digitsOnly = phoneNumber.replaceAll('[^0-9]', '');
        if (String.isBlank(digitsOnly)) { return null; }
        if (digitsOnly.length() == 10 && digitsOnly.startsWith('05')) { return '972' + digitsOnly.substring(1); }
        else {
            Integer firstNonZeroIndex = -1; Integer zeroCodePoint = '0'.codePointAt(0);
            for (Integer i = 0; i < digitsOnly.length(); i++) { if (digitsOnly.codePointAt(i) != zeroCodePoint) { firstNonZeroIndex = i; break; } }
            if (firstNonZeroIndex != -1) { return digitsOnly.substring(firstNonZeroIndex); } else { return '0'; }
        }
    }
}