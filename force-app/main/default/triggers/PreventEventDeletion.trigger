/**
 * @author      Litify Professional Services
 * @version     1.0.0
 */
trigger PreventEventDeletion on Event (before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        if(PreventEventDeletionHandler.isTriggerActive()){
            PreventEventDeletionHandler.preventDeletion(Trigger.old);
        }
    }
}