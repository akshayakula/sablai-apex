trigger VapiCallTrigger on Lead (after insert, after update) {
    List<String> phoneNumbers = new List<String>();
    
    for (Lead lead : Trigger.new) {
        if (String.isNotBlank(lead.Phone)) {
            phoneNumbers.add(lead.Phone);
        }
    }
    
    if (!phoneNumbers.isEmpty()) {
        LeadOutboundCallHandler.sendLeadInfoToServer(phoneNumbers);
    }
}