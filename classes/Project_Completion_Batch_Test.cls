/*   Name:          Project_Completion_Batch_Test
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          5/18/2018
 *   Description:   Test Class for Project Project_Completion_Batch
 *                
 */
@isTest
public class Project_Completion_Batch_Test {
	
    public static testMethod void test_simple_Yesterday(){
        //test data setup
        Account acc = new Account();
        acc.Name = 'Test923736';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Contract_End__c = Date.today().addDays(-1);
        opp.Name = 'Test218927';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addDays(30);
        insert opp;
        
        TASKRAY__Project__c proj = new TASKRAY__Project__c();
        proj.TASKRAY__Status__c = false;
        proj.Contract_Archive_1_Days__c = false;
        proj.TASKRAY__trOpportunity__c = opp.Id;
        insert proj;
        //end test data setup

        Test.startTest();
			Schedule_Project_Completion_Batch sh1 = new Schedule_Project_Completion_Batch();
			String sch = '0 0 23 * * ?'; system.schedule('Test Schedule_Project_Completion_Batch', sch, sh1); 
        	Project_Completion_Batch batch = new Project_Completion_Batch();
			database.executeBatch(batch);
        Test.stopTest();		
        
        // asserts
        proj = [SELECT Contract_Archive_1_Days__c FROM TASKRAY__Project__c WHERE Id = :proj.Id];
        System.assertEquals(true, proj.Contract_Archive_1_Days__c);
    }
	
    public static testMethod void test_simple_2Weeks(){
        //test data setup
        Account acc = new Account();
        acc.Name = 'Test923736';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Contract_End__c = Date.today().addDays(14);
        opp.Name = 'Test218927';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addDays(30);
        insert opp;
        
        TASKRAY__Project__c proj = new TASKRAY__Project__c();
        proj.TASKRAY__Status__c = false;
        proj.Contract_Archive_14_Days__c = false;
        proj.TASKRAY__trOpportunity__c = opp.Id;
        insert proj;
        //end test data setup

        Test.startTest();
			Schedule_Project_Completion_Batch sh1 = new Schedule_Project_Completion_Batch();
			String sch = '0 0 23 * * ?'; system.schedule('Test Schedule_Project_Completion_Batch', sch, sh1); 
        	Project_Completion_Batch batch = new Project_Completion_Batch();
			database.executeBatch(batch);
        Test.stopTest();		
        
        // asserts
        proj = [SELECT Contract_Archive_14_Days__c FROM TASKRAY__Project__c WHERE Id = :proj.Id];
        System.assertEquals(true, proj.Contract_Archive_14_Days__c);
    }
    
    public static testMethod void test_parent_Yesterday(){
        //test data setup
        Account acc = new Account();
        acc.Name = 'Test923736';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Contract_End__c = Date.today().addDays(-1);
        opp.Name = 'Test218927';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addDays(30);
        insert opp;
        
        TASKRAY__Project__c parent = new TASKRAY__Project__c();
        parent.TASKRAY__trOpportunity__c = opp.Id;
        insert parent;
        
        TASKRAY__Project__c proj = new TASKRAY__Project__c();
        proj.TASKRAY__Status__c = false;
        proj.Contract_Archive_1_Days__c = false;
        proj.TASKRAY__Project_Parent__c = parent.Id;
        insert proj;
        //end test data setup

        Test.startTest();
			Schedule_Project_Completion_Batch sh1 = new Schedule_Project_Completion_Batch();
			String sch = '0 0 23 * * ?'; system.schedule('Test Schedule_Project_Completion_Batch', sch, sh1); 
        	Project_Completion_Batch batch = new Project_Completion_Batch();
			database.executeBatch(batch);
        Test.stopTest();		
        
        // asserts
        proj = [SELECT Contract_Archive_1_Days__c FROM TASKRAY__Project__c WHERE Id = :proj.Id];
        System.assertEquals(true, proj.Contract_Archive_1_Days__c);
    }
	
    public static testMethod void test_parent_2Weeks(){
        //test data setup
        Account acc = new Account();
        acc.Name = 'Test923736';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Contract_End__c = Date.today().addDays(14);
        opp.Name = 'Test218927';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addDays(30);
        insert opp;
        
        TASKRAY__Project__c parent = new TASKRAY__Project__c();
        parent.TASKRAY__trOpportunity__c = opp.Id;
        insert parent;
        
        TASKRAY__Project__c proj = new TASKRAY__Project__c();
        proj.TASKRAY__Status__c = false;
        proj.Contract_Archive_14_Days__c = false;
        proj.TASKRAY__Project_Parent__c = parent.Id;
        insert proj;
        //end test data setup

        Test.startTest();
			Schedule_Project_Completion_Batch sh1 = new Schedule_Project_Completion_Batch();
			String sch = '0 0 23 * * ?'; system.schedule('Test Schedule_Project_Completion_Batch', sch, sh1); 
        	Project_Completion_Batch batch = new Project_Completion_Batch();
			database.executeBatch(batch);
        Test.stopTest();		
        
        // asserts
        proj = [SELECT Contract_Archive_14_Days__c FROM TASKRAY__Project__c WHERE Id = :proj.Id];
        System.assertEquals(true, proj.Contract_Archive_14_Days__c);
    }
    
}