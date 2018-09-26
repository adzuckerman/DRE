/*   Name:          ContractInformationCtrlTest
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          8/31/2017
 *   Description:   Unit test for ContractInformationCtrl
 */

@isTest
public class ContractInformationCtrlTest {

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
            DOC_Data_Configuration__c = 50,
            DOC_Data_Licensing__c = 50
        );
    }

    private static testMethod void testContractInformationController(){
        init();

        Test.startTest();

        List<Invoice__c> generatedInvoices = [SELECT Monthly_Revenue__c, Invoice_Date__c FROM Invoice__c];

        Test.stopTest();

        Integer currentYear = Date.today().year();
        Decimal revenuePriorCurrentYear = 0;
        Decimal revenueCurrentYear = 0;

        for (Invoice__c invoice : generatedInvoices) {
            if (invoice.Invoice_Date__c.year() < currentYear) {
                revenuePriorCurrentYear += invoice.Monthly_Revenue__c;
            } 
            else if (invoice.Invoice_Date__c.year() == currentYear) {
                revenueCurrentYear += invoice.Monthly_Revenue__c;
            }
        }

        ContractInformationCtrl controller = new ContractInformationCtrl();

        System.assertEquals(1, controller.opportunityList.size());
        System.assertEquals([SELECT Name FROM Account LIMIT 1].Name, controller.opportunityList[0].accountName);
        System.assertEquals(1, controller.invoicePriorList.size());
        System.assertEquals(revenuePriorCurrentYear, controller.invoicePriorList[0].revenuePriorCurrentYear);
        System.assertEquals(revenueCurrentYear, controller.invoicePriorList[0].revenueCurrentYear);
        System.assertEquals(3, controller.invoiceMonthList.size());
        System.assertEquals(currentYear, controller.currentYear);

        controller.endMonth = controller.startMonth.addMonths(-1);
        controller.getInvoicesByMonths();
        System.assertEquals(4, controller.invoiceMonthList.size());

        controller.startMonth = null;
        controller.endMonth = null;
        controller.getInvoicesByMonths();
        System.assertEquals(3, controller.invoiceMonthList.size());
    }

    private static testMethod void testContractInformationFiltering(){
        init();

        Test.startTest();

        Opportunity opp = [SELECT Contract_End__c FROM Opportunity LIMIT 1];
        opp.Contract_End__c = Date.today().addMonths(-1);
        update opp;
        Invoice__c generatedInvoice = [SELECT Enforce_Date__c FROM Invoice__c LIMIT 1];
        generatedInvoice.Enforce_Date__c = true;
        update generatedInvoice;

        Test.stopTest();

        ContractInformationCtrl controller = new ContractInformationCtrl();
        System.assertEquals(1, controller.opportunityList.size());
    }
}