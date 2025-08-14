public class MessageSessionAssignment {
    
    @InvocableMethod(label='Simple Session Assignment')
    public static List<String> simpleSessionAssignment(List<UrgentAssignmentRequest> requests) {
        List<String> results = new List<String>();
        
        for(UrgentAssignmentRequest req : requests) {
            try {
                // Step 1: Simple direct assignment
                MessagingSession session = new MessagingSession(
                    Id = req.sessionId,
                    OwnerId = req.agentId
                );
                update session;
                
                // Step 2: Send notification
                Urgent_Session_Assignment__e event = new Urgent_Session_Assignment__e(
                    Session_Id__c = req.sessionId,
                    Agent_Id__c = req.agentId,
                    Customer_Name__c = req.customerName,
                    Message__c = 'URGENT: Session assigned - Customer: ' + req.customerName
                );
                EventBus.publish(event);
                
                results.add('Success: Session assigned to agent');
                
            } catch(Exception e) {
                results.add('Error: ' + e.getMessage());
            }
        }
        
        return results;
    }
    
    public class UrgentAssignmentRequest {
        @InvocableVariable(label='Session ID' required=true)
        public String sessionId;
        
        @InvocableVariable(label='Agent ID' required=true)
        public String agentId;
        
        @InvocableVariable(label='Customer Name' required=false)
        public String customerName;
    }
}