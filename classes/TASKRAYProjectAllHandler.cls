/********************************************************************************************************
*    Handler class: TASKRAYProjectAllHandler.cls
*    Author:  
*    Date:  8/20/2018
*    
*    Trigger:  TASKRAYProjectAll.trigger
*    Test class: TASKRAYProjectAllHandlerTest.cls
********************************************************************************************************/

public class TASKRAYProjectAllHandler {
    //Handler for before insert methods
    public void onBeforeInsert(list<TASKRAY__Project__c> newList , map<id, TASKRAY__Project__c> newMap) {
        UpdateProjectStatge(newList, null, newMap, null);
        checkProjectName(newList,null, null);        
    }
    //Handler for after insert methods
    public void onAfterInsert(list<TASKRAY__Project__c> newList , map<id, TASKRAY__Project__c> newMap) {
        CreateToggleProjet(newList, null, newMap, null);
    }
    //Handler for before Update methods
    public void onBeforeUpdate(list<TASKRAY__Project__c> newList, map<id, TASKRAY__Project__c> newMap , map<id, TASKRAY__Project__c> oldMap) {
        UpdateProjectStatge(newList, null, newMap, oldMap);
        AutoArchiveTogglProject(newList, null, newMap, oldMap);
        checkProjectName(newList, 'isUpdate', oldMap);
    }
    //Handler for after Update methods
    public void onAfterUpdate(list<TASKRAY__Project__c> newList, map<id, TASKRAY__Project__c> newMap,  map<id, TASKRAY__Project__c> oldMap) {
        CreateToggleProjet(newList, null, newMap, oldMap);
    }

    //Handler for before Deletes methods
    //public void onBeforeDelete(list<TASKRAY__Project__c> oldList, map<id, TASKRAY__Project__c> oldMap) {}
    //Handler for after Deletes methods
    //public void onAfterDelete(list<TASKRAY__Project__c> oldList , map<id, TASKRAY__Project__c> oldMap) {}
    
    
    private void CreateToggleProjet(list<TASKRAY__Project__c>newList, list<TASKRAY__Project__c>oldList, map<id, TASKRAY__Project__c> newMap, map<id, TASKRAY__Project__c> oldMap) {
        Set<Id> TProjectIds = new Set<Id>();
        for(TASKRAY__Project__c proj : newList) {
            if(oldMap != null && oldMap.size() > 0)
            {
                TASKRAY__Project__c oldProject = oldMap.get(proj.Id);
                if( oldProject.Toggl_Auto_Creation_Approved__c == false && proj.Toggl_Auto_Creation_Approved__c == true)
                    TProjectIds.add(proj.Id);
            } else {
                if( proj.Toggl_Auto_Creation_Approved__c == true)
                    TProjectIds.add(proj.Id);
            }
        }
        
        if(TProjectIds.size() > 0)
        {
            
            // Limit: 10 callouts per transaction
            Map<Integer, Set<Id>> SetsMap = new Map<Integer, Set<Id>>();
            
            Integer i = 0;
            Integer j = 1;
            Set<Id> newSet;
            for(Id s: TProjectIds)
            {
                if(i == 0)
                   newSet = new Set<Id>();
                if(i <= 10) {
                   if(!SetsMap.containsKey(j))
                   {
                       newSet.add(s);
                       SetsMap.put(j, newSet);
                   } else {
                       Set<Id> existingSet = SetsMap.get(j);
                       existingSet.add(s);
                       SetsMap.put(j, existingSet);
                   }
                }
                i++;
                if(i == 10) { 
                    j++;
                    i = 0;
                }
            }
           
            
            if(SetsMap.size() > 0)
            {
                for(Integer ii: SetsMap.KeySet())
                {
                    Set<Id> s = SetsMap.get(ii);
                    if(!Test.isRunningTest())
                        ToggleProjectCreation.CreateToggleProject(s);
                }
            }
            
        }
        
    }
    
    // Add Toggle Project to Archive (Active = false) when Salesforce TASKRAY__Project is archived
    private void AutoArchiveTogglProject(list<TASKRAY__Project__c>newList, list<TASKRAY__Project__c>oldList, map<id, TASKRAY__Project__c> newMap, map<id, TASKRAY__Project__c> oldMap) {
        Set<Id> TProjectName = new Set<Id>();
        for(TASKRAY__Project__c proj : newList) {
            TASKRAY__Project__c oldProject = oldMap.get(proj.Id);
            if( oldProject.Archived_Date__c == null && proj.Archived_Date__c != null)
                TProjectName.add(proj.Id);
        }
        
        if(TProjectName.size() > 0)
        {
            List<Toggl_Time_Entry__c> TogglTimeEntry = [SELECT Id, Toggl_Id__c FROM Toggl_Time_Entry__c WHERE Project__c IN: TProjectName];
            
            Set<String> ToggleProgIds = new Set<String>();
            for(Toggl_Time_Entry__c tte: TogglTimeEntry )
            {
                ToggleProgIds.add(tte.Toggl_Id__c);
            }
            
            // Limit: 10 callouts per transaction
            Map<Integer, Set<String>> SetsMap = new Map<Integer, Set<String>>();
            if(ToggleProgIds.size() > 0)
            {
                Integer i = 0;
                Integer j = 1;
                Set<String> newSet;
                for(String s: ToggleProgIds)
                {
                    if(i == 0)
                       newSet = new Set<String>();
                    if(i <= 10) {
                       if(!SetsMap.containsKey(j))
                       {
                           newSet.add(s);
                           SetsMap.put(j, newSet);
                       } else {
                           Set<String> existingSet = SetsMap.get(j);
                           existingSet.add(s);
                           SetsMap.put(j, existingSet);
                       }
                    }
                    i++;
                    if(i == 10) { 
                        j++;
                        i = 0;
                    }
                }
            }
            
            if(SetsMap.size() > 0)
            {
                for(Integer i: SetsMap.KeySet())
                {
                    Set<String> s = SetsMap.get(i);
                    if(!Test.isRunningTest())
                        ToggleProjectUpdate.DeactivateToggleProject(s);
                }
            }
            
        }
    }
    
    
    private void UpdateProjectStatge(list<TASKRAY__Project__c>newList, list<TASKRAY__Project__c>oldList, map<id, TASKRAY__Project__c> newMap, map<id, TASKRAY__Project__c> oldMap) {
        Date TodayDate = Date.Today();
        for(TASKRAY__Project__c proj : newList) {
            if(proj.Client_Kick_Off_Meeting__c <= TodayDate && proj.Client_Delivered_Date__c == null && proj.Project_Stage_New__c != '2 - In Progress')
                proj.Project_Stage_New__c = '2 - In Progress';
            if(proj.Client_Delivered_Date__c != null && proj.Project_Stage_New__c != '3 - Delivered to Client')
                proj.Project_Stage_New__c = '3 - Delivered to Client';
            if(proj.Client_Feedback_Requested__c == true)
                proj.Project_Stage_New__c = '4 - Client Feedback Request';
            if(!String.isEmpty(proj.Deliverable_Satisfaction__c) || !String.isEmpty(proj.Meet_Business_Objective__c)
            || !String.isEmpty(proj.Project_Timeliness__c) || !String.isEmpty(proj.Deliverable_Components__c)
            || !String.isEmpty(proj.Use_DRE_Again__c) || !String.isEmpty(proj.Request__c))
                proj.Project_Stage_New__c = '5 - Client Feedback Received';
        }
    }
     
    private void checkProjectName(list<TASKRAY__Project__c> newList, String triggerValue, map<Id,TASKRAY__Project__c> oldMap)
    {
        map<String, TASKRAY__Project__c> nameMap = new Map<String, TASKRAY__Project__c>(); 
       	
        //if inserting multiple objects, check to see if any have the same name
        for(TASKRAY__Project__c tpcTmp : newList)
        {
            if(triggerValue != 'isUpdate')
            {
                if(nameMap.containsKey(tpcTmp.Name))
                {
                    tpcTmp.addError('Project Name (PICO ID) Must be Unique');
                }
                else
                {
                    nameMap.put(tpcTmp.Name, tpcTmp);
                }      
            }
            else
            {
                //if updating, only interested to see if the name got updated
                if(tpcTmp.Name != oldMap.get(tpcTmp.Id).Name)
                {
                    if(nameMap.containsKey(tpcTmp.Name))
                    {
                        tpcTmp.addError('Project Name (PICO ID) Must be Unique');
                    }
                    else
                    {
                        nameMap.put(tpcTmp.Name, tpcTmp);
                    }     
                }
            }
        }//end for
        
        //check to see whether any of the project names already exists in the database and if so, display an error        
        List<TASKRAY__Project__c> tpcList = [Select Name from TASKRAY__Project__c where Name in :nameMap.keySet()];  
                 
        if(!tpcList.isEmpty())
        {
            for(TASKRAY__Project__c tpcTmp : tpcList)
            {
				if (nameMap.get(tpcTmp.Name) != null){
					TASKRAY__Project__c tpcFaulty = nameMap.get(tpcTmp.Name);
					tpcFaulty.addError('Project Name (PICO ID) Must be Unique');	
				}
            }//end for
        }        
    }
}