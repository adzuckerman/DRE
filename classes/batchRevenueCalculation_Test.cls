/*   Name:          Batch Revenue Calculatiion Test Class
 *   Developer:     Adam Zuckerman - CLOUD MINE CONSULTING
 *   Date:          8/17/2017
 *   Description:   Test class for batchRevenueCalculation.
 *                
 */

@isTest
private class batchRevenueCalculation_Test {

    @testSetup
    static void setup(){
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
        
        insert new Pricebook2(
            Name = RevenueCalculationUtil.PRICEBOOK_NAME, 
            IsActive = true
        );
        
        insert new PricebookEntry(
            Product2Id = [SELECT Id FROM Product2 LIMIT 1].Id,
            Pricebook2Id = Test.getStandardPriceBookId(),
            UnitPrice = 100000,
            IsActive = false,
            UseStandardPrice = false
        );
        
        insert new PricebookEntry(
            Product2Id = [SELECT Id FROM Product2 LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            UnitPrice = 100000,
            IsActive = true,
            UseStandardPrice = false
        );
        
        insert new Account(
            Name = 'test'
        );
        
        Opportunity testOpp = new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = Date.today().addMonths(3),
            Contract_End__c = Date.today().addMonths(9),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50
        );
        insert testOpp;
    }
        
	static testmethod void test(){
        Test.startTest();
        batchRevenueCalculation BRC = new batchRevenueCalculation();
		database.executeBatch(BRC, 1);
        Test.stopTest(); 
    }
}