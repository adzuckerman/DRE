/*   Name:          Revenue Schedule Calculation
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          8/17/2017
 *   Description:   Trigger on Revenue Schedule object to make or refine revenue schedules. 
 *                
 */

trigger ProductRevenueSchedule on Product_Revenue_Schedule__c (before update, after update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
    
        /*
         * Revenue schedules refinement
         */
        if (!RevenueCalculationUtil.isTriggerEnabled) {
            return;
        } 
        
        RevenueCalculationUtil.refineSchedules([
            SELECT In_Forecast__c, POC__c, Revenue__c, Date__c, Product__c, Product__r.Name, Monthly_Revenue_Schedule__r.Opportunity__c, 
                Monthly_Revenue_Schedule__r.Opportunity__r.Amount, Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c, Monthly_Revenue_Schedule__r.Costs__c, Monthly_Revenue_Schedule__r.Gross__c,
                Revenue_Type__c
            FROM Product_Revenue_Schedule__c
            WHERE Id IN :Trigger.new
        ]);
        
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        
        /*
         * Revenue schedules calculations
         */
         if (!RevenueCalculationUtil.isTriggerEnabled) {
            return;
        }
        
        Monthly_Revenue_Schedule__c monthlySchedule = [SELECT Opportunity__c, Opportunity__r.In_Forecast__c, Opportunity__r.Automatic_Calculation__c FROM Monthly_Revenue_Schedule__c WHERE Id = :Trigger.new.get(0).Monthly_Revenue_Schedule__c];
        if (monthlySchedule.Opportunity__r.In_Forecast__c || !monthlySchedule.Opportunity__r.Automatic_Calculation__c) {
            return;
        }
        
        Id opportunityId = monthlySchedule.Opportunity__c;
        
        RevenueCalculationUtil.calculateSchedules([
            SELECT POC__c, Revenue__c, Date__c, Product__c, Product__r.Name, Monthly_Revenue_Schedule__r.Opportunity__r.Amount, 
                Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c, Monthly_Revenue_Schedule__r.Opportunity__c, Revenue_Type__c, Monthly_Revenue_Schedule__r.Costs__c, Monthly_Revenue_Schedule__r.Gross__c
            FROM Product_Revenue_Schedule__c
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :opportunityId
                AND Product__c = :Trigger.new.get(0).Product__c
            ORDER BY Date__c ASC
        ]);
        
        RevenueCalculationUtil.calculateInvoicesBySchedules([
            SELECT POC__c, Revenue__c, Date__c, Product__c, Product__r.Name, Monthly_Revenue_Schedule__r.Opportunity__r.Amount, 
                Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c, Monthly_Revenue_Schedule__r.Opportunity__c, Revenue_Type__c, Monthly_Revenue_Schedule__r.Costs__c, Monthly_Revenue_Schedule__r.Gross__c
            FROM Product_Revenue_Schedule__c
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :opportunityId
            ORDER BY Date__c ASC
        ], [
            SELECT In_Forecast__c, Invoice_Num__c, Invoice_Amount__c, Invoice_Date__c, Actual_Invoice_Date__c, Opportunity__c, Milestone_Description__c 
            FROM Invoice__c
            WHERE Opportunity__c = :opportunityId
        ]);
        
    }

}