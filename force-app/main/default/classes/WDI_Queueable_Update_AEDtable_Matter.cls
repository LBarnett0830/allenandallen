public class WDI_Queueable_Update_AEDtable_Matter implements Queueable, Database.AllowsCallouts {

    public List<litify_pm__Matter__c> filesToProcess = new List<litify_pm__Matter__c>();
  
    public WDI_Queueable_Update_AEDtable_Matter( List<litify_pm__Matter__c> recs) {
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

      if (!wdi_queueable_helper.env.Integration_Enabled && !Test.isRunningTest()) {
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
  
      //bulk retrieve associated Intakes for display name using filesToProcess
      set<String> idSet = new Set<String>();
      Map<String, String> intakeMap = new Map<String, String> ();
      for (litify_pm__Matter__c rec : filesToProcess) {
        if (String.IsNotBlank(rec.litify_pm__Primary_Intake__c)) {
          idSet.add(rec.litify_pm__Primary_Intake__c);
        }
      }
      List<litify_pm__Intake__c> intakeRecs = [SELECT Id, litify_pm__Display_Name__c FROM litify_pm__Intake__C WHERE Id In :idSet];
      for (litify_pm__Intake__c irec : intakeRecs) {
        intakeMap.put(irec.Id, irec.litify_pm__Display_Name__c);
      }

      for (litify_pm__Matter__c rec : filesToProcess) {
        try {
          system.debug('Process single record:' + rec + ' of ' + filesToProcess);
          WDI_Queueable_Helper.WDI_Id = rec.WDI_ID__c; 
          WDI_Queueable_Helper.WDI_MatterID = rec.name.mid(4,12);
          WDI_Queueable_Helper.WDI_Name = EncodingUtil.urlEncode(rec.litify_pm__Display_Name__c, 'UTF-8').replace('+', '%20') ;
          WDI_Queueable_Helper.WDI_Matter_Name = EncodingUtil.urlEncode(rec.litify_pm__Display_Name__c, 'UTF-8').replace('+', '%20') ;
          String intakeID = '';
          String intakeDisplayName = '';

          // check to see if there is a valid Intake ID. If so, find the display name and add it to the record.
          if (String.isNotBlank(rec.litify_pm__Primary_Intake__c)) {
            system.debug('assigning field 5 : ' + rec.WDI_ID__c + '   name:' + intakeMap.get(rec.litify_pm__Primary_Intake__c));
            intakeID = rec.WDI_ID__c;   
            intakeDisplayName = EncodingUtil.urlEncode(intakeMap.get(rec.litify_pm__Primary_Intake__c), 'UTF-8').replace('+', '%20') ;
          }

          system.debug('WDI_ID:' + WDI_Queueable_Helper.WDI_Id);
          if (WDI_Queueable_Helper.WDI_Id == null) {
            system.debug('ABORT ******************');
            return;
          }
  /*
          processResponse = WDI_Queueable_Helper.AEDTABLEprocess(
            5,
            WDI_Queueable_Helper.WDI_Id,
            WDI_Queueable_Helper.WDI_Name
          );
          system.debug('AEDTABLEprocess 5:' + processResponse);

        //old as of 2/28/2021
         processResponse = WDI_Queueable_Helper.AEDTABLEprocess(
            6,
            WDI_Queueable_Helper.WDI_MatterId,
            WDI_Queueable_Helper.WDI_Matter_Name
          );

          //new as of 2/28/2021
          processResponse = WDI_Queueable_Helper.AEDTABLEprocessField6(
            6,
            WDI_Queueable_Helper.WDI_MatterId,
            WDI_Queueable_Helper.WDI_Matter_Name,
            field5Id,
            field5Description
          )

  */
  /*
          processResponse = WDI_Queueable_Helper.AEDTABLEprocess(
            6,
            WDI_Queueable_Helper.WDI_MatterId,
            WDI_Queueable_Helper.WDI_Matter_Name
          );
  */
        processResponse = WDI_Queueable_Helper.AEDTABLEprocessField6(
          6, 
          WDI_Queueable_Helper.WDI_MatterId,
          WDI_Queueable_Helper.WDI_Matter_Name, 
          intakeID, 
          intakeDisplayName);
          system.debug('AEDTABLEprocess 6:' + processResponse);
        } catch (Exception e) {
          system.debug('Error updating AEDTable: ' + e.getmessage());
        }
      }
  
      processResponse = WDI_Queueable_Helper.LOGOUTprocess();
      system.debug('LOGOUTprocess response:' + processResponse);
    }
  }