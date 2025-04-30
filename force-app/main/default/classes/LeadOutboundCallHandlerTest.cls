@IsTest
private class LeadOutboundCallHandlerTest {
    @IsTest
    static void testSendPhoneNumberToServer() {
        // Set up test phone number
        String testPhoneNumber = '+1234567890';
        
        // Set up the mock callout
        Test.setMock(HttpCalloutMock.class, new PhoneOutboundCallMock());
        
        Test.startTest();
        
        // Call the method
        LeadOutboundCallHandler.sendLeadInfoToServer(new List<String>{ testPhoneNumber });
        
        Test.stopTest();
    }
    
    @IsTest
    static void testSendPhoneNumberToServerWithEmptyList() {
        Test.startTest();
        
        // Test with empty list
        LeadOutboundCallHandler.sendLeadInfoToServer(new List<String>());
        
        // Test with null
        LeadOutboundCallHandler.sendLeadInfoToServer(null);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testSendSpecificPhoneNumberToServer() {
        String testPhoneNumber = '+15713869946';
        Test.setMock(HttpCalloutMock.class, new PhoneOutboundCallMock());
        Test.startTest();
        LeadOutboundCallHandler.sendLeadInfoToServer(new List<String>{ testPhoneNumber });
        Test.stopTest();
    }
    
    // Mock HTTP Callout class
    private class PhoneOutboundCallMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            // Verify request format
            System.assertEquals('POST', request.getMethod());
            System.assertEquals('application/json', request.getHeader('Content-Type'));
            
            // Verify the request contains valid JSON
            Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(request.getBody());
            System.assertNotEquals(null, requestBody.get('phoneNumber'), 'Phone number should be present');
            
            // Create fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"status": "success"}');
            return response;
        }
    }
} 