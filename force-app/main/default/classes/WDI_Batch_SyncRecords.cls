global with sharing class WDI_Batch_SyncRecords implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
  public static final String STATUS_IN_PROGRESS = 'In Progress';
  public static final string READY_TO_PROCESS_STATUS = 'Ready to Process';
  public static final String STATUS_FAILED = 'Failed';
  public static final String STATUS_NEW = 'New';
  public static final String STATUS_SUCCESS = 'Success';
  public String queryString = null;
  public static final Integer BATCH_SIZE = 1; // set for ideal limit of callouts required for Worldox integration (numerous API calls required)

  global Database.QueryLocator start(Database.BatchableContext BC) {
    system.debug('In QueryLocator for WDI_Batch_SyncRecords');
    String query = null;
    Integer LIMIT_INT = 200;
    Decimal throttle = WDI_Queueable_Helper.env.Integration_Throttle;
    if (Test.isRunningTest()) {
      LIMIT_INT = 1;
    }

    //First, see if any records are 'In Process' older than 10 minutes ago.  if so, set them to failed and increment the error count by 1
    Decimal numerrors = 0;
    Datetime dt = System.now();
    dt = dt.addMinutes(-10);
    List<litify_docs__File_Info__c> tempqueue = [
      SELECT Id, WDI_Status__c, WDI_Number_Attempts_Failed__c, lastModifiedDate
      FROM Litify_docs__File_Info__c
      WHERE WDI_Status__c = :STATUS_IN_PROGRESS AND lastModifiedDate <= :dt
    ];
    system.debug('tempqueue:' + tempqueue);
    for (litify_docs__File_Info__c rec : tempqueue) {
      if (rec.WDI_Number_Attempts_Failed__c == null) {
        numerrors = 0;
      } else {
        numerrors = rec.WDI_Number_Attempts_Failed__c;
      }
      rec.WDI_Number_Attempts_Failed__c = numerrors + 1;
      rec.WDI_Status__c = STATUS_FAILED;
      rec.WDI_Error_Log__c = 'Stuck in the status - In Progress';
    }
    if (tempqueue.size() > 0) {
      system.debug('updating tempqueue:' + tempqueue);
      update tempqueue;
    }

    //test login to Worldox - if fails, do not run batch process
    String status = WDI_Queueable_Helper.LOGINprocess();
    if (status != 'Success') {
      //abort by returning zero records
      system.debug('aborting batch process, error in logging in:' + status);
      queryString = 'SELECT ID FROM Litify_docs__File_Info__c WHERE WDI_Status__c = \'nothing to find\'';
    }

    if (queryString != null) {
      System.debug('QueryString = ' + queryString);
      return Database.getQueryLocator(queryString);
    } else {
      system.debug('building new query string.');
      //select ready to process first - see if there is enough for limit. If not, include status_failed...
      //SELECT Ready to Process
      //SELECT Failed (new variable LIMIT), modify Failed records status to be = "Ready To Process"
      //SELECT All Ready to Process
      List<litify_docs__File_Info__c> l_queue = new List<litify_docs__File_Info__c>();

      QueryString = 'SELECT ID, litify_docs__Related_To_Api_Name__c FROM litify_docs__File_Info__c ';
      QueryString +=
        'WHERE (WDI_Status__c = \'' +
        READY_TO_PROCESS_STATUS +
        '\')';
      QueryString += ' ORDER BY CreatedDate DESC';
      if (throttle > 0) {
        QueryString += ' LIMIT ' + String.valueOf(throttle);
      }
      l_queue = Database.query(QueryString);
      system.debug('Found ' + l_queue.size() + ' ready to process files');
      // if l_queue == null then newsize = throttle else if size()  throttle then newsize = throttle -  l_queue.size() else newsize = 0;
      //if (newsize > 0) { do below }
      system.debug('queue size:' + l_queue.size() + '    throttle:' + throttle);
      if (l_queue.size() < throttle) {
        system.debug('looking for failed documents to add to payload:' + (throttle - l_queue.size() ) );
        QueryString = 'SELECT ID, WDI_Status__c  FROM litify_docs__File_Info__c ';
        QueryString += 'WHERE WDI_Status__c = \'' + STATUS_FAILED + '\'';
        QueryString += ' ORDER BY LastModifiedDate ASC';
        if (throttle > 0) {
          QueryString += ' LIMIT ' + String.valueOf(throttle - l_queue.size());
        }

        l_queue = Database.query(QueryString);
        system.debug('Found ' + l_queue.size() + ' failed documents');
        for (litify_docs__File_Info__c item : l_queue) {
          item.WDI_Status__c = READY_TO_PROCESS_STATUS;
        }
        if (l_queue.size() > 0) {
          update l_queue;
        }
      }
        system.debug('selecting files that are ready to process');
        QueryString = 'SELECT ID, litify_docs__Related_To_Api_Name__c FROM litify_docs__File_Info__c ';
        QueryString +=
          'WHERE (WDI_Status__c = \'' +
          READY_TO_PROCESS_STATUS +
          '\')';
        QueryString += ' ORDER BY LastModifiedDate DESC';
        if (throttle > 0) {
          QueryString += ' LIMIT ' + String.valueOf(throttle);
        }
        l_queue = Database.query(QueryString);
        system.debug('Found ' + l_queue.size() + ' documents converted to In Progress' );

        for (litify_docs__File_Info__c item : l_queue) {
          item.WDI_Status__c = STATUS_IN_PROGRESS;
        }

        if (l_queue.size() > 0) {
          update l_queue;
        }
      

      QueryString = 'SELECT ID, litify_docs__Related_To_Api_Name__c FROM litify_docs__File_Info__c ';
      QueryString += 'WHERE (WDI_Status__c = \'' + STATUS_IN_PROGRESS + '\') ';
      QueryString += ' ORDER BY CreatedDate DESC';
      if (throttle > 0) {
        QueryString += ' LIMIT ' + String.valueOf(throttle);
      }
      system.debug('Query String returned to process: ' + QueryString);
      return Database.getQueryLocator(QueryString);
    }
  }

  global void execute(SchedulableContext SC) {
    system.debug('In execute SchedulableContext for WDI_Bach_SyncRecords');

    List<litify_docs__File_Info__c> queues = [
      SELECT ID, litify_docs__Related_To_Api_Name__c
      FROM litify_docs__File_Info__c
      WHERE WDI_Status__c = :READY_TO_PROCESS_STATUS
      LIMIT 1
    ];
    system.debug('found record(s) to process:' + queues.size());
    if (queues.size() > 0) {
      WDI_Batch_SyncRecords batchJob = new WDI_Batch_SyncRecords();
      ID batchprocessId = Database.executeBatch(batchJob, BATCH_SIZE);
    }
    system.abortJob(SC.getTriggerId());
    WDI_Utilities.launchScheduleJob();
  }

  global void execute(
    Database.BatchableContext BC,
    List<litify_docs__File_Info__c> scope
  ) {
    WDI_Queueable_Send_Documents_v3 processJob = new WDI_Queueable_Send_Documents_v3(
      scope
    );
    //submit the job for processing
    system.debug('sending the job for processing');
    ID jobID = System.enqueueJob(processJob);
  }

  global void finish(Database.BatchableContext BC) {
  }
}