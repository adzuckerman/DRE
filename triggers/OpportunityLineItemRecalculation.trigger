/*   Name:          Opportunity Line Item Recalculation
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          8/17/2017
 *   Description:   Trigger to recalculate Opportunity line items and revenue schedules.
 *                
 */

trigger OpportunityLineItemRecalculation on OpportunityLineItem (before insert, before update, after insert, after update) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    
        /*
         * Opportunity line items and schedules calculations
         */
        if (!RevenueCalculationUtil.isTriggerEnabled) {
            return;
        } 
        
        Set<Id> oppoIds = new Set<Id>();
        for (OpportunityLineItem lineItem : Trigger.new) {
            oppoIds.add(lineItem.OpportunityId);
        }
        
        Set<Id> refinedOppoIds = new Set<Id>();
        List<Opportunity> oppos = [SELECT Automatic_Calculation__c, In_Forecast__c FROM Opportunity WHERE Id IN :oppoIds];
        for (Opportunity oppo : oppos) {
            if (!oppo.Automatic_Calculation__c || oppo.In_Forecast__c) {
                continue;
            }
            refinedOppoIds.add(oppo.Id);
        }
        
        RevenueCalculationUtil.calculateOpportunity([
            SELECT Amount, Product_Category__c, Contract_Start__c, Contract_End__c, Pricebook2Id, DOC_Data_Configuration__c, 
                DOC_Data_Licensing__c, DOC_Library_Configuration__c, DOC_Library_Licensing__c, Services_Percentage__c, 
                Subscription_Percentage__c, Override_Allocations__c
            FROM Opportunity 
            WHERE Id IN :refinedOppoIds
        ]);
    }

}