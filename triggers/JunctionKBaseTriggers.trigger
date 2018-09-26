trigger JunctionKBaseTriggers on Junction_Kbase__c (after insert, after update) {
    
    if(trigger.isInsert){
        TriggerUtil_JunctionKbase.updateTaskRay(trigger.new);
    }
    
    if(trigger.isUpdate){
        TriggerUtil_JunctionKbase.updateTaskRay(trigger.old,trigger.new);
    }

}