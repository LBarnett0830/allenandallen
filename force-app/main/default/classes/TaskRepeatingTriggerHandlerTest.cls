@isTest
private class TaskRepeatingTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Task_Repeating_Trigger_Settings__c customSettings = new Task_Repeating_Trigger_Settings__c();
        customSettings.Active_Trigger__c = true;
        insert customSettings;
    }

    @isTest
    private static void Unit1(){
        Task task1 = new Task(Status = 'Not Started', Subject = 'Hello World', RecurrenceRegeneratedType = 'RecurrenceRegenerateAfterToday', RecurrenceInterval = 60);
        insert task1;
        Task check1 = [SELECT RecurrenceRegeneratedType FROM Task WHERE Id = :task1.Id];
        System.assertEquals(check1.RecurrenceRegeneratedType, 'RecurrenceRegenerateAfterToday');
        task1.Status = 'NA';
        update task1;
        Task check2 = [SELECT RecurrenceRegeneratedType FROM Task WHERE Id = :task1.Id];
        System.assertEquals(check2.RecurrenceRegeneratedType, 'RecurrenceRegenerated');

    }
}