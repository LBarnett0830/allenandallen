Global class APDisbursementBatchSchedule implements Schedulable {
    
    public void execute(system.SchedulableContext sc){
        APDisbursementBatch objBatch =new APDisbursementBatch();
        database.executeBatch(objBatch);
    }
}