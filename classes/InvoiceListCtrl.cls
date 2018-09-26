/*   Name:          InvoiceListCtrl
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          8/31/2017
 *   Description:   Controller for InvoiceList page quering related invoice records
 *
 *   Updates:
 *      09/04/2017 - added revenue schedule query to get Monthly Revenue and Cumulative Revenue
 */

public with sharing class InvoiceListCtrl {
    public List<Invoice> invoices {get; set;}

    public InvoiceListCtrl(ApexPages.StandardController controller) {

        String opportunityId = controller.getRecord().Id;

        List<Invoice__c> invoiceList = [
            SELECT Accrued_Revenue_Formula__c, Deferred_Revenue_Formula__c, Invoice_Date__c, Invoice_Amount__c,
                Cumulative_Revenue__c, Cumulative_Invoices__c, Monthly_Revenue__c
            FROM Invoice__c
            WHERE Opportunity__c = :opportunityId
            ORDER BY Invoice_Date__c
        ];

        /* 
         * Legacy calculation was here previously, that is the reayon for wrapper class.
         */
        this.invoices = new List<Invoice>();
        for (Invoice__c invoice : invoiceList) {
            Invoice newInvoice = new Invoice();
            if (invoice.Invoice_Date__c != null) {
                newInvoice.name = invoice.Invoice_Date__c.addMonths(1).toStartofMonth().addDays(-1).format();                
            }
        
            newInvoice.monthRevenue = invoice.Monthly_Revenue__c;
            newInvoice.cumulativeRevenue = invoice.Cumulative_Revenue__c;
            newInvoice.cumulativeAmount = invoice.Cumulative_Invoices__c;
            newInvoice.accruedRevenue = invoice.Accrued_Revenue_Formula__c;
            newInvoice.deferredRevenue = invoice.Deferred_Revenue_Formula__c;

            invoices.add(newInvoice);
        }
    }

    private class Invoice {
        public String name {get; set;}
        public Decimal monthRevenue {get; set;}
        public Decimal cumulativeRevenue {get; set;}
        public Decimal cumulativeAmount {get; set;}
        public Decimal accruedRevenue {get; set;}
        public Decimal deferredRevenue {get; set;}
    }
}