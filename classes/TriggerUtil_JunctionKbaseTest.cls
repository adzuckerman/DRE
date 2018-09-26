@isTest
public class TriggerUtil_JunctionKbaseTest 
{
    @isTest
	public static void testJunctionKBase()
    {
        //insert TASKRAYProjects
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        TASKRAY__Project__c tProjectMain = new TASKRAY__Project__c();
        tProjectMain.TASKRAY__trAccount__c = acc.Id;        
        insert tProjectMain; 
        
        TASKRAY__Project__c tProjectsub = new TASKRAY__Project__c();
        tProjectsub.RecordTypeId = Schema.SObjectType.TASKRAY__Project__c.getRecordTypeInfosByName().get('Sub-Project').getRecordTypeId();
        tProjectsub.TASKRAY__trAccount__c = acc.Id;
        tProjectsub.TASKRAY__Project_Parent__c = tProjectMain.Id;
        insert tProjectsub; 
        
        //insert Tasks and associated list items
        TASKRAY__Project_Task__c tProjectTask = new TASKRAY__Project_Task__c();
        tProjectTask.Name = 'Extraction';
        tProjectTask.TASKRAY__Project__c = tProjectsub.Id;
        insert tProjectTask;
        
        TASKRAY__trChecklistItem__c tProjectChecklistItem = new TASKRAY__trChecklistItem__c();
        tProjectChecklistItem.TASKRAY__Project_Task__c = tProjectTask.Id;
        tProjectChecklistItem.Name = 'Kbase12345';
        insert tProjectChecklistItem; 
        
        TASKRAY__Project_Task__c tProjectTask1 = new TASKRAY__Project_Task__c();
        tProjectTask1.Name = 'DI-I';
        tProjectTask1.TASKRAY__Project__c = tProjectsub.Id;
        insert tProjectTask1;
        
        TASKRAY__trChecklistItem__c tProjectChecklistItem1 = new TASKRAY__trChecklistItem__c();
        tProjectChecklistItem1.TASKRAY__Project_Task__c = tProjectTask1.Id;
        tProjectChecklistItem1.Name = 'Kbase12345';
        insert tProjectChecklistItem1;
        
        TASKRAY__Project_Task__c tProjectTask2 = new TASKRAY__Project_Task__c();
        tProjectTask2.Name = 'DI-I Fixes';
        tProjectTask2.TASKRAY__Project__c = tProjectsub.Id;
        insert tProjectTask2;
        
        TASKRAY__trChecklistItem__c tProjectChecklistItem2 = new TASKRAY__trChecklistItem__c();
        tProjectChecklistItem2.TASKRAY__Project_Task__c = tProjectTask2.Id;
        tProjectChecklistItem2.Name = 'Kbase12345';
        insert tProjectChecklistItem2;
        
        
        TASKRAY__Project_Task__c tProjectTask3 = new TASKRAY__Project_Task__c();
        tProjectTask3.Name = 'DI-I Fix Check';
        tProjectTask3.TASKRAY__Project__c = tProjectsub.Id;
        insert tProjectTask3;
        
        TASKRAY__trChecklistItem__c tProjectChecklistItem3 = new TASKRAY__trChecklistItem__c();
        tProjectChecklistItem3.TASKRAY__Project_Task__c = tProjectTask3.Id;
        tProjectChecklistItem3.Name = 'Kbase12345';
        insert tProjectChecklistItem3;
        
        TASKRAY__Project_Task__c tProjectTask4 = new TASKRAY__Project_Task__c();
        tProjectTask4.Name = 'DI-II';
        tProjectTask4.TASKRAY__Project__c = tProjectsub.Id;
        insert tProjectTask4;
        
        TASKRAY__trChecklistItem__c tProjectChecklistItem4 = new TASKRAY__trChecklistItem__c();
        tProjectChecklistItem4.TASKRAY__Project_Task__c = tProjectTask4.Id;
        tProjectChecklistItem4.Name = 'Kbase12345';
        insert tProjectChecklistItem4;
        
        TASKRAY__Project_Task__c tProjectTask5 = new TASKRAY__Project_Task__c();
        tProjectTask5.Name = 'DI-II Fixes';
        tProjectTask5.TASKRAY__Project__c = tProjectsub.Id;
        insert tProjectTask5;
        
        TASKRAY__trChecklistItem__c tProjectChecklistItem5 = new TASKRAY__trChecklistItem__c();
        tProjectChecklistItem5.TASKRAY__Project_Task__c = tProjectTask5.Id;
        tProjectChecklistItem5.Name = 'Kbase12345';
        insert tProjectChecklistItem5;
        
        TASKRAY__Project_Task__c tProjectTask6 = new TASKRAY__Project_Task__c();
        tProjectTask6.Name = 'DI-II Fix Check';
        tProjectTask6.TASKRAY__Project__c = tProjectsub.Id;
        insert tProjectTask6;
        
        TASKRAY__trChecklistItem__c tProjectChecklistItem6 = new TASKRAY__trChecklistItem__c();
        tProjectChecklistItem6.TASKRAY__Project_Task__c = tProjectTask6.Id;
        tProjectChecklistItem6.Name = 'Kbase12345';
        insert tProjectChecklistItem6;
        
        //insertKbase
        Kbase__c kb = new Kbase__c();
        kb.Name = 'Kbase12345';
        kb.Extraction_Quantity__c = 1;
        kb.Extraction_Task_Description__c = 'Text';
        insert kb;        
        
        //insert case
        Case c = new Case();
        c.Case_Name__c = 'Case12345';
        insert c;
        
        List<Junction_Kbase__c> jKbaseList = new List<Junction_Kbase__c>();
        
        //insert Junction Kbase
        Junction_Kbase__c jKbase = new Junction_Kbase__c();
        jKbase.Name = 'LEAVE';
        jKbase.Case__c = c.Id;
        jKbase.LMS_Bucket__c = 'Assigned';
        jKbase.TaskRay_Project__c = tProjectsub.Id;
        jKbase.Kbases__c = kb.Id;
        jKbase.Extraction_Assigned_Date__c = date.today();
        jKbase.Extraction_Completion_Date__c = date.today() + 1;
        insert jKbase;
        
        jKbaseList.add(jKbase);
        
        test.startTest();
        
        TriggerUtil_JunctionKbase.updateTaskRay(jKbaseList);
        
        test.stopTest();
        
        TASKRAY__trChecklistItem__c trcliTest = [select Assigned_Date__c, Completion_date__c from TASKRAY__trChecklistItem__c  where id = :tProjectChecklistItem.Id];
        
        system.assertEquals(date.today(), trcliTest.Assigned_Date__c);
        system.assertEquals(date.today() + 1, trcliTest.Completion_date__c);                                                    
        
    }    
}