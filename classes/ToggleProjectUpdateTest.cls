/********************************************************************************************************
*    Handler class: ToggleProjectUpdateTest.cls
*    Author:  
*    Date:  8/22/2018
*    
*    Called from:  TASKRAYProjectAllHandler.trigger
*    Test class: ToggleProjectUpdate.cls
*    Mock Class: HTTPMockCallout.cls
********************************************************************************************************/

@isTest
public class ToggleProjectUpdateTest {

    private static testmethod void testToggleProjectUpdate(){
    
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
        
        TASKRAY__Project__c currentTProject = [SELECT Id, TASKRAY__Status__c, Archived_Reason__c, Archived_Date__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        
        Test.StartTest();
            
            currentTProject.TASKRAY__Status__c = true;
            currentTProject.Archived_Reason__c = 'Contract Terminated';
            currentTProject.Archived_Date__c = datetime.now();
            
            update currentTProject;
            Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        Test.StopTest();
        
        //TASKRAY__Project__c currentTProjectUp = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        //System.assertEquals('Client Feedback Request', currentTProjectUp.Project_Stage_New__c);
        
        
    }
    
    private static testmethod void testToggleProjectUpdate1(){
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        // from the class that implements HttpCalloutMock. 
        Set<String> aId = new Set<String>();
        aId.add('912345678');
        ToggleProjectUpdate.DeactivateToggleProject(aId);
        
        // Verify response received contains fake values
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        //System.assertEquals(200, res.getStatusCode());
    }
}