public with sharing class TaskRepeatingTriggerHandler {
    private static final Boolean TRIGGER_ENABLED = Boolean.valueOf(String.valueOf(Task_Repeating_Trigger_Settings__c.getOrgDefaults().get('Active_Trigger__c')));
    private static final String N_A_STATUS = 'NA';
    private static final String REPEAT_THIS_TASK_TASK_CLOSED = 'RecurrenceRegenerated';

    public static void updateRepeatingStatus(List<Task> newTasks){
        for(Task currentTask : newTasks){
            if(currentTask.Status == N_A_STATUS){
                if(String.isNotBlank(currentTask.RecurrenceRegeneratedType) && currentTask.RecurrenceRegeneratedType <> REPEAT_THIS_TASK_TASK_CLOSED){
                    currentTask.RecurrenceRegeneratedType = REPEAT_THIS_TASK_TASK_CLOSED;
                }
            }
        }
    }

    public static Boolean isTriggerEnabled(){
        return TRIGGER_ENABLED; 
    }
}