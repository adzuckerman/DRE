public class TriggerUtil_JunctionKbase {
    
    
    public static void updateTaskRay(List<Junction_Kbase__c> newJunctions){
        
        List<string> refIds = new List<string>();
        List<id> subProjIds = new List<id>();
        Map<string,junction_kBase__c> refIdJBaseMap = new Map<string,junction_kBase__c>();  
        Set<id> assigneeIDs = new Set<id>();
        For(Junction_Kbase__c j: newJunctions){
            if(j.LMS_Bucket__c != 'Rejected'){
                refIds.add(j.Kbases_Name__c);                
                subProjIds.add(j.TaskRay_Project__c);
                refIdJBaseMap.put(j.Kbases_Name__c,j);
                assigneeIDs.add(j.DI_I_Assignee_Name__c);
                assigneeIDs.add(j.DI_I_Fix_Check_Assignee_Name__c);
                assigneeIDs.add(j.DI_I_Fixes_Assignee_Name__c);
                assigneeIDs.add(j.DI_II_Assignee_Name__c);
                assigneeIDs.add(j.DI_II_Fix_Check_Assignee_Name__c); 
                assigneeIDs.add(j.DI_II_Fixes_Assignee_Name__c);
                assigneeIDs.add(j.Extraction_Assignee_Name__c);
            } 
        }        
        system.debug('assigneeIds size' + assigneeIDs.size());
        List<user> users = [SELECT name FROM user WHERE id IN: assigneeIDs];
        Map<id,user> userMap = new Map<id,user>(users);
        
        List<TASKRAY__trChecklistItem__c> tasks = [
                        SELECT TASKRAY__Project_Task__r.Ref_ID__c, 
                                TASKRAY__Project_Task__r.TASKRAY__Project__c,
                                TASKRAY__Project_Task__r.name,
                                Assigned_Date__c,Completion_Date__c,Reference_Status__c,
                                Assignee_Name__c,name
                                FROM  TASKRAY__trChecklistItem__c WHERE 
                        TASKRAY__Project_Task__r.TASKRAY__Project__c IN: subProjIds AND 
                        Name IN: refIds];
        system.debug(tasks.size() + ' task matches');
        if(tasks.isEmpty()) return;
        For(TASKRAY__trChecklistItem__c ti: tasks){
            system.debug(refIdJBaseMap.get(ti.Name) + ' ' + refIdJBaseMap.get(ti.name).TaskRay_Project__c + ' *&^ ' + ti.TASKRAY__Project_Task__r.TASKRAY__Project__c);
            if(refIdJBaseMap.get(ti.Name) != NULL  
               && refIdJBaseMap.get(ti.name).TaskRay_Project__c == ti.TASKRAY__Project_Task__r.TASKRAY__Project__c){
                system.debug('match found' + ti.TASKRAY__Project_Task__r.name); 
                   Junction_Kbase__c j = refIdJBaseMap.get(ti.name);
                   //we update all tasks with this general information
                   ti.Kbase__c = j.Kbases__c;
                   ti.Junction_Kbase__c = j.id;
                   if(ti.TASKRAY__Project_Task__r.name == 'Extraction'){
                       ti.Assigned_Date__c = j.Extraction_Assigned_Date__c;
                       ti.completion_date__c = j.Extraction_Completion_Date__c;
                       ti.Assignee_Name__c = (userMap.get(j.Extraction_Assignee_Name__c) != NULL) ? userMap.get(j.Extraction_Assignee_Name__c).name : NULL;
                       ti.Reference_Status__c  = j.Extraction_Reference_Status__c;
                   }else if(ti.TASKRAY__Project_Task__r.name == 'DI-I'){
                       ti.Assigned_Date__c = j.DI_I_Assigned_Date__c;
                       ti.completion_date__c = j.DI_I_Completion_Date__c;
                       ti.Assignee_Name__c = (userMap.get(j.DI_I_Assignee_Name__c) != NULL) ? userMap.get(j.DI_I_Assignee_Name__c).name : NULL;
                       ti.Reference_Status__c  = j.DI_I_Reference_Status__c;
                   }else if(ti.TASKRAY__Project_Task__r.name == 'DI-I Fixes'){
                       ti.Assigned_Date__c = j.DI_I_Fixes_Assigned_Date__c;
                       ti.completion_date__c = j.DI_I_Fixes_Completion_Date__c;
                       ti.Assignee_Name__c = (userMap.get(j.DI_I_Fixes_Assignee_Name__c) != NULL) ? userMap.get(j.DI_I_Fixes_Assignee_Name__c).name : NULL;
                   }else if(ti.TASKRAY__Project_Task__r.name == 'DI-I Fix Check'){
                       ti.Assigned_Date__c = j.DI_I_Fix_Check_Assigned_Date__c;
                       ti.completion_date__c = j.DI_I_Fix_Check_Completion_Date__c;
                       ti.Assignee_Name__c = (userMap.get(j.DI_I_Fix_Check_Assignee_Name__c) != NULL) ? userMap.get(j.DI_I_Fix_Check_Assignee_Name__c).name : NULL;
                   }else if(ti.TASKRAY__Project_Task__r.name == 'DI-II'){
                       ti.Assigned_Date__c = j.DI_II_Assigned_Date__c;
                       ti.completion_date__c = j.DI_II_Completion_Date__c;
                       ti.Assignee_Name__c = (userMap.get(j.DI_II_Assignee_Name__c) != NULL) ? userMap.get(j.DI_II_Assignee_Name__c).name : NULL;
                       ti.Reference_Status__c  = j.DI_II_Reference_Status__c;
                   }else if(ti.TASKRAY__Project_Task__r.name == 'DI-II Fixes'){
                       ti.Assigned_Date__c = j.DI_II_Fixes_Assigned_Date__c;
                       ti.completion_date__c = j.DI_II_Fixes_Completion_Date__c;
                       ti.Assignee_Name__c = (userMap.get(j.DI_II_Fixes_Assignee_Name__c) != NULL) ? userMap.get(j.DI_II_Fixes_Assignee_Name__c).name : NULL;
                   }else if(ti.TASKRAY__Project_Task__r.name == 'DI-II Fix Check'){
                       ti.Assigned_Date__c = j.DI_II_Fix_Check_Assigned_Date__c;
                       ti.completion_date__c = j.DI_II_Fix_Check_Completion_Date__c;
                       ti.Assignee_Name__c = (userMap.get(j.DI_II_Fix_Check_Assignee_Name__c) != NULL) ? userMap.get(j.DI_II_Fix_Check_Assignee_Name__c).name : NULL;
                   }
               }
        }
        System.debug('Tasks about to update' + tasks);
        update tasks;
        
        
    }
    
    public static void updateTaskRay(List<Junction_Kbase__c> oldJunctions,List<Junction_Kbase__c> newJunctions){
        
        List<Junction_Kbase__c> junctions = new List<Junction_Kbase__c>();
        For(integer i = 0; i<newJunctions.size(); i++){
            junctions.add(newJunctions[i]);
        }
        
        TriggerUtil_JunctionKbase.updateTaskRay(junctions);
    }

}