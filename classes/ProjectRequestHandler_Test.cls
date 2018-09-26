@isTest
public class ProjectRequestHandler_Test {

    private static testmethod void testRequestHandler(){
        //test data setup
        Account acc = new Account();
        acc.Name = 'Sanofi';
        insert acc;
        
        Contact newContact = new Contact();
        newContact.FirstName = 'FirstName1';
        newContact.LastName = 'LastName1';
        newContact.Email = 'test1@email.com';
        newContact.AccountId = acc.Id;
        insert newContact;
        
        Project_Request__c pr1 = new Project_Request__c();
        pr1.Requester_Name__c = 'FirstName1 LastName1';
        pr1.Requester_Email__c = 'test1@email.com';
        pr1.Question__c = '12345678901234567890';
        pr1.Problem__c = '12345678901234567890';
        pr1.Solution__c = '12345678901234567890';
        pr1.Value__c = '12345678901234567890';
            
        insert pr1;
        
        Project_Request__c pr2 = new Project_Request__c();
        pr2.Requester_Name__c = 'FirstName2 LastName2';
        pr2.Requester_Email__c = 'test2@email.com';
		pr2.Question__c = '12345678901234567890';
        pr2.Problem__c = '12345678901234567890';
        pr2.Solution__c = '12345678901234567890';
        pr2.Value__c = '12345678901234567890';
        insert pr2;
        
        Project_Request__c myPR1 = [SELECT Id, Requester_Contact__r.Name FROM Project_Request__c WHERE Id = :pr1.Id];
        Project_Request__c myPR2 = [SELECT Id, Requester_Contact__r.Name FROM Project_Request__c WHERE Id = :pr2.Id];
        
        system.assertEquals(myPR1.Requester_Contact__r.Name, pr1.Requester_Name__c);
        system.assertEquals(myPR1.Requester_Contact__r.Name, pr1.Requester_Name__c);     
    }        
}