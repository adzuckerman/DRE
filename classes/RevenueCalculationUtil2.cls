public with sharing class RevenueCalculationUtil2 {
    
    public static final String PRICEBOOK_NAME = 'Components';
    
    public static List<LockDateWrapper> lockedDates { 
        get {
            if (lockedDates != null) {
                return lockedDates;
            }
            else {
                lockedDates = new List<LockDateWrapper>();
            }
            
            List<Revenue_Costs_Data_Lock__mdt> dateLocks = [
                SELECT Start_Date__c, End_Date__c, Type__c
                FROM Revenue_Costs_Data_Lock__mdt
            ];
            for (Revenue_Costs_Data_Lock__mdt dateLock : dateLocks) {
                lockedDates.add(
                    new LockDateWrapper(
                        dateLock.Start_Date__c,
                        dateLock.End_Date__c,
                        dateLock.Type__c
                    )
                );
            }
            return lockedDates;
        }
        private set;
    }
    
    public static Boolean isTriggerEnabled = true;
    
    public static void calculateOpportunity(List<Opportunity> oppos) {
        List<OpportunityLineItem> existingLines = [
            SELECT OpportunityId, PricebookEntryId, Contract_Start__c, Contract_End__c
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppos
        ];
        
        List<Product_Revenue_Schedule__c> existingSchedules = [
            SELECT In_Forecast__c, Date__c, Monthly_Revenue_Schedule__r.Costs__c
            FROM Product_Revenue_Schedule__c 
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c IN :oppos
        ];
        
        List<Product_Revenue_Schedule__c> schedulesToDelete = new List<Product_Revenue_Schedule__c>();
        for (Product_Revenue_Schedule__c schedule : existingSchedules) {
            if (!isProductScheduleLocked(lockedDates, schedule) || schedule.In_Forecast__c) {
                schedulesToDelete.add(schedule);
            }
        }
        
        // Invoices are no longer deleted when the opportunity is closed won
        List<Invoice__c> existingInvoices = [
            SELECT In_Forecast__c, Invoice_Num__c, Invoice_Amount__c, Invoice_Date__c, Actual_Invoice_Date__c, Opportunity__c, Milestone_Description__c
            FROM Invoice__c
            WHERE Opportunity__c IN :oppos
        ];
        
        isTriggerEnabled = false;
        delete schedulesToDelete;
        delete existingInvoices; //delete invoices?
        isTriggerEnabled = true;
    
        Map<Id, List<Monthly_Revenue_Schedule__c>> monthlyRevenues = generateMonthlyRevenues(oppos);
        List<Monthly_Revenue_Schedule__c> monthlyRevenuesToUpsert = new List<Monthly_Revenue_Schedule__c>();
        for (List<Monthly_Revenue_Schedule__c> monthlyRevenuesList : monthlyRevenues.values()) {
            monthlyRevenuesToUpsert.addAll(monthlyRevenuesList);
        }
        
        isTriggerEnabled = false;
        upsert monthlyRevenuesToUpsert;
        isTriggerEnabled = true;
        
        List<Product_Revenue_Schedule__c> schedulesToUpsert = configureSchedules(oppos, monthlyRevenuesToUpsert);
        isTriggerEnabled = false;
        upsert schedulesToUpsert;
        isTriggerEnabled = true;
        
        //Invoices are no longer deleted when the opportunity is closed won
        List<Invoice__c> invoicesToUpsert = configureInvoices([
            SELECT POC__c, Revenue__c, Date__c, Product__c, Product__r.Name, Monthly_Revenue_Schedule__r.Opportunity__r.Amount, Monthly_Revenue_Schedule__r.Costs__c, Monthly_Revenue_Schedule__r.Gross__c, Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c, Monthly_Revenue_Schedule__r.Opportunity__c, Revenue_Type__c
            FROM Product_Revenue_Schedule__c
            WHERE Id IN :schedulesToUpsert
            ORDER BY Date__c ASC
        ], existingInvoices);
        isTriggerEnabled = false;
        upsert invoicesToUpsert;
        isTriggerEnabled = true; //delete invoices?
    }
    
    public static Map<Id, List<Monthly_Revenue_Schedule__c>> generateMonthlyRevenues(List<Opportunity> oppos) {
        Map<String, Monthly_Revenue_Schedule__c> existingMonthlyRevenues = new Map<String, Monthly_Revenue_Schedule__c>();
        for (Monthly_Revenue_Schedule__c revenue : [
            SELECT Opportunity__c, Date__c,Costs__c
            FROM Monthly_Revenue_Schedule__c
            WHERE Opportunity__c IN :oppos
        ]) {
            
            existingMonthlyRevenues.put(String.valueOf(revenue.Opportunity__c) + String.valueOf(revenue.Date__c.month()) + String.valueOf(revenue.Date__c.year()), revenue);
        }
    	
        system.debug('existingMonthlyRevenues----' + existingMonthlyRevenues);
        
        Map<Id, List<Monthly_Revenue_Schedule__c>> result = new Map<Id, List<Monthly_Revenue_Schedule__c>>();
        
        Map<Id, Opportunity> schedulesOpportunities = new Map<Id, Opportunity>([
            SELECT DOC_Data_Configuration__c, DOC_Data_Licensing__c, DOC_Library_Configuration__c,
                DOC_Library_Licensing__c, Services_Percentage__c, Subscription_Percentage__c, Override_Allocations__c,
                (SELECT Contract_Start__c, Contract_End__c FROM OpportunityLineItems)
            FROM Opportunity
            WHERE Id IN :oppos
        ]);
        
        for (Opportunity opp : oppos) {
        
            if (!result.containsKey(opp.Id)) {
                result.put(opp.Id, new List<Monthly_Revenue_Schedule__c>());
            }
            
            Date startDate = opp.Contract_Start__c;
            Date endDate = opp.Contract_End__c;
            Integer duration = startDate != null && endDate != null ? startDate.monthsBetween(endDate) : 0;
            
            for (OpportunityLineItem currentProduct : schedulesOpportunities.get(opp.Id).OpportunityLineItems) {
            	Date productStartDate = currentProduct != null && currentProduct.Contract_Start__c != null ? currentProduct.Contract_Start__c : opp.Contract_Start__c;
                Date productEndDate = currentProduct != null && currentProduct.Contract_End__c != null ? currentProduct.Contract_End__c : opp.Contract_End__c;
                
                startDate = startDate > productStartDate ? productStartDate : startDate;
                endDate = endDate < productEndDate ? productEndDate : endDate;
                
                if (startDate == null || endDate == null) {
                    continue;
                }
                
                duration = startDate.monthsBetween(endDate) + 2;
            }
            system.debug('duration' + duration);
            
            for (Integer i = 0; i < duration; i++) {
                //system.debug('special key---' + String.valueOf(opp.Id) + String.valueOf(startDate.addMonths(i).month()) + String.valueOf(startDate.addMonths(i).year()));
                //system.debug('existingMRS----' + existingMonthlyRevenues.get(String.valueOf(opp.Id) + String.valueOf(startDate.addMonths(i).month()) + String.valueOf(startDate.addMonths(i).year())).Id);
                result.get(opp.Id).add(
                    new Monthly_Revenue_Schedule__c(
                        Id = existingMonthlyRevenues.containsKey(String.valueOf(opp.Id) + String.valueOf(startDate.addMonths(i).month()) + String.valueOf(startDate.addMonths(i).year())) ? existingMonthlyRevenues.get(String.valueOf(opp.Id) + String.valueOf(startDate.addMonths(i).month()) + String.valueOf(startDate.addMonths(i).year())).Id : null,
                        Opportunity__c = opp.Id,
                        Date__c = startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)
                    )
                );
            }
        }
        system.debug('result----' + result);
        return result;
    }

    public static void calculateInvoices(List<Invoice__c> invoices) {
        Decimal currentAmountSum = 0.0;
        
        List<Net_Accounts_Receivable_Months__mdt> accReceivable = [
            SELECT Months__c
            FROM Net_Accounts_Receivable_Months__mdt
            LIMIT 1
        ];
        
        integer invNo = 0;
        for (Invoice__c invoice : invoices) {
            currentAmountSum += invoice.Invoice_Amount__c != null ? invoice.Invoice_Amount__c : 0.0;
            system.debug('invoice.Accrued_Revenue__c BEFORE----' + invoice.Accrued_Revenue__c);
            invoice.Deferred_Revenue__c = currentAmountSum - (invoice.Accrued_Revenue__c != null ? invoice.Accrued_Revenue__c : 0.0);
            invoice.Cumulative_Invoices__c = currentAmountSum;
            system.debug('currentAmountSum----' + currentAmountSum);
            system.debug('invoice.Deferred_Revenue__c----' + invoice.Deferred_Revenue__c);
            system.debug('invoice.Accrued_Revenue__c----' + invoice.Accrued_Revenue__c);
            
            invoice.Net_Accounts_Receivable__c = invoice.Invoice_Amount__c != null ? invoice.Invoice_Amount__c : 0.0;
            for (Integer i = invNo - Integer.valueOf(accReceivable[0].Months__c) + 1; i >= 0 && i < invNo; i++) {
                invoice.Net_Accounts_Receivable__c += invoices[i].Invoice_Amount__c != null ? invoices[i].Invoice_Amount__c : 0;
            }
            invNo++;
			//logic to validate cumulative invoices does not exceed Opp amount          
            if(trigger.isExecuting && invoice.Cumulative_Invoices__c > invoice.Opportunity_Amount__c ){
                trigger.newMap.get(invoice.id).addError('Cumulative invoices exceed the opportunity amount. Please verify the invoice amounts.');
                return;
            }
        }
        
        isTriggerEnabled = false;
        update invoices;
        isTriggerEnabled = true;
    }
    
    public static void calculateSchedules(List<Product_Revenue_Schedule__c> scheds, Date currentPRSDate) {
        if (scheds.isEmpty()) {
            return;
        }
    
        List<Product_Revenue_Schedule__c> schedsToUpdate = new List<Product_Revenue_Schedule__c>();
        
        Map<Id, Map<Id, decimal>> productsMap = new Map<Id, Map<Id, decimal>>();
        for (OpportunityLineItem lineItem : [SELECT TotalPrice, Contract_Start__c, Contract_End__c, OpportunityId, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c]) {
            if (!productsMap.containsKey(lineItem.OpportunityId)) {
                productsMap.put(lineItem.OpportunityId, new Map<Id, decimal>());
            }
            if (!productsMap.get(lineItem.OpportunityId).containsKey(lineItem.Product2Id)) {
            	productsMap.get(lineItem.OpportunityId).put(lineItem.Product2Id, 0);
            }
            productsMap.get(lineItem.OpportunityId).put(lineItem.Product2Id, productsMap.get(lineItem.OpportunityId).get(lineItem.Product2Id) + lineItem.TotalPrice);
        }
        
        List<SObject> schedulesOpportunity = [
            SELECT DOC_Data_Configuration__c, DOC_Data_Licensing__c, DOC_Library_Configuration__c,
                DOC_Library_Licensing__c, Services_Percentage__c, Subscription_Percentage__c, Override_Allocations__c
            FROM Opportunity
            WHERE Id = :scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c
        ];
        
        Id productId = scheds.get(0).Product__c;
        Decimal productAmount = productsMap.containsKey(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c) && productsMap.get(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c).containsKey(productId) ?
        						productsMap.get(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c).get(productId) :
        						null; 
        if (productAmount == 0 || productAmount == null) {
            return;
        }
        
        Decimal currentPocSum = 0;

        for (Product_Revenue_Schedule__c sched : scheds) {
            if ((sched.Date__c <= Date.today() || isProductScheduleLocked(lockedDates, sched)) && !sched.Monthly_Revenue_Schedule__r.Opportunity__r.Unlock_Future_Revenue__c) {
                currentPocSum += sched.POC__c;
                system.debug('Date.today() sched.Date__c---' + sched.Date__c);
            }
            else if ((sched.Date__c <= currentPRSDate || isProductScheduleLocked(lockedDates, sched)) && sched.Monthly_Revenue_Schedule__r.Opportunity__r.Unlock_Future_Revenue__c) {
                currentPocSum += sched.POC__c;
                system.debug('currentPRSDate sched.Date__c---' + sched.Date__c);
            }
            else {
                schedsToUpdate.add(sched);
            }
        }
        
        for (Product_Revenue_Schedule__c sched : schedsToUpdate) {
            sched.POC__c = (100.0 - currentPocSum) / schedsToUpdate.size();
            sched.Revenue__c = productAmount * sched.POC__c / 100.0;
        }
        system.debug('schedsToUpdate----' + schedsToUpdate);
        
        isTriggerEnabled = false;
        update schedsToUpdate;
        isTriggerEnabled = true;
    }
    
    public static void calculateInvoicesBySchedules(List<Product_Revenue_Schedule__c> schedules, List<Invoice__c> existingInvoices) {
        if (schedules.isEmpty()) {
            return;
        }
    
        Map<Date, Invoice__c> invoiceMap = new Map<Date, Invoice__c>();
        for (Invoice__c invoice : existingInvoices) {
            if (invoiceMap.containsKey(invoice.Invoice_Date__c.addMonths(1).toStartOfMonth().addDays(-1))) {
                continue;
            }
            invoiceMap.put(
                invoice.Invoice_Date__c.addMonths(1).toStartOfMonth().addDays(-1), invoice    
            );
        }
        
        Map<Date, List<Product_Revenue_Schedule__c>> oppoSchedulesMap = new Map<Date, List<Product_Revenue_Schedule__c>>();
        for (Product_Revenue_Schedule__c schedule : schedules) {
            if (!oppoSchedulesMap.containsKey(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1))) {
                oppoSchedulesMap.put(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1), new List<Product_Revenue_Schedule__c>());
            }
            oppoSchedulesMap.get(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1)).add(schedule);
        }
        
        List<Invoice__c> invoices = new List<Invoice__c>();

        Decimal currentOppCumulativeRevenue = 0.0;
        Decimal currentOppCumulativeCost = 0.0;
        Decimal currentOppCumulativeGrossProfit = 0.0;
        Decimal currentOppCumulativeInvoices = 0.0;
        Decimal currentOppInvoiceDefRevenue = 0.0;
        Decimal currentOppInvoiceAccruedRevenue = 0.0;
        
        // Add 2 more months?
        Date maxDate = null;
        for (Date invDate : oppoSchedulesMap.keyset()) {
            if (maxDate == null || maxDate < invDate) {
                maxDate = invDate;
            }
        }
        oppoSchedulesMap.put(maxDate.addDays(1).AddMonths(1).addDays(-1), new List<Product_Revenue_Schedule__c>());
        oppoSchedulesMap.put(maxDate.addDays(1).AddMonths(2).addDays(-1), new List<Product_Revenue_Schedule__c>());
        
        for (Date invDate : oppoSchedulesMap.keySet()) {
        
            Decimal currentMonthOppInvoiceRevenue = 0.0;
            Decimal currentMonthOppInvoiceCost = 0.0;
            Decimal currentMonthOppInvoiceGrossProfit = 0.0;
            Decimal currentMonthOppInvoiceRevenueServ = 0.0;
            Decimal currentMonthOppInvoiceRevenueSubscr = 0.0;
            for (Product_Revenue_Schedule__c schedule : oppoSchedulesMap.get(invDate)) {
                currentMonthOppInvoiceRevenue += schedule.Revenue__c;
                currentMonthOppInvoiceCost = schedule.Monthly_Revenue_Schedule__r.Costs__c;
                currentMonthOppInvoiceGrossProfit = schedule.Monthly_Revenue_Schedule__r.Gross__c;
                currentMonthOppInvoiceRevenueServ += schedule.Revenue_Type__c == ContractInformationCtrl.SERVICES ? schedule.Revenue__c : 0;
                currentMonthOppInvoiceRevenueSubscr += schedule.Revenue_Type__c == ContractInformationCtrl.SUBSCRIPTION ? schedule.Revenue__c : 0;
            }
            
            Invoice__c invoiceToAdd = new Invoice__c(
                Opportunity__c = schedules.get(0).Monthly_Revenue_Schedule__r.Opportunity__c,
                Invoice_Date__c = invDate
            );
            
            if (invoiceMap.containsKey(invDate)) {
            
                invoiceToAdd.Id = invoiceMap.get(invDate).Id;
            
                if (!invoiceMap.get(invDate).In_Forecast__c && invoiceMap.get(invDate).Invoice_Amount__c != null) {
                    currentOppInvoiceDefRevenue += invoiceMap.get(invDate).Invoice_Amount__c;
                    invoiceToAdd.Milestone_Description__c = invoiceMap.get(invDate).Milestone_Description__c;
                    invoiceToAdd.Invoice_Amount__c = invoiceMap.get(invDate).Invoice_Amount__c;
                    
                    currentOppCumulativeInvoices += invoiceMap.get(invDate).Invoice_Amount__c;
                }
            }
            currentOppInvoiceDefRevenue -= currentMonthOppInvoiceRevenue;
            currentOppInvoiceAccruedRevenue += currentMonthOppInvoiceRevenue;
            currentOppCumulativeRevenue += currentMonthOppInvoiceRevenue;
            currentOppCumulativeCost += currentMonthOppInvoiceCost;
            currentOppCumulativeGrossProfit += currentMonthOppInvoiceGrossProfit;

            invoiceToAdd.Monthly_Revenue_Services__c = currentMonthOppInvoiceRevenueServ;
            invoiceToAdd.Monthly_Revenue_Subscription__c = currentMonthOppInvoiceRevenueSubscr;
            invoiceToAdd.Monthly_Revenue__c = currentMonthOppInvoiceRevenue;
            invoiceToAdd.Cumulative_Revenue__c = currentOppCumulativeRevenue;
            invoiceToAdd.Cumulative_Cost_of_Revenue__c = currentOppCumulativeCost;
            invoiceToAdd.Cumulative_Gross_Profit__c = currentOppCumulativeGrossProfit;
            invoiceToAdd.Cumulative_Invoices__c = currentOppCumulativeInvoices;
            invoiceToAdd.Deferred_Revenue__c = currentOppInvoiceDefRevenue;
            invoiceToAdd.Accrued_Revenue__c = currentOppInvoiceAccruedRevenue;
            
            invoices.add(
                invoiceToAdd
            );
        }
        
        isTriggerEnabled = false;
        upsert invoices;
        isTriggerEnabled = true;
    }
    
    public static void refineSchedules(List<Product_Revenue_Schedule__c> scheds) {
        if (scheds.isEmpty()) {
            return;
        }
        
        Map<Id, Product_Revenue_Schedule__c> scaledSchedules = new Map<Id, Product_Revenue_Schedule__c>(scheds);
        
        List<Id> oppIds = new List<Id>();
        for (Product_Revenue_Schedule__c sched : scheds) {
            oppIds.add(sched.Monthly_Revenue_Schedule__r.Opportunity__c);
        }
        
        Map<Id, Map<Id, decimal>> productsMap = new Map<Id, Map<Id, decimal>>();
        for (OpportunityLineItem lineItem : [SELECT TotalPrice, Contract_Start__c, Contract_End__c, OpportunityId, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppIds]) {
            if (!productsMap.containsKey(lineItem.OpportunityId)) {
                productsMap.put(lineItem.OpportunityId, new Map<Id, decimal>());
            }
            if (!productsMap.get(lineItem.OpportunityId).containsKey(lineItem.Product2Id)) {
            	productsMap.get(lineItem.OpportunityId).put(lineItem.Product2Id, 0);
            }
            productsMap.get(lineItem.OpportunityId).put(lineItem.Product2Id, productsMap.get(lineItem.OpportunityId).get(lineItem.Product2Id) + lineItem.TotalPrice);
        }
        
        Map<Id, SObject> schedulesOpportunities = new Map<Id, Opportunity>([
            SELECT DOC_Data_Configuration__c, DOC_Data_Licensing__c, DOC_Library_Configuration__c,
                DOC_Library_Licensing__c, Services_Percentage__c, Subscription_Percentage__c, Override_Allocations__c
            FROM Opportunity
            WHERE Id = :scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c
        ]);
        
        for (Product_Revenue_Schedule__c sched : (List<Product_Revenue_Schedule__c>) Trigger.new) {
            String productId = scaledSchedules.get(sched.Id).Product__c;
            
            Decimal productAmount = productsMap.containsKey(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c) && productsMap.get(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c).containsKey(productId) ? 
            						productsMap.get(scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__c).get(productId) :
            						null;
            if (productAmount == 0 || productAmount == null) {
                continue;
            }
                
            if (sched.POC__c != ((Product_Revenue_Schedule__c) Trigger.oldMap.get(sched.Id)).POC__c) {
                sched.Revenue__c = productAmount * sched.POC__c / 100.0;
                system.debug('sched.POC__c----' + sched.POC__c);
                system.debug('sched.Revenue__c----' + sched.Revenue__c);
            }
            else if (sched.Revenue__c != ((Product_Revenue_Schedule__c) Trigger.oldMap.get(sched.Id)).Revenue__c) {
                sched.POC__c = sched.Revenue__c * 100.0 / productAmount;
            }
        }
    }
    
    public static List<Product_Revenue_Schedule__c> configureSchedules(List<Opportunity> oppos, List<Monthly_Revenue_Schedule__c> monthlyRevenues) {
        if (oppos.isEmpty() || monthlyRevenues.isEmpty()) {
            return new List<Product_Revenue_Schedule__c>();
        }
        system.debug('monthlyRevenues---' + monthlyRevenues);
        List<Product_Revenue_Schedule__c> schedulesToUpsert = new List<Product_Revenue_Schedule__c>();
    
        Map<Id, Map<Id, decimal>> productsMap = new Map<Id, Map<Id, decimal>>();
        for (OpportunityLineItem lineItem : [SELECT TotalPrice, Contract_Start__c, Contract_End__c, OpportunityId, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppos]) {
            if (!productsMap.containsKey(lineItem.OpportunityId)) {
                productsMap.put(lineItem.OpportunityId, new Map<Id, decimal>());
            }
            if (!productsMap.get(lineItem.OpportunityId).containsKey(lineItem.Product2Id)) {
            	productsMap.get(lineItem.OpportunityId).put(lineItem.Product2Id, 0);
            }
            productsMap.get(lineItem.OpportunityId).put(lineItem.Product2Id, productsMap.get(lineItem.OpportunityId).get(lineItem.Product2Id) + lineItem.TotalPrice);
        }
        
        Map<Id, SObject> schedulesOpportunities = new Map<Id, SObject>();
        for (SObject opp : oppos) {
            schedulesOpportunities.put((Id) opp.get('Id'), opp);
        }
        
        Map<Id, Map<Date, Id>> monthlyOppoDateIdMap = new Map<Id, Map<Date, Id>>();
        for (Monthly_Revenue_Schedule__c monthlyRevenue : monthlyRevenues) {
            if (!monthlyOppoDateIdMap.containsKey(monthlyRevenue.Opportunity__c)) {
                monthlyOppoDateIdMap.put(
                    monthlyRevenue.Opportunity__c, 
                    new Map<Date, Id>()
                );
            }
            monthlyOppoDateIdMap.get(monthlyRevenue.Opportunity__c).put(monthlyRevenue.Date__c, monthlyRevenue.Id);
        }
        
        Map<Id, List<Product_Revenue_Schedule__c>> lockedProductRevenueSchedules = new Map<Id, List<Product_Revenue_Schedule__c>>();
        for (Product_Revenue_Schedule__c schedule : [
            SELECT Monthly_Revenue_Schedule__r.Opportunity__c, Revenue__c, Product__c, Product__r.Name , Date__c
            FROM Product_Revenue_Schedule__c
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c IN :oppos]) {
            
            if (!lockedProductRevenueSchedules.containsKey(schedule.Monthly_Revenue_Schedule__r.Opportunity__c)) {
                lockedProductRevenueSchedules.put(
                    schedule.Monthly_Revenue_Schedule__r.Opportunity__c, 
                    new List<Product_Revenue_Schedule__c>()
                );
            }
            lockedProductRevenueSchedules.get(schedule.Monthly_Revenue_Schedule__r.Opportunity__c).add(schedule);
            
            //idle update of locked data, as it's used for invoices
            schedulesToUpsert.add(schedule);
        }
        
        for (Opportunity opp : [
            SELECT Amount, Product_Category__c, Contract_Start__c, Contract_End__c, Override_Allocations__c,
            	(SELECT Id, Contract_Start__c, Contract_End__c, Product2Id, Product2.Revenue_Period__c FROM OpportunityLineItems)
            FROM Opportunity 
            WHERE Id IN :oppos]) {
            
            if (opp.Contract_End__c == null || opp.Contract_Start__c == null) {
                continue;
            }
            
            Map<Id, Decimal> lockedProductAllocations = new Map<Id, Decimal>();
            Set<String> lockedDates = new Set<String>();
            if (lockedProductRevenueSchedules.containsKey(opp.Id)) {
                for (Product_Revenue_Schedule__c schedule : lockedProductRevenueSchedules.get(opp.Id)) {
                    if (!lockedProductAllocations.containsKey(schedule.Product__c)) {
                        lockedProductAllocations.put(schedule.Product__c, 0);
                    }
                    lockedProductAllocations.put(
                        schedule.Product__c, 
                        lockedProductAllocations.get(schedule.Product__c) + schedule.Revenue__c
                    );
                    lockedDates.add(String.valueOf(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1).month())
                        + String.valueOf(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1).year()));
                }
            }
            
            if (productsMap.containsKey(opp.Id)) {
	            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
	            	Decimal productAmount = productsMap.get(opp.Id).get(oli.Product2Id);
	                if (productAmount == 0 || productAmount == null) {
	                    continue;
	                }
	                
	                Decimal initialProductAmount = productAmount;
	                
	                if (lockedProductAllocations.containsKey(oli.Product2Id)) {
	                    productAmount -= lockedProductAllocations.get(oli.Product2Id);
	                }
	                
	                Date startDate = oli.Contract_Start__c != null ? oli.Contract_Start__c : opp.Contract_Start__c;
	                Date endDate = oli.Contract_End__c != null ? oli.Contract_End__c : opp.Contract_End__c;
	                //Date startDate = opp.Contract_Start__c > productStartDate ? productStartDate : opp.Contract_Start__c;
	                //Date endDate = opp.Contract_End__c < productEndDate ? productEndDate : opp.Contract_End__c;
	                Integer duration = startDate.monthsBetween(endDate);
	                Integer lockedDuration = 0; 
                    
                    //integer xduration = oli.Product2.Revenue_Period__c != null ? (integer)oli.Product2.Revenue_Period__c : duration;
	               
	                for (Integer i = 1; i < duration + 1; i++) {
	                    if (!lockedDates.contains(
	                        String.valueOf(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1).month())
	                        + String.valueOf(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1).year()))) {
	                        
	                        continue; 
	                    }
	                    lockedDuration++;
	                }
	                
	                for (Integer i = 1; i < duration + 1; i++) {
	                    if (lockedDates.contains(
	                        String.valueOf(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1).month())
	                        + String.valueOf(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1).year()))) {
	                        
	                        continue;
	                    }
	                	
                        system.debug('monthlyOppoDateIdMap---' + monthlyOppoDateIdMap.get(opp.Id));
                        system.debug('startDate---' + startDate.addMonths(1 + i).toStartOfMonth().addDays(-1));
                        system.debug('monthlyOppoDateIdMap Date---' + monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)));
	                    schedulesToUpsert.add(
	                        new Product_Revenue_Schedule__c(
                                Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(i).toStartOfMonth().addDays(-1)),
	                            Product__c = oli.Product2Id,
	                            //Date__c = startDate.addMonths(2 + i).toStartOfMonth().addDays(-1),
	                            // Date__c = startDate.addMonths(1 + i).toStartOfMonth().addDays(-1),
	                            POC__c = 100.0 * (productAmount / initialProductAmount) / (duration - lockedDuration),
	                            Revenue__c = 1.0 * productAmount / (duration - lockedDuration) 
	                        )
	                    );
	                }
	            }
            }
        }
        system.debug('schedulesToUpsert----' + schedulesToUpsert);
        return schedulesToUpsert;
    }
    
    private static List<Invoice__c> configureInvoices(List<Product_Revenue_Schedule__c> schedules, List<Invoice__c> existingInvoices) {
        Map<Id, Map<Date, Invoice__c>> invoiceMap = new Map<Id, Map<Date, Invoice__c>>();
        for (Invoice__c invoice : existingInvoices) {
            if (!invoiceMap.containsKey(invoice.Opportunity__c)) {
                invoiceMap.put(invoice.Opportunity__c, new Map<Date, Invoice__c>());
            }
            invoiceMap.get(invoice.Opportunity__c).put(
                invoice.Invoice_Date__c.addMonths(1).toStartOfMonth().addDays(-1),
                invoice    
            );
        }
    
        Map<Id, Map<Date, List<Product_Revenue_Schedule__c>>> oppoSchedulesMap = new Map<Id, Map<Date, List<Product_Revenue_Schedule__c>>>();
        for (Product_Revenue_Schedule__c schedule : schedules) {
            if (!oppoSchedulesMap.containsKey(schedule.Monthly_Revenue_Schedule__r.Opportunity__c)) {
                oppoSchedulesMap.put(
                    schedule.Monthly_Revenue_Schedule__r.Opportunity__c, 
                    new Map<Date, List<Product_Revenue_Schedule__c>>()
                );
            }
            if (!oppoSchedulesMap.get(schedule.Monthly_Revenue_Schedule__r.Opportunity__c).containsKey(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1))) {
                oppoSchedulesMap.get(schedule.Monthly_Revenue_Schedule__r.Opportunity__c).put(
                    schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1),
                    new List<Product_Revenue_Schedule__c>()
                );
            }
            oppoSchedulesMap
                .get(schedule.Monthly_Revenue_Schedule__r.Opportunity__c)
                    .get(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1))
                        .add(schedule);
        }
        
        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Id oppoId : oppoSchedulesMap.keySet()) {
        
            Decimal currentOppCumulativeRevenue = 0.0;
            Decimal currentOppCumulativeCosts = 0.0;
            Decimal currentOppCumulativeGrossProfit = 0.0;
            Decimal currentOppCumulativeInvoices = 0.0;
            Decimal currentOppInvoiceDefRevenue = 0.0;
            Decimal currentOppInvoiceAccruedRevenue = 0.0;
            
            // Add 2 more months?
            Date maxDate = null;
            for (Date invDate : oppoSchedulesMap.get(oppoId).keyset()) {
                if (maxDate == null || maxDate < invDate) {
                    maxDate = invDate;
                }
            }
            oppoSchedulesMap.get(oppoId).put(maxDate.addDays(1).AddMonths(1).addDays(-1), new List<Product_Revenue_Schedule__c>());
            oppoSchedulesMap.get(oppoId).put(maxDate.addDays(1).AddMonths(2).addDays(-1), new List<Product_Revenue_Schedule__c>());
            
            for (Date invDate : oppoSchedulesMap.get(oppoId).keySet()) {
            
                Decimal currentMonthOppInvoiceRevenue = 0.0;
                Decimal currentMonthOppInvoiceCosts = 0.0;
                Decimal currentMonthOppInvoiceGrossProfit = 0.0;
                Decimal currentMonthOppInvoiceRevenueServ = 0.0;
                Decimal currentMonthOppInvoiceRevenueSubscr = 0.0;
                for (Product_Revenue_Schedule__c schedule : oppoSchedulesMap.get(oppoId).get(invDate)) {
                    currentMonthOppInvoiceRevenue += schedule.Revenue__c;
                    currentMonthOppInvoiceCosts = schedule.Monthly_Revenue_Schedule__r.Costs__c;
                    currentMonthOppInvoiceGrossProfit = schedule.Monthly_Revenue_Schedule__r.Gross__c;
                    currentMonthOppInvoiceRevenueServ += schedule.Revenue_Type__c == ContractInformationCtrl.SERVICES ? schedule.Revenue__c : 0;
                    currentMonthOppInvoiceRevenueSubscr += schedule.Revenue_Type__c == ContractInformationCtrl.SUBSCRIPTION ? schedule.Revenue__c : 0;
                }
                
                Invoice__c invoiceToAdd = new Invoice__c(
                    Opportunity__c = oppoId,
                    Invoice_Date__c = invDate
                );
                
                if (invoiceMap.containsKey(oppoId) && invoiceMap.get(oppoId).containsKey(invDate)) {
                    // invoiceToAdd.Id = invoiceMap.get(oppoId).get(invDate).Id;
                    
                    if (!invoiceMap.get(oppoId).get(invDate).In_Forecast__c && invoiceMap.get(oppoId).get(invDate).Invoice_Amount__c != null) {
                        currentOppInvoiceDefRevenue += invoiceMap.get(oppoId).get(invDate).Invoice_Amount__c;
                        invoiceToAdd.Milestone_Description__c = invoiceMap.get(oppoId).get(invDate).Milestone_Description__c;
                        invoiceToAdd.Invoice_Amount__c = invoiceMap.get(oppoId).get(invDate).Invoice_Amount__c;
                        invoiceToAdd.Actual_Invoice_Date__c = invoiceMap.get(oppoId).get(invDate).Actual_Invoice_Date__c;
                        invoiceToAdd.Invoice_Num__c = invoiceMap.get(oppoId).get(invDate).Invoice_Num__c;
                        
                        currentOppCumulativeInvoices += invoiceMap.get(oppoId).get(invDate).Invoice_Amount__c;
                    }
                }

                currentOppInvoiceDefRevenue -= currentMonthOppInvoiceRevenue;
                currentOppCumulativeCosts += currentMonthOppInvoiceCosts;
                currentOppCumulativeGrossProfit += currentMonthOppInvoiceGrossProfit;
                currentOppInvoiceAccruedRevenue += currentMonthOppInvoiceRevenue;
                currentOppCumulativeRevenue += currentMonthOppInvoiceRevenue;
                
                invoiceToAdd.Monthly_Revenue_Services__c = currentMonthOppInvoiceRevenueServ;
                invoiceToAdd.Monthly_Revenue_Subscription__c = currentMonthOppInvoiceRevenueSubscr;
                invoiceToAdd.Monthly_Revenue__c = currentMonthOppInvoiceRevenue;
                invoiceToAdd.Cumulative_Revenue__c = currentOppCumulativeRevenue;
                invoiceToAdd.Cumulative_Cost_of_Revenue__c = currentOppCumulativeCosts;
                invoiceToAdd.Cumulative_Gross_Profit__c = currentOppCumulativeGrossProfit;
                invoiceToAdd.Cumulative_Invoices__c = currentOppCumulativeInvoices;
                invoiceToAdd.Deferred_Revenue__c = currentOppInvoiceDefRevenue;
                invoiceToAdd.Accrued_Revenue__c = currentOppInvoiceAccruedRevenue;
                
                invoices.add(
                    invoiceToAdd
                );
            }

        }
        
        return invoices;
    }
    
    private static Boolean isProductScheduleLocked(List<LockDateWrapper> lockedDates, Product_Revenue_Schedule__c schedule) {
        Boolean inRange = false;
        for (LockDateWrapper lockedDate : lockedDates) {
            if (lockedDate.lockType != 'Revenue') {
                continue;
            }
            inRange = (lockedDate.startDate != null && lockedDate.endDate != null && schedule.Date__c >= lockedDate.startDate && schedule.Date__c <= lockedDate.endDate)
                || (lockedDate.startDate != null && lockedDate.endDate == null && schedule.Date__c >= lockedDate.startDate)
                || (lockedDate.startDate == null && lockedDate.endDate != null && schedule.Date__c <= lockedDate.endDate);
                
            if (inRange) {
                break;
            }
        }
        
        return inRange;
    }
    
    public class LockDateWrapper {
    
        public Date startDate { get; private set; }
        public Date endDate { get; private set; }
        public String lockType { get; private set; }
        
        public LockDateWrapper(Date startDate, Date endDate, String lockType) {
            this.startDate = startDate;
            this.endDate = endDate;
            this.lockType = lockType;
        }
        
    }
    
}