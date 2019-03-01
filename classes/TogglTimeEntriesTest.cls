@isTest
private class TogglTimeEntriesTest 
{	
	@isTest static void test_method_one() 
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

            TogglTimeEntriesSchedulable schedule = new TogglTimeEntriesSchedulable();
            schedule.execute(null);

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