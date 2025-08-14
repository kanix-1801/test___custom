/**
 * Created by Noa Salemon Karlinsky on 23/07/2024.
 */

public with sharing class UpdateRecordInvMethod {

    public class Input {

        @InvocableVariable(Required=true)
        public List<SObject> recordList;

        @InvocableVariable(Required=true)
        public String booleanFieldApiName;

        @InvocableVariable(Required=true Description='true / false')
        public Boolean BooleanFieldValue;

        @InvocableVariable(Required=true Description='max 200 , the records amount to update in every batch')
        public Integer batchSize;

    }
    public class Output {

        @InvocableVariable(Description='Success / Failed')
        public String jobStatus;

        @InvocableVariable(Description='if status equal Success - return batch job id')
        public String jobId;

        @InvocableVariable(Description='if status equal Failed - return error message')
        public String errorMessage;
    }

    @InvocableMethod(Label='Update Record in Batch')
    public static List<Output> updateRecords(List<Input> inputList) {

        Input input = inputList[0];
        Output output = new Output();
        List<Output> outputList = new List<UpdateRecordInvMethod.Output>();
        Integer batchSize = input.batchSize <= 200 ? input.batchSize : 200;


        if (!input.recordList.isEmpty()) {

            for (SObject record : input.recordList) {
                record.put(input.booleanFieldApiName, input.BooleanFieldValue);
            }

            UpdateRecordBtc updateRecordBtc = new UpdateRecordBtc(input.recordList);
            System.debug('input.recordList '+input.recordList);
            try {
                output.jobId = Database.executeBatch(updateRecordBtc, batchSize);
                output.jobStatus = 'Success';
            } catch (Exception ex) {
                output.jobStatus = 'Failed';
                output.errorMessage = ex.getMessage();
            }
        }

        outputList.add(output);
        return outputList;
    }

}