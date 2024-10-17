@IsTest (seealldata = false)

private class WDI_Batch_SyncRecordsTest {

    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_FAILED = 'Failed';
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_SUCCESS = 'Success';
    public static final String MatterNAME = 'litify_pm__Matter__c';
    public static final String IntakeNAME = 'litify_pm__Intake__c';

    static testmethod void testFailedStatus() {
        
        Account a = WDIDataFactory.createAccount();
        litify_pm__Matter__c m = WDIDataFactory.createMatter(a);

        litify_docs__File_Info__c testFileInfo = WDIDataFactory.createFileInfo(MatterNAME,m.Id);
        testFileInfo.WDI_Status__C = STATUS_FAILED;
        UPDATE testFileInfo;

        test.startTest();
        WDI_Batch_SyncRecords Job = new WDI_Batch_SyncRecords();
        DataBase.executeBatch(Job);
        test.stopTest();
    }

    static testmethod void testInProgressStatus() {
        
        Account a = WDIDataFactory.createAccount();
        litify_pm__Matter__c m = WDIDataFactory.createMatter(a);

        litify_docs__File_Info__c testFileInfo = WDIDataFactory.createFileInfo(MatterNAME,m.Id);
        testFileInfo.WDI_Status__C = STATUS_IN_PROGRESS;
        UPDATE testFileInfo;

        test.startTest();
        WDI_Batch_SyncRecords Job = new WDI_Batch_SyncRecords();
        DataBase.executeBatch(Job);
        test.stopTest();
    }
}