/*   Name:          ToggleAdminBatchProgress
 *   Date:          1/14/2019
 *   Description:   Test class for Toggle Admin Batch Progress.
 *                
 */

@isTest
public with sharing class ToggleAdminBatchProgressTest {
   
    @isTest
    public static void testToggleAdminBatch() {
        
        ToggleAdminBatchProgress TAB = new ToggleAdminBatchProgress();
        TAB.noOfDays = '365';
        TAB.c.StartDate = Date.Today().addDays(-365);
        TAB.c.EndDate = Date.Today();
        
        //Test.setCreatedDate(testCustomLog.Id, Datetime.now().addDays(-100));

        Test.startTest();
            Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
            TAB.StartBatch();
            BatchJobsProgress BJP = new BatchJobsProgress();
            BJP.apexClassName = 'TogglToSalesforceBatch';
            BJP.getBatchJobs();
            //Database.executeBatch(new TogglToSalesforceBatch(), 1);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Toggl_Time_Entry__c> timeEnrtries = [SELECT Id FROM Toggl_Time_Entry__c];
        List<Toggl_Custom_Log__c> customLogs = [SELECT Id FROM Toggl_Custom_Log__c];

        System.assertEquals(0, customLogs.size(), 'Logs are not empty');
    }
    
    @isTest
    public static void testToggleAdminBatch2() {
        
        ToggleAdminBatchProgress TAB = new ToggleAdminBatchProgress();
        
        //Test.setCreatedDate(testCustomLog.Id, Datetime.now().addDays(-100));

        Test.startTest();
            Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
            TAB.StartBatch();
            BatchJobsProgress BJP = new BatchJobsProgress();
            BJP.apexClassName = 'TogglToSalesforceBatch';
            BJP.getBatchJobs();
            //Database.executeBatch(new TogglToSalesforceBatch(), 1);
        Test.stopTest();
            BJP.getBatchJobs();

        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Toggl_Time_Entry__c> timeEnrtries = [SELECT Id FROM Toggl_Time_Entry__c];
        List<Toggl_Custom_Log__c> customLogs = [SELECT Id FROM Toggl_Custom_Log__c];

        System.assertEquals(0, customLogs.size(), 'Logs are not empty');
    }
    
    @isTest
    public static void testToggleAdminBatch3() {
        
        ToggleAdminBatchProgress TAB = new ToggleAdminBatchProgress();
        
        //Test.setCreatedDate(testCustomLog.Id, Datetime.now().addDays(-100));

        Test.startTest();
            Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
            TAB.StartBatch();
            TAB.StartBatch();
            //Database.executeBatch(new TogglToSalesforceBatch(), 1);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Toggl_Time_Entry__c> timeEnrtries = [SELECT Id FROM Toggl_Time_Entry__c];
        List<Toggl_Custom_Log__c> customLogs = [SELECT Id FROM Toggl_Custom_Log__c];

        System.assertEquals(0, customLogs.size(), 'Logs are not empty');
    }
    
    @isTest 
    static void test_method_one() 
    {
        // Data Setup
        TASKRAY__Project__c taskRayProject = new TASKRAY__Project__c();
        taskRayProject.Name = 'testDeutoria';
        insert taskRayProject;

        TASKRAY__Project__c taskRayProject2 = new TASKRAY__Project__c();
        taskRayProject2.TASKRAY__Project_Parent__c = taskRayProject.Id;
        insert taskRayProject2;

        Toggl_Time_Entry__c timeEntry = new Toggl_Time_Entry__c();
        timeEntry.Project__c = taskRayProject.Id;
        timeEntry.Start_Date__c = Datetime.now();
        timeEntry.End_Date__c = Datetime.now().addHours(1);
        insert timeEntry;

        Toggl_Time_Entry__c timeEntry2 = new Toggl_Time_Entry__c();
        timeEntry2.Project__c = taskRayProject.Id;
        timeEntry2.Start_Date__c = Datetime.now();
        timeEntry2.End_Date__c = Datetime.now().addHours(2);
        insert timeEntry2;

        Toggl_Time_Entry__c timeEntry3 = new Toggl_Time_Entry__c();
        timeEntry3.Project__c = taskRayProject2.Id;
        timeEntry3.Start_Date__c = Datetime.now();
        timeEntry3.End_Date__c = Datetime.now().addHours(1);
        insert timeEntry3;

        Toggl_Time_Entry__c timeEntry4 = new Toggl_Time_Entry__c();
        timeEntry4.Project__c = taskRayProject2.Id;
        timeEntry4.Start_Date__c = Datetime.now();
        timeEntry4.End_Date__c = Datetime.now().addHours(2);
        insert timeEntry4;

    // Run Code
        Test.startTest();

            ToggleAdminBatchProgress TAB = new ToggleAdminBatchProgress();
            TAB.StartBatch2();

        Test.stopTest();

        // Verify Results
        List<CronTrigger> cronList =
            [
                SELECT Id, State 
                FROM CronTrigger 
                ORDER BY CreatedDate 
                ASC LIMIT 10
            ];

        if(cronList.size() > 0 && cronList[0].State == 'COMPLETE')
        {
            List<TASKRAY__Project__c> taskRayProjectList =
                [
                    SELECT Id, Total_Actual_Project_Time__c
                    FROM TASKRAY__Project__c
                    WHERE Name = 'testDeutoria'
                ];

            System.assertEquals(taskRayProjectList.size(), 1);
            System.assertEquals(taskRayProjectList[0].Total_Actual_Project_Time__c, 6);
        }
    }

    @isTest 
    static void test_method_two() 
    {
        // Data Setup
        TASKRAY__Project__c taskRayProject = new TASKRAY__Project__c();
        taskRayProject.Name = 'testDeutoria';
        insert taskRayProject;

        TASKRAY__Project__c taskRayProject2 = new TASKRAY__Project__c();
        taskRayProject2.TASKRAY__Project_Parent__c = taskRayProject.Id;
        insert taskRayProject2;

        Toggl_Time_Entry__c timeEntry = new Toggl_Time_Entry__c();
        timeEntry.Project__c = taskRayProject.Id;
        timeEntry.Start_Date__c = Datetime.now();
        timeEntry.End_Date__c = Datetime.now().addHours(1);
        insert timeEntry;

        Toggl_Time_Entry__c timeEntry2 = new Toggl_Time_Entry__c();
        timeEntry2.Project__c = taskRayProject.Id;
        timeEntry2.Start_Date__c = Datetime.now();
        timeEntry2.End_Date__c = Datetime.now().addHours(2);
        insert timeEntry2;

        Toggl_Time_Entry__c timeEntry3 = new Toggl_Time_Entry__c();
        timeEntry3.Project__c = taskRayProject2.Id;
        timeEntry3.Start_Date__c = Datetime.now();
        timeEntry3.End_Date__c = Datetime.now().addHours(1);
        insert timeEntry3;

        Toggl_Time_Entry__c timeEntry4 = new Toggl_Time_Entry__c();
        timeEntry4.Project__c = taskRayProject2.Id;
        timeEntry4.Start_Date__c = Datetime.now();
        timeEntry4.End_Date__c = Datetime.now().addHours(2);
        insert timeEntry4;

    // Run Code
        Test.startTest();

            ToggleAdminBatchProgress TAB = new ToggleAdminBatchProgress();
            TAB.StartBatch2();
            TAB.StartBatch2();
        Test.stopTest();

        // Verify Results
        List<CronTrigger> cronList =
            [
                SELECT Id, State 
                FROM CronTrigger 
                ORDER BY CreatedDate 
                ASC LIMIT 10
            ];

        if(cronList.size() > 0 && cronList[0].State == 'COMPLETE')
        {
            List<TASKRAY__Project__c> taskRayProjectList =
                [
                    SELECT Id, Total_Actual_Project_Time__c
                    FROM TASKRAY__Project__c
                    WHERE Name = 'testDeutoria'
                ];

            System.assertEquals(taskRayProjectList.size(), 1);
            System.assertEquals(taskRayProjectList[0].Total_Actual_Project_Time__c, 6);
        }
    }

}