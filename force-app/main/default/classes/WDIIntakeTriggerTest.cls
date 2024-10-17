@IsTest (seealldata = false)

public with sharing class WDIIntakeTriggerTest {

    @istest
    public static void WDIIntakeTriggerTest1() {
        Account a = WDIDataFactory.createAccount();
        litify_pm__Intake__c i = WDIDataFactory.createIntake(a);
    }




    @istest
    public static void WDIIntakeTriggerTest2() {

        test.starttest();
            litify_pm__Case_Type__c ct = WDIDataFactory.createCaseType();
            Account a = WDIDataFactory.createAccount();
            litify_pm__Intake__c i = WDIDataFactory.createIntake(a);
            i.litify_pm__Case_Type__c = ct.Id;
            Account b = WDIDataFactory.createAccount();
            i.litify_pm__Client__c = b.Id;
            i.litify_pm__Description__c = 'something new';
            update i;
        test.stoptest();
    }
}