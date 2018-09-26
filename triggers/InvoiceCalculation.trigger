trigger InvoiceCalculation on Invoice__c (after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        
        /*
         * Revenue schedules calculations
         */
        if (!RevenueCalculationUtil.isTriggerEnabled) {
            return;
        }
        
        RevenueCalculationUtil.calculateInvoices([
            SELECT Invoice_Amount__c, Invoice_Date__c, Deferred_Revenue__c, Accrued_Revenue__c
            FROM Invoice__c
            WHERE Opportunity__c = :Trigger.new.get(0).Opportunity__c
            ORDER BY Invoice_Date__c ASC
        ]);
        
    }
    
}