public with sharing class LeadCallDetailsHandler {
    
    @InvocableMethod(label='Update Lead Call Details' description='Updates call details fields on a Lead record based on Lead Name')
    public static void updateLeadCallDetails(List<CallDetailsRequest> requests) {
        for(CallDetailsRequest req : requests) {
            updateCallDetails(req.leadName, req.recordingUrl, req.callSummary, req.sentimentScore);
        }
    }
    
    private static void updateCallDetails(String leadName, String recordingUrl, String callSummary, Decimal sentimentScore) {
        if(String.isBlank(leadName)) {
            System.debug('Lead name is empty');
            return;
        }
        
        try {
            // Query for the Lead with the given last name
            List<Lead> leads = [SELECT Id, Call_Recording_URL__c, Call_Summary__c, Sentiment_Score__c 
                               FROM Lead WHERE LastName = :leadName LIMIT 1];
            
            if(leads.isEmpty()) {
                System.debug('No Lead found with last name: ' + leadName);
                return;
            }
            
            Lead leadToUpdate = leads[0];
            
            // Only update fields that are provided
            if(recordingUrl != null) {
                leadToUpdate.Call_Recording_URL__c = recordingUrl;
            }
            
            if(callSummary != null) {
                leadToUpdate.Call_Summary__c = callSummary;
            }
            
            if(sentimentScore != null) {
                leadToUpdate.Sentiment_Score__c = sentimentScore;
            }
            
            update leadToUpdate;
            System.debug('Successfully updated call details for Lead with last name: ' + leadName);
        } catch(Exception e) {
            System.debug('Error updating Lead call details: ' + e.getMessage());
        }
    }
    
    // Input wrapper class
    public class CallDetailsRequest {
        @InvocableVariable(label='Lead Name' required=true)
        public String leadName;
        
        @InvocableVariable(label='Call Recording URL' required=false)
        public String recordingUrl;
        
        @InvocableVariable(label='Call Summary' required=false)
        public String callSummary;
        
        @InvocableVariable(label='Sentiment Score' required=false)
        public Decimal sentimentScore;
    }
} 