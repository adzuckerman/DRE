/*   Name:          Batch Revenue Calculculation
 *   Developer:     Adam Zuckerman - CLOUD MINE CONSULTING
 *   Date:          8/16/17
 *   Description:   Batch APEX to utilizing RevenueCaluculationUtil to recalculate revenue schedules,
 * 					invoice, accrued, and deferred revenue for existing Opportunities.									
 * 
 * 	 Updates:       Sergiusz Koczanowski - Updated batch for Invoices recalculation.
 */

global class batchRevenueCalculation implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Override_Allocations__c, Contract_Start__c, Contract_End__c, Product_Category__c, Pricebook2Id, Amount FROM Opportunity WHERE Contract_Start__c != NULL AND Contract_End__c != NULL'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        if (true) return;
    
        /*
         * Adjusting invoices
         */
        // RevenueCalculationUtil.calculateInvoicesBySchedules([
        //     SELECT Revenue_Type__c, POC__c, Revenue__c, Date__c, Product__c, Product__r.Name, Monthly_Revenue_Schedule__r.Opportunity__r.Amount, Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c
        //     FROM Product_Revenue_Schedule__c
        //     WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :scope.get(0).Id
        //     ORDER BY Date__c ASC
        // ], [
        //     SELECT Invoice_Amount__c, Invoice_Date__c, Opportunity__c, Milestone_Description__c 
        //     FROM Invoice__c
        //     WHERE Opportunity__c = :scope.get(0).Id
        // ]);
        
        /*
         * Populating percentages without calling of trigger
         */
        Map<String, ContractDrivers__c> oppoSettings = ContractDrivers__c.getAll();
        for (Opportunity opp : scope) {
            if (!oppoSettings.containsKey(opp.Product_Category__c)) {
                continue;
            }
            ContractDrivers__c oppoSetting = oppoSettings.get(opp.Product_Category__c);
            
            opp.DOC_Data_Configuration__c = oppoSetting.DOC_Data_Configuration__c;
            opp.DOC_Data_Licensing__c = oppoSetting.DOC_Data_Licensing__c;
            opp.DOC_Library_Configuration__c = oppoSetting.DOC_Library_Configuration__c;
            opp.DOC_Library_Licensing__c = oppoSetting.DOC_Library_Licensing__c;
            opp.Services_Percentage__c = oppoSetting.Services__c;
            opp.Subscription_Percentage__c = oppoSetting.Subscription__c;
        }
        RevenueCalculationUtil.isTriggerEnabled = false;
        update scope;
        RevenueCalculationUtil.isTriggerEnabled = true;
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}