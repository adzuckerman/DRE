/*   Name:          Revenue Calculation Test Class
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          11/30/2017
 *   Description:   Test class for Department Revenue Calculation.
 *                
 */
 
@isTest
private class DepartmentRevenueScheduleTest {

    private static void init() {
        insert new Account(
            Name = 'test'
        );
    
        insert new ContractDrivers__c(
            Name = 'Data Hub',
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50,
            DOC_Library_Configuration__c = 0,
            DOC_Library_Licensing__c = 0,
            Services__c = 0,
            Subscription__c = 0
        );
    
        insert new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50
        );
        
        insert new Department__c(
            Name = 'test'
        );
    }
    
    static testmethod void testImportDepartmentCosts_Success() {
        init();
        
        Test.startTest();
        
        upsert new Department_Revenue_Schedule__c(
            Opportunity__c = [SELECT Id FROM Opportunity LIMIT 1].Id,
            Costs__c = 50000,
            Import_Date__c = Date.today(),
            Department__c = [SELECT Id FROM Department__c LIMIT 1].Id
        ); 
        
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM Monthly_Revenue_Schedule__c].size());
        System.assertEquals(1, [SELECT Id FROM Department_Revenue_Schedule__c].size());
    }
    
    static testmethod void testImportDepartmentCostsForMonth_Success() {
        init();
        
        insert new Monthly_Revenue_Schedule__c(
            Opportunity__c = [SELECT Id FROM Opportunity LIMIT 1].Id,
            Date__c = Date.today()
        );
        
        Test.startTest();
        
        upsert new Department_Revenue_Schedule__c(
            Opportunity__c = [SELECT Id FROM Opportunity LIMIT 1].Id,
            Costs__c = 50000,
            Import_Date__c = Date.today(),
            Department__c = [SELECT Id FROM Department__c LIMIT 1].Id
        ); 
        
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM Monthly_Revenue_Schedule__c].size());
        System.assertEquals(1, [SELECT Id FROM Department_Revenue_Schedule__c].size());
    }

}