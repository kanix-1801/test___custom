/**
 * Created by Noa Salemon Karlinsky on 23/07/2024.
 */

public with sharing class UpdateRecordBtc implements Database.Batchable<SObject> {

    private List<SObject> recordList;

    public UpdateRecordBtc(List<SObject> recordList) {
        this.recordList = recordList;
    }

    public Iterable<SObject> start(Database.BatchableContext context) {
        return this.recordList;
    }
    public void execute(Database.BatchableContext context, List<SObject> records) {
        update records;
    }

    public void finish(Database.BatchableContext context) {
    }


}