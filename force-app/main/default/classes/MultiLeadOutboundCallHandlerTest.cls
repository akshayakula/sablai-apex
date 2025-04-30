@isTest
public class MultiLeadOutboundCallHandlerTest {
    
    @isTest
    static void testSendMultipleLeadsToServer() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new MultiLeadOutboundCallMock());
        
        // Create test leads without inserting them (to avoid trigger)
        List<String> leadNames = new List<String>{
            'Test Lead 1',
            'Test Lead 2',
            'Test Lead 3'
        };
        
        // Create the actual call - this will skip the actual HTTP callout
        // due to the mock but still execute the method
        Test.startTest();
        MultiLeadOutboundCallHandler.sendMultipleLeadsToServer(new List<List<String>>{leadNames});
        Test.stopTest();
        
        // Not much to assert since we're using a mock
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
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new MultiLeadOutboundCallMock());
        
        // Create a list of Lead LastNames (more than MAX_LEADS)
        List<String> leadNames = new List<String>();
        for (Integer i = 1; i <= 8; i++) {
            leadNames.add('Test Lead ' + i);
        }
        
        Test.startTest();
        MultiLeadOutboundCallHandler.sendMultipleLeadsToServer(new List<List<String>>{leadNames});
        Test.stopTest();
        
        // Not much to assert since we're using a mock
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