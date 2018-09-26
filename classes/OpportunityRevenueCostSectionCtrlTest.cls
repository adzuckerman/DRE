@isTest
public class OpportunityRevenueCostSectionCtrlTest {

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
        
        insert new Department__c(
            Name = 'Test'
        );
        
        insert new Department_Revenue_Schedule__c(
            Department__c = [SELECT Id FROM Department__c LIMIT 1].Id,
            Monthly_Revenue_Schedule__c = [SELECT Id FROM Monthly_Revenue_Schedule__c LIMIT 1].Id,
            Costs__c = 1000
        );
        
        Test.setCurrentPage(Page.OpportunityRevenueCostSection);
        ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM Opportunity LIMIT 1].Id);
    }
    
    static testmethod void testConstructCtrl_Success() {
        init();
        
        Test.startTest();
        
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController([SELECT Id FROM Opportunity LIMIT 1]);
        OpportunityRevenueCostSectionCtrl customCtrl = new OpportunityRevenueCostSectionCtrl(standardCtrl);
        Map<Id, Boolean> testMap = customCtrl.lockedSchedules;
        
        Test.stopTest();
        
        System.assertEquals(6, testMap.size());
        System.assertEquals(6, customCtrl.revenues.size(), 'Six months should be covered.');
        System.assertEquals(1, customCtrl.revenuesMap.values().size(), 'Should be one department record splitted by months.');
    }
    
    static testmethod void testCalculateRevenueAmount_Success() {
        init();

        ApexPages.StandardController standardCtrl = new ApexPages.StandardController([SELECT Id FROM Opportunity LIMIT 1]);
        OpportunityRevenueCostSectionCtrl customCtrl = new OpportunityRevenueCostSectionCtrl(standardCtrl);
        
        Department_Revenue_Schedule__c depRevenue = [
            SELECT Department__r.Name, Date__c 
            FROM Department_Revenue_Schedule__c 
            WHERE Costs__c != null
            LIMIT 1
        ];
        
        ApexPages.currentPage().getParameters().put('departmentCostId', depRevenue.Department__r.Name + '-:-' + String.valueOf(depRevenue.Date__c));
        ApexPages.currentPage().getParameters().put('departmentCostValue', '100');
        
        Test.startTest();
        
        customCtrl.updateDepartmentCost();
        
        Test.stopTest();
        
        System.assertEquals(100, [SELECT Costs__c FROM Department_Revenue_Schedule__c WHERE Costs__c != null LIMIT 1].Costs__c);
    }

}