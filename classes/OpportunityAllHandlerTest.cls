@isTest
public class OpportunityAllHandlerTest{
    

    private static testmethod void testOpportunityAllHandler0()
    {
        // Data Setup
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        // Run Code
        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());

            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.AccountId = acc.Id;
            opp.StageName = 'Capabilities Presentation';       
            opp.CloseDate = (Date.today()).addDays(6);
            opp.In_Forecast__c = true;
            opp.Toggl_Pre_Sale_Project_Approved__c = true;
            insert opp;

        Test.stopTest();

        // Verify Results
        // no verification needed since no modification happends in the Salesforce org
    }

    private static testmethod void testOpportunityAllHandler5()
    {
        // Data Setup
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';       
        opp.CloseDate = (Date.today()).addDays(6);
        opp.In_Forecast__c = true;
        opp.Toggl_Pre_Sale_Project_Approved__c = true;
        insert opp;

        TASKRAY__Project__c project = new TASKRAY__Project__c();
        project.TASKRAY__trOpportunity__c = opp.Id;
        project.Toggl_Id__c = 'test';
        project.Toggl_Auto_Creation_Approved__c = false;
        insert project;

        // Run Code
        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());

            opp.Bob_Scott_Approved_Final_Contract_SOW__c = true;
            opp.Contract_Uploaded__c = true;
            opp.Proposal_Uploaded__c = true;
            opp.StageName = 'Closed Won'; 
            opp.CloseDate = (Date.today()).addDays(-1);
            update opp;

        Test.stopTest();

        // Verify Results
        // no verification needed since no modification happends in the Salesforce org
    }

    private static testmethod void testOpportunityAllHandler1(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
       
        opp.CloseDate = (Date.today()).addDays(6);
        insert opp;
        
        
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'sa4-test-WXYZ';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        tte.Opportunity__c = opp.Id;
        insert tte;
        
        Opportunity opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        opp1.StageName = 'Closed Lost';
        
        
        Test.StartTest();
            update opp1;
        Test.StopTest();
        
        Toggl_Time_Entry__c timeEntry = [SELECT Id, GAAP_Class__c  FROM Toggl_Time_Entry__c WHERE Id = :tte.Id];
        System.assertEquals('Sales & Marketing', timeEntry.GAAP_Class__c);
        
    }
    
    private static testmethod void testOpportunityAllHandler2(){
        
        Account acc = new Account();
        acc.Name = 'Doctor Evidence';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
       
        opp.CloseDate = (Date.today()).addDays(6);
        insert opp;
        
        
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'CE Admin/Internal';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        tte.Opportunity__c = opp.Id;
        insert tte;
        
        Opportunity opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        opp1.StageName = 'Closed Lost';
        
        
        Test.StartTest();
            update opp1;
        Test.StopTest();
        
        Toggl_Time_Entry__c timeEntry = [SELECT Id, GAAP_Class__c  FROM Toggl_Time_Entry__c WHERE Id = :tte.Id];
        System.assertEquals('Sales & Marketing', timeEntry.GAAP_Class__c);
        
    }
    
    private static testmethod void testOpportunityAllHandler3(){
        
        Account acc = new Account();
        acc.Name = 'DRE Tech';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
       
        opp.CloseDate = (Date.today()).addDays(6);
        insert opp;
        
        
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'DRE Tech_Admin/Internal';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        tte.Opportunity__c = opp.Id;
        insert tte;
        
        Opportunity opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        opp1.StageName = 'Closed Lost';
        
        
        Test.StartTest();
            update opp1;
        Test.StopTest();
        
        Toggl_Time_Entry__c timeEntry = [SELECT Id, GAAP_Class__c  FROM Toggl_Time_Entry__c WHERE Id = :tte.Id];
        System.assertEquals('Research & Development', timeEntry.GAAP_Class__c);
        
    }
    
    private static testmethod void testOpportunityAllHandler4(){
        
        Account acc = new Account();
        acc.Name = 'DRE Tech';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
       
        opp.CloseDate = (Date.today()).addDays(6);
        insert opp;
        
        
        
        TASKRAY__Project__c tProject = new TASKRAY__Project__c();
        tProject.TASKRAY__trAccount__c = acc.Id;
        tProject.Name = 'toggle project name';
        insert tProject;
        
        Toggl_Time_Entry__c tte = new Toggl_Time_Entry__c();
        tte.Account__c = acc.Id;
        tte.Project_Name__c = 'sa4-test-project | toggle project name';
        tte.Start_Date__c = (Date.Today()).addDays(-60);
        tte.Project__c = tProject.Id;
        tte.Toggl_Id__c = '912345678';
        tte.Opportunity__c = opp.Id;
        insert tte;
        
        Opportunity opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id];
        opp1.StageName = 'Closed Lost';
        
        
        Test.StartTest();
            update opp1;
        Test.StopTest();
        
        Toggl_Time_Entry__c timeEntry = [SELECT Id, GAAP_Class__c  FROM Toggl_Time_Entry__c WHERE Id = :tte.Id];
        System.assertEquals('2.0 Cap', timeEntry.GAAP_Class__c);
        
    }

    private static testmethod void testUpdateInvoicesOnClosedWon() {
        
        // Data setup
        Account acc = new Account();
        acc.Name = 'Test Account 212444';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp 422334';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
        opp.CloseDate = (Date.today()).addDays(6);
        opp.Contract_Uploaded__c = true;
        opp.Bob_Scott_Approved_Final_Contract_SOW__c = true;
        opp.In_Forecast__c = true;
        opp.Proposal_Uploaded__c = true;
        opp.Amount = 10000;
        insert opp;
        
        Invoice__c inv = new Invoice__c();
        inv.In_Forecast__c = true;
        inv.Invoice_Num__c = 'NA';
        inv.Opportunity__c = opp.Id;
        inv.Invoice_Amount__c = 1000;
        insert inv;
        
        // Run code
        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
        
        // Verify results
        inv = [SELECT Invoice_Num__c FROM Invoice__c WHERE Id = :inv.Id];
        System.assertEquals('TBD', inv.Invoice_Num__c, 'Invoice number should now be "TBD" beause of the OpportunityAllHandler-UpdateInvoicesOnClosedWon method');
    }
    
    @isTest
    public static void testProductNameMappingInsert()
    {
        
        Account acc = new Account();
        acc.Name = 'DRE Tech';
        insert acc;
        
        Product2 prod = new Product2(Name = 'Focused Literature Reviews');
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = test.getStandardPricebookId(),
                                                          Product2Id = prod.Id,
                                                          UnitPrice = 10000,
                                                          IsActive = true);
        insert standardPrice;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
        opp.Product_Category__c = 'Project';
        opp.CloseDate = (Date.today()).addDays(6);
        
        
        test.startTest();
        
        insert opp;  
        
        test.stopTest();
        
        Opportunity oppTest = [Select Id, Pricebook2Id from Opportunity where Id = :opp.Id];
        OpportunityLineItem oli = [Select Id, UnitPrice, Name from OpportunityLineItem where OpportunityId = :opp.Id];
        
        System.assertEquals(oppTest.Pricebook2Id, test.getStandardPricebookId());
        System.assertEquals(oli.UnitPrice, 10000);   
    }
    
    @isTest
    public static void testProductNameMappingUpdate()
    {
        Account acc = new Account();
        acc.Name = 'DRE Tech';
        insert acc;
        
        Product2 prod1 = new Product2(Name = 'Focused Literature Reviews');
        Product2 prod2 = new Product2(Name = 'GROWTH Basic Annual License');
        
        insert new List<Product2> { prod1, prod2 };
        
        /*insert new Pricebook2(
            Name = RevenueCalculationUtil.PRICEBOOK_NAME, 
            IsActive = true
        );*/
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPriceBookId(),
                                                          Product2Id = prod1.Id,
                                                          UnitPrice = 10000,
                                                          IsActive = true);
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = Test.getStandardPriceBookId(),
                                                          Product2Id = prod2.Id,
                                                          UnitPrice = 15000,
                                                          IsActive = true);
        
        insert new List<PricebookEntry> { standardPrice, standardPrice2 };
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
        opp.Product_Category__c = 'Project';
        opp.CloseDate = (Date.today()).addDays(6);
        
        insert opp;
        
        test.startTest();
        
        opp.Product_Category__c = 'GROWTH';
        RevenueCalculationUtil.isTriggerEnabled = false;
        update opp;

        test.stopTest();
        
        Opportunity oppTest = [Select Id, Pricebook2Id from Opportunity where Id = :opp.Id];
        system.debug('oli Query---'+ [Select Id, UnitPrice, Name from OpportunityLineItem where OpportunityId = :opp.Id]);
        OpportunityLineItem oli = [Select Id, UnitPrice, Name from OpportunityLineItem where OpportunityId = :opp.Id];
        
        System.assertEquals(oppTest.Pricebook2Id, test.getStandardPricebookId());
        System.assertEquals(oli.UnitPrice, 15000);
        
    }
}