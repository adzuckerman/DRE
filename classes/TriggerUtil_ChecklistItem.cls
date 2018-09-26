public class TriggerUtil_ChecklistItem {
    
    public static void rollupTaskDate(List<TASKRAY__trChecklistItem__c> oldChecks,List<TASKRAY__trChecklistItem__c> newChecks){
        
        List<id> taskIDs = new List<id>();

        For(integer i = 0; i<newChecks.size(); i++){
            system.debug(oldChecks[i].Assigned_Date__c + ' ' + newChecks[i].Assigned_Date__c);
            if(oldChecks[i].Assigned_Date__c != newChecks[i].Assigned_Date__c || oldChecks[i].Completion_Date__c  != newChecks[i].Completion_Date__c){
                taskIDs.add(newChecks[i].TASKRAY__Project_Task__c);
            }
        }
        
        if(taskIDs.isEmpty()) return;
        system.debug(taskIDs.size() + 'We have task IDs');
        
        //query all checklist items on the task
        List<TASKRAY__trChecklistItem__c> checklists = [SELECT Assigned_Date__c,Completion_Date__c,TASKRAY__Project_Task__c FROM
                                                         TASKRAY__trChecklistItem__c WHERE TASKRAY__Project_Task__c IN: taskIDs];
        List<TASKRAY__Project_Task__c> tasks = [SELECT TASKRAY__trStartDate__c,TASKRAY__Deadline__c FROM TASKRAY__Project_Task__c WHERE ID IN: taskIDs ];
        Map<id,List<TASKRAY__trChecklistItem__c>> taskChecklistMap = new Map<id,List<TASKRAY__trChecklistItem__c>>();
        For(TASKRAY__trChecklistItem__c cl: checklists){
            if(taskChecklistMap.get(cl.TASKRAY__Project_Task__c) != NULL){
                List<TASKRAY__trChecklistItem__c> items = taskChecklistMap.get(cl.TASKRAY__Project_Task__c);
                items.add(cl);
                taskChecklistMap.put(cl.TASKRAY__Project_Task__c,items);
            }else{
                List<TASKRAY__trChecklistItem__c> items = new List<TASKRAY__trChecklistItem__c>();
                items.add(cl);
                taskChecklistMap.put(cl.TASKRAY__Project_Task__c,items);
            }
        }
        
        //Now loop and get the earliest and latest dates and update the task
        List<TASKRAY__Project_Task__c> tasksToUpdate = new List<TASKRAY__Project_Task__c>();
        for (TASKRAY__Project_Task__c t : tasks){
            List<TASKRAY__trChecklistItem__c> items = taskChecklistMap.get(t.id);
            t.TASKRAY__trStartDate__c = NULL;
            t.TASKRAY__Deadline__c = NULL;
            For(TASKRAY__trChecklistItem__c i: items){
                if((i.Assigned_Date__c != NULL && i.Assigned_Date__c < t.TASKRAY__trStartDate__c) || t.TASKRAY__trStartDate__c == NULL){
                    t.TASKRAY__trStartDate__c = i.Assigned_Date__c;
                }
                if((i.Completion_Date__c != NULL && i.Completion_Date__c > t.TASKRAY__Deadline__c)  || t.TASKRAY__Deadline__c == NULL){
                    t.TASKRAY__Deadline__c = i.Completion_Date__c;
                }
            }
            tasksToUpdate.add(t);
        }
        
        update tasksToUpdate;
    }

}