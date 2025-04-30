@isTest
public class MultiLeadOutboundCallHandlerTest {
    
    @isTest
    static void testSendMultipleLeadsToServer() {
        // Create test leads
        List<Lead> testLeads = new List<Lead>{
            new Lead(LastName = 'Test Lead 1', Company = 'Test Company 1', Phone = '+15551234001', Status = 'Open - Not Contacted'),
            new Lead(LastName = 'Test Lead 2', Company = 'Test Company 2', Phone = '+15551234002', Status = 'Open - Not Contacted'),
            new Lead(LastName = 'Test Lead 3', Company = 'Test Company 3', Phone = '+15551234003', Status = 'Open - Not Contacted')
        };
        insert testLeads;
        
        // Create a list of Lead LastNames
        List<String> leadNames = new List<String>{
            'Test Lead 1',
            'Test Lead 2',
            'Test Lead 3'
        };
        
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new MultiLeadOutboundCallMock());
        
        Test.startTest();
        MultiLeadOutboundCallHandler.sendMultipleLeadsToServer(new List<List<String>>{leadNames});
        Test.stopTest();
        
        // Not much to assert since we're using a mock, but we can verify no exceptions were thrown
    }
    
    @isTest
    static void testSendMultipleLeadsToServerWithEmptyBatch() {
        Test.setMock(HttpCalloutMock.class, new MultiLeadOutboundCallMock());
        
        Test.startTest();
        // Test with empty batch
        MultiLeadOutboundCallHandler.sendMultipleLeadsToServer(new List<List<String>>{new List<String>()});
        Test.stopTest();
        
        // No assertions needed - just confirming no exceptions are thrown
    }
    
    @isTest
    static void testSendMultipleLeadsToServerWithNoLeads() {
        Test.setMock(HttpCalloutMock.class, new MultiLeadOutboundCallMock());
        
        Test.startTest();
        // Test with batch containing non-existent leads
        MultiLeadOutboundCallHandler.sendMultipleLeadsToServer(new List<List<String>>{new List<String>{'Non-existent Lead'}});
        Test.stopTest();
        
        // No assertions needed - just confirming no exceptions are thrown
    }
    
    @isTest
    static void testSendMultipleLeadsToServerWithMoreThanMaxLeads() {
        // Create 8 test leads (more than MAX_LEADS)
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 1; i <= 8; i++) {
            testLeads.add(new Lead(
                LastName = 'Test Lead ' + i,
                Company = 'Test Company ' + i,
                Phone = '+1555123400' + i,
                Status = 'Open - Not Contacted'
            ));
        }
        insert testLeads;
        
        // Create a list of Lead LastNames
        List<String> leadNames = new List<String>();
        for (Integer i = 1; i <= 8; i++) {
            leadNames.add('Test Lead ' + i);
        }
        
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new MultiLeadOutboundCallMock());
        
        Test.startTest();
        MultiLeadOutboundCallHandler.sendMultipleLeadsToServer(new List<List<String>>{leadNames});
        Test.stopTest();
        
        // Not much to assert since we're using a mock, but we can verify no exceptions were thrown
    }
    
    // Mock HTTP Response for testing
    private class MultiLeadOutboundCallMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"status":"success","message":"Calls initiated successfully"}');
            return response;
        }
    }
} 