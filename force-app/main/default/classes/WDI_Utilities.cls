global with sharing class WDI_Utilities {
    public static String SCHEDULER_NAME = 'WDI SYNC JOB';
    public static final Integer INTERVAL_INT = 2;
    public static final String INTERVAL_STRING ='2';

    public static void launchScheduleJob() {
        if (Test.IsRunningTest() ) {
            SCHEDULER_NAME = 'TESTClass WDI SYNC JOB';
        }
        string minutes = String.valueOf(system.now().addMinutes(INTERVAL_INT).minute() );
        if (getInterval() != null) {
            minutes = String.valueOf(system.now().addMinutes(getInterval()).minute());
        }
        WDI_Batch_SyncRecords scheduleJob = new WDI_Batch_SyncRecords();

        String seconds = '0';
        string hours = '*';
        String dayOfMonth = '*';
        String dayOfWeek = '?';
        String month = '*';
        String year = '*';
        String sch = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
        system.schedule(SCHEDULER_NAME, sch, scheduleJob);

    }

    //get scheduler interval
    public static Integer getInterval() {
        wdi_queueable_helper.WDI_Environment currec = wdi_queueable_helper.env;
        if (currec == null) {
            return INTERVAL_INT;
        } else {
            return currec.Scheduled_Interval;
        }
    }

    /*
//code to initiate batch process from Immediate Window
WDI_Batch_SyncRecords scheduleJob = new WDI_Batch_SyncRecords();
		string minutes = '20';

        String seconds = '0';
        string hours = '*';
        String dayOfMonth = '*';
        String dayOfWeek = '?';
        String month = '*';
        String year = '*';
        String sch = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
String jobID = System.schedule('WDI SYNC JOB', sch, scheduleJob) ;


    */
}