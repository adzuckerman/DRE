@isTest
public class TogglGAAPClassBatchTest{
    
    private static testmethod void testGAAPClassBatch1() {

        Account acc = new Account();
        acc.Name = 'Doctor Evidence';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test926345';
        opp.AccountId = acc.Id;
        opp.StageName = 'Qualification/Prospecting';
        opp.CloseDate = Date.today();
        insert opp;
        
        TASKRAY__Project__c proj = new TASKRAY__Project__c();
        proj.Name = 'CE Admin/Internal';
        proj.TASKRAY__trOpportunity__c = opp.Id;
        insert proj;
        
        Toggl_Time_Entry__c timeEntry = new Toggl_Time_Entry__c();
        timeEntry.Account__c = acc.Id;
        timeEntry.Project_Name__c = 'CE Admin/Internal';
        insert timeEntry;
        
        Test.StartTest();
            Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
            TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
            database.executebatch(d, 1);
        Test.StopTest();
        
        timeEntry = [SELECT Project__c, GAAP_Class__c, Opportunity__c FROM Toggl_Time_Entry__c WHERE Id = :timeEntry.Id];
        System.assertEquals(proj.Id, timeEntry.Project__c);
        System.assertEquals(opp.Id, timeEntry.Opportunity__c);
        System.assertEquals('Sales & Marketing', timeEntry.GAAP_Class__c);
    }
    
    private static testmethod void testGAAPClassBatch2() {

        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test926345';
        opp.AccountId = acc.Id;
        opp.StageName = 'Qualification/Prospecting';
        opp.CloseDate = Date.today();
        insert opp;
        
        opp = [SELECT Opportunity_ID__c FROM Opportunity WHERE Id = :opp.Id];
        
        TASKRAY__Project__c proj = new TASKRAY__Project__c();
        proj.Name = opp.Opportunity_ID__c;// + ' | SNF-Neur-025';
        proj.TASKRAY__trOpportunity__c = opp.Id;
        insert proj;
        
        Toggl_Time_Entry__c timeEntry = new Toggl_Time_Entry__c();
        timeEntry.Account__c = acc.Id;
        timeEntry.Project_Name__c = opp.Opportunity_ID__c + ' | SNF-Neur-025';
        insert timeEntry;
        
        Test.StartTest();
            Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
            TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
            database.executebatch(d, 1);
        Test.StopTest();
        
        timeEntry = [SELECT Project__c, GAAP_Class__c, Opportunity__c FROM Toggl_Time_Entry__c WHERE Id = :timeEntry.Id];
        system.debug('timeEntry---' + timeEntry);
        System.assertEquals(proj.Id, timeEntry.Project__c);
        System.assertEquals(opp.Id, timeEntry.Opportunity__c);
        System.assertEquals('Work in Progress', timeEntry.GAAP_Class__c);
    }
}