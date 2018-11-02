/********************************************************************************************************
*    Name:  TaskRaySubprojectBatch.cls
*    Author:  
*    Date:  6/12/2018
*    
*    Scheduler class: TaskRaySubprojectScheduler.cls
*    Test class: TaskRaySubprojectBatchTest.cls
********************************************************************************************************/

global class TaskRaySubprojectBatch implements Database.Batchable <SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String Query='SELECT Id, Digitized__c FROM TASKRAY__Project__c WHERE TASKRAY__Project_Parent__c != null';
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<TASKRAY__Project__c> scope)
    {
        
        List<Junction_Kbase__c> JunctionKbase = [SELECT Id, TaskRay_Project__c FROM Junction_Kbase__c WHERE TaskRay_Project__c IN: scope AND LMS_Bucket__c != 'Rejected'];
        Map<Id, List<Junction_Kbase__c>> JunctionKbaseMap = new Map<Id, List<Junction_Kbase__c>>();
        for(Junction_Kbase__c jk: JunctionKbase) {
            if(!JunctionKbaseMap.containsKey(jk.TaskRay_Project__c))
            {
                List<Junction_Kbase__c> newList = new List<Junction_Kbase__c>();
                newList.add(jk);
                JunctionKbaseMap.put(jk.TaskRay_Project__c, newList);
            } else {
                List<Junction_Kbase__c> exList = JunctionKbaseMap.get(jk.TaskRay_Project__c);
                exList.add(jk);
                JunctionKbaseMap.put(jk.TaskRay_Project__c, exList);
            }
        }
        List<TASKRAY__Project__c> TASKRAYProjectToUpdate = new List<TASKRAY__Project__c>();
        for(TASKRAY__Project__c tp: scope)
        {
            if(JunctionKbaseMap.containsKey(tp.Id))
            {
                List<Junction_Kbase__c> currentTaskProject = JunctionKbaseMap.get(tp.Id);
                Integer JunctionKbaseNumber = currentTaskProject.size();
                tp.Digitized__c = JunctionKbaseNumber;
                TASKRAYProjectToUpdate.add(tp);
            }
        }
        
        if(TASKRAYProjectToUpdate.size() > 0)
            update TASKRAYProjectToUpdate;
    }

    global void finish(Database.BatchableContext bc)
    {
        
    }
}