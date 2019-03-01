public class InvoiceAllHelper {

    public static void SetInForecast(List<Invoice__c> newList, Map<Id, Invoice__c> oldMap) {
        
        for (Invoice__c newInv : newList) {
            Invoice__c oldInv = oldMap.get(newInv.Id);
            if ((newInv.Invoice_Num__c != 'NA' && newInv.Invoice_Num__c != 'TBD') && (oldInv.Invoice_Num__c == 'NA' || oldInv.Invoice_Num__c == 'TBD')) {
                newInv.In_Forecast__c = false;
            }
        }
        
    }
    
}