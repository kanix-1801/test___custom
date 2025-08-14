public with sharing class GetBusinessHours {
    @InvocableMethod(label='Get Business Hours')
    public static List<Boolean> getBusinessHours(List<IdDatetimePair> inputs) {
        List<Boolean> results = new List<Boolean>();
        
        for (IdDatetimePair input : inputs) {
            // Retrieve the BusinessHours record by Id
            BusinessHours bh = [SELECT Id, TimeZoneSidKey FROM BusinessHours WHERE Id = :input.businessHoursId];
            
            // Convert targetTime to the time zone of the BusinessHours
            Datetime targetTime = convertToTimeZone(input.targetTime, bh.TimeZoneSidKey);
            
            // Determine whether the input time is within the business hours
            Boolean isWithin = BusinessHours.isWithin(bh.Id, targetTime);
            
            results.add(isWithin);
        }
        
        return results;
    }
    
    public class IdDatetimePair {
        @InvocableVariable(label='Business Hours Id')
        public String businessHoursId;
        
        @InvocableVariable(label='Target Time')
        public Datetime targetTime;
    }
    
    // Method to convert Datetime to the specified time zone
    private static Datetime convertToTimeZone(Datetime dt, String timeZone) {
        String formattedTime = dt.format('yyyy-MM-dd HH:mm:ss', timeZone);
        return DateTime.valueOf(formattedTime);
    }
}