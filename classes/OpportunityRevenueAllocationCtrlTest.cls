@isTest
public class OpportunityRevenueAllocationCtrlTest {

    private static void init() {
        insert new ContractDrivers__c(
            Name = 'Data Hub',
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50,
            DOC_Library_Configuration__c = 0,
            DOC_Library_Licensing__c = 0,
            Services__c = 0,
            Subscription__c = 0
        );
        
        insert new Product2(
            Name = 'DOC Data Configuration'
        );
        
        insert new Account(
            Name = 'test'
        );
        
        insert new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = Date.today().addMonths(-2),
            Contract_End__c = Date.today().addMonths(4),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50
        );
        
        Test.setCurrentPage(Page.OpportunityRevenueAllocation);
        ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM Opportunity LIMIT 1].Id);
    }
    
    static testmethod void testConstructCtrl_Success() {
        init();
        
        Test.startTest();
        
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController([SELECT Id FROM Opportunity LIMIT 1]);
        OpportunityRevenueAllocationCtrl customCtrl = new OpportunityRevenueAllocationCtrl(standardCtrl);
        
        Test.stopTest();
        
        System.assertEquals(1, customCtrl.schedulesList.size(), 'Should be one row for one product.');
        System.assertEquals(6, customCtrl.schedulesList.get(0).size(), 'Should be six schedules for one product.');
    }
    
    static testmethod void testCalculateRevenueAmount_Success() {
        init();

        ApexPages.StandardController standardCtrl = new ApexPages.StandardController([SELECT Id FROM Opportunity LIMIT 1]);
        OpportunityRevenueAllocationCtrl customCtrl = new OpportunityRevenueAllocationCtrl(standardCtrl);
        
        List<Product_Revenue_Schedule__c> revenues = [
            SELECT POC__c, Revenue__c
            FROM Product_Revenue_Schedule__c
            ORDER BY Date__c ASC
        ];
        System.assertEquals(6, revenues.size());
        
        ApexPages.currentPage().getParameters().put('scheduleId', revenues.get(0).Id);
        ApexPages.currentPage().getParameters().put('schedulePoc', '100');
        ApexPages.currentPage().getParameters().put('scheduleRevenue', String.valueOf(revenues.get(0).Revenue__c));
        
        Test.startTest();
        
        customCtrl.updateSchedule();
        
        Test.stopTest();
        
        System.assertEquals(50000, [SELECT Revenue__c FROM Product_Revenue_Schedule__c WHERE Id = :revenues.get(0).Id].Revenue__c);
    }

}