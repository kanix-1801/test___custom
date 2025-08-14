public Class GetObjectFieldLabels{
    // Input class for Flow
    public class Input {
        @InvocableVariable
        public String objectApiName;
        
        @InvocableVariable
        public String inputFieldList;
    }

    // Output class for Flow
    public class Output {
        @InvocableVariable
        public String validFields;    // e.g., "Name,AccountNumber"
        
        @InvocableVariable
        public String invalidFields;  // e.g., "testInvalid,testXYZ"

        @InvocableVariable
        public List<String> validFieldsArray;  // e.g., ["Name", "AccountNumber"]
    }

    // Invocable method
    @InvocableMethod(label='Validate Object Fields')
    public static List<Output> validateFields(List<Input> requestList) {
        List<Output> results = new List<Output>();

        for (Input request : requestList) {
            List<String> valid = new List<String>();
            List<String> invalid = new List<String>();
            
            if (String.isBlank(request.objectApiName) || String.isBlank(request.inputFieldList)) {
                results.add(new Output());
                continue;
            }

            Map<String, Schema.SObjectField> fieldMap;
            try {
                fieldMap = Schema.getGlobalDescribe()
                    .get(request.objectApiName)
                    .getDescribe()
                    .fields.getMap();
            } catch (Exception e) {
                results.add(new Output());
                continue;
            }

            for (String field : request.inputFieldList.split(',')) {
                field = field.trim();
                if (fieldMap.containsKey(field)) {
                    valid.add(field);
                } else {
                    invalid.add(field);
                }
            }

            Output result = new Output();
            result.validFields = String.join(valid, ',');
            result.invalidFields = String.join(invalid, ',');
            result.validFieldsArray = valid; // Add array version
            results.add(result);
        }

        return results;
    }
}