/*   Name:          InvoiceListCtrlTest
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          8/31/2017
 *   Description:   Unit test for InvoiceListCtrl
 */

@isTest
private class InvoiceListCtrlTest {

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

        insert new Product2(
            Name = 'DOC Data Licensing'
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

        insert new PricebookEntry(
            Product2Id = [SELECT Id FROM Product2][1].Id,
            Pricebook2Id = Test.getStandardPriceBookId(),
            UnitPrice = 100000,
            IsActive = false,
            UseStandardPrice = false
        );

        insert new PricebookEntry(
            Product2Id = [SELECT Id FROM Product2][1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            UnitPrice = 100000,
            IsActive = true,
            UseStandardPrice = false
        );

        insert new Account(
            Name = 'test'
        );

        insert new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Contract_Start__c = Date.today().addMonths(-12),
            Contract_End__c = Date.today().addMonths(4),
            Amount = 100000,
            StageName = 'Closed Lost',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            Use_New_Forecasting_Algorithm__c = false
        );
    }

    private static testMethod void testInvoiceListController(){
        init();

        Test.startTest();

        ApexPages.StandardController standardCtrl = new ApexPages.StandardController([SELECT Id FROM Opportunity LIMIT 1]);
        InvoiceListCtrl customCtrl = new InvoiceListCtrl(standardCtrl);

        Test.stopTest();

        System.assertEquals(16, customCtrl.invoices.size(), 'Should be 16 invoices.');
        System.assertEquals(6250, customCtrl.invoices[0].monthRevenue, 'Monthly revenue should be 6250.');
    }
	
}