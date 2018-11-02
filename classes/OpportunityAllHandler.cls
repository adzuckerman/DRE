/********************************************************************************************************
*    Handler Name:  OpportunityAllHandler.cls
*    Author: OMNIVO DIGITAL (www.omnivodigital.com)
*    Date:  9/24/2018
*    
*    Trigger: OpportunityAll.trigger
*    Test class: OpportunityAllHandlerTest.cls
********************************************************************************************************/

public class OpportunityAllHandler {
    //Handler for before insert methods
    //public void onBeforeInsert(list<Opportunity> newList , map<id, Opportunity> newMap) {
        
    //}
    //Handler for after insert methods
    //public void onAfterInsert(list<Opportunity> newList , map<id, Opportunity> newMap) {
        
    //}
    //Handler for before Update methods
    public void onBeforeUpdate(list<Opportunity> newList, map<id, Opportunity> newMap , map<id, Opportunity> oldMap) {
        
    }
    //Handler for after Update methods
    public void onAfterUpdate(list<Opportunity> newList, map<id, Opportunity> newMap,  map<id, Opportunity> oldMap) {
        UpdateTogglTimeEntryGAAPClass(newList, newMap, oldMap);
    }

    //Handler for before Deletes methods
    /*public void onBeforeDelete(list<Opportunity> oldList , map<id, Opportunity> oldMap) {

    }
    //Handler for after Deletes methods
    public void onAfterDelete(list<Opportunity> oldList , map<id, Opportunity> oldMap) {

    }*/
    
    private void UpdateTogglTimeEntryGAAPClass(list<Opportunity> newList , map<id, Opportunity> newMap, map<id, Opportunity> oldMap)
    {
        Set<Id> OpportunityIds = new Set<Id>();
        for( Opportunity opp: newList ) 
        {
            Opportunity oldOpp = oldMap.get(opp.Id);
            if(opp.StageName != oldOpp.StageName)
                OpportunityIds.add(opp.Id);
        }
        
        if(OpportunityIds.size() > 0)
        {
            List<Toggl_Time_Entry__c> TogglTimeEntries = [SELECT Id, GAAP_Class__c, Account__c, Account__r.Name, Project__c, Project__r.Name, Project__r.TASKRAY__trOpportunity__c, Project__r.TASKRAY__trOpportunity__r.StageName, Opportunity__c, Opportunity__r.StageName FROM Toggl_Time_Entry__c WHERE Opportunity__c IN: OpportunityIds];
            UpdateTimeEntryGAAPClass(TogglTimeEntries);
        }
            
    }
    
    
    // called also from TogglGAAPClassBatch.cls
    public void UpdateTimeEntryGAAPClass(List<Toggl_Time_Entry__c> allTimeEntries) {
        if(allTimeEntries.size() > 0)
        {
            for ( Toggl_Time_Entry__c timeEntry : allTimeEntries ) {
                
                String StageName = '';
                if(timeEntry.Opportunity__c == null)
                {
                    timeEntry.Opportunity__c = timeEntry.Project__r.TASKRAY__trOpportunity__c; 
                    StageName = timeEntry.Project__r.TASKRAY__trOpportunity__r.StageName; 
                } else {
                    StageName = timeEntry.Opportunity__r.StageName; 
                }   
                System.debug('Opp ====> ' + timeEntry.Opportunity__c);
                System.debug('StageName ====> ' + StageName );
                if(!String.isEmpty(timeEntry.Project__r.Name) && !String.isEmpty(StageName) && !String.isEmpty(timeEntry.Account__r.Name))
                {
                    String taskrayType = '';
                    if((timeEntry.Project__r.Name).contains('-'))
                    {
                        String[] splitProject = (timeEntry.Project__r.Name).split('-');
                        if(splitProject[2] != null && splitProject[2] != '')
                        {
                            if(splitProject[2].length() == 3)
                                taskrayType = 'PICO ID';
                            if(splitProject[2].length() == 4)
                                taskrayType = 'Contract ID';
                        }
                    }
                    
                    if(timeEntry.Account__r.Name != 'Doctor Evidence' && timeEntry.Account__r.Name != 'DRE Tech')
                    {
                        if(taskrayType == 'Contract ID' || taskrayType == 'PICO ID' || timeEntry.Project__r.Name == 'DOC Label' || timeEntry.Project__r.Name == 'Data Hub')
                        {
                            if(StageName != 'Closed Won' && StageName != 'Closed Lost')
                            {
                                timeEntry.GAAP_Class__c  = 'Work In Progress';  
                            } 
                            if(StageName == 'Closed Won')
                                timeEntry.GAAP_Class__c = 'Cost of Revenue';
                            if(StageName == 'Closed Lost')   
                                timeEntry.GAAP_Class__c = 'Sales & Marketing';
                        }
                        else if (timeEntry.Project__r.Name == 'Pre-Sale'){
                            timeEntry.GAAP_Class__c = 'Sales & Marketing';
                        }
                    } else {
                        if(timeEntry.Account__r.Name == 'Doctor Evidence')
                        {
                            if(timeEntry.Project__r.Name == 'CE Admin/Internal' || timeEntry.Project__r.Name == 'CS Admin/Internal')
                            {
                                timeEntry.GAAP_Class__c = 'Sales & Marketing';
                            } else {
                                timeEntry.GAAP_Class__c = 'General & Administrative';
                            }
                           
                        } else {
                            if(timeEntry.Account__r.Name == 'DRE Tech')
                            {
                                if(timeEntry.Project__r.Name == 'DRE Tech_Admin/Internal' || timeEntry.Project__r.Name == 'DRE Tech_Platform Maintenance')
                                {
                                    timeEntry.GAAP_Class__c = 'Research & Development';
                                } else {
                                    timeEntry.GAAP_Class__c = '2.0 Cap';
                                }
                            }
                        }
                    }
                    
                }
            }
            update allTimeEntries;
        }
    }
}