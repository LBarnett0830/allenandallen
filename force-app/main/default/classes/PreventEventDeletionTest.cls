/**
 * @author      Litify Professional Services
 * @version     1.0.0
 */

@isTest
private class PreventEventDeletionTest {
    @isTest static void testEmptyCustomSettings() {
        insert new Trigger_PreventEventDeletion__c(SetupOwnerId=UserInfo.getOrganizationId(),
                                            Active__c=True,
                                            Excluded_Profiles__c = '',
                                            Error_Message__c = '');
        
        Profile standardUserProfile = [SELECT Id, Name 
                                       FROM Profile
                                       WHERE Name = 'Standard User'
                                       LIMIT 1];
        
        String uniqueUserName = 'standardUser' + DateTime.now().getTime() + '@testorg.com';
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles',
                                 UserName=uniqueUserName);
        
        insert testUser;
        
        
        Event testEvent = new Event();
        testEvent.Subject = 'TestEvent';
        testEvent.OwnerId = testUser.Id;
        testEvent.DurationInMinutes = 60;
        testEvent.ActivityDateTime = DateTime.now();
        
        insert testEvent;
        
        System.runAs(testUser){
            Test.startTest();
            Database.DeleteResult result = Database.delete(testEvent, false);
            Test.stopTest();
            
            System.assert(!result.isSuccess());
            System.assert(result.getErrors().size() > 0);
            System.assertEquals('ERROR: You have no permissions to delete Events. Please contact your System Admin.',
                                result.getErrors()[0].getMessage());
        } 
        
    }
    
    @isTest static void testEventDeletion() {
        insert new Trigger_PreventEventDeletion__c(SetupOwnerId=UserInfo.getOrganizationId(),
                                            Active__c=True,
                                            Excluded_Profiles__c = 'System Administrator',
                                            Error_Message__c = 'You are not allowed to delete Events! Please contact to your System Administrator.');
        
        Profile standardUserProfile = [SELECT Id, Name 
                                       FROM Profile
                                       WHERE Name = 'Standard User'
                                       LIMIT 1];
        
        String uniqueUserName = 'standardUser' + DateTime.now().getTime() + '@testorg.com';
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles',
                                 UserName=uniqueUserName);
        
        insert testUser;
        
        
        Event testEvent = new Event();
        testEvent.Subject = 'TestEvent';
        testEvent.OwnerId = testUser.Id;
        testEvent.DurationInMinutes = 60;
        testEvent.ActivityDateTime = DateTime.now();
        
        insert testEvent;
        
        System.runAs(testUser){
            Test.startTest();
            Database.DeleteResult result = Database.delete(testEvent, false);
            Test.stopTest();
            System.assert(!result.isSuccess());
            System.assert(result.getErrors().size() > 0);
            System.assertEquals('You are not allowed to delete Events! Please contact to your System Administrator.',
                                result.getErrors()[0].getMessage());
        } 
    }
    @isTest static void testSysAdminProfile() {
        
        insert new Trigger_PreventEventDeletion__c(SetupOwnerId=UserInfo.getOrganizationId(),
                                            Active__c=True,
                                            Excluded_Profiles__c = 'System Administrator',
                                            Error_Message__c = 'You are not allowed to delete Events! Please contact to your System Administrator.');
        
        Profile sysAdmin = [SELECT id, Name
                            FROM Profile
                            WHERE Name = 'System Administrator'
                            LIMIT 1
                           ];
        
        if(sysAdmin != null) {
            
            String uniqueUserName = 'standardUser' + DateTime.now().getTime() + '@testorg.com';
            User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = sysAdmin.Id,
                                     TimeZoneSidKey='America/Los_Angeles',
                                     UserName=uniqueUserName);
            
            insert testUser;
            
            Event testEvent = new Event();
            testEvent.Subject = 'TestEvent';
            testEvent.OwnerId = testUser.Id;
            testEvent.DurationInMinutes = 60;
            testEvent.ActivityDateTime = DateTime.now();
            
            insert testEvent;
            
            System.runAs(testUser){
                Test.startTest();
                Database.DeleteResult result = Database.delete(testEvent, false);
                Test.stopTest();
                System.assert(result.isSuccess());
                System.assertEquals(result.getErrors().size() , 0);
                
            }
        }
    }
}