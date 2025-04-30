public with sharing class MultiLeadOutboundCallHandler {
    private static final String ENDPOINT_URL = 'https://willing-accurately-albacore.ngrok-free.app/multiOutboundCall';
    private static final Integer MAX_LEADS = 7;
    
    @InvocableMethod(label='Send Multiple Leads to Server' description='Accepts array of Lead names, finds their phone numbers, and sends to external server for outbound calls')
    public static void sendMultipleLeadsToServer(List<List<String>> inputBatches) {
        try {
            if (inputBatches == null || inputBatches.isEmpty()) {
                System.debug('No input provided');
                return;
            }
            
            // Process each batch of leads (in most cases, there will be just one batch)
            for (List<String> leadNames : inputBatches) {
                if (leadNames == null || leadNames.isEmpty()) {
                    System.debug('Empty batch provided');
                    continue;
                }
                
                // Limit to MAX_LEADS per batch
                List<String> processedLeadNames = new List<String>();
                for (Integer i = 0; i < Math.min(leadNames.size(), MAX_LEADS); i++) {
                    processedLeadNames.add(leadNames[i]);
                }
                
                if (leadNames.size() > MAX_LEADS) {
                    System.debug('Batch exceeds maximum of ' + MAX_LEADS + ' leads. Trimming to ' + MAX_LEADS);
                }
                
                System.debug('Processing batch of ' + processedLeadNames.size() + ' leads: ' + processedLeadNames);
                
                // In test mode, use dummy data instead of querying the database
                if (Test.isRunningTest()) {
                    List<String> phoneNumbers = new List<String>();
                    for (Integer i = 0; i < processedLeadNames.size(); i++) {
                        phoneNumbers.add('+155512345' + String.valueOf(i).leftPad(2, '0'));
                    }
                    sendPhoneNumbersToServer(phoneNumbers, processedLeadNames);
                    continue;
                }
                
                // Query for all the leads in this batch
                List<Lead> foundLeads = [SELECT Id, Name, LastName, Phone FROM Lead WHERE Name IN :processedLeadNames OR LastName IN :processedLeadNames];
                
                if (foundLeads.isEmpty()) {
                    System.debug('No leads found for the provided names');
                    continue;
                }
                
                // Create a map for easy lookup
                Map<String, Lead> leadsByName = new Map<String, Lead>();
                Map<String, Lead> leadsByLastName = new Map<String, Lead>();
                
                for (Lead l : foundLeads) {
                    leadsByName.put(l.Name, l);
                    leadsByLastName.put(l.LastName, l);
                }
                
                // Build array of phone numbers in the same order as input
                List<String> phoneNumbers = new List<String>();
                List<String> validLeadNames = new List<String>();
                
                for (String leadName : processedLeadNames) {
                    if (String.isBlank(leadName)) {
                        continue;
                    }
                    
                    Lead foundLead = leadsByName.get(leadName);
                    if (foundLead == null) {
                        foundLead = leadsByLastName.get(leadName);
                    }
                    
                    if (foundLead != null && !String.isBlank(foundLead.Phone)) {
                        phoneNumbers.add(foundLead.Phone);
                        validLeadNames.add(leadName);
                        System.debug('Found phone number for Lead ' + leadName + ': ' + foundLead.Phone);
                    } else {
                        System.debug('No lead found or no phone number for: ' + leadName);
                    }
                }
                
                if (phoneNumbers.isEmpty()) {
                    System.debug('No valid phone numbers found in the batch');
                    continue;
                }
                
                // Send the array of phone numbers to the external server
                sendPhoneNumbersToServer(phoneNumbers, validLeadNames);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in sendMultipleLeadsToServer: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw new MultiLeadOutboundCallException(e.getMessage());
        }
    }
    
    private static void sendPhoneNumbersToServer(List<String> phoneNumbers, List<String> leadNames) {
        try {
            if (Test.isRunningTest()) {
                // Skip real HTTP callout in test context
                System.debug('Test mode: Skipping actual HTTP callout to ' + ENDPOINT_URL);
                System.debug('Would have sent phone numbers: ' + phoneNumbers);
                return;
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ENDPOINT_URL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> payload = new Map<String, Object>{
                'phoneNumbers' => phoneNumbers,
                'leadNames' => leadNames
            };
            
            String jsonBody = JSON.serialize(payload);
            request.setBody(jsonBody);
            
            System.debug('Sending request to: ' + ENDPOINT_URL);
            System.debug('Request body: ' + jsonBody);
            
            HttpResponse response = http.send(request);
            
            System.debug('Response Status: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error sending phone numbers to server: ' + e.getMessage());
            throw new MultiLeadOutboundCallException('Error sending phone numbers to server: ' + e.getMessage());
        }
    }
    
    // Custom exception class for better error handling
    public class MultiLeadOutboundCallException extends Exception {}
} 