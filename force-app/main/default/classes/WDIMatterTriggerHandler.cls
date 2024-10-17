public class WDIMatterTriggerHandler {

    public static void processrecs(List <litify_pm__Matter__c> recs) {
        //submit the job for processing
        //this will update the Worldox fields for Matter and Intake
        system.debug('Calling WDI_Queueable_Update_AEDTAble with the following records:');
        system.debug('Recs to process:' + recs);
        WDI_Queueable_Update_AEDtable_Matter processJob = new WDI_Queueable_Update_AEDtable_Matter(recs);
        system.debug('sending the job for processing');
        ID jobID = System.enqueueJob(processJob);
        system.debug('JobID:' + jobID);

    }
}