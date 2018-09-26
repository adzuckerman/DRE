trigger UpdateRole on TASKRAY__Project_Task__c (before insert, before update) 
{
    if(Trigger.isUpdate)
        {
            System.debug('oldValues' + Trigger.Old);
            System.debug('newValues' + Trigger.Old);
            UpdateRoleHelper.UpdateRole(Trigger.Old, Trigger.New);
        }
    else if(Trigger.isInsert)
    {
        System.debug('newValues' + Trigger.Old);
        UpdateRoleHelper.UpdateRole(null, Trigger.New);
	}
}