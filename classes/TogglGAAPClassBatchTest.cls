@isTest
public class TogglGAAPClassBatchTest{
    
    private static testmethod void testOpportunityAllHandler1(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
       
        opp.CloseDate = (Date.today()).addDays(6);
        insert opp;
        
        
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'sa4-test-WXYZ';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        tte.Opportunity__c = opp.Id;
        insert tte;
        
        Opportunity opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        opp1.StageName = 'Closed Lost';
        update opp1;
        
        Test.StartTest();
            TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
            database.executebatch(d, 1);
        Test.StopTest();
        
        Toggl_Time_Entry__c timeEntry = [SELECT Id, GAAP_Class__c  FROM Toggl_Time_Entry__c WHERE Id = :tte.Id];
        System.assertEquals('Sales & Marketing', timeEntry.GAAP_Class__c);
        
    }
    
    private static testmethod void testOpportunityAllHandler2(){
        
        Account acc = new Account();
        acc.Name = 'Doctor Evidence';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
       
        opp.CloseDate = (Date.today()).addDays(6);
        insert opp;
        
        
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'CE Admin/Internal';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        tte.Opportunity__c = opp.Id;
        insert tte;
        
        Opportunity opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        opp1.StageName = 'Closed Lost';
        update opp1;
        
        Test.StartTest();
            TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
            database.executebatch(d, 1);
        Test.StopTest();
        
        Toggl_Time_Entry__c timeEntry = [SELECT Id, GAAP_Class__c  FROM Toggl_Time_Entry__c WHERE Id = :tte.Id];
        System.assertEquals('Sales & Marketing', timeEntry.GAAP_Class__c);
        
    }
    
    private static testmethod void testOpportunityAllHandler3(){
        
        Account acc = new Account();
        acc.Name = 'DRE Tech';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
       
        opp.CloseDate = (Date.today()).addDays(6);
        insert opp;
        
        
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'DRE Tech_Admin/Internal';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        tte.Opportunity__c = opp.Id;
        insert tte;
        
        Opportunity opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        opp1.StageName = 'Closed Lost';
        update opp1;
        
        Test.StartTest();
            TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
            database.executebatch(d, 1);
        Test.StopTest();
        
        Toggl_Time_Entry__c timeEntry = [SELECT Id, GAAP_Class__c  FROM Toggl_Time_Entry__c WHERE Id = :tte.Id];
        System.assertEquals('Research & Development', timeEntry.GAAP_Class__c);
        
    }
    
    private static testmethod void testOpportunityAllHandler4(){
        
        Account acc = new Account();
        acc.Name = 'DRE Tech';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
       
        opp.CloseDate = (Date.today()).addDays(6);
        insert opp;
        
        
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'toggle project name';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        tte.Opportunity__c = opp.Id;
        insert tte;
        
        Opportunity opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        opp1.StageName = 'Closed Lost';
        update opp1;
        
        Test.StartTest();
            TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
            database.executebatch(d, 1);
        Test.StopTest();
        
        Toggl_Time_Entry__c timeEntry = [SELECT Id, GAAP_Class__c  FROM Toggl_Time_Entry__c WHERE Id = :tte.Id];
        System.assertEquals('2.0 Cap', timeEntry.GAAP_Class__c);
        
    }
}