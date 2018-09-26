/*******************************************************************************************************
*    Name:  TogglGAAPClassBatch.cls
*    Author:  
*    Date:  9/24/2018
*    
*    Test class:TogglGAAPClassTest.cls
*    Update GAAP Class for all Toggl projects
*    TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
*    database.executebatch(d, 200);
********************************************************************************************************/

global class TogglGAAPClassBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String Query = 'SELECT Id, GAAP_Class__c, Account__c, Account__r.Name, Project__c, Project__r.Name, Project__r.TASKRAY__trOpportunity__c, Project__r.TASKRAY__trOpportunity__r.StageName, Opportunity__c, Opportunity__r.StageName FROM Toggl_Time_Entry__c WHERE Project__c <> NULL';
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<Toggl_Time_Entry__c> scope)
    {
                 
        OpportunityAllHandler OAH = new OpportunityAllHandler();
        OAH.UpdateTimeEntryGAAPClass(scope);
        
    }

    global void finish(Database.BatchableContext bc)
    {
        
    }
}