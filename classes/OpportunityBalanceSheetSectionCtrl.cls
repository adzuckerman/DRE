/*   Name:          InvoiceListCtrl
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          11/2/2017
 *   Description:   Controller for OpportunityBalanceSheet page quering related invoice records
 */

public with sharing class OpportunityBalanceSheetSectionCtrl {

    public List<Invoice__c> invoices { get; private set; }
    public Boolean isForecasted { get; private set; }

    public OpportunityBalanceSheetSectionCtrl(ApexPages.StandardController controller) {

        String opportunityId = controller.getRecord().Id;
        
        Opportunity opportunity = [
            SELECT IsClosed, In_Forecast__c
            FROM Opportunity
            WHERE Id = :opportunityId
        ];
        this.isForecasted = opportunity.In_Forecast__c;

        this.invoices = [
            SELECT Accrued_Revenue_Formula__c, Deferred_Revenue_Formula__c, Invoice_Date__c, Invoice_Amount__c,
                Cumulative_Revenue__c, Cumulative_Invoices__c, Monthly_Revenue__c
            FROM Invoice__c
            WHERE Opportunity__c = :opportunityId
            ORDER BY Invoice_Date__c
        ];
        
        for (Invoice__c invoice : this.invoices) {
            invoice.Invoice_Date__c = invoice.Invoice_Date__c.addMonths(1).toStartofMonth().addDays(-1);
        }
    }

}