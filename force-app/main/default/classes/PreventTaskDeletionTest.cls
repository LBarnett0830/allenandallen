/**
 * @author      Litify Professional Services
 * @version     1.0.0
 */

@isTest
private class PreventTaskDeletionTest {
    @isTest static void testEmptyCustomSettings() {
        insert new Trigger_PreventTaskDeletion__c(SetupOwnerId=UserInfo.getOrganizationId(),
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
        
        
        Task testTask = new Task();
        testTask.Subject = 'TestTask';
        testTask.OwnerId = testUser.Id;
        
        insert testTask;
        
        System.runAs(testUser){
            Test.startTest();
            Database.DeleteResult result = Database.delete(testTask, false);
            Test.stopTest();
            
            System.assert(!result.isSuccess());
            System.assert(result.getErrors().size() > 0);
            System.assertEquals('ERROR: You have no permissions to delete Tasks. Please contact your System Admin.',
                                result.getErrors()[0].getMessage());
        } 
        
    }
    
    @isTest static void testTaskDeletion() {
        insert new Trigger_PreventTaskDeletion__c(SetupOwnerId=UserInfo.getOrganizationId(),
                                            Active__c=True,
                                            Excluded_Profiles__c = 'System Administrator',
                                            Error_Message__c = 'You are not allowed to delete Tasks! Please contact to your System Administrator.');
        
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
        
        
        Task testTask = new Task();
        testTask.Subject = 'TestTask';
        testTask.OwnerId = testUser.Id;
        
        insert testTask;
        
        System.runAs(testUser){
            Test.startTest();
            Database.DeleteResult result = Database.delete(testTask, false);
            Test.stopTest();
            System.assert(!result.isSuccess());
            System.assert(result.getErrors().size() > 0);
            System.assertEquals('You are not allowed to delete Tasks! Please contact to your System Administrator.',
                                result.getErrors()[0].getMessage());
        } 
    }
    @isTest static void testSysAdminProfile() {
        
        insert new Trigger_PreventTaskDeletion__c(SetupOwnerId=UserInfo.getOrganizationId(),
                                            Active__c=True,
                                            Excluded_Profiles__c = 'System Administrator',
                                            Error_Message__c = 'You are not allowed to delete Tasks! Please contact to your System Administrator.');
        
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
            
            Task testTask = new Task();
            testTask.Subject = 'TestTask';
            testTask.OwnerId = testUser.Id;
            
            insert testTask;
            
            System.runAs(testUser){
                Test.startTest();
                Database.DeleteResult result = Database.delete(testTask, false);
                Test.stopTest();
                System.assert(result.isSuccess());
                System.assertEquals(result.getErrors().size() , 0);
                
            }
        }
    }
}