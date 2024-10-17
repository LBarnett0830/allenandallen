@IsTest(SeeAllData=false)

private class WDI_Queueable_Update_AEDtable_IntakeTest {

    static testmethod void testInsert() {
        Account a = WDIDataFactory.createAccount();
        //testmock to provide a successful login for Worldox
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockLOGInprocess() );

        test.starttest();
        litify_pm__Intake__c m = WDIDataFactory.createIntake(a);
        test.stoptest();
    }

    static testmethod void testInsertFailure() {
        Account a = WDIDataFactory.createAccount();
        
        test.starttest();
        litify_pm__Intake__c m = WDIDataFactory.createIntake(a);
        test.stoptest();
    }
}