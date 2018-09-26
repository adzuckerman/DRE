@isTest
public class projectToRequest_EXT_Test {

    public static testMethod void testProjectToRequest_EXT(){
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
        
        apexpages.StandardController sc = new apexpages.StandardController(pr1);
        projectToRequest_EXT ext = new projectToRequest_EXT(sc);
        
        projectToRequest_EXT.convertRequestToProject();
        
        //TO-DO: Make this a proper test class with asserts, duplicate functionality checking, etc
    }
}