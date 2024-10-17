public class WDI_Queueable_Update_AEDtable_Intake implements Queueable, Database.AllowsCallouts {

    public List<litify_pm__Intake__c> filesToProcess = new List<litify_pm__Intake__c>();
  
    public WDI_Queueable_Update_AEDtable_Intake( List<litify_pm__Intake__c> recs) {
        system.debug('Here 1');
        filesToProcess.addAll(recs);
        system.debug('Recs:' + recs);
        system.debug('filesToProcess:' + filesToProcess);
    }
  
    public void execute(QueueableContext context) {
      system.debug('in Execute WDI_Queueable_Update_AEDtable');
      system.debug('context:' + context);
      system.debug('filesToProcess:' + filesToProcess);
  
      if (filesToProcess.size() == 0) {
        return;
      }
      if (!wdi_queueable_helper.env.AED_Integration_Enabled && !Test.isRunningTest() ) {
        return;
      }
  
      //login once to Worldox for all file processing
      String processResponse = '';
      processResponse = WDI_Queueable_Helper.LOGINprocess();
      system.debug('LOGINprocess response:' + processResponse);
      if (processResponse != 'Success') {
        System.debug('Error Logging into Worldox');
        return;
      }
  
      for (litify_pm__Intake__c rec : filesToProcess) {
        try {
          system.debug('Process single record:' + rec + ' of ' + filesToProcess);
          WDI_Queueable_Helper.WDI_Id = rec.WDI_ID__c;
          WDI_Queueable_Helper.WDI_MatterID = rec.name.mid(4,12);
          WDI_Queueable_Helper.WDI_Name = EncodingUtil.urlEncode(rec.litify_pm__Display_Name__c, 'UTF-8').replace('+', '%20') ;
          WDI_Queueable_Helper.WDI_Matter_Name = EncodingUtil.urlEncode(rec.litify_pm__Display_Name__c, 'UTF-8').replace('+', '%20') ;
  
          system.debug('WDI_ID:' + WDI_Queueable_Helper.WDI_Id);
          if (WDI_Queueable_Helper.WDI_Id == null) {
            system.debug('ABORT ******************');
            return;
          }
  
          processResponse = WDI_Queueable_Helper.AEDTABLEprocess(
            5,
            WDI_Queueable_Helper.WDI_Id,
            WDI_Queueable_Helper.WDI_Name
          );
          system.debug('AEDTABLEprocess 5:' + processResponse);
          /*
          processResponse = WDI_Queueable_Helper.AEDTABLEprocess(
            6,
            WDI_Queueable_Helper.WDI_MatterId,
            WDI_Queueable_Helper.WDI_Matter_Name
          );
          system.debug('AEDTABLEprocess 6:' + processResponse);
          */
        } catch (Exception e) {
          system.debug('Error updating AEDTable: ' + e.getmessage());
        }
      }
  
      processResponse = WDI_Queueable_Helper.LOGOUTprocess();
      system.debug('LOGOUTprocess response:' + processResponse);
    }
  }