@isTest
public class OpportunityGrossProfitSectionCtrlTest {

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
        
        Test.setCurrentPage(Page.OpportunityGrossProfitSection);
        ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM Opportunity LIMIT 1].Id);
    }
    
    static testmethod void testConstructCtrl_Success() {
        init();
        
        Test.startTest();
        
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController([SELECT Id FROM Opportunity LIMIT 1]);
        OpportunityGrossProfitSectionCtrl customCtrl = new OpportunityGrossProfitSectionCtrl(standardCtrl);
        
        Test.stopTest();
        
        System.assertEquals(6, customCtrl.revenues.size(), 'Six months should be covered.');
    }

}