/*   Name:          Revenue Calculation Utility
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          8/17/2017
 *   Description:   Utility to calculate revenue schedules, invoices, accrued and deferred revenue.
 *                
 *   Updates:
 *      08/17/2017 - Adam Zuckerman    - Changed revenue schedule date to realize revenue at the end of
 *                                       the current month.
 *      08/22/2017 - Serge Kochanovsky - Changed and refined conditions.
 *      10/01/2017 - Serge Kochanovsky - Adjusted class for new objects (Monthly and Product Revenues)
 *      01/15/2018 - Serge Kochanovsky - Added locking system for scheduled records.
 *      04/09/2018 - Mirela Chituc     - Added calculation on invoices for Cumulative_Cost_of_Revenue__c and 
 *                                       Cumulative_Gross_Profit__c
 */

public with sharing class RevenueCalculationUtil {

    public static final String PRICEBOOK_NAME = 'Components';

    public static final Map<String, String> PRODUCTS_MAP = new Map<String, String> {
        'DOC Data Configuration' => 'DOC_Data_Configuration__c',
        'DOC Data Licensing' => 'DOC_Data_Licensing__c',
        'DOC Library Configuration' => 'DOC_Library_Configuration__c',
        'DOC Library Licensing' => 'DOC_Library_Licensing__c',
        'Services' => 'Services__c',
        'Subscription' => 'Subscription__c'
    };
    
    public static final Map<String, String> PRODUCTS_OPPO_MAP = new Map<String, String> {
        'DOC Data Configuration' => 'DOC_Data_Configuration__c',
        'DOC Data Licensing' => 'DOC_Data_Licensing__c',
        'DOC Library Configuration' => 'DOC_Library_Configuration__c',
        'DOC Library Licensing' => 'DOC_Library_Licensing__c',
        'Services' => 'Services_Percentage__c',
        'Subscription' => 'Subscription_Percentage__c'
    };
    
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
        
        List<Invoice__c> existingInvoices = [
            SELECT In_Forecast__c, Invoice_Num__c, Invoice_Amount__c, Invoice_Date__c, Actual_Invoice_Date__c, Opportunity__c, Milestone_Description__c
            FROM Invoice__c
            WHERE Opportunity__c IN :oppos
        ];
        
        isTriggerEnabled = false;
        delete schedulesToDelete;
        delete existingInvoices;
        isTriggerEnabled = true;
        
        List<OpportunityLineItem> lineItemsToHandle = configureLineitems(oppos, existingLines);
        
        isTriggerEnabled = false;
        delete [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId IN :lineItemsToHandle];
        List<OpportunityLineItem> lineItemsToDelete = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lineItemsToUpsert = new List<OpportunityLineItem>();
        for (OpportunityLineItem lineItem : lineItemsToHandle) {
            if (lineItem.Id != null && lineItem.UnitPrice == 0) {
                lineItemsToDelete.add(lineItem);
            }
            else {
                lineItemsToUpsert.add(lineItem);
            }
        }
        delete lineItemsToDelete;
        upsert lineItemsToUpsert;
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
        
        List<Invoice__c> invoicesToUpsert = configureInvoices([
            SELECT POC__c, Revenue__c, Date__c, Product__c, Product__r.Name, Monthly_Revenue_Schedule__r.Opportunity__r.Amount, Monthly_Revenue_Schedule__r.Costs__c, Monthly_Revenue_Schedule__r.Gross__c, Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c, Monthly_Revenue_Schedule__r.Opportunity__c, Revenue_Type__c
            FROM Product_Revenue_Schedule__c
            WHERE Id IN :schedulesToUpsert
            ORDER BY Date__c ASC
        ], existingInvoices);
        isTriggerEnabled = false;
        upsert invoicesToUpsert;
        isTriggerEnabled = true;
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
    
        Map<Id, List<Monthly_Revenue_Schedule__c>> result = new Map<Id, List<Monthly_Revenue_Schedule__c>>();
        
        Map<Id, Map<Id, OpportunityLineItem>> lineItems = new Map<Id, Map<Id, OpportunityLineItem>>();
        for (OpportunityLineItem lineItem : [SELECT TotalPrice, Contract_Start__c, Contract_End__c, OpportunityId, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppos]) {
            if (!lineItems.containsKey(lineItem.OpportunityId)) {
                lineItems.put(lineItem.OpportunityId, new Map<Id, OpportunityLineItem>());
            }
            lineItems.get(lineItem.OpportunityId).put(lineItem.Product2Id, lineItem);
        }
        
        Map<String, ContractDrivers__c> settings = ContractDrivers__c.getAll();
        
        Map<String, Product2> products = new Map<String, Product2>();
        for (Product2 product : [SELECT Name FROM Product2 WHERE Name IN :PRODUCTS_OPPO_MAP.keySet()]) {
            products.put(product.Name, product);
        }
        
        Map<Id, SObject> schedulesOpportunities = new Map<Id, Opportunity>([
            SELECT DOC_Data_Configuration__c, DOC_Data_Licensing__c, DOC_Library_Configuration__c,
                DOC_Library_Licensing__c, Services_Percentage__c, Subscription_Percentage__c, Override_Allocations__c
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
            
            ContractDrivers__c oppoSetting = settings.get(opp.Product_Category__c);
            
            for (String productName : products.keySet()) {
                if (oppoSetting == null) {
                    break;
                }
            
                Decimal productAmount = lineItems.containsKey(opp.Id) && lineItems.get(opp.Id).containsKey(products.get(productName).Id) ?
                    lineItems.get(opp.Id).get(products.get(productName).Id).TotalPrice : 
                    opp.Amount *
                        ((Boolean) ((Opportunity) schedulesOpportunities.get(opp.Id)).Override_Allocations__c ?
                        (schedulesOpportunities.get(opp.Id).get(PRODUCTS_OPPO_MAP.get(productName)) != null ? (Decimal) schedulesOpportunities.get(opp.Id).get(PRODUCTS_OPPO_MAP.get(productName)) / 100.0 : 0) :
                        (Decimal) oppoSetting.get(PRODUCTS_MAP.get(productName)) / 100.0);

                if (productAmount == 0) {
                    continue;
                }
                
                OpportunityLineItem currentProduct = lineItems.containsKey(opp.Id) && lineItems.get(opp.Id).containsKey(products.get(productName).Id) ? 
                    lineItems.get(opp.Id).get(products.get(productName).Id) : 
                    null;
                
                Date productStartDate = currentProduct != null && currentProduct.Contract_Start__c != null ? currentProduct.Contract_Start__c : opp.Contract_Start__c;
                Date productEndDate = currentProduct != null && currentProduct.Contract_End__c != null ? currentProduct.Contract_End__c : opp.Contract_End__c;
                
                startDate = startDate > productStartDate ? productStartDate : startDate;
                endDate = endDate < productEndDate ? productEndDate : endDate;
                
                if (startDate == null || endDate == null) {
                    continue;
                }
                
                duration = startDate.monthsBetween(endDate);
            }
        
            for (Integer i = 0; i < duration; i++) {
                result.get(opp.Id).add(
                    new Monthly_Revenue_Schedule__c(
                        Id = existingMonthlyRevenues.containsKey(String.valueOf(opp.Id) + String.valueOf(startDate.addMonths(i).month()) + String.valueOf(startDate.addMonths(i).year())) ? existingMonthlyRevenues.get(String.valueOf(opp.Id) + String.valueOf(startDate.addMonths(i).month()) + String.valueOf(startDate.addMonths(i).year())).Id : null,
                        Opportunity__c = opp.Id,
                        Date__c = startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)
                    )
                );
            }
        }
        
        return result;
    }

    public static void calculateInvoices(List<Invoice__c> invoices) {
        Decimal currentAmountSum = 0.0;
        for (Invoice__c invoice : invoices) {
            currentAmountSum += invoice.Invoice_Amount__c != null ? invoice.Invoice_Amount__c : 0.0;
            invoice.Deferred_Revenue__c = currentAmountSum - (invoice.Accrued_Revenue__c != null ? invoice.Accrued_Revenue__c : 0.0);
        }
        
        isTriggerEnabled = false;
        update invoices;
        isTriggerEnabled = true;
    }
    
    public static void calculateSchedules(List<Product_Revenue_Schedule__c> scheds) {
        if (scheds.isEmpty()) {
            return;
        }
    
        List<Product_Revenue_Schedule__c> schedsToUpdate = new List<Product_Revenue_Schedule__c>();
        
        Map<Id, Map<Id, OpportunityLineItem>> lineItems = new Map<Id, Map<Id, OpportunityLineItem>>();
        for (OpportunityLineItem lineItem : [SELECT TotalPrice, Contract_Start__c, Contract_End__c, OpportunityId, Product2Id FROM OpportunityLineItem WHERE OpportunityId = :scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c]) {
            if (!lineItems.containsKey(lineItem.OpportunityId)) {
                lineItems.put(lineItem.OpportunityId, new Map<Id, OpportunityLineItem>());
            }
            lineItems.get(lineItem.OpportunityId).put(lineItem.Product2Id, lineItem);
        }
        
        List<SObject> schedulesOpportunity = [
            SELECT DOC_Data_Configuration__c, DOC_Data_Licensing__c, DOC_Library_Configuration__c,
                DOC_Library_Licensing__c, Services_Percentage__c, Subscription_Percentage__c, Override_Allocations__c
            FROM Opportunity
            WHERE Id = :scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c
        ];
        
        ContractDrivers__c oppoSetting = ContractDrivers__c.getAll().get(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c);
        
        String productName = scheds.get(0).Product__r.Name;
        Decimal productAmount = lineItems.containsKey(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c) && lineItems.get(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c).containsKey(scheds.get(0).Product__c) ?
            lineItems.get(scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c).get(scheds.get(0).Product__c).TotalPrice : 
            scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__r.Amount * 
                ((Boolean) ((Opportunity) schedulesOpportunity.get(0)).Override_Allocations__c ?
                (schedulesOpportunity.get(0).get(PRODUCTS_OPPO_MAP.get(productName)) != null ? (Decimal) schedulesOpportunity.get(0).get(PRODUCTS_OPPO_MAP.get(productName)) / 100.0 : 0) :
                (Decimal) oppoSetting.get(PRODUCTS_MAP.get(productName)) / 100.0);
        
        Decimal currentPocSum = 0;
        for (Product_Revenue_Schedule__c sched : scheds) {
            if (sched.Date__c <= Date.today() || isProductScheduleLocked(lockedDates, sched)) {
                currentPocSum += sched.POC__c;
            }
            else {
                schedsToUpdate.add(sched);
            }
        }
        
        for (Product_Revenue_Schedule__c sched : schedsToUpdate) {
            sched.POC__c = (100.0 - currentPocSum) / schedsToUpdate.size();
            sched.Revenue__c = productAmount * sched.POC__c / 100.0;
        }
        
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
        for (Date invDate : oppoSchedulesMap.keySet()) {
        
            Decimal currentMonthOppInvoiceRevenue = 0.0;
            Decimal currentMonthOppInvoiceCost = 0.0;
            Decimal currentMonthOppInvoiceGrossProfit = 0.0;
            Decimal currentMonthOppInvoiceRevenueServ = 0.0;
            Decimal currentMonthOppInvoiceRevenueSubscr = 0.0;
            for (Product_Revenue_Schedule__c schedule : oppoSchedulesMap.get(invDate)) {
                currentMonthOppInvoiceRevenue += schedule.Revenue__c;
                currentMonthOppInvoiceCost += schedule.Monthly_Revenue_Schedule__r.Costs__c;
                currentMonthOppInvoiceGrossProfit += schedule.Monthly_Revenue_Schedule__r.Gross__c;
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
        
        Map<Id, Map<Id, OpportunityLineItem>> lineItems = new Map<Id, Map<Id, OpportunityLineItem>>();
        for (OpportunityLineItem lineItem : [SELECT TotalPrice, Contract_Start__c, Contract_End__c, OpportunityId, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppIds]) {
            if (!lineItems.containsKey(lineItem.OpportunityId)) {
                lineItems.put(lineItem.OpportunityId, new Map<Id, OpportunityLineItem>());
            }
            lineItems.get(lineItem.OpportunityId).put(lineItem.Product2Id, lineItem);
        }
        
        Map<Id, SObject> schedulesOpportunities = new Map<Id, Opportunity>([
            SELECT DOC_Data_Configuration__c, DOC_Data_Licensing__c, DOC_Library_Configuration__c,
                DOC_Library_Licensing__c, Services_Percentage__c, Subscription_Percentage__c, Override_Allocations__c
            FROM Opportunity
            WHERE Id = :scheds.get(0).Monthly_Revenue_Schedule__r.Opportunity__c
        ]);
        
        for (Product_Revenue_Schedule__c sched : (List<Product_Revenue_Schedule__c>) Trigger.new) {
            ContractDrivers__c oppoSetting = ContractDrivers__c.getAll().get(scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c);
            String productName = scaledSchedules.get(sched.Id).Product__r.Name;
            
            Decimal productAmount = lineItems.containsKey(scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__c) && lineItems.get(scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__c).containsKey(sched.Product__c) ?
                lineItems.get(scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__c).get(sched.Product__c).TotalPrice : 
                scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__r.Amount *
                    ((Boolean) ((Opportunity) schedulesOpportunities.get(scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__c)).Override_Allocations__c ?
                    (schedulesOpportunities.get(scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__c).get(PRODUCTS_OPPO_MAP.get(productName)) != null ? (Decimal) schedulesOpportunities.get(scaledSchedules.get(sched.Id).Monthly_Revenue_Schedule__r.Opportunity__c).get(PRODUCTS_OPPO_MAP.get(productName)) / 100.0 : 0) :
                    (Decimal) oppoSetting.get(PRODUCTS_MAP.get(productName)) / 100.0);
                
            if (sched.POC__c != ((Product_Revenue_Schedule__c) Trigger.oldMap.get(sched.Id)).POC__c) {
                sched.Revenue__c = productAmount * sched.POC__c / 100.0;
            }
            else if (sched.Revenue__c != ((Product_Revenue_Schedule__c) Trigger.oldMap.get(sched.Id)).Revenue__c) {
                sched.POC__c = sched.Revenue__c * 100.0 / productAmount;
            }
        }
    }
    
    public static List<OpportunityLineItem> configureLineitems(List<Opportunity> oppos, List<OpportunityLineItem> existingLines) {
        if (oppos.isEmpty()) {
            return new List<OpportunityLineItem>();
        }
    
        Map<Id, Map<Id, OpportunityLineItem>> linesMap = new Map<Id, Map<Id, OpportunityLineItem>>();
        for (OpportunityLineItem existingLine : existingLines) {
            if (!linesMap.containsKey(existingLine.OpportunityId)) {
                linesMap.put(existingLine.OpportunityId, new Map<Id, OpportunityLineItem>());
            }
            linesMap.get(existingLine.OpportunityId).put(existingLine.PricebookEntryId, existingLine);
        }
    
        List<Pricebook2> pricebook = [SELECT Id FROM Pricebook2 WHERE Name = :PRICEBOOK_NAME];
        if (pricebook.isEmpty()) {
            return new List<OpportunityLineItem>();
        }
    
        Map<String, ContractDrivers__c> settings = ContractDrivers__c.getAll();
        
        Map<String, Product2> products = new Map<String, Product2>();
        for (Product2 product : [SELECT Name FROM Product2 WHERE Name IN :PRODUCTS_OPPO_MAP.keySet()]) {
            products.put(product.Name, product);
        }
        
        Map<Id, Id> productToPricebookEntry = new Map<Id, Id>();
        for (PricebookEntry entry : [SELECT Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id = :pricebook.get(0).Id]) {
            productToPricebookEntry.put(entry.Product2Id ,entry.Id);
        }
        
        Map<Id, SObject> schedulesOpportunities = new Map<Id, SObject>();
        for (SObject opp : oppos) {
            schedulesOpportunities.put((Id) opp.get('Id'), opp);
        }
        
        List<OpportunityLineItem> lineItemsResult = new List<OpportunityLineItem>();
        for (Opportunity opp : oppos) {
            if (opp.Contract_End__c == null || opp.Product_Category__c == null || opp.Contract_Start__c == null) {
                continue;
            }
            
            // if (!settings.containsKey(opp.Product_Category__c) || opp.Pricebook2Id != pricebook.get(0).Id) {
            //     continue;
            // }
            
            ContractDrivers__c oppoSetting = settings.get(opp.Product_Category__c);
            
            for (String productName : products.keySet()) {
                Decimal productAmount = opp.Amount *
                    ((Boolean) ((Opportunity) schedulesOpportunities.get(opp.Id)).Override_Allocations__c ?
                    (schedulesOpportunities.get(opp.Id).get(PRODUCTS_OPPO_MAP.get(productName)) != null ? (Decimal) schedulesOpportunities.get(opp.Id).get(PRODUCTS_OPPO_MAP.get(productName)) / 100.0 : 0) :
                    (Decimal) oppoSetting.get(PRODUCTS_MAP.get(productName)) / 100.0);
                
                /*
                 * Save zero line for deletion in master method
                 */
                // if (productAmount == 0) {
                //     continue;
                // }
                
                lineItemsResult.add(
                    new OpportunityLineItem(
                        Id = 
                            linesMap.containsKey(opp.Id) && linesMap.get(opp.Id).containsKey(productToPricebookEntry.get(products.get(productName).Id)) ?
                            linesMap.get(opp.Id).get(productToPricebookEntry.get(products.get(productName).Id)).Id : null,
                        OpportunityId = opp.Id,
                        PricebookEntryId = productToPricebookEntry.get(products.get(productName).Id),
                        Quantity = 1,
                        UnitPrice = productAmount,
                        Contract_Start__c = 
                            linesMap.containsKey(opp.Id) && linesMap.get(opp.Id).containsKey(productToPricebookEntry.get(products.get(productName).Id)) ?
                            linesMap.get(opp.Id).get(productToPricebookEntry.get(products.get(productName).Id)).Contract_Start__c : null,
                        Contract_End__c = 
                            linesMap.containsKey(opp.Id) && linesMap.get(opp.Id).containsKey(productToPricebookEntry.get(products.get(productName).Id)) ?
                            linesMap.get(opp.Id).get(productToPricebookEntry.get(products.get(productName).Id)).Contract_End__c : null
                    )
                );
            }
        }
        
        return lineItemsResult;
    }
    
    public static List<Product_Revenue_Schedule__c> configureSchedules(List<Opportunity> oppos, List<Monthly_Revenue_Schedule__c> monthlyRevenues) {
        if (oppos.isEmpty() || monthlyRevenues.isEmpty()) {
            return new List<Product_Revenue_Schedule__c>();
        }
        
        List<Product_Revenue_Schedule__c> schedulesToUpsert = new List<Product_Revenue_Schedule__c>();
    
        Map<String, ContractDrivers__c> settings = ContractDrivers__c.getAll();
        
        Map<String, Product2> products = new Map<String, Product2>();
        for (Product2 product : [SELECT Name FROM Product2 WHERE Name IN :PRODUCTS_OPPO_MAP.keySet()]) {
            products.put(product.Name, product);
        }
        
        Map<Id, Map<Id, OpportunityLineItem>> lineItems = new Map<Id, Map<Id, OpportunityLineItem>>();
        for (OpportunityLineItem lineItem : [SELECT TotalPrice, Contract_Start__c, Contract_End__c, OpportunityId, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppos]) {
            if (!lineItems.containsKey(lineItem.OpportunityId)) {
                lineItems.put(lineItem.OpportunityId, new Map<Id, OpportunityLineItem>());
            }
            lineItems.get(lineItem.OpportunityId).put(lineItem.Product2Id, lineItem);
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
            SELECT Monthly_Revenue_Schedule__r.Opportunity__c, Revenue__c, Product__r.Name , Date__c
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
            SELECT Amount, Product_Category__c, Contract_Start__c, Contract_End__c, Override_Allocations__c
            FROM Opportunity 
            WHERE Id IN :oppos]) {
            
            if (opp.Contract_End__c == null || opp.Product_Category__c == null || opp.Contract_Start__c == null) {
                continue;
            }
            
            // if (!settings.containsKey(opp.Product_Category__c)) {
            //     continue;
            // }
            
            Map<String, Decimal> lockedProductAllocations = new Map<String, Decimal>();
            Set<String> lockedDates = new Set<String>();
            if (lockedProductRevenueSchedules.containsKey(opp.Id)) {
                for (Product_Revenue_Schedule__c schedule : lockedProductRevenueSchedules.get(opp.Id)) {
                    if (!lockedProductAllocations.containsKey(schedule.Product__r.Name)) {
                        lockedProductAllocations.put(schedule.Product__r.Name, 0);
                    }
                    lockedProductAllocations.put(
                        schedule.Product__r.Name, 
                        lockedProductAllocations.get(schedule.Product__r.Name) + schedule.Revenue__c
                    );
                    lockedDates.add(String.valueOf(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1).month())
                        + String.valueOf(schedule.Date__c.addMonths(1).toStartOfMonth().addDays(-1).year()));
                }
            }
            
            ContractDrivers__c oppoSetting = settings.get(opp.Product_Category__c);
            
            for (String productName : products.keySet()) {
                Decimal productAmount = lineItems.containsKey(opp.Id) && lineItems.get(opp.Id).containsKey(products.get(productName).Id) ?
                    lineItems.get(opp.Id).get(products.get(productName).Id).TotalPrice : 
                    opp.Amount *
                        ((Boolean) ((Opportunity) schedulesOpportunities.get(opp.Id)).Override_Allocations__c ?
                        (schedulesOpportunities.get(opp.Id).get(PRODUCTS_OPPO_MAP.get(productName)) != null ? (Decimal) schedulesOpportunities.get(opp.Id).get(PRODUCTS_OPPO_MAP.get(productName)) / 100.0 : 0) :
                        (Decimal) oppoSetting.get(PRODUCTS_MAP.get(productName)) / 100.0);

                if (productAmount == 0) {
                    continue;
                }
                
                Decimal initialProductAmount = productAmount;
                
                if (lockedProductAllocations.containsKey(productName)) {
                    productAmount -= lockedProductAllocations.get(productName);
                }
                
                OpportunityLineItem currentProduct = lineItems.containsKey(opp.Id) && lineItems.get(opp.Id).containsKey(products.get(productName).Id) ? 
                    lineItems.get(opp.Id).get(products.get(productName).Id) : 
                    null;
                
                Date startDate = currentProduct != null && currentProduct.Contract_Start__c != null ? currentProduct.Contract_Start__c : opp.Contract_Start__c;
                Date endDate = currentProduct != null && currentProduct.Contract_End__c != null ? currentProduct.Contract_End__c : opp.Contract_End__c;
                Integer duration = startDate.monthsBetween(endDate);
                Integer lockedDuration = 0;
                
                for (Integer i = 0; i < duration; i++) {
                    if (!lockedDates.contains(
                        String.valueOf(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1).month())
                        + String.valueOf(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1).year()))) {
                        
                        continue;
                    }
                    lockedDuration++;
                }
                
                for (Integer i = 0; i < duration; i++) {
                    if (lockedDates.contains(
                        String.valueOf(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1).month())
                        + String.valueOf(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1).year()))) {
                        
                        continue;
                    }
                
                    schedulesToUpsert.add(
                        new Product_Revenue_Schedule__c(
                            Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)),
                            Product__c = products.get(productName).Id,
                            //Date__c = startDate.addMonths(2 + i).toStartOfMonth().addDays(-1),
                            // Date__c = startDate.addMonths(1 + i).toStartOfMonth().addDays(-1),
                            POC__c = 100.0 * (productAmount / initialProductAmount) / (duration - lockedDuration),
                            Revenue__c = 1.0 * productAmount / (duration - lockedDuration) 
                        )
                    );
                }
            }
        }
        
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
            for (Date invDate : oppoSchedulesMap.get(oppoId).keySet()) {
            
                Decimal currentMonthOppInvoiceRevenue = 0.0;
                Decimal currentMonthOppInvoiceCosts = 0.0;
                Decimal currentMonthOppInvoiceGrossProfit = 0.0;
                Decimal currentMonthOppInvoiceRevenueServ = 0.0;
                Decimal currentMonthOppInvoiceRevenueSubscr = 0.0;
                for (Product_Revenue_Schedule__c schedule : oppoSchedulesMap.get(oppoId).get(invDate)) {
                    currentMonthOppInvoiceRevenue += schedule.Revenue__c;
                    currentMonthOppInvoiceCosts += schedule.Monthly_Revenue_Schedule__r.Costs__c;
                    currentMonthOppInvoiceGrossProfit += schedule.Monthly_Revenue_Schedule__r.Gross__c;
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