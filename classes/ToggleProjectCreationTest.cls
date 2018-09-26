/********************************************************************************************************
*    Handler class: ToggleProjectCreationTest.cls
*    Author:  
*    Date:  9/4/2018
*    
*    Called from:  TASKRAYProjectAllHandler.trigger
*    Test class: ToggleProjectCreation.cls
*    Mock Class: HTTPMockCallout.cls
********************************************************************************************************/

@isTest
public class ToggleProjectCreationTest {

    private static testmethod void testToggleProjectCreation(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'sa4-test-project';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        insert tte;
        
        Set<Id> pIds = new Set<Id>();
        pIds.add(tProject.Id);
        Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
            ToggleProjectCreation.CreateToggleProject(pIds);
            
        Test.StopTest();
        
        
    }
    
    
}