/*   Name:          Revenue ForecastingTest Class
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          2/23/2018
 *   Description:   Test class for Revenue Forecasting.
 *                
 */
 
@isTest
private class RevenueForecastingTest {

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
        
        insert new Forecasting_Revenue_Recognition__c(
            Name = 'Data Hub',
            Contract_Length__c = 5
        );
        
        insert new Forecasting_Offering_Allocation__c(
            Name = 'Data Hub', 
            Subscription__c = 40,
            Services__c = 60
        );
        
        insert new Forecasting_Invoicing_Schedule__c(
            Name = 'Data Hub',
            Booking_Month_0__c = 0,
            Booking_Month_1__c = 25,
            Booking_Month_2__c = 25,
            Booking_Month_3__c = 0,
            Booking_Month_4__c = 25,
            Booking_Month_5__c = 0,
            Booking_Month_6__c = 25
        );
        
        insert new Product2(
            Name = 'Subscription'
        );
        
        insert new Product2(
            Name = 'Services'
        );
        
        insert new Pricebook2(
            Name = RevenueCalculationUtil.PRICEBOOK_NAME, 
            IsActive = true
        );
        
        insert new PricebookEntry(
            Product2Id = [SELECT Id FROM Product2][0].Id,
            Pricebook2Id = Test.getStandardPriceBookId(),
            UnitPrice = 100000,
            IsActive = false,
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
            Product2Id = [SELECT Id FROM Product2][0].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            UnitPrice = 100000,
            IsActive = true,
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
    }
    
    static testmethod void testCalculateOpportunity_Success() {
        init();
    
        Test.startTest();
        
        Opportunity testOpp = new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Amount = 100000,
            StageName = 'New',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            In_Forecast__c = true
        );
        insert testOpp;
        
        Test.stopTest();
        
        System.assert(![
            SELECT Id 
            FROM Product_Revenue_Schedule__c 
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :testOpp.Id
                AND In_Forecast__c = true].isEmpty(), 
            'Here must be generated revenue records.'
        );
        System.assertEquals(12, [
            SELECT Id 
            FROM Product_Revenue_Schedule__c 
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :testOpp.Id].size()
        );
        System.assertEquals(100000/5*0.4, [
            SELECT Revenue__c 
            FROM Product_Revenue_Schedule__c 
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :testOpp.Id
                AND Product__r.Name = 'Subscription'
            ORDER BY Date__c ASC][1].Revenue__c
        );
        System.assertEquals(100000/5*0.6, [
            SELECT Revenue__c 
            FROM Product_Revenue_Schedule__c 
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :testOpp.Id
                AND Product__r.Name = 'Services'
            ORDER BY Date__c ASC][1].Revenue__c
        );
        System.assertEquals(0, [
            SELECT Invoice_Amount__c 
            FROM Invoice__c 
            WHERE Opportunity__c = :testOpp.Id
            ORDER BY Invoice_Date__c ASC][0].Invoice_Amount__c
        );
        System.assert(![
            SELECT Invoice_Amount__c 
            FROM Invoice__c 
            WHERE Opportunity__c = :testOpp.Id
                AND In_Forecast__c = true].isEmpty(),
            'Here mustbe generated Invoices'
        );
        System.assertEquals(0, [
            SELECT Invoice_Amount__c 
            FROM Invoice__c 
            WHERE Opportunity__c = :testOpp.Id
            ORDER BY Invoice_Date__c ASC][0].Invoice_Amount__c
        );
        System.assertEquals(100000*0.25, [
            SELECT Invoice_Amount__c 
            FROM Invoice__c
            WHERE Opportunity__c = :testOpp.Id
            ORDER BY Invoice_Date__c ASC][1].Invoice_Amount__c
        );
        System.assertEquals(0, [
            SELECT Invoice_Amount__c 
            FROM Invoice__c 
            WHERE Opportunity__c = :testOpp.Id
            ORDER BY Invoice_Date__c ASC][3].Invoice_Amount__c
        );
    }
    
    static testmethod void testCalculateOpportunity_Failure() {
        init();
    
        Test.startTest();
        
        Opportunity testOpp = new Opportunity(
            Name = 'test',
            CloseDate = Date.today(),
            Product_Category__c = 'Data Hub',
            Amount = 0,
            StageName = 'New',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id,
            In_Forecast__c = true
        );
        insert testOpp;
        
        Test.stopTest();
        
        System.assert([
            SELECT Id 
            FROM Product_Revenue_Schedule__c 
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :testOpp.Id
                AND In_Forecast__c = true].isEmpty(), 
            'Here must not be any generated revenue records presenting.'
        );
    }

}