/********************************************************************************************************
*    Name:  ProcessInstanceStepBatchTest.cls
*    Author:  
*    Date:  6/8/2017
*    
*    Batch class: ProcessInstanceStepBatch.cls
*    Scheduled class: ProcessInstanceStepScheduler.cls
********************************************************************************************************/

@isTest
public class ProcessInstanceStepBatchTest {

    public static testMethod void testProcessInstanceStepBatch(){
        
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
        
        Preferred_Vendor__c pv = new Preferred_Vendor__c();
        pv.Name = 'Preferred Vendor Name';
        pv.Rate_Type__c = 'Hourly Rate';
        pv.Hourly_Rate__c = 100;
        insert pv;
        
        Preferred_Vendor_Request__c pvr = new Preferred_Vendor_Request__c();
        pvr.PICO_ID__c = proj.Id;
        pvr.Preferred_Vendor__c = pv.Id;
        pvr.Est_Hours_to_Complete__c = 5;
        insert pvr;
        
        Test.startTest();
            ProcessInstanceStepBatch p = new ProcessInstanceStepBatch();
            database.executebatch(p);
            
            
        Test.stopTest();
    }
}