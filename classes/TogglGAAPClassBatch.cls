/*******************************************************************************************************
*    Name:  TogglGAAPClassBatch.cls
*    Author: OMNIVO DIGITAL (www.omnivodigital.com) 
*    Date:  9/24/2018
*    Modified Date: 10/1/2018
*
*    Test class:TogglGAAPClassTest.cls
*    Update GAAP Class for all Toggl projects
*    TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
*    database.executebatch(d, 10);
********************************************************************************************************/

global with sharing class TogglGAAPClassBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global TogglGAAPClassBatch(){
    }
     
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Project_Name__c, Account__r.Name FROM Toggl_Time_Entry__c WHERE Project_Name__c != NULL AND Project__c = NULL');
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        
        Set<String> projectNames = new Set<String>();
        for (Toggl_Time_Entry__c tte : (List<Toggl_Time_Entry__c>)scope) {
            projectNames.add(tte.Project_Name__c);
            System.debug(tte.Id);
        }
            
        Map<String, TASKRAY__Project__c> TASKRAYProjectsMap = new Map<String, TASKRAY__Project__c>();
        Map<String, String> TASKRAYProjectsStageMap = new Map<String, String>();
        // Get Existing Task RAY Projects
        List<TASKRAY__Project__c> existingTASKRAYProjects = [SELECT Id, Name, TASKRAY__trOpportunity__c, TASKRAY__trOpportunity__r.StageName FROM TASKRAY__Project__c WHERE Name IN :projectNames];
        for (TASKRAY__Project__c existingProject : existingTASKRAYProjects) {
            TASKRAYProjectsMap.put(existingProject.Name, existingProject);
            TASKRAYProjectsStageMap.put(existingProject.Name, existingProject.TASKRAY__trOpportunity__r.StageName);
        }
        
        for (Toggl_Time_Entry__c tte : (List<Toggl_Time_Entry__c>)scope) {
            String projectName = tte.Project_Name__c;
            String accountName = tte.Account__r.Name;
            String opportunityStageName = '';
            String GAAPClass = '';
            String taskrayType = '';
            
            
            if (TASKRAYProjectsMap.containsKey(projectName))
                opportunityStageName = TASKRAYProjectsStageMap.get(projectName);
            
            if(!String.isEmpty(projectName) && !String.isEmpty(opportunityStageName) && !String.isEmpty(accountName))
            {
                if(projectName.contains('-'))
                {
                    String[] splitProject = projectName.split('-');
                    if(splitProject[2] != null && splitProject[2] != '')
                    {
                        if(splitProject[2].length() == 3) taskrayType = 'PICO ID';
                        if(splitProject[2].length() == 4) taskrayType = 'Contract ID';
                    }
                }
                
                if(accountName != 'Doctor Evidence' && accountName != 'DRE Tech')
                {
                    if(taskrayType == 'Contract ID' || taskrayType == 'PICO ID')
                    {
                        if(opportunityStageName != 'Closed Won' && opportunityStageName != 'Closed Lost') GAAPClass = 'Work In Progress';  
                        if(opportunityStageName == 'Closed Won') GAAPClass = 'Cost of Revenue';
                        if(opportunityStageName == 'Closed Lost') GAAPClass = 'Sales & Marketing';
                    }
                } else {
                    if(accountName == 'Doctor Evidence')
                    {
                        if(projectName == 'CE Admin/Internal' || projectName == 'CS Admin/Internal') {
                            GAAPClass = 'Sales & Marketing';
                        } else { GAAPClass = 'General & Administrative'; }
                    } else {
                        if(accountName == 'DRE Tech')
                        {
                            if(projectName == 'DRE Tech_Admin/Internal' || projectName == 'DRE Tech_Platform Maintenance') {
                                GAAPClass = 'Research & Development';
                            } else { GAAPClass = '2.0 Cap'; }
                        }
                    }
                }
            }
            Id projectId = null;
            Id opportunityId = null;
            if(TASKRAYProjectsMap.containsKey(projectName))
            {
                TASKRAY__Project__c trp = TASKRAYProjectsMap.get(projectName);
                if(trp != null)
                {
                    projectId = TASKRAYProjectsMap.get(projectName).Id;
                    opportunityId = TASKRAYProjectsMap.get(projectName).TASKRAY__trOpportunity__c;
                }
            }
            
            
            tte.Project__c = projectId;
            tte.Opportunity__c = opportunityId;
            tte.GAAP_Class__c = GAAPClass;
            
        }
        
        update scope;
        
        /*List<ToggleAccount__mdt> creds = [SELECT Username__c, Password__c, API_Token__c, Workspace_ID__c, New_User_Profile_Name__c FROM ToggleAccount__mdt];
        if (creds.isEmpty()) {
            throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
        }

        String username = creds[0].Username__c;
        String workspaceId = creds[0].Workspace_ID__c;
        
        
        
        Map<String, TASKRAY__Project__c> TASKRAYProjectsMap = new Map<String, TASKRAY__Project__c>();
        Map<String, String> TASKRAYProjectsStageMap = new Map<String, String>();
        // Get Existing Task RAY Projects
        List<TASKRAY__Project__c> existingTASKRAYProjects = [SELECT Id, Name, TASKRAY__trOpportunity__c, TASKRAY__trOpportunity__r.StageName FROM TASKRAY__Project__c];
        for (TASKRAY__Project__c existingProject : existingTASKRAYProjects) {
            TASKRAYProjectsMap.put(existingProject.Name, existingProject);
            TASKRAYProjectsStageMap.put(existingProject.Name, existingProject.TASKRAY__trOpportunity__r.StageName);
        }
        
       
        // Get Existing Toggl Time Entries where start date is between sinceDate and untilDate and that don't have an assigned Project or Opportunity
        List<Toggl_Time_Entry__c> ExistingTogglTimeEntries = [SELECT Id, Toggl_Id__c, Project_Name__c, Project__c, Opportunity__c, GAAP_Class__c FROM Toggl_Time_Entry__c WHERE Start_Date__c >=: sinceDate AND Start_Date__c <=: untilDate AND (Project__c = NULL OR Opportunity__c = NULL)];
        Map<String, Toggl_Time_Entry__c> TogglTimeEntriesMap = new Map<String, Toggl_Time_Entry__c>();
        for(Toggl_Time_Entry__c tte: ExistingTogglTimeEntries)
        {
            TogglTimeEntriesMap.put(tte.Toggl_Id__c, tte);
        }
        
        // List to keep the Toggl time entries to update
        List<Toggl_Time_Entry__c> tteToUpdate = new List<Toggl_Time_Entry__c>();
        
        // Iterate through pages and get all toggle time entries
        for(String spage : pages) 
        {
            Integer page = Integer.valueOf(spage);
            TogglToSalesforce TTS = new TogglToSalesforce();
            String requestUrl = apiReporstsUrl+ '/details?workspace_id=' + workspaceId + '&user_agent=' + username
                + '&since=' + sinceString + '&until=' + untilString + '&page=' + String.valueOf(page);
            HttpResponse resp = TTS.invokeCallout(requestUrl, '', 'GET', new Map<String, String>());
            
            if (resp.getStatusCode() == 400) {
                resp = TTS.invokeCallout(requestUrl, '', 'GET', new Map<String, String>());
    
                if (resp.getStatusCode() == 400) {
                    List<Toggl_Custom_Log__c> sameLogs = [SELECT Id FROM Toggl_Custom_Log__c WHERE URL__c = :requestUrl];
    
                    if (sameLogs.isEmpty()) {
                        Toggl_Custom_Log__c customLog = new Toggl_Custom_Log__c(
                            URL__c = requestUrl
                        );
                        insert customLog;
                    }
                    return;
                }
            }
            
            TogglToSalesforce.ReportDetailsWrapper reportDetails = (TogglToSalesforce.ReportDetailsWrapper) JSON.deserialize(resp.getBody(), TogglToSalesforce.ReportDetailsWrapper.class);
            
            // iterate through retrived time entries
            for (TogglToSalesforce.TimeEntryWrapper timeEntry : reportDetails.data) {
                // get project name
                String projectName = (timeEntry.project).trim();
                if(projectName.contains('|'))
                {
                    String[] pName = projectName.split('\\|');
                    projectName = (pName[0]).trim();
                }
                String accountName = timeEntry.client;
                String opportunityStageName = '';
                String GAAPClass = '';
                String taskrayType = '';
                
                    
                if(TASKRAYProjectsMap.containsKey(projectName))
                    opportunityStageName = TASKRAYProjectsStageMap.get(projectName);
                
                if(!String.isEmpty(projectName) && !String.isEmpty(opportunityStageName) && !String.isEmpty(accountName))
                {
                    if(projectName.contains('-'))
                    {
                        String[] splitProject = projectName.split('-');
                        if(splitProject[2] != null && splitProject[2] != '')
                        {
                            if(splitProject[2].length() == 3) taskrayType = 'PICO ID';
                            if(splitProject[2].length() == 4) taskrayType = 'Contract ID';
                        }
                    }
                    
                    if(accountName != 'Doctor Evidence' && accountName != 'DRE Tech')
                    {
                        if(taskrayType == 'Contract ID' || taskrayType == 'PICO ID')
                        {
                            if(opportunityStageName != 'Closed Won' && opportunityStageName != 'Closed Lost') GAAPClass = 'Work In Progress';  
                            if(opportunityStageName == 'Closed Won') GAAPClass = 'Cost of Revenue';
                            if(opportunityStageName == 'Closed Lost') GAAPClass = 'Sales & Marketing';
                        }
                    } else {
                        if(accountName == 'Doctor Evidence')
                        {
                            if(projectName == 'CE Admin/Internal' || projectName == 'CS Admin/Internal') {
                                GAAPClass = 'Sales & Marketing';
                            } else { GAAPClass = 'General & Administrative'; }
                        } else {
                            if(accountName == 'DRE Tech')
                            {
                                if(projectName == 'DRE Tech_Admin/Internal' || projectName == 'DRE Tech_Platform Maintenance') {
                                    GAAPClass = 'Research & Development';
                                } else { GAAPClass = '2.0 Cap'; }
                            }
                        }
                    }
                }
                Id projectId = null;
                Id opportunityId = null;
                if(TASKRAYProjectsMap.containsKey(projectName))
                {
                    TASKRAY__Project__c trp = TASKRAYProjectsMap.get(projectName);
                    if(trp != null)
                    {
                        projectId = TASKRAYProjectsMap.get(projectName).Id;
                        opportunityId = TASKRAYProjectsMap.get(projectName).TASKRAY__trOpportunity__c;
                    }
                }
                
                
                String stId = String.valueOf(timeEntry.id);
                // update existing toggl time entry
                if(TogglTimeEntriesMap.containsKey(stId))
                {
                    Toggl_Time_Entry__c tte = TogglTimeEntriesMap.get(stId);
                    tte.Project_Name__c = projectName;
                    tte.Project__c = projectId;
                    tte.Opportunity__c = opportunityId;
                    tte.GAAP_Class__c = GAAPClass;
                    tteToUpdate.add(tte);
                }
                
            }
        }
        if(tteToUpdate.size() > 0)
            update tteToUpdate;*/
    }
    
    

    global void finish(Database.BatchableContext bc)
    {
        
    }
}