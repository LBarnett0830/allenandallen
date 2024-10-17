@IsTest (seealldata = false)

    public with sharing class WDIMatterTriggerTest {
    
        @istest
        public static void WDIMatterTriggerTest1() {
            system.debug('in triggerTest1');

            test.starttest();
                Account a = WDIDataFactory.createAccount();
                litify_pm__Matter__c i = WDIDataFactory.createMatter(a);
            test.stoptest();
        }



        @istest
        public static void WDIMatterTriggerTest2() {
            system.debug('in triggerTest2');

            test.starttest();
            litify_pm__Case_Type__c ct = WDIDataFactory.createCaseType();
                Account a = WDIDataFactory.createAccount();
                litify_pm__Matter__c m = WDIDataFactory.createMatter(a);
                m.litify_pm__Case_Type__c = ct.Id;
                Account b = WDIDataFactory.createAccount();
                m.litify_pm__Client__c = b.Id;
                m.litify_pm__Description__c = 'something new';
                update m;
            test.stoptest();
        }

        @istest
        public static void WDIMatterTriggerTestBulk() {
            System.debug('in TriggerTestBulk');
            Integer imax = 10;
            litify_pm__Matter__c m = new litify_pm__Matter__c();

            litify_pm__Case_Type__c ct = WDIDataFactory.createCaseType();
            Account a = WDIDataFactory.createAccount();
            Account b = WDIDataFactory.createAccount();
            List<litify_pm__Matter__c> mrecs = New List<litify_pm__Matter__c>();

            FOR (Integer i=0;i < imax;i++) {
                system.debug('in for loop i=' + i);
                m = WDIDataFactory.createMatter(a);
                m.litify_pm__Case_Type__c = ct.Id;
                m.litify_pm__Client__c = b.Id;
                m.litify_pm__Description__c = 'something new';
                mrecs.add(m);
            }
            update mrecs;

        }

    }