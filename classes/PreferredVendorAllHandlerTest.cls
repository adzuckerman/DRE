@isTest
public class PreferredVendorAllHandlerTest{
    
    private static testmethod void testPreferredVendorAll1(){
        //test data setup
        Account acc = new Account();
        acc.Name = 'Test923736';
        insert acc;
        
        Contact newContact = new Contact();
        newContact.LastName = 'LastName';
        newContact.Email = 'test@email.com';
        newContact.AccountId = acc.Id;
        insert newContact;
        
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
        
        Preferred_Vendor__c PreferredVendor = new Preferred_Vendor__c();
        PreferredVendor.Hourly_Rate__c = 20;
        PreferredVendor.Rate_Type__c = 'Hourly Rate';
        
        insert PreferredVendor;
        
        Preferred_Vendor_Staff__c pvs = new Preferred_Vendor_Staff__c();
        pvs.Email__c = 'Test@emailtestalert.com';
        pvs.Preferred_Vendor__c = PreferredVendor.Id;
        
        insert pvs;
        
        Preferred_Vendor_Request__c pvr = new Preferred_Vendor_Request__c();
        pvr.PICO_ID__c = proj.Id;
        pvr.Status__c = 'PO No. Requested';
        pvr.Preferred_Vendor__c = PreferredVendor.Id;
        pvr.Est_Hours_to_Complete__c = 20;
        pvr.DRE_Point_of_Contact__c = UserInfo.getUserId();
        insert pvr;
        
        //Submit Quote for Approval
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(pvr.id);
        Approval.ProcessResult result = Approval.process(app);
        
        //ProcessInstance ActiveProcessInstance = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId =: pvr.Id AND Status = 'Pending' LIMIT 1];
        //system.debug('====> ' + ActiveProcessInstance.Status);
                
        
        Test.startTest();
            Preferred_Vendor__c pv = [SELECT Id, Rate_Type__c FROM Preferred_Vendor__c WHERE Id =: PreferredVendor.Id];
            pv.DRE_Point_of_Contact__c = pvs.Id;
            pv.Rate_Type__c = 'Flat Rate';
            pv.Hourly_Rate__c = null;        	
            update pv;
            
            Preferred_Vendor_Request__c pvrUpdated = [SELECT Id, Status__c  FROM Preferred_Vendor_Request__c WHERE Preferred_Vendor__c =: pv.Id];
        	
        
            System.assertEquals('Rejected', pvrUpdated.Status__c);
        Test.stopTest();  
        
            
    }
    
    
    private static testmethod void testPreferredVendorAll2(){
        //test data setup
        Account acc = new Account();
        acc.Name = 'Test923736';
        insert acc;
        
        Contact newContact = new Contact();
        newContact.LastName = 'LastName';
        newContact.Email = 'test@email.com';
        newContact.AccountId = acc.Id;
        insert newContact;
        
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
        
        Preferred_Vendor__c PreferredVendor = new Preferred_Vendor__c();
        PreferredVendor.Hourly_Rate__c = 20;
        PreferredVendor.Rate_Type__c = 'Hourly Rate';
        insert PreferredVendor;
        
        Preferred_Vendor_Staff__c pvs = new Preferred_Vendor_Staff__c();
        pvs.Email__c = 'Test@emailtestalert.com';
        pvs.Preferred_Vendor__c = PreferredVendor.Id;
        
        insert pvs;
        
        Preferred_Vendor_Request__c pvr = new Preferred_Vendor_Request__c();
        pvr.PICO_ID__c = proj.Id;
        pvr.Status__c = 'In Approval Process';
        pvr.Preferred_Vendor__c = PreferredVendor.Id;
        pvr.Est_Hours_to_Complete__c = 20;
        pvr.DRE_Point_of_Contact__c = UserInfo.getUserId();
        insert pvr;
        
        Preferred_Vendor_Request__c pvr1 = new Preferred_Vendor_Request__c();
        pvr1.PICO_ID__c = proj.Id;
        pvr1.Status__c = 'PO No. Requested';
        pvr1.Preferred_Vendor__c = PreferredVendor.Id;
        pvr1.Est_Hours_to_Complete__c = 20;
        pvr1.DRE_Point_of_Contact__c = UserInfo.getUserId();
        insert pvr1;
        
        //Submit Quote for Approval
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(pvr.id);
        Approval.ProcessResult result = Approval.process(app);
        
        //ProcessInstance ActiveProcessInstance = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId =: pvr.Id AND Status = 'Pending' LIMIT 1];
        //system.debug('====> ' + ActiveProcessInstance.Status);
                
        
        Test.startTest();
            Preferred_Vendor__c pv = [SELECT Id, Rate_Type__c FROM Preferred_Vendor__c WHERE Id =: PreferredVendor.Id];
            pv.DRE_Point_of_Contact__c = pvs.Id;
            //pv.Rate_Type__c = 'Flat Rate';
            //pv.Hourly_Rate__c = null;
            
            update pv;
            
            List<Preferred_Vendor_Request__c>  pvrUpdated = [SELECT Id, Status__c  FROM Preferred_Vendor_Request__c WHERE Preferred_Vendor__c =: pv.Id];
            for(Preferred_Vendor_Request__c pvre: pvrUpdated )
                System.assertEquals('Rejected', pvre.Status__c);
        Test.stopTest();      
    }
    
}