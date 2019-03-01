public with sharing class InvoiceHandler {
    
    public static void UpdateGAAPOnTimeEntries(List<Invoice__c> newList, Map<Id, Invoice__c> oldMap) {
    	
    	Set<Id> oppIds = new Set<Id>();
    	for (Invoice__c newInv : newList) {
    		Invoice__c oldInv = oldMap.get(newInv.Id);
    		if (newInv.Invoice_Num__c != 'NA' && newInv.Invoice_Num__c != 'TBD' && (newInv.Invoice_Num__c != oldInv.Invoice_Num__c || newInv.Actual_Invoice_Date__c != oldInv.Actual_Invoice_Date__c)) {
    			oppIds.add(newInv.Opportunity__c);
    		}
    	}
    	
    	if (oppIds.size() > 0) {
    		List<Toggl_Time_Entry__c> tes = [SELECT Id, Project_Name__c, Account__r.Name, Start_Date__c FROM Toggl_Time_Entry__c 
    											WHERE Project__r.TASKRAY__trOpportunity__c IN :oppIds OR Sub_Project__r.TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__c IN :oppIds];
    		if (tes.size() > 0) {
    			TogglGAAPClassBatch.SetGAAPClass(tes, false);
    		}
    	}
    	
    }
    
}