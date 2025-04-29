public class LeadOutboundCallHandler {
    private static final String ENDPOINT_URL = 'https://willing-accurately-albacore.ngrok-free.app/initiateOutboundCall';
    
    @InvocableMethod(label='Send Phone Number to Server' description='Sends phone number to external server for outbound call')
    public static void sendPhoneNumberToServer(List<String> phoneNumbers) {
        try {
            if (phoneNumbers == null || phoneNumbers.isEmpty()) {
                System.debug('No phone numbers provided');
                return;
            }
            
            // Debug the incoming phone numbers
            System.debug('Processing phone numbers: ' + phoneNumbers);
            
            // Process each phone number
            for (String phoneNumber : phoneNumbers) {
                try {
                    if (String.isBlank(phoneNumber)) {
                        System.debug('Empty phone number provided');
                        continue;
                    }
                    
                    // Create HTTP request
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(ENDPOINT_URL);
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/json');
                    
                    // Create request body
                    Map<String, String> payload = new Map<String, String>{
                        'phoneNumber' => phoneNumber
                    };
                    
                    String jsonBody = JSON.serialize(payload);
                    request.setBody(jsonBody);
                    
                    // Debug the request
                    System.debug('Sending request to: ' + ENDPOINT_URL);
                    System.debug('Request body: ' + jsonBody);
                    
                    // Send request
                    HttpResponse response = http.send(request);
                    
                    // Log response
                    System.debug('Response Status: ' + response.getStatusCode());
                    System.debug('Response Body: ' + response.getBody());
                    
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error processing phone number: ' + phoneNumber + '. Error: ' + e.getMessage());
                    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
                    throw new LeadOutboundCallException('Error processing phone number: ' + e.getMessage());
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in sendPhoneNumberToServer: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw new LeadOutboundCallException(e.getMessage());
        }
    }
    
    // Custom exception class for better error handling
    public class LeadOutboundCallException extends Exception {}
} 