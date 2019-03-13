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

    private static testmethod void testToggleProjectCreationNew(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.Toggl_Auto_Creation_Approved__c = true;
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'sa4-test-project';
        insert tProject;
        
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        
        Test.StartTest();
        
        ToggleProjectCreation.CreateToggleProject(new Set<Id> { tProject.Id });
        
        Test.StopTest();
        
        tProject = [SELECT Toggl_Id__c FROM TASKRAY__Project__c WHERE Id = :tProject.Id];
        System.assertEquals('912345678', tProject.Toggl_Id__c);
    }
    
    private static testmethod void testToggleProjectCreationExisting(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 348975';
        opp.AccountId = acc.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today();
        insert opp;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.Toggl_Auto_Creation_Approved__c = true;
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'sa4-test-WXYA';
        tProject.Secondary_Project_Name__c = 'X';
        tProject.TASKRAY__trOpportunity__c = opp.Id;
        insert tProject;
        
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        
        Test.StartTest();
        
        ToggleProjectCreation.CreateToggleProject(new Set<Id> { tProject.Id });
        
        Test.StopTest();
        
        tProject = [SELECT Toggl_Id__c FROM TASKRAY__Project__c WHERE Id = :tProject.Id];
        System.assertEquals('912345679', tProject.Toggl_Id__c);
    }
    
}