trigger taskRayCheckListItemTriggers on TASKRAY__trChecklistItem__c (before insert, before update, after update) {
    
    if(trigger.isbefore){
        if(trigger.isUpdate){
            UpdateRoleCheckListHelper.UpdateRole(Trigger.Old, Trigger.New);
        }else if(trigger.isInsert){
            UpdateRoleCheckListHelper.UpdateRole(null, Trigger.New);
        }
    }else if(trigger.isAfter){
        //TriggerUtil_ChecklistItem.rollupTaskDate(trigger.old,trigger.new);
    }

        

}