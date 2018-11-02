/********************************************************************************************************
*    Name:  TaskRaySubprojectBatchTest.cls
*    Author:  
*    Date:  6/12/2018
*    
*    Scheduler class: TaskRaySubprojectScheduler.cls
*    Class: TaskRaySubprojectBatch.cls
********************************************************************************************************/
@isTest
public class TaskRaySubprojectBatchTest{
    
    private static testmethod void testTaskRaySubprojectBatch(){
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact cnt = new Contact(LastName = 'TestCon', AccountId = acc.Id);
        insert cnt;
        
        Case c  = new Case();
        //enter details
        c.AccountId = acc.Id;
        c.ContactId = cnt.Id;
        //c.RecordTypeId = rtId;
        c.Type = 'My Type';
        c.Origin = 'My Origin';
        c.Status = 'My Status';
        insert c;
        
        //insert Parent TASKRAY__Project__c
        TASKRAY__Project__c tpp = new TASKRAY__Project__c(Name = 'Parent Project', TASKRAY__trAccount__c = acc.Id);
        insert tpp;
        
        TASKRAY__Project__c tpc1 = new TASKRAY__Project__c(Name = 'Child Project 1', TASKRAY__Project_Parent__c = tpp.Id);
        insert tpc1;
        TASKRAY__Project__c tpc2 = new TASKRAY__Project__c(Name = 'Child Project 2', TASKRAY__Project_Parent__c = tpp.Id);
        insert tpc2;
        TASKRAY__Project__c tpc3 = new TASKRAY__Project__c(Name = 'Child Project 3', TASKRAY__Project_Parent__c = tpp.Id);
        insert tpc3;
        
        
        
        //insert Kbase
        Kbase__c kb = new Kbase__c(Name='Kbase12345', Extraction_Quantity__c=1, Extraction_Task_Description__c='Text');
        insert kb;
        
        //insert Junction Kbase
        List<Junction_Kbase__c> jkbList = new List<Junction_Kbase__c>();
        Junction_Kbase__c jkb1 = new Junction_Kbase__c(Name='jkb12345', Kbases__c = kb.Id, Case__c = c.Id, TaskRay_Project__c = tpc1.Id, LMS_Bucket__c = 'Assigned');
        jkbList.add(jkb1);
        Junction_Kbase__c jkb2 = new Junction_Kbase__c(Name='jkb12346', Kbases__c = kb.Id, Case__c = c.Id, TaskRay_Project__c = tpc2.Id, LMS_Bucket__c = 'On Hold');
        jkbList.add(jkb2);
        Junction_Kbase__c jkb3 = new Junction_Kbase__c(Name='jkb12347', Kbases__c = kb.Id, Case__c = c.Id, TaskRay_Project__c = tpc2.Id, LMS_Bucket__c = 'Assigned');
        jkbList.add(jkb3);
        Junction_Kbase__c jkb4 = new Junction_Kbase__c(Name='jkb12348', Kbases__c = kb.Id, Case__c = c.Id, TaskRay_Project__c = tpc3.Id, LMS_Bucket__c = 'On Hold');
        jkbList.add(jkb4);
        Junction_Kbase__c jkb5 = new Junction_Kbase__c(Name='jkb12349', Kbases__c = kb.Id, Case__c = c.Id, TaskRay_Project__c = tpc3.Id, LMS_Bucket__c = 'Assigned');
        jkbList.add(jkb5);
        Junction_Kbase__c jkb6 = new Junction_Kbase__c(Name='jkb12350', Kbases__c = kb.Id, Case__c = c.Id, TaskRay_Project__c = tpc3.Id, LMS_Bucket__c = 'Rejected');
        jkbList.add(jkb6);

        insert jkbList;
        
        Test.StartTest();
            TaskRaySubprojectBatch obj = new TaskRaySubprojectBatch();
            DataBase.executeBatch(obj); 
            
            List<TASKRAY__Project__c> TASKRAYProjects = [SELECT Id, Digitized__c FROM TASKRAY__Project__c WHERE TASKRAY__Project_Parent__c =: tpp.Id];
            for(TASKRAY__Project__c ctp: TASKRAYProjects )
            {
                if(ctp.Id == tpc1.TASKRAY__Project_Parent__c )
                    System.assertEquals(1, ctp.Digitized__c);
                if(ctp.Id == tpc2.TASKRAY__Project_Parent__c )
                    System.assertEquals(2, ctp.Digitized__c);
                if(ctp.Id == tpc3.TASKRAY__Project_Parent__c  )
                    System.assertEquals(2, ctp.Digitized__c);
            }
            
            
        Test.StopTest();
    }
}