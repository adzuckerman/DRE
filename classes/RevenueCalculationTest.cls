/*   Name:          Revenue Calculation Test Class
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          8/17/2017
 *   Description:   Test class for Revenue Calculation.
 *                
 */

@isTest
private class RevenueCalculationTest {

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
    }
    
    static testmethod void testCalculateOpportunity_Success() {
        init();
    
        Test.startTest();
        
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
            DOC_Data_Licensing__c = 50,
            Use_New_Forecasting_Algorithm__c = false
        );
        insert testOpp;
        
        /*LEGACY*/
        //insert new Revenue_Schedule__c(Opportunity__c = [SELECT Id FROM Opportunity LIMIT 1].Id);
        
        Test.stopTest();
        
        System.assert(![SELECT Id FROM Product_Revenue_Schedule__c WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :testOpp.Id].isEmpty(), 'Here must be generated revenue records.');
    }
    
    static testmethod void testCalculateOpportunity_Validated() {
        init();
    
        Test.startTest();
        
        Opportunity testOppStart = new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = null,
            Contract_End__c = Date.today().addMonths(9),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50
        );
        insert testOppStart;
        
        Opportunity testOppOffer = new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = null,
            Contract_Start__c = Date.today().addMonths(3),
            Contract_End__c = Date.today().addMonths(9),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50
        );
        insert testOppOffer;
        
        Test.stopTest();
        
        System.assert([SELECT Id FROM Product_Revenue_Schedule__c WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :testOppStart.Id].isEmpty(), 'Here must not be any generated revenue records.');
        System.assert([SELECT Id FROM Product_Revenue_Schedule__c WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :testOppOffer.Id].isEmpty(), 'Here must not be any generated revenue records.');
    }
    
    static testmethod void testCalculateRevenuePOC_Success() {
        init();
        
        insert new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = Date.today().addMonths(-2),
            Contract_End__c = Date.today().addMonths(4),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50,
            Use_New_Forecasting_Algorithm__c = false
        );
        
        List<Product_Revenue_Schedule__c> revenues = [
            SELECT POC__c, Revenue__c, Monthly_Revenue_Schedule__r.Costs__c
            FROM Product_Revenue_Schedule__c
            ORDER BY Date__c ASC
        ];
        System.assertEquals(6, revenues.size());
        
        Test.startTest();
        
        Product_Revenue_Schedule__c revToUpdate = revenues[0];
        revToUpdate.POC__c = 100;
        update revToUpdate;
        
        Test.stopTest();

        System.assertEquals(50000, [SELECT Amount FROM Opportunity LIMIT 1].Amount);
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem].size());
        System.assertEquals(50000, [SELECT TotalPrice FROM OpportunityLineItem LIMIT 1].TotalPrice);
        System.assertEquals(50000, [SELECT Revenue__c FROM Product_Revenue_Schedule__c WHERE Id = :revToUpdate.Id].Revenue__c);
    }
    
    static testmethod void testCalculateRevenueAmount_Success() {
        init();
        
        insert new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = Date.today().addMonths(-2),
            Contract_End__c = Date.today().addMonths(4),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50,
            Use_New_Forecasting_Algorithm__c = false
        );
        
        List<Product_Revenue_Schedule__c> revenues = [
            SELECT POC__c, Revenue__c, Monthly_Revenue_Schedule__r.Costs__c 
            FROM Product_Revenue_Schedule__c
            ORDER BY Date__c ASC
        ];
        System.assertEquals(6, revenues.size());
        
        Test.startTest();
        
        Product_Revenue_Schedule__c revToUpdate = revenues[0];
        revToUpdate.Revenue__c = 50000;
        update revToUpdate;
        
        List<Invoice__c> generatedInvoices = [SELECT Invoice_Amount__c FROM Invoice__c];
        System.assert(!generatedInvoices.isEmpty(), 'Invoices should be automatically generated.');
        
        generatedInvoices.get(0).Invoice_Amount__c = 10000;
        update generatedInvoices;
        
        Test.stopTest();
        
        System.assertEquals(100, [SELECT POC__c FROM Product_Revenue_Schedule__c WHERE Id = :revToUpdate.Id].POC__c);
    }
    
    static testmethod void testCalculateOpportunityLineItems_Success() {
        init();
        
        insert new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = Date.today().addMonths(-2),
            Contract_End__c = Date.today().addMonths(4),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50,
            Use_New_Forecasting_Algorithm__c = false
        );
        
        Test.startTest();
        
        delete new OpportunityLineItem(
            Id = [SELECT Id FROM OpportunityLineItem LIMIT 1].Id
        );
        
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Amount FROM Opportunity LIMIT 1].Amount);
    }

    static testmethod void testInvoiceInitialCalculation_Success() {
        init();
        
        insert new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = Date.today().addMonths(-2),
            Contract_End__c = Date.today().addMonths(4),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50
        );
        
        Test.startTest();
    
        Invoice__c invoiceToInsert = new Invoice__c(
            Opportunity__c = [SELECT Id FROM Opportunity LIMIT 1].Id,
            Invoice_Amount__c = 10000
        );
        insert invoiceToInsert;
        System.assertEquals(null, [SELECT Deferred_Revenue__c FROM Invoice__c WHERE Id = :invoiceToInsert.Id].Deferred_Revenue__c);
        
        update invoiceToInsert;
        System.assertEquals(10000, [SELECT Deferred_Revenue__c FROM Invoice__c WHERE Id = :invoiceToInsert.Id].Deferred_Revenue__c);
        
        Test.stopTest();
    }
    
    static testmethod void testCalculateOpportunityLineItemsEmptySetting_Success() {
        init();
        
        Test.startTest();
        
        insert new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = Date.today().addMonths(-2),
            Contract_End__c = Date.today().addMonths(4),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            DOC_Data_Configuration__c = null,
            DOC_Data_Licensing__c = null,
            Services_Percentage__c = 100,
            Override_Allocations__c = true,
            Use_New_Forecasting_Algorithm__c = false
        );
        
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Amount FROM Opportunity LIMIT 1].Amount);
    }

}