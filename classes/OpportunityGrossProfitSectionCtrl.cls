/*   Name:          OpportunityGrossProfitSectionCtrl
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          11/1/2017
 *   Description:   Controller for OpportunityGrossProfitSection page quering related revenue records
 */
 
public with sharing class OpportunityGrossProfitSectionCtrl {

    public List<Monthly_Revenue_Schedule__c> revenues { get; private set; }
    public Boolean isForecasted { get; private set; }

    public OpportunityGrossProfitSectionCtrl(ApexPages.StandardController controller) {
        String opportunityId = controller.getRecord().Id;
        
        Opportunity opportunity = [
            SELECT IsClosed, In_Forecast__c, CloseDate, Contract_Start__c, Contract_End__c
            FROM Opportunity
            WHERE Id = :opportunityId
        ];
        this.isForecasted = opportunity.In_Forecast__c;
        
        Date closeDate = opportunity.CloseDate != null ? opportunity.CloseDate : Date.today().addYears(-10);
        Date contractStart = opportunity.Contract_Start__c != null ? opportunity.Contract_Start__c.toStartOfMonth() : Date.today().addYears(-10);
        Date contractEnd = opportunity.Contract_End__c != null ? opportunity.Contract_End__c.addMonths(1).toStartOfMonth().addDays(-1) : Date.today().addYears(10);
        
        this.revenues = [
            SELECT Revenue__c, Costs__c,Gross__c, Date__c
            FROM Monthly_Revenue_Schedule__c
            WHERE Opportunity__c = :opportunityId
                AND ((Opportunity__r.In_Forecast__c = true AND Date__c >= :closeDate) OR (Opportunity__r.In_Forecast__c = false AND Date__c >= :contractStart AND Date__c <= :contractEnd))
            ORDER BY Date__c ASC
        ];
        
        for (Monthly_Revenue_Schedule__c revenue : this.revenues) {
            revenue.Date__c = revenue.Date__c.addMonths(1).toStartofMonth().addDays(-1);
        } 
    }

}