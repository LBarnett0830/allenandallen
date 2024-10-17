global class WDIBatchDeleteLitifyDocs implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    public static final string STATUS_SUCCESS = 'Success';
    public static final Integer BATCH_SIZE = 25;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        //Select all records where flag ToDelete is True
        String query = 'SELECT Id FROM litify_docs__File_Info__c WHERE WDI_Status__c = \'' + STATUS_SUCCESS + '\'';
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext SC) {
        database.executebatch(new WDIBatchDeleteLitifyDocs(), BATCH_SIZE );
    }

    global void execute(Database.BatchableContext bc, List<litify_docs__File_Info__c> records){
        // process each batch of records
        // use Docrio API to delete documents
        
        //create comma delimited string of ID's to delete
        String idString;
        String[] temp1 = New String[]{};
        for (litify_docs__File_Info__c rec : records) {
            temp1.add(rec.Id);
        }
        idString = string.join(temp1,',');
        
        system.debug('Deleting records:' + idString);
        system.debug('calling deletefiles.');
        if (!test.isRunningTest() ) {
            WDIAWSService.deleteFiles(idString);
        }
   

    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        //maybe log that documents were deleted
    }    
}