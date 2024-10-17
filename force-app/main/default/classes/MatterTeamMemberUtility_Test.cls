@isTest(SeeAllData=false)
private class MatterTeamMemberUtility_Test{
    
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

        litify_PM__Matter__c m2 = new litify_PM__Matter__c();
        m2.litify_pm__Client__c = a.Id;
        m2.litify_pm__Display_Name__c = 'matter test 2';
        m2.MTM_Ids__c = '0000000000000000';
        mattersToInsert.add(m2);

        litify_PM__Matter__c m3 = new litify_PM__Matter__c();
        m3.litify_pm__Client__c = a.Id;
        m3.litify_pm__Display_Name__c = 'matter test 3';
        m3.MTM_Ids__c = '0000000000000000';
        mattersToInsert.add(m3);

        insert mattersToInsert;

        List<User> usersToInsert = new List<User>();

        User u1 = new User();
        u1.FirstName = 'Test1';
        u1.LastName = 'User1';
        u1.Email = 'litify1@doesnotexist.com';
        u1.Username = 'litify1@doesnotexist.com' + System.currentTimeMillis();
        u1.CompanyName = 'Litify';
        u1.Title = 'title';
        u1.Alias = 'alias';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usersToInsert.add(u1);

        User u2 = new User();
        u2.FirstName = 'Test2';
        u2.LastName = 'User2';
        u2.Email = 'litify2@doesnotexist.com';
        u2.Username = 'litify2@doesnotexist.com' + System.currentTimeMillis();
        u2.CompanyName = 'Litify';
        u2.Title = 'title';
        u2.Alias = 'alias';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LanguageLocaleKey = 'en_US';
        u2.LocaleSidKey = 'en_US';
        u2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usersToInsert.add(u2);

        insert usersToInsert;
    }

    static testMethod void testTeamMemberIdAdd(){
        litify_PM__Matter__c m1 = [SELECT Id, MTM_Ids__c FROM litify_PM__Matter__c WHERE litify_pm__Display_Name__c = 'matter test 1'];
        litify_PM__Matter__c m2 = [SELECT Id, MTM_Ids__c FROM litify_PM__Matter__c WHERE litify_pm__Display_Name__c = 'matter test 2'];
        User u1 = [SELECT ID FROM USer WHERE FirstName = 'Test1'];
        User u2 = [SELECT ID FROM USer WHERE FirstName = 'Test2'];
        List<litify_pm__Matter_Team_Member__c> mtmsToInsert = new List<litify_pm__Matter_Team_Member__c>();

        litify_pm__Matter_Team_Member__c mtm1 = new litify_pm__Matter_Team_Member__c();
        mtm1.name = 'test team member 1';
        mtm1.litify_pm__Matter__c = m1.id;
        mtm1.litify_pm__User__c = u1.id;
        mtmsToInsert.add(mtm1);

        litify_pm__Matter_Team_Member__c mtm2 = new litify_pm__Matter_Team_Member__c();
        mtm2.name = 'test team member 2';
        mtm2.litify_pm__Matter__c = m2.id;
        mtm2.litify_pm__User__c = u1.id;
        mtmsToInsert.add(mtm2);

        Test.startTest();
        insert mtmsToInsert;
        mtm2.litify_pm__User__c = u2.id;
        update mtm2;
        delete mtm2;
        Test.stopTest();
        

        m1 = [SELECT Id, MTM_Ids__c FROM litify_PM__Matter__c WHERE litify_pm__Display_Name__c = 'matter test 1'];
        system.debug(m1.MTM_Ids__c);
        //system.assert(m1.MTM_Ids__c.contains(u1.Id), 'Error: Matter field does not contain User Id');

        m2 = [SELECT Id, MTM_Ids__c FROM litify_PM__Matter__c WHERE litify_pm__Display_Name__c = 'matter test 2'];
        system.debug(m2.MTM_Ids__c);
        //system.assert(m2.MTM_Ids__c.contains(u1.Id), 'Error: Matter field does not contain User Id');
        
    }

}