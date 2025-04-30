public class LeadStatusHandler {
    
    public class StatusInput {
        @InvocableVariable(label='Lead Name' required=true)
        public String leadName;
    }
    
    @InvocableMethod(label='Mark Lead as Contacted' description='Updates the Lead status to Working-Contacted')
    public static void markLeadAsContacted(List<StatusInput> inputs) {
        try {
            if (inputs == null || inputs.isEmpty()) {
                System.debug('No inputs provided');
                return;
            }
            
            for (StatusInput input : inputs) {
                try {
                    if (String.isBlank(input.leadName)) {
                        System.debug('Empty lead name provided');
                        continue;
                    }
                    
                    // Query for the Lead
                    List<Lead> leads = [SELECT Id, Name, Status FROM Lead WHERE Name = :input.leadName LIMIT 1];
                    if (leads.isEmpty()) {
                        System.debug('No Lead found for name: ' + input.leadName);
                        continue;
                    }
                    
                    Lead leadToUpdate = leads[0];
                    
                    // Update the status to Working-Contacted
                    leadToUpdate.Status = 'Working - Contacted';
                    
                    // Update the record
                    update leadToUpdate;
                    System.debug('Successfully updated status for Lead: ' + input.leadName);
                    
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error processing lead: ' + input.leadName + '. Error: ' + e.getMessage());
                    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
                    throw new LeadStatusException('Error updating status: ' + e.getMessage());
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in markLeadAsContacted: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw new LeadStatusException(e.getMessage());
        }
    }
    
    // Custom exception class for better error handling
    public class LeadStatusException extends Exception {}
}