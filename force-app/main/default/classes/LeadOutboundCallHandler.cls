public class LeadOutboundCallHandler {
    private static final String ENDPOINT_URL = 'https://willing-accurately-albacore.ngrok-free.app/initiateOutboundCall';
    
    @InvocableMethod(label='Send Lead Info to Server' description='Accepts phone numbers or Lead names, finds phone if needed, and sends to external server for outbound call')
    public static void sendLeadInfoToServer(List<String> inputs) {
        try {
            if (inputs == null || inputs.isEmpty()) {
                System.debug('No input provided');
                return;
            }
            System.debug('Processing inputs: ' + inputs);
            for (String input : inputs) {
                try {
                    if (String.isBlank(input)) {
                        System.debug('Empty input provided');
                        continue;
                    }
                    String phoneNumber = null;
                    // Heuristic: if input starts with '+' or is all digits, treat as phone number
                    if (input.trim().startsWith('+') || input.trim().replaceAll('[^0-9]', '').length() >= 10) {
                        phoneNumber = input.trim();
                        System.debug('Input treated as phone number: ' + phoneNumber);
                    } else {
                        // Otherwise, treat as Lead name
                        List<Lead> leads = [SELECT Id, Name, Phone FROM Lead WHERE Name = :input LIMIT 1];
                        if (leads.isEmpty()) {
                            System.debug('No Lead found for name: ' + input);
                            continue;
                        }
                        Lead foundLead = leads[0];
                        if (String.isBlank(foundLead.Phone)) {
                            System.debug('No phone number for Lead: ' + input);
                            continue;
                        }
                        phoneNumber = foundLead.Phone;
                        System.debug('Found phone number for Lead ' + input + ': ' + phoneNumber);
                    }
                    // Send the phone number to the external server
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(ENDPOINT_URL);
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/json');
                    Map<String, String> payload = new Map<String, String>{
                        'phoneNumber' => phoneNumber
                    };
                    String jsonBody = JSON.serialize(payload);
                    request.setBody(jsonBody);
                    System.debug('Sending request to: ' + ENDPOINT_URL);
                    System.debug('Request body: ' + jsonBody);
                    HttpResponse response = http.send(request);
                    System.debug('Response Status: ' + response.getStatusCode());
                    System.debug('Response Body: ' + response.getBody());
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error processing input: ' + input + '. Error: ' + e.getMessage());
                    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
                    throw new LeadOutboundCallException('Error processing input: ' + e.getMessage());
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in sendLeadInfoToServer: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw new LeadOutboundCallException(e.getMessage());
        }
    }
    
    // Custom exception class for better error handling
    public class LeadOutboundCallException extends Exception {}
} 