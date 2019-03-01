@isTest
public class InvoiceAllTest {

    @isTest
    public static void TestSetInForecast() {
        
        // Data setup
        Account acc = new Account();
        acc.Name = 'Test 375645';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test353423';
        opp.CloseDate = Date.today();
        opp.Product_Category__c = 'Data Hub';
        opp.Contract_Start__c = Date.today().addMonths(3);
        opp.Contract_End__c = Date.today().addMonths(9);
        opp.Amount = 100000;
        opp.StageName = 'Closed Lost';
        opp.AccountId = acc.Id;
        opp.DOC_Data_Configuration__c = 50;
        opp.DOC_Data_Licensing__c = 50;
        insert opp;
        
        Invoice__c inv1 = new Invoice__c();
        inv1.In_Forecast__c = true;
        inv1.Invoice_Num__c = 'NA';
        inv1.Opportunity__c = opp.Id;
        
        Invoice__c inv2 = new Invoice__c();
        inv2.In_Forecast__c = true;
        inv2.Invoice_Num__c = 'TBD';
        inv2.Opportunity__c = opp.Id;
        
        insert new List<Invoice__c>{ inv1, inv2 };
        
        // Run code
        Test.startTest();
        inv1.Invoice_Num__c = '9998';
        inv2.Invoice_Num__c = '9999';
        update new List<Invoice__c>{ inv1, inv2 };
        Test.stopTest();
        
        // Verify Results
        inv1 = [SELECT In_Forecast__c FROM Invoice__c WHERE Id = :inv1.Id];
        System.assertEquals(false, inv1.In_Forecast__c);
        inv2 = [SELECT In_Forecast__c FROM Invoice__c WHERE Id = :inv2.Id];
        System.assertEquals(false, inv2.In_Forecast__c);
    }
    
}