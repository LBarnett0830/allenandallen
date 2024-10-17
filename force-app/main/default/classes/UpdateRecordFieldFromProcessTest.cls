@isTest(SeeAllData=false)
private class  UpdateRecordFieldFromProcessTest {
   // Unit test setup. Create all required data for testing
    @testSetup static void initData() {
        litify_pm__Public_Setup__c setting = new litify_pm__Public_Setup__c();
        setting.litify_pm__Run_Triggers__c = true;
        insert setting;
        Account a = new Account();
        a.Name = 'Test Client';
        a.litify_pm__First_Name__c = 'Test';
        a.litify_pm__Last_Name__c = 'Client';
        insert a;
        List<litify_PM__Matter__c> mattersToInsert = new List<litify_PM__Matter__c>();
        litify_PM__Matter__c m1 = new litify_PM__Matter__c();
        m1.litify_pm__Client__c = a.Id;
        m1.litify_pm__Display_Name__c = 'matter test 1';
        mattersToInsert.add(m1);
        insert mattersToInsert;
    }

     static testmethod void test_action() {
        litify_pm__Matter__c matter1 = [SELECT ID FROM litify_pm__Matter__c LIMIT 1];
        Test.startTest();
        List<UpdateRecordFieldFromProcess.InputParam> l_inputParams = new List<UpdateRecordFieldFromProcess.InputParam>();
        UpdateRecordFieldFromProcess.InputParam param = new UpdateRecordFieldFromProcess.InputParam();
        param.recordId = matter1.Id;
        param.recordField = 'litify_pm__Docket_Number__c';
        param.str_value = 'litify_pm__Docket_Number__c';
        l_inputParams.add(param);
        UpdateRecordFieldFromProcess.updateRecordField(l_inputParams);
        matter1 = [SELECT ID,litify_pm__Docket_Number__c FROM litify_pm__Matter__c LIMIT 1];
       	system.assert(matter1.litify_pm__Docket_Number__c =='litify_pm__Docket_Number__c');
        l_inputParams = new List<UpdateRecordFieldFromProcess.InputParam>();
        param = new UpdateRecordFieldFromProcess.InputParam();
        param.recordId = matter1.Id;
        param.recordField = 'Discharge Date';
        param.date_value = Date.Today();
        l_inputParams.add(param);
        UpdateRecordFieldFromProcess.updateRecordField(l_inputParams);
        matter1 = [SELECT ID,litify_pm__Discharge_Date__c FROM litify_pm__Matter__c LIMIT 1];
       	system.assert(matter1.litify_pm__Discharge_Date__c == Date.Today());
        l_inputParams = new List<UpdateRecordFieldFromProcess.InputParam>();
        param = new UpdateRecordFieldFromProcess.InputParam();
        param.recordId = matter1.Id;
        param.recordField = 'litify_pm__Amount_Due_to_Client__c';
        param.number_value = 100;
        l_inputParams.add(param);
        UpdateRecordFieldFromProcess.updateRecordField(l_inputParams);
        matter1 = [SELECT ID,litify_pm__Amount_Due_to_Client__c FROM litify_pm__Matter__c LIMIT 1];
       	system.assert(matter1.litify_pm__Amount_Due_to_Client__c == 100);
        Test.stopTest();
    }
}