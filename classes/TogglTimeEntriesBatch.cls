global  with sharing class TogglTimeEntriesBatch implements Database.Batchable<sObject> 
{       
    global Database.querylocator start(Database.BatchableContext BC) 
    {
        String queryString = 'SELECT Id, TASKRAY__Project_Parent__c, Total_Actual_Project_Time__c FROM TASKRAY__Project__c';

        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<SObject> records) 
    {
        List<TASKRAY__Project__c> taskRayProjectList = (List<TASKRAY__Project__c>)records;

        Set<Id> taskRayProjectSet = new Set<Id>();

        for(TASKRAY__Project__c taskRayProject : taskRayProjectList)
        {
            taskRayProjectSet.add(taskRayProject.Id);
        }
        
        List<Toggl_Time_Entry__c> projectTimeEntryList =    
            [
                SELECT Id, Duration_Computed__c, Project__c
                FROM Toggl_Time_Entry__c
                WHERE Project__c IN :taskRayProjectSet
            ];

        Map<String, Decimal> projectToTotalActualProjectTimeMap = new Map<String, Decimal>();

        for(Toggl_Time_Entry__c projectTimeEntry : projectTimeEntryList)
        {
            if(projectTimeEntry.Duration_Computed__c != null)
            {
                if(projectToTotalActualProjectTimeMap.get(projectTimeEntry.Project__c) == null)
                {
                    projectToTotalActualProjectTimeMap.put(projectTimeEntry.Project__c, projectTimeEntry.Duration_Computed__c);
                }
                else
                {
                    projectToTotalActualProjectTimeMap.put(projectTimeEntry.Project__c, projectToTotalActualProjectTimeMap.get(projectTimeEntry.Project__c) + projectTimeEntry.Duration_Computed__c);
                }
            }
        }

        List<Toggl_Time_Entry__c> subProjectTimeEntryList = 
            [
                SELECT Id, Duration_Computed__c, Project__c, Project__r.TASKRAY__Project_Parent__c
                FROM Toggl_Time_Entry__c
                WHERE Project__r.TASKRAY__Project_Parent__c IN :taskRayProjectSet
            ];

        for(Toggl_Time_Entry__c projectTimeEntry : subProjectTimeEntryList)
        {
            if(projectTimeEntry.Duration_Computed__c != null)
            { 
                if(projectToTotalActualProjectTimeMap.get(projectTimeEntry.Project__r.TASKRAY__Project_Parent__c) == null)
                {
                    projectToTotalActualProjectTimeMap.put(projectTimeEntry.Project__r.TASKRAY__Project_Parent__c, projectTimeEntry.Duration_Computed__c);
                }
                else
                {
                    projectToTotalActualProjectTimeMap.put(projectTimeEntry.Project__r.TASKRAY__Project_Parent__c, projectToTotalActualProjectTimeMap.get(projectTimeEntry.Project__r.TASKRAY__Project_Parent__c) + projectTimeEntry.Duration_Computed__c);
                }
            }
        }       

        for(TASKRAY__Project__c taskRayProject : taskRayProjectList)
        {
            if (projectToTotalActualProjectTimeMap.containsKey(taskRayProject.Id)) {
                taskRayProject.Total_Actual_Project_Time__c = projectToTotalActualProjectTimeMap.get(taskRayProject.Id);
            } else {
                taskRayProject.Total_Actual_Project_Time__c = 0;
            }
        }

        update taskRayProjectList;
    }
    
    global void finish(Database.BatchableContext BC) 
    {

    }   
}