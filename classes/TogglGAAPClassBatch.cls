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
        return Database.getQueryLocator(System.Label.GAAPBatchQuery);//'SELECT Id, Project_Name__c, Account__r.Name FROM Toggl_Time_Entry__c WHERE Id = \'a1hc0000001khPkAAI\'');
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        SetGAAPClass((List<Toggl_Time_Entry__c>)scope, true);
    }
    
    public static void SetGAAPClass(List<Toggl_Time_Entry__c> scope, boolean setProjectAndOpp) {
    	Map<String, Opportunity> OpportunityMap = new Map<String, Opportunity>();
        Set<String> projectNames = new Set<String>();
        for (Toggl_Time_Entry__c tte : scope) {
            String projectName = tte.Project_Name__c;
            string oppId = null;
            if(projectName.contains('|'))
            {
                String[] pName = projectName.split('\\|');
                string firstPart = pName[0].trim();
                projectName = firstPart;//pName[1].trim();
                if (firstPart.length() >= 3) {
                    if (firstPart.startsWith('SF') && firstPart.substring(2).isNumeric()) {
                        oppId = firstPart;
                    }
                }
                system.debug('projectName---' + projectName);
            }
            projectNames.add(projectName);
            if (oppId != null) {
                OpportunityMap.put(oppId, null);
            }
        }
            
        Map<String, TASKRAY__Project__c> TASKRAYProjectsMap = new Map<String, TASKRAY__Project__c>();
        Map<String, Opportunity> TASKRAYProjectsOpps = new Map<String, Opportunity>();
        // Get Existing Task RAY Projects
        List<TASKRAY__Project__c> existingTASKRAYProjects = [SELECT Id, Name, Client_Delivered_Date__c, TASKRAY__trOpportunity__r.First_non_NA_Invoice_Date__c, TASKRAY__trOpportunity__c, 
        															TASKRAY__trOpportunity__r.StageName, TASKRAY__trOpportunity__r.CloseDate , POC__c
        														FROM TASKRAY__Project__c WHERE Name IN :projectNames];
        system.debug('projectNames---' + projectNames);
        system.debug('existingTASKRAYProjects----' + existingTASKRAYProjects);
        for (TASKRAY__Project__c existingProject : existingTASKRAYProjects) {
            TASKRAYProjectsMap.put(existingProject.Name, existingProject);
            TASKRAYProjectsOpps.put(existingProject.Name, existingProject.TASKRAY__trOpportunity__r);
        }
        
        for (Opportunity opp : [SELECT Opportunity_ID__c, StageName, CloseDate FROM Opportunity WHERE Opportunity_ID__c IN :OpportunityMap.keyset()]) {
            OpportunityMap.put(opp.Opportunity_ID__c, opp);
        }
        
        for (Toggl_Time_Entry__c tte : scope) {
            String projectName = tte.Project_Name__c;
            String projectName2 = null;
            string oppId = null;
            if(projectName.contains('|'))
            {
                String[] pName = projectName.split('\\|');
                string firstPart = pName[0].trim();
                projectName = firstPart;
                projectName2 = pName[1].trim();
                if (firstPart.length() >= 3) {
                    if (firstPart.startsWith('SF') && firstPart.substring(2).isNumeric()) {
                        oppId = firstPart;
                    }
                }
            }
            String accountName = tte.Account__r.Name;
            String opportunityStageName = '';
            Date opportunityCloseDate = null;
            
            if (TASKRAYProjectsOpps.containsKey(projectName) && TASKRAYProjectsOpps.get(projectName) != null) {
                opportunityStageName = TASKRAYProjectsOpps.get(projectName).StageName;
                opportunityCloseDate = TASKRAYProjectsOpps.get(projectName).CloseDate;
            }
            
            if (oppId != null && OpportunityMap.containsKey(oppId) && OpportunityMap.get(oppId) != null) {
                opportunityStageName = OpportunityMap.get(oppId).StageName;
                opportunityCloseDate = OpportunityMap.get(oppId).CloseDate;
            }
            
            Boolean notPOC = false;
            if(TASKRAYProjectsMap.containsKey(projectName)) {
                notPOC = true;
            	TASKRAY__Project__c trp = TASKRAYProjectsMap.get(projectName);
            	if (trp == null) {
                    notPOC = false;
                } else {
                    if (trp.POC__c != 'Not POC')
                        notPOC = false;
                    if (trp.Client_Delivered_Date__c == null)
                        notPOC = false;
                    if (trp.TASKRAY__trOpportunity__r.First_non_NA_Invoice_Date__c == null)
                        notPOC = false;
                    else if (tte.Start_Date__c > trp.TASKRAY__trOpportunity__r.First_non_NA_Invoice_Date__c)
                        notPOC = false;
                }
            }
            
            system.debug('projectName before---' + projectName);
            system.debug('opportunityStageName---' + opportunityStageName);
            String GAAPClass = TogglToSalesforce.GetGAAPClass(projectName, projectName2, accountName, opportunityStageName, opportunityCloseDate, tte.Start_Date__c == null ? null : tte.Start_Date__c.date(), notPOC);
            
            Id projectId = null;
            Id opportunityId = null;
            system.debug('TASKRAYProjectsMap.get(projectName)---' + TASKRAYProjectsMap.get(projectName));
            if(TASKRAYProjectsMap.containsKey(projectName))
            {
                TASKRAY__Project__c trp = TASKRAYProjectsMap.get(projectName);
                if(trp != null)
                {
                    projectId = TASKRAYProjectsMap.get(projectName).Id;
                    opportunityId = TASKRAYProjectsMap.get(projectName).TASKRAY__trOpportunity__c;
                }
            }
            if (oppId != null && OpportunityMap.containsKey(oppId) && OpportunityMap.get(oppId) != null) {
                opportunityId = OpportunityMap.get(oppId).Id;
            }
            
            if (setProjectAndOpp) {
	            tte.Project__c = projectId;
	            tte.Opportunity__c = opportunityId;
            }
            tte.GAAP_Class__c = GAAPClass;
            
        }
        
        update scope;
    }

    global void finish(Database.BatchableContext bc)
    {
        
    }
}