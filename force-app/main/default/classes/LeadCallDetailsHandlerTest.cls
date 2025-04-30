@isTest
public class LeadCallDetailsHandlerTest {
    
    @isTest
    static void testUpdateLeadCallDetails() {
        // Create test data
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
        
        // Verify the initial state
        Lead initialLead = [SELECT Id, Call_Recording_URL__c, Call_Summary__c, Sentiment_Score__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(null, initialLead.Call_Recording_URL__c);
        System.assertEquals(null, initialLead.Call_Summary__c);
        System.assertEquals(null, initialLead.Sentiment_Score__c);
        
        // Create the request
        LeadCallDetailsHandler.CallDetailsRequest request = new LeadCallDetailsHandler.CallDetailsRequest();
        request.leadName = testLead.LastName;
        request.recordingUrl = 'https://example.com/recording.mp3';
        request.callSummary = 'This is a test call summary';
        request.sentimentScore = 0.75;
        
        Test.startTest();
        LeadCallDetailsHandler.updateLeadCallDetails(new List<LeadCallDetailsHandler.CallDetailsRequest>{request});
        Test.stopTest();
        
        // Query the lead to verify the fields were updated
        Lead updatedLead = [SELECT Id, Call_Recording_URL__c, Call_Summary__c, Sentiment_Score__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('https://example.com/recording.mp3', updatedLead.Call_Recording_URL__c);
        System.assertEquals('This is a test call summary', updatedLead.Call_Summary__c);
        System.assertEquals(0.75, updatedLead.Sentiment_Score__c);
    }
    
    @isTest
    static void testUpdateLeadCallDetailsPartial() {
        // Create test data
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
        
        // Create the request with only some fields
        LeadCallDetailsHandler.CallDetailsRequest request = new LeadCallDetailsHandler.CallDetailsRequest();
        request.leadName = testLead.LastName;
        request.recordingUrl = 'https://example.com/recording.mp3';
        // Omit call summary and sentiment score
        
        Test.startTest();
        LeadCallDetailsHandler.updateLeadCallDetails(new List<LeadCallDetailsHandler.CallDetailsRequest>{request});
        Test.stopTest();
        
        // Query the lead to verify that only the recording URL was updated
        Lead updatedLead = [SELECT Id, Call_Recording_URL__c, Call_Summary__c, Sentiment_Score__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('https://example.com/recording.mp3', updatedLead.Call_Recording_URL__c);
        System.assertEquals(null, updatedLead.Call_Summary__c);
        System.assertEquals(null, updatedLead.Sentiment_Score__c);
    }
    
    @isTest
    static void testUpdateLeadCallDetailsWithInvalidLeadName() {
        // Test with invalid Lead name
        LeadCallDetailsHandler.CallDetailsRequest request = new LeadCallDetailsHandler.CallDetailsRequest();
        request.leadName = 'Non-Existent Lead';
        request.recordingUrl = 'https://example.com/recording.mp3';
        request.callSummary = 'This is a test call summary';
        request.sentimentScore = 0.75;
        
        Test.startTest();
        // This should not throw any exception but just log a debug message
        LeadCallDetailsHandler.updateLeadCallDetails(new List<LeadCallDetailsHandler.CallDetailsRequest>{request});
        Test.stopTest();
        
        // No assertion needed - just testing that no exception is thrown
    }
    
    @isTest
    static void testUpdateLeadCallDetailsWithEmptyLeadName() {
        // Test with empty lead name
        LeadCallDetailsHandler.CallDetailsRequest request = new LeadCallDetailsHandler.CallDetailsRequest();
        request.leadName = '';
        request.recordingUrl = 'https://example.com/recording.mp3';
        
        Test.startTest();
        // This should not throw any exception but just log a debug message
        LeadCallDetailsHandler.updateLeadCallDetails(new List<LeadCallDetailsHandler.CallDetailsRequest>{request});
        Test.stopTest();
        
        // No assertion needed - just testing that no exception is thrown
    }
} 