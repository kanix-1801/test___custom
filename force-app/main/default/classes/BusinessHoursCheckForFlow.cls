public with sharing class BusinessHoursCheckForFlow {

    public class Input {
        @InvocableVariable(required=true)
        public Datetime inputDateTime;

        @InvocableVariable(required=true)
        public Id businessHoursId;

        @InvocableVariable(required=true)
        public String businessHoursTimeZoneSidKey;
    }

    public class Output {
        @InvocableVariable
        public String answer;

        @InvocableVariable
        public Datetime nextBusinessDateTime;
    }

    @InvocableMethod(label='Check Business Hours with Holiday and Lunch Logic')
    public static List<Output> checkBusinessHours(List<Input> inputs) {
        List<Output> results = new List<Output>();

        // Get user's timezone
        User user = [SELECT TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        String userTzId = user.TimeZoneSidKey;
        
        System.debug('User TimeZone: ' + userTzId);

        for (Input input : inputs) {
            Output output = new Output();
            Id bhId = input.businessHoursId;
            String bhTzId = input.businessHoursTimeZoneSidKey;
            Datetime inputUserLocal = input.inputDateTime;
            
            System.debug('Input parameters - BH ID: ' + bhId + ', BH TZ: ' + bhTzId + ', DateTime: ' + inputUserLocal);

            // Format datetime in BH timezone to extract correct time & date
            String bhDateStr = inputUserLocal.format('yyyy-MM-dd', bhTzId);
            String bhTimeStr = inputUserLocal.format('HH:mm:ss', bhTzId);
            String bhDayName = inputUserLocal.format('EEEE', bhTzId);
            
            // Check if today is Friday
            Boolean isFriday = bhDayName.equals('Friday');
            System.debug('In BH timezone - Date: ' + bhDateStr + ', Time: ' + bhTimeStr + ', Day: ' + bhDayName + ', Is Friday: ' + isFriday);

            Date inputDate = Date.valueOf(bhDateStr);

            List<String> parts = bhTimeStr.split(':');
            Integer hour = Integer.valueOf(parts[0]);
            Integer minute = Integer.valueOf(parts[1]);
            Integer second = Integer.valueOf(parts[2]);
            Time inputTime = Time.newInstance(hour, minute, second, 0);
            
            // Calculate minutes since midnight for current time
            Integer currentTimeInMinutes = (hour * 60) + minute;
            System.debug('Parsed Time: ' + inputTime + ', Minutes since midnight: ' + currentTimeInMinutes);

            Time lunchStart = Time.newInstance(12, 30, 0, 0);
            Time lunchEnd = Time.newInstance(12, 59, 59, 999);
            
            System.debug('Lunch period: ' + lunchStart + ' to ' + lunchEnd);

            // Enhanced holiday query with better debugging
            List<Holiday> holidaysToday = [
                SELECT Id, Name, ActivityDate, RecurrenceDayOfWeekMask, StartTimeInMinutes, EndTimeInMinutes,
                       RecurrenceStartDate, RecurrenceEndDateOnly
                FROM Holiday
                WHERE (ActivityDate = :inputDate OR RecurrenceDayOfWeekMask != null)
            ];
            
            System.debug('Found ' + holidaysToday.size() + ' potential holidays for date: ' + inputDate);
            for(Holiday h : holidaysToday) {
                System.debug('Holiday: ' + h.Name + ', Date: ' + h.ActivityDate + 
                           ', RecurrenceMask: ' + h.RecurrenceDayOfWeekMask + 
                           ', StartTime: ' + h.StartTimeInMinutes + ', EndTime: ' + h.EndTimeInMinutes + 
                           ', RecurrenceStart: ' + h.RecurrenceStartDate + ', RecurrenceEnd: ' + h.RecurrenceEndDateOnly);
            }

            Boolean isRealHoliday = false;
            Boolean isLunch = false;

            for (Holiday h : holidaysToday) {
                Boolean matchesDate = (h.ActivityDate != null && h.ActivityDate == inputDate);
                Boolean matchesRecurring = (h.RecurrenceDayOfWeekMask != null &&
                                            isDayInMask(bhDayName, h.RecurrenceDayOfWeekMask));
                Boolean isMatch = matchesDate || matchesRecurring;
                
                System.debug('Holiday ' + h.Name + ' - matchesDate: ' + matchesDate + 
                           ', matchesRecurring: ' + matchesRecurring + ', isMatch: ' + isMatch);

                if (isMatch) {
                    // Check if this is a recurring holiday with a defined end date that has already passed
                    if (h.RecurrenceDayOfWeekMask != null && h.RecurrenceEndDateOnly != null) {
                        if (inputDate > h.RecurrenceEndDateOnly) {
                            System.debug('Skipping elapsed recurring holiday: ' + h.Name);
                            continue; // Skip this holiday as it has already ended
                        }
                    }
                    
                    // For holidays with specific start/end times, check if current time is within the holiday time range
                    if (h.StartTimeInMinutes != null && h.EndTimeInMinutes != null) {
                        // Only consider this holiday if the current time falls within its time range
                        if (currentTimeInMinutes < h.StartTimeInMinutes || currentTimeInMinutes > h.EndTimeInMinutes) {
                            System.debug('Current time ' + currentTimeInMinutes + 
                                      ' is outside holiday time range (' + h.StartTimeInMinutes + 
                                      ' - ' + h.EndTimeInMinutes + '), skipping holiday: ' + h.Name);
                            continue; // Skip this holiday as current time is outside its range
                        }
                        System.debug('Current time is within the holiday time range for: ' + h.Name);
                    }
                    
                    if (h.Name != null && h.Name.toLowerCase().contains('lunch')) {
                        // Skip lunch check on Fridays
                        if (isFriday) {
                            System.debug('Skipping lunch check on Friday');
                            continue;
                        }
                        
                        Boolean isInLunchTime = (inputTime >= lunchStart && inputTime <= lunchEnd);
                        System.debug('Lunch check - Is in lunch time: ' + isInLunchTime);
                        
                        if (isInLunchTime) {
                            isLunch = true;
                        }
                    } else {
                        isRealHoliday = true;
                        System.debug('Found real holiday: ' + h.Name);
                        break;
                    }
                }
            }

            // Check if within business hours directly with the input datetime
            Boolean isWithin = BusinessHours.isWithin(bhId, inputUserLocal);
            System.debug('Is within business hours: ' + isWithin);

            // Final logic determination
            if (isRealHoliday) {
                output.answer = 'offline';
                output.nextBusinessDateTime = BusinessHours.nextStartDate(bhId, inputUserLocal);
                System.debug('Result: HOLIDAY - offline, next start: ' + output.nextBusinessDateTime);
            } else if (isLunch) {
                output.answer = 'lunch';
                output.nextBusinessDateTime = BusinessHours.nextStartDate(bhId, inputUserLocal);
                System.debug('Result: LUNCH - lunch, next start: ' + output.nextBusinessDateTime);
            } else {
                if (isWithin) {
                    output.answer = 'online';
                    output.nextBusinessDateTime = null;
                    System.debug('Result: ONLINE - within business hours');
                } else {
                    output.answer = 'offline';
                    output.nextBusinessDateTime = BusinessHours.nextStartDate(bhId, inputUserLocal);
                    System.debug('Result: OFFLINE - outside business hours, next start: ' + output.nextBusinessDateTime);
                }
            }

            results.add(output);
        }

        return results;
    }

    private static Boolean isDayInMask(String dayName, Integer mask) {
        Map<String, Integer> maskMap = new Map<String, Integer>{
            'Sunday'    => 1,
            'Monday'    => 2,
            'Tuesday'   => 4,
            'Wednesday' => 8,
            'Thursday'  => 16,
            'Friday'    => 32,
            'Saturday'  => 64
        };
        
        Integer dayValue = maskMap.containsKey(dayName) ? maskMap.get(dayName) : 0;
        Boolean result = (dayValue > 0) && ((mask & dayValue) > 0);
        System.debug('Day mask check - Day: ' + dayName + ', Mask: ' + mask + ', Day value: ' + dayValue + ', Result: ' + result);
        
        return result;
    }
}