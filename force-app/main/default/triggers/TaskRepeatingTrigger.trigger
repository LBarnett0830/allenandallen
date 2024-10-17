trigger TaskRepeatingTrigger on Task (before update) {
	if(Trigger.isBefore && Trigger.isUpdate){
        if(TaskRepeatingTriggerHandler.isTriggerEnabled()){
            TaskRepeatingTriggerHandler.updateRepeatingStatus(Trigger.new);
        }
    }
}