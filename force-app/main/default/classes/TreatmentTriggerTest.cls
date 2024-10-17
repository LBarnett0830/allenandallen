@isTest(SeeAllData=false)
private class TreatmentTriggerTest {
    // Unit test setup. Create all required data for testing
    @testSetup static void initData() {
        litify_pm__Public_Setup__c setting = new litify_pm__Public_Setup__c();
        setting.litify_pm__Run_Triggers__c = true;
        insert setting;
        List<Account> l_accounts = new List<Account>();
        Account acc1 = new Account(litify_pm__First_Name__c ='Account 1', litify_pm__Last_Name__c ='Last Name 1');
        acc1.BillingCity = 'New York';
        acc1.BillingCountry = 'United States';
        acc1.BillingStreet = 'Avenue';
        acc1.BillingPostalCode = '12412';
        l_accounts.add(acc1);
        Account acc2 = new Account(litify_pm__First_Name__c ='Account 2', litify_pm__Last_Name__c ='Last Name 2');
        acc2.BillingCity = 'New York';
        acc2.BillingCountry = 'United States';
        acc2.BillingStreet = 'Avenue';
        acc2.BillingPostalCode = '12412';
        l_accounts.add(acc2);
        insert l_accounts;
        List<litify_pm__Matter__c> l_matters = new List<litify_pm__Matter__c>();
        litify_pm__Matter__c matter1 = new litify_pm__Matter__c();
        matter1.litify_pm__Client__c = acc1.Id;
        //matter1.litify_pm__Companion__c = companion.Id;
        l_matters.add(matter1);
        insert l_matters;
        litify_pm__Injury__c injury = new litify_pm__Injury__c();
        injury.litify_pm__Matter__c = matter1.Id;
        insert injury;
    }
    /* 
test new treatment add 
*/
    static testmethod void test_trigger() {
        litify_pm__Injury__c injury  = [SELECT ID, litify_pm__Matter__c FROM litify_pm__Injury__c LIMIT 1];
        Account account1 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c ='Account 1'];
        Account account2 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c ='Account 2'];
        Test.startTest();
        litify_pm__Treatment__c treatment = new litify_pm__Treatment__c();
        treatment.litify_pm__Injury__c = injury.Id;
        treatment.litify_pm__Doctor_Facility__c = account1.Id;
        treatment.litify_pm__Treatment_Date__c = DAte.Today();
        treatment.litify_pm__Treatment_Notes__c  = 'TEST';
        insert treatment;
        Treatment_Summary__c summary  = [SELECT ID, Summary__c  FROM Treatment_Summary__c  WHERE Matter__c = :injury.litify_pm__Matter__c ];
        system.assert(summary.Summary__c != null);
        treatment.litify_pm__Doctor_Facility__c = account2.Id;
        update treatment;
        summary  = [SELECT ID,Summary__c   FROM Treatment_Summary__c  WHERE Matter__c = :injury.litify_pm__Matter__c ];
        system.assert(summary.Summary__c != null);
        delete treatment;
        List<Treatment_Summary__c> l_summary  = [SELECT ID,Summary__c   FROM Treatment_Summary__c  WHERE Matter__c = :injury.litify_pm__Matter__c ];
        system.assert(l_summary.size() == 0);
        Test.stopTest();
    }
}