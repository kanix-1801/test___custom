public with sharing class UserTimeZoneUtil {

    public class Input {
        @InvocableVariable(required=true)
        public Id userId;
    }

    public class Output {
        @InvocableVariable
        public Decimal gmtOffset;
    }

    @InvocableMethod(label='Get User GMT Offset')
    public static List<Output> getUserGMTOffset(List<Input> inputs) {
        List<Output> results = new List<Output>();

        for (Input input : inputs) {
            Output result = new Output();
            result.gmtOffset = 0;

            if (input.userId != null) {
                // Set a test time to calculate the offset
                DateTime gmtNow = System.now();

                // Get user’s time zone
                User u = [SELECT Id, TimeZoneSidKey FROM User WHERE Id = :input.userId LIMIT 1];

                // Format the same DateTime using the user’s time zone
                String userFormatted = gmtNow.format('HH', u.TimeZoneSidKey);
                Integer userHour = Integer.valueOf(userFormatted);
                Integer gmtHour = Integer.valueOf(gmtNow.formatGMT('HH'));

                Integer offset = userHour - gmtHour;

                // Handle wrapping around midnight
                if (offset > 12) offset -= 24;
                if (offset < -12) offset += 24;

                result.gmtOffset = Decimal.valueOf(offset);
            }

            results.add(result);
        }

        return results;
    }
}