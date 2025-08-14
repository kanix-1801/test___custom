@isTest
private class GetBusinessHoursTest {
    @IsTest
    static void testGetBusinessHours() {
        List<GetBusinessHours.IdDatetimePair> inputs = new List<GetBusinessHours.IdDatetimePair>();
        GetBusinessHours.IdDatetimePair input = new GetBusinessHours.IdDatetimePair();
        input.businessHoursId = [select id from businessHours where isDefault = true].Id;
        input.targetTime = Datetime.newInstance(2023, 6, 22, 10, 0, 0);
        inputs.add(input);

        List<Boolean> results = GetBusinessHours.getBusinessHours(inputs);

        System.assert(results[0], 'Should be business horus');

    }
}