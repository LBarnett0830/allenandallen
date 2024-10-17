public class WDIIntakeTriggerHandler {


        public static void processrecs(List <litify_pm__Intake__c> recs) {
            //submit the job for processing
            //this will update the Worldox fields for Matter and Intake
            system.debug('Calling WDI_Queueable_Update_AEDTAble_Intake with the following records:');
            system.debug('Recs:' + recs);
            WDI_Queueable_Update_AEDtable_Intake processJob = new WDI_Queueable_Update_AEDtable_Intake(recs);
            system.debug('sending the job for processing');
            ID jobID = System.enqueueJob(processJob);
            system.debug('JobID:' + jobID);
    
        }
    }