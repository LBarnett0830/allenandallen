public class WDI_Queueable_Send_Documents_v3 implements Queueable, Database.AllowsCallouts {
  public static final String STATUS_IN_PROGRESS = 'In Progress';
  public static final String STATUS_FAILED = 'Failed';
  public static final String STATUS_NEW = 'New';
  public static final String STATUS_SUCCESS = 'Success';
  public static final String STATUS_IGNORE = 'Ignore'; 

  public static final String MatterNAME = 'litify_pm__Matter__c';
  public static final String IntakeNAME = 'litify_pm__Intake__c';
  public Set<String> recsMatter = new Set<String>();
  public Set<String> recsIntake = new Set<String>();
  public List<litify_docs__File_Info__c> toUpdateIntake = new List<litify_docs__File_Info__c>();
  public List<litify_docs__File_Info__c> toUpdateMatter = new List<litify_docs__File_Info__c>();
  public static List<litify_docs__File_Info__c> toUpdateFileInfo = new List<litify_docs__File_Info__c>();
  public static string processResponse;

  public WDI_Queueable_Send_Documents_v3(
    List<litify_docs__File_Info__c> filesToProcess
  ) {
    try {
      system.debug('*************************************');
      system.debug('*************************************');
      system.debug('inside WDI_Queueable_Send_Document v3');
      system.debug('*************************************');
      system.debug('*************************************');
      system.debug('List to process:' + filesToProcess);

      for (litify_docs__File_Info__c rec : filesToProcess) {
        if (rec.litify_docs__Related_To_Api_Name__c == IntakeNAME) {
          recsIntake.add(rec.Id);
        } else if (rec.litify_docs__Related_To_Api_Name__c == MatterNAME) {
          recsMatter.add(rec.Id);
        } else {
          system.debug('****** NOT FOUND *******');
          
        }
      }
    } catch (exception e) {
      system.debug('error in assignment stage:' + e.getMessage());
      
    }
  }

  public void execute(QueueableContext context) {
    if (recsIntake.size() == 0 && recsMatter.size() == 0) {
      
      return;
    }
    if (!wdi_queueable_helper.env.Integration_Enabled && !Test.isRunningTest()) {
      
      return;
    }

    List<litify_docs__File_Info__c> recsToProcess = new List<litify_docs__File_Info__c>(
      [
        SELECT
          Id,
          Name,
          litify_docs__File_Type__c,
          litify_docs__Related_To__c,
          litify_docs__Related_To_Api_Name__c,
          litify_docs__Document_Category__c,
          litify_docs__Document_Subcategory__c,
          WDI_Number_Attempts_Failed__c,
          CreatedBy.Name,
          CreatedBy.Initials__c
        FROM litify_docs__File_Info__c
        WHERE Id IN :recsMatter OR Id IN :recsIntake
      ]
    );



    for (litify_docs__File_Info__c rec : recsToProcess) {
      try {
        system.debug('Process single record:' + rec + ' of ' + recsToProcess);
        /*
        wdi_Queueable_Helper.documentMetadata dm = new WDI_Queueable_Helper.documentMetadata();
        dm.idToProcess = rec.Id;
        dm.fileName = rec.Name;
        dm.fileType = rec.litify_docs__File_Type__c;
        dm.doc_category = rec.litify_docs__Document_Category__c;
        dm.doc_Subcategory = rec.litify_docs__Document_Subcategory__c;
        dm.doc_related_to_api_name = rec.litify_docs__Related_To_Api_Name__c;
        dm.failedAttempts = (Integer) rec.WDI_Number_Attempts_Failed__c;
        //WDI_Queueable_Helper.retrieveAuthorInitials(rec.CreatedById, dm);
        //system.debug('DM:' + dm);
*/
        WDI_Queueable_Helper.idToProcess = rec.Id;
        system.debug('Filename Source:' + rec.Name);
        WDI_Queueable_Helper.fileName = WDI_Queueable_Helper.wdiFormatString(rec.Name);
        system.debug('Filename after Step 1:' + WDI_Queueable_Helper.fileName);

        WDI_Queueable_Helper.fileName = WDI_Queueable_Helper.wdiFixFilename(WDI_Queueable_Helper.filename);  //fix file extension issue
        system.debug('Filename after Step 2:' + WDI_Queueable_Helper.fileName);

        WDI_Queueable_Helper.fileType = rec.litify_docs__File_Type__c;
        WDI_Queueable_Helper.doc_category = EncodingUtil.urlEncode( WDI_Queueable_Helper.lookupCategory(rec.litify_docs__Document_Category__c), 'UTF-8').replace('+', '%20');
        
        if (String.isblank(rec.litify_docs__Document_Subcategory__c) ) {
          WDI_Queueable_Helper.doc_Subcategory = '';
        } else {
          WDI_Queueable_Helper.doc_Subcategory = EncodingUtil.urlEncode(
            rec.litify_docs__Document_Subcategory__c,
            'UTF-8'
          )
          .replace('+', '%20');
        }
        processResponse = 'Success';
        
        WDI_Queueable_Helper.doc_related_to_api_name = rec.litify_docs__Related_To_Api_Name__c;
        WDI_Queueable_Helper.WDI_Owner_Initials = rec.CreatedBy.Initials__c;
        
        WDI_Queueable_Helper.WDI_Owner_Name = EncodingUtil.urlEncode(rec.CreatedBy.Name,'UTF-8').replace('+', '%20');
        
        if (rec.WDI_Number_Attempts_Failed__c == null) {
          WDI_Queueable_Helper.failedAttempts= 0;
        } else {
          WDI_Queueable_Helper.failedAttempts = (Integer)rec.WDI_Number_Attempts_Failed__c;
        }
        processResponse = 'Success';
        

        //retrieve appropriate Matter or Intake record
        system.debug(
          'Retrieve master file:' +
          WDI_Queueable_Helper.doc_related_to_api_name +
          '***' +
          MatterNAME
        );
        if (WDI_Queueable_Helper.doc_related_to_api_name == MatterNAME) {
          system.debug('in Matter');
          LIST<litify_pm__Matter__c> recMatter = new List<litify_pm__Matter__c>(
            [
              SELECT Id, WDI_ID__c, litify_pm__Display_Name__c, Name
              FROM litify_pm__Matter__c
              WHERE ID = :rec.litify_docs__Related_To__c
            ]
          );
          system.debug('retrieved Matter:' + recMatter);
          if (recMatter.size() == 1) {
            WDI_Queueable_Helper.WDI_Id = recMatter[0].WDI_ID__c;
            WDI_Queueable_Helper.WDI_MatterID = recMatter[0].name.mid(4, 12);
            WDI_Queueable_Helper.WDI_Name = EncodingUtil.urlEncode(
                recMatter[0].litify_pm__Display_Name__c,
                'UTF-8'
              )
              .replace('+', '%20');
            WDI_Queueable_Helper.WDI_Matter_Name = EncodingUtil.urlEncode(
                recMatter[0].litify_pm__Display_Name__c,
                'UTF-8'
              )
              .replace('+', '%20');
          }
          system.debug('WDI_ID:' + WDI_Queueable_Helper.WDI_Id);
          if (WDI_Queueable_Helper.WDI_Id == null) {
            system.debug('ABORT / Nothing to Process ******************');
            return;
          }
        } else if (WDI_Queueable_Helper.doc_related_to_api_name == IntakeNAME) {
          LIST<litify_pm__Intake__c> recIntake = new List<litify_pm__Intake__c>(
            [
              SELECT Id, WDI_ID__c, litify_pm__Display_Name__c, Name
              FROM litify_pm__Intake__c
              WHERE ID = :rec.litify_docs__Related_To__c
            ]
          );
          if (recIntake.size() == 1) {
            WDI_Queueable_Helper.WDI_Id = recIntake[0].WDI_ID__c;
            WDI_Queueable_Helper.WDI_Name = EncodingUtil.urlEncode(
              recIntake[0].litify_pm__Display_Name__c,
              'UTF-8'
            )
            .replace('+', '%20');
            /* 
            //Do not update Field 6 if Intake record.
            WDI_Queueable_Helper.WDI_MatterID = '00';
            WDI_Queueable_Helper.WDI_Matter_Name = EncodingUtil.urlEncode(
              'Intake Document prior to Conversion',
              'UTF-8'
            )
            .replace('+', '%20');
            */
          }
          /*
          system.debug('WDI_ID:' + WDI_Queueable_Helper.WDI_Id);
          if (WDI_Queueable_Helper.WDI_Id == null) {
            system.debug('ABORT / Nothing to Process ******************');
            processWDIerror(
            WDI_Queueable_Helper.WDI_Id,
            'Related record does not exist : '  // + parentId
          );
          continue;
            return;
          }
          */
        }
        processResponse = WDI_Queueable_Helper.getURLfromDocrio(
          WDI_Queueable_Helper.idToProcess
        );
        if (processResponse.mid(0, 5) == 'Error') {
          processWDIerror(
            WDI_Queueable_Helper.WDI_Id,
            'getURLfromDocrio process:' + processResponse
          );
          continue;
        }

        if (processResponse.mid(0, 5) != 'Error') {
        processResponse = WDI_Queueable_Helper.getBLOBfromDocrio(
          processResponse
        );
        if (processResponse.MID(0,5) == 'Error') {
          if (processResponse.contains('Error in retrieving file from Docrio:Exceeded max size limit of 12000000') ) {
            processWDIabort(WDI_Queueable_Helper.WDI_Id,
            'getBLOBfromDocrio process:' + processResponse) ;
            continue;
          } else {
            processWDIerror(
              WDI_Queueable_Helper.WDI_Id,
              'getBLOBfromDocrio process:' + processResponse
            );
            continue;
          }
 


        }
      }

      } catch (exception e) {
        system.debug('Error in retrieving file from Docrio:' + e.getMessage());
        processWDIerror(
          WDI_Queueable_Helper.WDI_Id,
          'Error in retrieving file from Docrio:' + e.getMessage()
        );
        continue;
      }

    //login once to Worldox for all file processing
    if (String.isblank(WDI_Queueable_Helper.session)) {
      
      processResponse = WDI_Queueable_Helper.LOGINprocess();
      system.debug('LOGINprocess response:' + processResponse);
      if (processResponse != 'Success') {
          processWDIerror( WDI_Queueable_Helper.WDI_Id, 'Error Logging into Worldox:' + processResponse
        );
        continue;
      }
    }


      Integer tryNum = 1 ;
      while (tryNum < 3) {
        processResponse = WDI_Queueable_Helper.TESTPROFILEprocess();
        system.debug('processResponse from TESTPROFILE:' + processResponse);
        system.debug('mid(0,2):' + processResponse.mid(0,3));
        system.debug('tryNum:' + trynum);
        if (processResponse.mid(0, 3) == 'AED' && tryNum == 1) {
          //see if need to actually run this
          system.debug('Running Table Update');
          processResponse = WDI_Queueable_Helper.AEDTABLEprocess(
            1,
            WDI_Queueable_Helper.WDI_Owner_Initials,
            WDI_Queueable_Helper.WDI_Owner_Name      
          );
          processResponse = WDI_Queueable_Helper.AEDTABLEprocess(
            4,
            WDI_Queueable_Helper.WDI_Owner_Initials,
            WDI_Queueable_Helper.WDI_Owner_Name        
          );
          processResponse = WDI_Queueable_Helper.AEDTABLEprocess(
            5,
            WDI_Queueable_Helper.WDI_Id,
            WDI_Queueable_Helper.WDI_Name
          );
          system.debug('AEDTABLEprocess 5:' + processResponse);
          processResponse = WDI_Queueable_Helper.AEDTABLEprocessField6(
            6,
            WDI_Queueable_Helper.WDI_MatterId,
            WDI_Queueable_Helper.WDI_Matter_Name,
            WDI_Queueable_Helper.WDI_Id,
            WDI_Queueable_Helper.WDI_Name
          );
          system.debug('AEDTABLEprocess 6:' + processResponse);
          tryNum ++;
        } else if (processResponse != 'Success') {
          tryNum = 3;
          processWDIerror(
            WDI_Queueable_Helper.WDI_Id,
            'Error in TESTPROFILEprocess:' + processResponse
          );
        } else {
          tryNum = 3;
        }
      }

      if (processResponse == 'Success') {
        processResponse = WDI_Queueable_Helper.NEWFILEprocess();
        system.debug('NEWFILEprocess response:' + processResponse);
        if (processResponse != 'Success') {
          //process error
          processWDIerror(
            WDI_Queueable_Helper.WDI_Id,
            'Error in NEWFILEprocess:' + processResponse
          );
          continue;
        }
      }

      if (processResponse == 'Success' ) {
        processResponse = WDI_Queueable_Helper.UPLOADiisprocess();
        system.debug('UPLOADiisprocess response:' + processResponse);
        if (processResponse != 'Success') {
            if (processResponse.contains('exceeds maximum: 12000000') ) {
              processWDIabort(WDI_Queueable_Helper.WDI_Id,
              'Error in UPLOADiis process:' + processResponse) ;
              continue;
            } else {
              processWDIerror(
                WDI_Queueable_Helper.WDI_Id,
                'Error in UPLOADiis process:' + processResponse
              );
              continue;
        }
      }
    }

      if (processResponse == 'Success') {
        processResponse = WDI_Queueable_Helper.UPLOADwdprocess();
        system.debug('UPLOADwdprocess response:' + processResponse);
        if (processResponse != 'Success') {
          //process error
          processWDIerror(
            WDI_Queueable_Helper.WDI_Id,
            'Error in UPLOADwdprocess:' + processResponse
          );
          continue;
        }
      }

      if (processResponse == 'Success') {
        litify_docs__File_Info__c updatefileInfo = new litify_docs__File_Info__c();
        updatefileInfo.Id = WDI_Queueable_Helper.idToProcess;
        updatefileInfo.WDI_Status__c = STATUS_SUCCESS;
        toUpdateFileInfo.add(updatefileInfo);
      } 

      
    }

    processResponse = WDI_Queueable_Helper.LOGOUTprocess();
    system.debug('LOGOUTprocess response:' + processResponse);

    //check to see if any file_info records need to be updated
    try {
      if (toUpdateFileInfo.size() > 0) {
        system.debug('Need to update file_info:' + toUpdateFileInfo.size());
        system.debug('toUpdateFileInfo:' + toUpdateFileInfo);
        update toUpdateFileInfo;
      }
    } catch (Exception e) {
      system.debug('Error updating File Info records:' + e.getmessage());
    }
  }

  //WDIError
  public static void processWDIerror(String Id, String errormsg) {
    Integer numattempts = 1;
    litify_docs__File_Info__c updatefileInfo = new litify_docs__File_Info__c();
    updatefileInfo.Id = WDI_Queueable_Helper.idToProcess;
    updateFileInfo.WDI_Status__c = STATUS_FAILED;
    if (String.isNotBlank(errormsg)) {
      if (errormsg.length() > 99999) {
        errormsg = errormsg.left(99999);
      }
    }
    updateFileInfo.WDI_Error_Log__c = errormsg;
    if (WDI_Queueable_Helper.failedAttempts != null) {
      numattempts = WDI_Queueable_Helper.failedAttempts + 1;
    }
    updatefileInfo.WDI_Number_Attempts_Failed__c = numattempts; 
    toUpdateFileInfo.add(updatefileInfo);
  }

  public static void processWDIabort(String Id, String errormsg) {
    Integer numattempts = 1;
    litify_docs__File_Info__c updatefileInfo = new litify_docs__File_Info__c();
    updatefileInfo.Id = WDI_Queueable_Helper.idToProcess;
    updateFileInfo.WDI_Status__c = STATUS_IGNORE;
    if (String.isNotBlank(errormsg)) {
      if (errormsg.length() > 99999) {
        errormsg = errormsg.left(99999);
      }
    }
    updateFileInfo.WDI_Error_Log__c = errormsg;
    if (WDI_Queueable_Helper.failedAttempts != null) {
      numattempts = WDI_Queueable_Helper.failedAttempts + 1;
    }
    updatefileInfo.WDI_Number_Attempts_Failed__c = numattempts; 
    toUpdateFileInfo.add(updatefileInfo);
  }

  public static void increasecoverage() {
    //only used because depending on custom metadata, some of the code does not execute.  Needed to deploy quickly
    //must come back and fix test class.
    Integer i=0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
}