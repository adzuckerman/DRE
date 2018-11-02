trigger OpportunityRevenueCalculation on Opportunity (before insert, before update, after insert, after update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        /*
         * Opportunity pricebook setting
         */
        if (!RevenueCalculationUtil.isTriggerEnabled || !RevenueCalculationUtil2.isTriggerEnabled) {
            return;
        } 
        
        List<Pricebook2> pricebook = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME];
        if (!pricebook.isEmpty()) {
            for (Opportunity opp : Trigger.new) {
                if (!opp.Automatic_Calculation__c) {
                    continue;
                }
            
                if (opp.Pricebook2Id != null) {
                    continue;
                }
                
                opp.Pricebook2Id = pricebook.get(0).Id;
            }
        }
        
        Set<String> oppsToClean = new Set<String>();
        for (Opportunity opp : Trigger.new) {
            if (!opp.Automatic_Calculation__c) {
                continue;
            }
        
            // If a user unchecks the in forecast checkbox delete all the in forecast invoices and revenue schedules regardless of Opportunity stage.
            if (Trigger.IsUpdate && !opp.In_Forecast__c && Trigger.oldMap.get(opp.Id).In_Forecast__c) {
                oppsToClean.add(opp.Id);
            }
            
            // Upon reaching the Opportunity stage 'Closed Lost', automatically uncheck the forecast checkbox and delete all forecasted records.
            if (!opp.IsWon && opp.IsClosed && Trigger.oldMap != null && !(!Trigger.oldMap.get(opp.Id).IsWon && Trigger.oldMap.get(opp.Id).IsClosed)) {
                opp.In_Forecast__c = false;
                oppsToClean.add(opp.Id);
            }
            
            // Upon reaching the Opportunity stage 'Closed Won', automatically generate the non-forecasted revenue schedules and invoices AND automatically uncheck the in forecast checkbox. The first part of this is already happening, but the current process does not uncheck the in forecast checkbox automatically. This needs to be implemented.
            if (opp.IsWon && opp.IsClosed && Trigger.oldMap != null && !(Trigger.oldMap.get(opp.Id).IsWon && Trigger.oldMap.get(opp.Id).IsClosed)) {
                opp.In_Forecast__c = false;
            }
            
        }
        
        delete [SELECT Id FROM Invoice__c WHERE In_Forecast__c = true AND Opportunity__c IN :oppsToClean];
        delete [SELECT Id FROM Product_Revenue_Schedule__c WHERE In_Forecast__c = true AND Monthly_Revenue_Schedule__r.Opportunity__c IN :oppsToClean];
    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    
        /*
         * Opportunity schedules calculations
         */
        if (!RevenueCalculationUtil.isTriggerEnabled || !RevenueCalculationUtil2.isTriggerEnabled) {
            return;
        } 
        
        List<Opportunity> oppsToSchedule = new List<Opportunity>();
        List<Opportunity> oppsToSchedule2 = new List<Opportunity>();
        List<Opportunity> oppsToForecast = new List<Opportunity>();
        List<Opportunity> oppsToForecast2 = new List<Opportunity>();
        
        for (Opportunity opp : Trigger.new) {
            if (!opp.Automatic_Calculation__c) {
                continue;
            }
        
            Boolean isOpportunityNew = Trigger.oldMap == null || !Trigger.oldMap.containsKey(opp.Id);
            Boolean isCloseDateChanged = !isOpportunityNew && Trigger.oldMap.get(opp.Id).CloseDate != opp.CloseDate;
            Boolean isForecastingChanged = !isOpportunityNew && Trigger.oldMap.get(opp.Id).In_Forecast__c != opp.In_Forecast__c;
            Boolean isOfferingChanged = !isOpportunityNew && Trigger.oldMap.get(opp.Id).Product_Category__c != opp.Product_Category__c;
            Boolean isContractEndChanged = !isOpportunityNew && Trigger.oldMap.get(opp.Id).Contract_End__c != opp.Contract_End__c;
            Boolean isContractStartChanged = !isOpportunityNew && Trigger.oldMap.get(opp.Id).Contract_Start__c != opp.Contract_Start__c;
            Boolean isAmountChanged = !isOpportunityNew && Trigger.oldMap.get(opp.Id).Amount != opp.Amount;
            Boolean isStageChanged = !isOpportunityNew && Trigger.oldMap.get(opp.Id).StageName != opp.StageName;
            Boolean isPercentageSettingChanged = !isOpportunityNew && (Trigger.oldMap.get(opp.Id).Override_Allocations__c != opp.Override_Allocations__c);
            Boolean isPercentageChanged = !isOpportunityNew 
                && (Trigger.oldMap.get(opp.Id).DOC_Data_Configuration__c != opp.DOC_Data_Configuration__c
                || Trigger.oldMap.get(opp.Id).DOC_Data_Licensing__c != opp.DOC_Data_Licensing__c
                || Trigger.oldMap.get(opp.Id).DOC_Library_Configuration__c != opp.DOC_Library_Configuration__c
                || Trigger.oldMap.get(opp.Id).DOC_Library_Licensing__c != opp.DOC_Library_Licensing__c
                || Trigger.oldMap.get(opp.Id).Services_Percentage__c != opp.Services_Percentage__c
                || Trigger.oldMap.get(opp.Id).Subscription_Percentage__c != opp.Subscription_Percentage__c);
        
            if (opp.In_Forecast__c && !opp.IsClosed && opp.Product_Category__c != null && opp.CloseDate != null) {
                if (opp.Use_New_Forecasting_Algorithm__c == true)
                	oppsToForecast2.add(opp);
                else
                	oppsToForecast.add(opp);
            }
            else if (opp.isClosed && (isOpportunityNew || isForecastingChanged || isOfferingChanged || isAmountChanged 
                || isStageChanged || isContractEndChanged || isContractStartChanged || isPercentageChanged || isPercentageSettingChanged)) {
                
                if (opp.Use_New_Forecasting_Algorithm__c == true)
                	oppsToSchedule2.add(opp);
                else
                	oppsToSchedule.add(opp);
            }
        }
        
        RevenueCalculationUtil.calculateOpportunity(oppsToSchedule);
        RevenueCalculationUtil2.calculateOpportunity(oppsToSchedule2);
        RevenueForecastingUtil.forecastOpportunity(oppsToForecast);
        RevenueForecastingUtil2.forecastOpportunity(oppsToForecast2);
    }

}