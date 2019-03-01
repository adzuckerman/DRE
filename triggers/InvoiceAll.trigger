trigger InvoiceAll on Invoice__c (before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        InvoiceAllHelper.SetInForecast(Trigger.new, Trigger.oldMap);
    } 
    
}