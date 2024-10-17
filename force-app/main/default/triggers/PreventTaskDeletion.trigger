/**
 * @author      Litify Professional Services
 * @version     1.0.0
 */
trigger PreventTaskDeletion on Task (before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        if(PreventTaskDeletionHandler.isTriggerActive()){
            PreventTaskDeletionHandler.preventDeletion(Trigger.old);
        }
    }
}