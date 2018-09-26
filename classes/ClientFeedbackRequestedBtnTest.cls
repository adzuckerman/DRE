@isTest
public class ClientFeedbackRequestedBtnTest{
    
    private static testmethod void testClientFeedbackRequest(){
    
        Account acc1 = new Account();
        acc1.Name = 'Sanofi';
        insert acc1;
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        Contact cnt = new Contact();
        cnt.FirstName = 'Contact';
        cnt.LastName = 'Test';
        cnt.AccountId = acc.Id;
        cnt.Email = 'testemail@testemail.com';
        insert cnt;
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Client_Kick_Off_Meeting__c = (Date.Today()).addDays(-5);
        tProject.Contact_Name__c = cnt.Id;
        tProject.Requester_Name__c = 'Contact Test';
        tProject.Question__c = 'question question question question';
        tProject.Problem__c = 'problem problem problem problem';
        tProject.Solution__c = 'Solution solution solution solution';
        tProject.Value__c = 'Value Value Value Value Value Value';
        insert tProject;
        
        /*Project_Request__c pr = new Project_Request__c();
        pr.Requester_Contact__c = cnt.Id;
        pr.TaskRay_Project__c = tProject.Id;
        pr.Requester_Name__c = 'Contact Test';
        pr.Question__c = 'question question question question';
        pr.Problem__c = 'problem problem problem problem';
        pr.Solution__c = 'Solution solution solution solution';
        pr.Value__c = 'Value Value Value Value Value Value';
        insert pr;*/
        
        Apexpages.StandardController sc = new Apexpages.StandardController(tProject);
        ClientFeedbackRequestedBtn CFR = new ClientFeedbackRequestedBtn(sc);
        Test.StartTest();
            CFR.SendEmail();
            CFR.BackToTRProject();
        Test.StopTest();
        
        TASKRAY__Project__c currentTProject = [SELECT Id, Client_Feedback_Requested__c FROM TASKRAY__Project__c WHERE Id =: tProject.Id];
        System.assertEquals(true, currentTProject.Client_Feedback_Requested__c );
       
    }
}