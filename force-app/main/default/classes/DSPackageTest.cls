@isTest(SeeAllData=false)
private class  DSPackageTest {
    @testSetup static void initData() {
        litify_pm__Public_Setup__c setting = new litify_pm__Public_Setup__c();
        setting.litify_pm__Run_Triggers__c = true;
        insert setting;
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        List<Account> l_accounts = new List<Account>();
        Account acc1 = new Account(litify_pm__First_Name__c ='Account 1', litify_pm__Last_Name__c ='Last Name 1');
        acc1.BillingCity = 'New York';
        acc1.BillingCountry = 'United States';
        acc1.BillingStreet = 'Avenue';
        acc1.BillingPostalCode = '12412';
        acc1.RecordTypeId = recordTypeId;
        l_accounts.add(acc1);
        Account acc2 = new Account(litify_pm__First_Name__c ='Account 2', litify_pm__Last_Name__c ='Last Name 2');
        acc2.BillingCity = 'New York';
        acc2.BillingCountry = 'United States';
        acc2.BillingStreet = 'Avenue';
        acc2.BillingPostalCode = '12412';
        acc2.RecordTypeId = recordTypeId;
        l_accounts.add(acc2);
        insert l_accounts;
        litify_pm__Intake__c intake = new litify_pm__Intake__c();
        intake.litify_pm__Client__c = acc1.Id;
        insert intake;
    	litify_pm__Matter__c matter1 = new litify_pm__Matter__c();
        matter1.litify_pm__Client__c = acc1.Id;
        matter1.litify_pm__Primary_Intake__c  = intake.Id;
        insert matter1;
        insert new dfsle__EnvelopeConfiguration__c(Name ='TEST 32453', dfsle__SourceObject__c = 'litify_pm__Matter__c', dfsle__Active__c = true);
    }

    static testmethod void test_MatterAndIntakeTrigger() {
        Account acc1 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c ='Account 1'];
        Contact cont1 = [SELECT ID FROM Contact WHERE AccountId =:acc1.Id];
        Account acc2 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c ='Account 2'];
        Contact cont2 = [SELECT ID FROM Contact WHERE AccountId =:acc2.Id];
        Test.startTest();
        litify_pm__Intake__c intake = new litify_pm__Intake__c();
        intake.litify_pm__Client__c = acc1.Id;
        insert intake;
        intake = [SELECT Id, Client_Contact_ds__c FROM litify_pm__Intake__c WHERE  Id = : intake.Id];
        system.assert(intake.Client_Contact_ds__c == cont1.Id);
        litify_pm__Matter__c matter1 = new litify_pm__Matter__c();
        matter1.litify_pm__Client__c = acc1.Id;
        matter1.litify_pm__Primary_Intake__c  = intake.Id;
        insert matter1;
        matter1 = [SELECT Id, Client_Contact_ds__c FROM litify_pm__Matter__c WHERE  Id = : matter1.Id];
        system.assert(matter1.Client_Contact_ds__c == cont1.Id);
        intake.litify_pm__Client__c = acc2.Id;
        update intake;
        intake = [SELECT Id, Client_Contact_ds__c FROM litify_pm__Intake__c WHERE  Id = : intake.Id];
        system.assert(intake.Client_Contact_ds__c == cont2.Id);
        matter1.litify_pm__Client__c = acc2.Id;
        update matter1;
        matter1 = [SELECT Id, Client_Contact_ds__c FROM litify_pm__Matter__c WHERE  Id = : matter1.Id];
        system.assert(matter1.Client_Contact_ds__c == cont2.Id);
        Test.stopTest();
    }

    static testmethod void test_defaultIntakeBatch() {
        Account acc1 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c ='Account 1'];
        Contact cont1 = [SELECT ID FROM Contact WHERE AccountId =:acc1.Id];
        litify_pm__Intake__c intake = new litify_pm__Intake__c();
        intake.litify_pm__Client__c = acc1.Id;
        insert intake;
    	Test.startTest();
        DSPostInstallScript batchJob = new DSPostInstallScript();
        batchJob.ACTION_TYPE = 'INTAKE_UPDATE';
		Database.executeBatch(batchJob);
        Test.stopTest();
        intake = [SELECT Id, Client_Contact_ds__c FROM litify_pm__Intake__c WHERE  Id = : intake.Id];
        system.assert(intake.Client_Contact_ds__c == cont1.Id);
    }

    static testmethod void test_defaultMatterBatch() {
        Account acc1 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c ='Account 1'];
        Contact cont1 = [SELECT ID FROM Contact WHERE AccountId =:acc1.Id];
        litify_pm__Intake__c intake = new litify_pm__Intake__c();
        intake.litify_pm__Client__c = acc1.Id;
        insert intake;
        litify_pm__Matter__c matter1 = new litify_pm__Matter__c();
        matter1.litify_pm__Client__c = acc1.Id;
        matter1.litify_pm__Primary_Intake__c  = intake.Id;
        insert matter1;
    	Test.startTest();
        DSPostInstallScript batchJob = new DSPostInstallScript();
        batchJob.ACTION_TYPE = 'MATTER_UPDATE';
		Database.executeBatch(batchJob);
        Test.stopTest();
        matter1 = [SELECT Id, Client_Contact_ds__c FROM litify_pm__Matter__c WHERE  Id = : matter1.Id];
        system.assert(matter1.Client_Contact_ds__c == cont1.Id);
    }

    static testmethod void test_templateSelector() {
        Account acc1 = [SELECT ID FROM Account WHERE litify_pm__First_Name__c ='Account 1'];
        Contact cont1 = [SELECT ID FROM Contact WHERE AccountId =:acc1.Id];
        litify_pm__Intake__c intake = new litify_pm__Intake__c();
        intake.litify_pm__Client__c = acc1.Id;
        insert intake;
        litify_pm__Matter__c matter1 = new litify_pm__Matter__c();
        matter1.litify_pm__Client__c = acc1.Id;
        matter1.litify_pm__Primary_Intake__c  = intake.Id;
        insert matter1;
    	Test.startTest();
        
        List<Map<String, String>>  l_records = DocusignTemplateMenuController.getTemplates(matter1.Id);
        system.assert(l_records.size() >0 );
        Test.stopTest();
        
    }
}