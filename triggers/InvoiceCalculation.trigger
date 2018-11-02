trigger InvoiceCalculation on Invoice__c (after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        
        /*
         * Revenue schedules calculations
         */
        if (!RevenueCalculationUtil.isTriggerEnabled || !RevenueCalculationUtil2.isTriggerEnabled) {
            return;
        }
        
        RevenueCalculationUtil.calculateInvoices([
            SELECT Invoice_Amount__c, Invoice_Date__c, Deferred_Revenue__c, Accrued_Revenue__c
            FROM Invoice__c
            WHERE Opportunity__c = :Trigger.new.get(0).Opportunity__c
              AND Opportunity__r.Use_New_Forecasting_Algorithm__c != true
            ORDER BY Invoice_Date__c ASC
        ]);
        
        RevenueCalculationUtil2.calculateInvoices([
            SELECT Invoice_Amount__c, Invoice_Date__c, Deferred_Revenue__c, Accrued_Revenue__c
            FROM Invoice__c
            WHERE Opportunity__c = :Trigger.new.get(0).Opportunity__c
              AND Opportunity__r.Use_New_Forecasting_Algorithm__c = true
            ORDER BY Invoice_Date__c ASC
        ]);
        
    }
    
}