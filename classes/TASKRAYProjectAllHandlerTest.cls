@isTest
public class TASKRAYProjectAllHandlerTest {
    
    private static testmethod void testTASKRAYProjectAllInsert(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Client_Kick_Off_Meeting__c = (Date.Today()).addDays(-5);
        
        Test.StartTest();
            insert tProject;
        Test.StopTest();
        
        TASKRAY__Project__c currentTProject = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('2 - In Progress', currentTProject.Project_Stage_New__c);
       
    }
    
    private static testmethod void testTASKRAYProjectAllUpdate(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        insert tProject;
        
        TASKRAY__Project__c currentTProject = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('1 - New Project Request', currentTProject.Project_Stage_New__c);
        
        Test.StartTest();
            currentTProject.Client_Kick_Off_Meeting__c = (Date.Today()).addDays(-5);
            update currentTProject;
        Test.StopTest();
        
        TASKRAY__Project__c currentTProjectUp = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('2 - In Progress', currentTProjectUp.Project_Stage_New__c);
        
        
    }
    
    
    private static testmethod void testTASKRAYProjectAllUpdate1(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        insert tProject;
        
        TASKRAY__Project__c currentTProject = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('1 - New Project Request', currentTProject.Project_Stage_New__c);
        
        Test.StartTest();
            currentTProject.Client_Delivered_Date__c = (Date.Today()).addDays(-5);
            update currentTProject;
        Test.StopTest();
        
        TASKRAY__Project__c currentTProjectUp = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('3 - Delivered to Client', currentTProjectUp.Project_Stage_New__c);
        
        
    }
    
    private static testmethod void testTASKRAYProjectAllUpdate2(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        insert tProject;
        
        TASKRAY__Project__c currentTProject = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('1 - New Project Request', currentTProject.Project_Stage_New__c);
        
        Test.StartTest();
            currentTProject.Client_Feedback_Requested__c = true;
            update currentTProject;
        Test.StopTest();
        
        TASKRAY__Project__c currentTProjectUp = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('4 - Client Feedback Request', currentTProjectUp.Project_Stage_New__c);
        
        
    }
    
    private static testmethod void testTASKRAYProjectAllUpdate3(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        insert tProject;
        
        TASKRAY__Project__c currentTProject = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('1 - New Project Request', currentTProject.Project_Stage_New__c);
        
        Test.StartTest();
            currentTProject.Deliverable_Satisfaction__c = '4 - Satisfied';
            update currentTProject;
        Test.StopTest();
        
        TASKRAY__Project__c currentTProjectUp = [SELECT Id, Project_Stage_New__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals('5 - Client Feedback Received', currentTProjectUp.Project_Stage_New__c);
        
        
    }
    
    private static testmethod void testTASKRAYProjectAllUpdate4(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Secondary_Project_Name__c = 'Seconday Project Name';
        tProject.Toggl_Auto_Creation_Approved__c = true;
        
        Test.StartTest();
            insert tProject;
        Test.StopTest();
    }
    
    private static testmethod void testTASKRAYProjectAllUpdate5(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Secondary_Project_Name__c = 'Seconday Project Name';
        insert tProject;
        
        TASKRAY__Project__c currentTProject = [SELECT Id, Toggl_Auto_Creation_Approved__c  FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        
        Test.StartTest();
            currentTProject.Toggl_Auto_Creation_Approved__c = true;
            update currentTProject;
        Test.StopTest();
    }
    
    private static testmethod void testTASKRAYProjectAllUpdate7(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Secondary_Project_Name__c = 'Seconday Project Name';
        insert tProject;
        
        TASKRAY__Project__c currentTProject = [SELECT Id, Toggl_Auto_Creation_Approved__c  FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        Toggl_Time_Entry__c tpe = new Toggl_Time_Entry__c ();
        tpe.Toggl_Id__c = '222222';
        tpe.Project__c = currentTProject.Id;
        insert tpe;
        
        Test.StartTest();
            currentTProject.Archived_Date__c = Date.today();
            update currentTProject;
        Test.StopTest();
    }
    private static testmethod void testTASKRAYProjectAllUniqueName()
    {
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        List<TASKRAY__Project__c> tpList = new List<TASKRAY__Project__c>();
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'Test Name';
        tProject.Secondary_Project_Name__c = 'Seconday Project Name';
        tpList.add(tProject);
        
        TASKRAY__Project__c tProject1 = new TASKRAY__Project__c();
        tProject1.TASKRAY__trAccount__c = acc.Id;
        tProject1.Name = 'Test Name';
        tProject1.Secondary_Project_Name__c = 'Seconday Project Name';
        
        TASKRAY__Project__c tProject2 = new TASKRAY__Project__c();
        tProject2.TASKRAY__trAccount__c = acc.Id;
        tProject2.Name = 'Test Name1';
        tProject2.Secondary_Project_Name__c = 'Seconday Project Name';
        tpList.add(tProject2);
        
        insert tpList;
        
        Test.StartTest();
        
        try
        {
            insert tProject1;
        }
        catch(Exception e){}
        try
        {
            tProject2.Name = 'Test Name';
            update tproject2;
        }
        catch(Exception e){}
        
        
        Test.StopTest();
        
        List<TASKRAY__Project__c> testProjectList = [SELECT Id, Name FROM TASKRAY__Project__c WHERE Id in :tpList];
        Map<Id, TASKRAY__Project__c> testProjectMap = new Map<Id, TASKRAY__Project__c>(testProjectList);
        
        system.assertEquals(2, testProjectList.size());
        system.assertEquals('Test Name', testProjectMap.get(tProject.Id).Name);
        system.assertEquals('Test Name1', testProjectMap.get(tProject2.Id).Name);
    }

}