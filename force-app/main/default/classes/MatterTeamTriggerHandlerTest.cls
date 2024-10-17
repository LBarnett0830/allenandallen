@isTest(SeeAllData=false) 
private class MatterTeamTriggerHandlerTest {

    @testSetup static void initData() {
        List<Account> l_accounts = new List<Account>();
        Account acc1 = new Account(litify_pm__First_Name__c ='Account 1', litify_pm__Last_Name__c ='Last Name 1');
        acc1.BillingCity = 'New York';
        acc1.BillingCountry = 'United States';
        acc1.BillingStreet = 'Avenue';
        acc1.BillingPostalCode = '12412';
        acc1.Phone  = '1241242';
        l_accounts.add(acc1);
        insert l_accounts;
        List<litify_pm__Matter__c> l_matters = new List<litify_pm__Matter__c>();
        litify_pm__Matter__c matter1 = new litify_pm__Matter__c();
        matter1.litify_pm__Client__c = acc1.Id;
        l_matters.add(matter1);
        insert l_matters;
        List<User> l_users = new List<User>();
        Profile standardUserProfile = [SELECT Id, Name 
                                       FROM Profile
                                       WHERE Name = 'Litify Power User'
                                       LIMIT 1];
        String uniqueUserName = 'standardUser1' + DateTime.now().getTime() + '@testorg.com';
        User testUser1 = new User(Alias = 'standt', Email='standarduser1@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName=uniqueUserName);
        
        l_users.add(testUser1); 
        uniqueUserName = 'standardUser2' + DateTime.now().getTime() + '@testorg.com';
        User testUser2 = new User(Alias = 'standt', Email='standarduser2@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName=uniqueUserName);
        
        l_users.add(testUser2); 
        uniqueUserName = 'standardUser3' + DateTime.now().getTime() + '@testorg.com';
        User testUser3 = new User(Alias = 'standt', Email='standarduser3@testorg.com',
                                  EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName=uniqueUserName);
        
        l_users.add(testUser3); 
        insert l_users;  
    }

    @isTest static void createMatterTeamMember() {
        litify_pm__Matter__c testMatter = [SELECT ID FROM litify_pm__Matter__c LIMIT 1];
        User user1 = [SELECT ID FROM User WHERE Email = 'standarduser1@testorg.com'];
        Test.startTest();
        litify_pm__Matter_Team_Member__c teamMember = new litify_pm__Matter_Team_Member__c();
        teamMember.litify_pm__User__c = user1.Id;
        teamMember.litify_pm__Matter__c = testMatter.Id;
        teamMember.Sharing_Access__c = 'Read';
        insert teamMember;
        List<litify_pm__Matter__Share> teamShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
                                                   RowCause FROM litify_pm__Matter__Share WHERE ParentId = :testMatter.Id AND UserOrGroupId= :user1.Id];
        System.assertEquals(teamShrs.size(), 1, 'Set the object\'s sharing model to Private.');
        Test.stopTest();
    }

    @isTest static void updateMatterTeamMember() {
        litify_pm__Matter__c testMatter = [SELECT ID FROM litify_pm__Matter__c LIMIT 1];
        User user1 = [SELECT ID FROM User WHERE Email = 'standarduser1@testorg.com'];
        User user2 = [SELECT ID FROM User WHERE Email = 'standarduser2@testorg.com'];
        Test.startTest();
        litify_pm__Matter_Team_Member__c teamMember = new litify_pm__Matter_Team_Member__c();
        teamMember.litify_pm__User__c = user1.Id;
        teamMember.litify_pm__Matter__c = testMatter.Id;
        teamMember.Sharing_Access__c = 'Read';
        insert teamMember;
        teamMember.litify_pm__User__c = user2.Id;
        update teamMember;
        List<litify_pm__Matter__Share> teamShrsUser1 = [SELECT Id, UserOrGroupId, AccessLevel, 
                                                   RowCause FROM litify_pm__Matter__Share WHERE ParentId = :testMatter.Id AND UserOrGroupId= :user1.Id];
        List<litify_pm__Matter__Share> teamShrsUser2 = [SELECT Id, UserOrGroupId, AccessLevel, 
                                                   RowCause FROM litify_pm__Matter__Share WHERE ParentId = :testMatter.Id AND UserOrGroupId= :user2.Id];
        System.assertEquals(teamShrsUser2.size(), 1, 'Add sharing');
        Test.stopTest();
        
    }
    @isTest static void deleteMatterTeamMember() {
        litify_pm__Matter__c testMatter = [SELECT ID FROM litify_pm__Matter__c LIMIT 1];
        User user1 = [SELECT ID FROM User WHERE Email = 'standarduser1@testorg.com'];
        litify_pm__Matter_Team_Member__c teamMember = new litify_pm__Matter_Team_Member__c();
        teamMember.litify_pm__User__c = user1.Id;
        teamMember.litify_pm__Matter__c = testMatter.Id;
        teamMember.Sharing_Access__c = 'Read';
        insert teamMember;
        Test.startTest();
        delete teamMember;
        List<litify_pm__Matter__Share> teamShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
                                                   RowCause FROM litify_pm__Matter__Share WHERE ParentId = :testMatter.Id AND UserOrGroupId= :user1.Id];
        System.assertEquals(teamShrs.size(), 0, 'Remove sharing');
        Test.stopTest();
    }
}