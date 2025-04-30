public with sharing class LeadTranscriptHandler {
    
    @InvocableMethod(label='Update Lead Transcript' description='Updates the Transcript field on a Lead record based on Lead Name')
    public static void updateLeadTranscript(List<TranscriptRequest> requests) {
        for(TranscriptRequest req : requests) {
            updateTranscript(req.leadName, req.transcription);
        }
    }
    
    private static void updateTranscript(String leadName, String transcription) {
        if(String.isBlank(leadName) || String.isBlank(transcription)) {
            System.debug('Lead name or transcription is empty');
            return;
        }
        
        try {
            // Query for the Lead with the given last name
            List<Lead> leads = [SELECT Id, Transcript__c FROM Lead WHERE LastName = :leadName LIMIT 1];
            
            if(leads.isEmpty()) {
                System.debug('No Lead found with last name: ' + leadName);
                return;
            }
            
            Lead leadToUpdate = leads[0];
            leadToUpdate.Transcript__c = transcription;
            
            update leadToUpdate;
            System.debug('Successfully updated transcript for Lead with last name: ' + leadName);
        } catch(Exception e) {
            System.debug('Error updating Lead transcript: ' + e.getMessage());
        }
    }
    
    // Input wrapper class
    public class TranscriptRequest {
        @InvocableVariable(label='Lead Name' required=true)
        public String leadName;
        
        @InvocableVariable(label='Transcription' required=true)
        public String transcription;
    }
} 