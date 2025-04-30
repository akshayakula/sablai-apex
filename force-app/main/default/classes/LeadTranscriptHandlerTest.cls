@isTest
public class LeadTranscriptHandlerTest {
    
    @isTest
    static void testUpdateLeadTranscript() {
        // Create test data
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
        
        // Verify the initial state
        System.assertEquals(null, [SELECT Transcript__c FROM Lead WHERE Id = :testLead.Id].Transcript__c);
        
        // Create the request
        LeadTranscriptHandler.TranscriptRequest request = new LeadTranscriptHandler.TranscriptRequest();
        request.leadName = testLead.LastName;
        request.transcription = 'This is a test transcript';
        
        Test.startTest();
        LeadTranscriptHandler.updateLeadTranscript(new List<LeadTranscriptHandler.TranscriptRequest>{request});
        Test.stopTest();
        
        // Query the lead to verify the transcript was updated
        Lead updatedLead = [SELECT Id, Transcript__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('This is a test transcript', updatedLead.Transcript__c);
    }
    
    @isTest
    static void testUpdateLeadTranscriptWithInvalidLeadName() {
        // Test with invalid Lead name
        LeadTranscriptHandler.TranscriptRequest request = new LeadTranscriptHandler.TranscriptRequest();
        request.leadName = 'Non-Existent Lead';
        request.transcription = 'This is a test transcript';
        
        Test.startTest();
        // This should not throw any exception but just log a debug message
        LeadTranscriptHandler.updateLeadTranscript(new List<LeadTranscriptHandler.TranscriptRequest>{request});
        Test.stopTest();
        
        // No assertion needed - just testing that no exception is thrown
    }
    
    @isTest
    static void testUpdateLeadTranscriptWithEmptyInputs() {
        // Test with empty inputs
        LeadTranscriptHandler.TranscriptRequest request = new LeadTranscriptHandler.TranscriptRequest();
        request.leadName = '';
        request.transcription = '';
        
        Test.startTest();
        // This should not throw any exception but just log a debug message
        LeadTranscriptHandler.updateLeadTranscript(new List<LeadTranscriptHandler.TranscriptRequest>{request});
        Test.stopTest();
        
        // No assertion needed - just testing that no exception is thrown
    }
} 