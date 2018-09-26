/*   Name:          Revenue Forecasting Utility
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          2/21/2018
 *   Description:   Utility to forecast revenue schedules, invoices, accrued and deferred revenue.
 *                
 *   Updates:
 *      2/23/2018 - Serge Kochanovsky - Deployed class and created custom settings
 *      3/05/2018 - Adam Zuckerman    - Added one month to revenue recognition and allocations
 *      3/14/2018 - Adam Zuckerman    - Added duration + 1 to for loop to add PRS to last MRS
 *      4/09/2018 - Mirela Chituc     - Added calculation on invoices for Cumulative_Cost_of_Revenue__c and 
 *                                      Cumulative_Gross_Profit__c
 */

public with sharing class RevenueForecastingUtil {

    public static final String PRICEBOOK_NAME = 'Components';

    public static final Map<String, String> PRODUCTS_MAP = new Map<String, String> {
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
    
    public static Boolean isTriggerEnabled = true;
    
    public static void forecastOpportunity(List<Opportunity> oppos) {
        List<Product_Revenue_Schedule__c> existingSchedules = [
            SELECT In_Forecast__c, Date__c
            FROM Product_Revenue_Schedule__c 
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c IN :oppos
        ];
        
        List<Invoice__c> existingInvoices = [
            SELECT In_Forecast__c, Invoice_Num__c, Invoice_Amount__c, Invoice_Date__c, Actual_Invoice_Date__c, Opportunity__c, Milestone_Description__c
            FROM Invoice__c
            WHERE Opportunity__c IN :oppos
        ];
        
        isTriggerEnabled = false;
        delete existingSchedules;
        delete existingInvoices;
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
            SELECT POC__c, Revenue__c, Date__c, Product__c, Product__r.Name, Monthly_Revenue_Schedule__r.Costs__c, Monthly_Revenue_Schedule__r.Gross__c, Monthly_Revenue_Schedule__r.Opportunity__r.Amount, Monthly_Revenue_Schedule__r.Opportunity__r.Product_Category__c, Monthly_Revenue_Schedule__r.Opportunity__c, Revenue_Type__c
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
            SELECT Opportunity__c, Date__c
            FROM Monthly_Revenue_Schedule__c
            WHERE Opportunity__c IN :oppos
        ]) {
            
            existingMonthlyRevenues.put(String.valueOf(revenue.Opportunity__c) + String.valueOf(revenue.Date__c.month()) + String.valueOf(revenue.Date__c.year()), revenue);
        }
    
        Map<Id, List<Monthly_Revenue_Schedule__c>> result = new Map<Id, List<Monthly_Revenue_Schedule__c>>();
        
        Map<Id, SObject> schedulesOpportunities = new Map<Id, Opportunity>([
            SELECT Product_Category__c
            FROM Opportunity
            WHERE Id IN :oppos
        ]);
        
        Map<String, Forecasting_Revenue_Recognition__c> forecastingSettings = Forecasting_Revenue_Recognition__c.getAll();
        
        for (Opportunity opp : oppos) {
        
            if (!result.containsKey(opp.Id)) {
                result.put(opp.Id, new List<Monthly_Revenue_Schedule__c>());
            }
            
            Date startDate = opp.CloseDate;
            Date endDate = opp.CloseDate.addMonths(
                Integer.valueOf(forecastingSettings.get(opp.Product_Category__c).Contract_Length__c) + 1
            );
            Integer duration = startDate != null && endDate != null ? startDate.monthsBetween(endDate) : 0;
        
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
    
    public static List<Product_Revenue_Schedule__c> configureSchedules(List<Opportunity> oppos, List<Monthly_Revenue_Schedule__c> monthlyRevenues) {
        if (oppos.isEmpty() || monthlyRevenues.isEmpty()) {
            return new List<Product_Revenue_Schedule__c>();
        }
        
        List<Product_Revenue_Schedule__c> schedulesToUpsert = [
            SELECT Monthly_Revenue_Schedule__r.Opportunity__c, Revenue__c, Product__r.Name , Date__c
            FROM Product_Revenue_Schedule__c
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c IN :oppos
        ];
    
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
            monthlyOppoDateIdMap.get(monthlyRevenue.Opportunity__c).put(monthlyRevenue.Date__c.addMonths(1).toStartOfMonth().addDays(-1), monthlyRevenue.Id);
        }
        
        Map<String, Forecasting_Revenue_Recognition__c> forecastingSettings = Forecasting_Revenue_Recognition__c.getAll();
        Map<String, Forecasting_Offering_Allocation__c> allocationSettings = Forecasting_Offering_Allocation__c.getAll();
        
        Id subscriptionId = [SELECT Id FROM Product2 WHERE Name = 'Subscription'].Id;
        Id serviceId = [SELECT Id FROM Product2 WHERE Name = 'Services'].Id;
        
        for (Opportunity opp : [
            SELECT Product_Category__c, Amount, CloseDate
            FROM Opportunity 
            WHERE Id IN :oppos]) {
            
            if (opp.Product_Category__c == null || opp.Amount == 0) {
                continue;
            }

            Forecasting_Offering_Allocation__c oppoSetting = allocationSettings.get(opp.Product_Category__c);

            Date startDate = opp.CloseDate;
            Date endDate = opp.CloseDate.addMonths(
                Integer.valueOf(forecastingSettings.get(opp.Product_Category__c).Contract_Length__c) + 1
            );
            // -1 because revenues whould start from 2nd month, first one is empty
            Integer duration = startDate != null && endDate != null ? startDate.monthsBetween(endDate) - 1 : 0;
            
            //first month empty schedule
            schedulesToUpsert.add(
                new Product_Revenue_Schedule__c(
                    In_Forecast__c = true,
                    Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1).toStartOfMonth().addDays(-1)),
                    Product__c = subscriptionId,
                    POC__c = 0,
                    Revenue__c = 0
                )
            );
            schedulesToUpsert.add(
                new Product_Revenue_Schedule__c(
                    In_Forecast__c = true,
                    Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1).toStartOfMonth().addDays(-1)),
                    Product__c = serviceId,
                    POC__c = 0,
                    Revenue__c = 0
                )
            );
            
            for (Integer i = 1; i < duration + 1; i++) {
                if (oppoSetting.Subscription__c != null && oppoSetting.Subscription__c != 0) {
                    schedulesToUpsert.add(
                        new Product_Revenue_Schedule__c(
                            In_Forecast__c = true,
                            Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)),
                            Product__c = subscriptionId,
                            POC__c = 100.0 * opp.Amount * (oppoSetting.Subscription__c / 100) / duration / (opp.Amount * (oppoSetting.Subscription__c / 100)),
                            Revenue__c = 1.0 * opp.Amount * (oppoSetting.Subscription__c / 100) / duration 
                        )
                    );
                }
                if (oppoSetting.Services__c != null && oppoSetting.Services__c != 0) {
                    schedulesToUpsert.add(
                        new Product_Revenue_Schedule__c(
                            In_Forecast__c = true,
                            Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)),
                            Product__c = serviceId,
                            POC__c = 100.0 * opp.Amount * (oppoSetting.Services__c / 100) / duration / (opp.Amount * (oppoSetting.Services__c / 100)),
                            Revenue__c = 1.0 * opp.Amount * (oppoSetting.Services__c / 100) / duration 
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
                // invoice.Invoice_Date__c.toStartOfMonth().addDays(-1),
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
        
        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([
            SELECT Product_Category__c, Amount
            FROM Opportunity
            WHERE Id IN :oppoSchedulesMap.keySet()
        ]);
        
        Map<String, Forecasting_Invoicing_Schedule__c> invoicingSettings = Forecasting_Invoicing_Schedule__c.getAll();
        
        List<Net_Accounts_Receivable_Months__mdt> accReceivable = [
            SELECT Months__c
            FROM Net_Accounts_Receivable_Months__mdt
            LIMIT 1
        ];
        
        Set<String> flds = Forecasting_Invoicing_Schedule__c.sObjectType.getDescribe().fields.getMap().keySet();
        
        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Id oppoId : oppoSchedulesMap.keySet()) {
            Forecasting_Invoicing_Schedule__c oppoSetting = invoicingSettings.get(opportunitiesMap.get(oppoId).Product_Category__c);
        
            Decimal currentOppCumulativeRevenue = 0.0;
            Decimal currentOppCumulativeCost = 0.0;
            Decimal currentOppCumulativeGrossProfit = 0.0;
            Decimal currentOppCumulativeInvoices = 0.0;
            Decimal currentOppInvoiceDefRevenue = 0.0;
            Decimal currentOppInvoiceAccruedRevenue = 0.0;
            
            Integer bookingMonthNumber = 0;
            
            for (Date invDate : oppoSchedulesMap.get(oppoId).keySet()) {
                     
                Decimal currentMonthOppInvoiceRevenue = 0.0;
                Decimal currentMonthOppInvoiceCost = 0.0;
                Decimal currentMonthOppInvoiceGrossProfit = 0.0;
                Decimal currentMonthOppInvoiceRevenueServ = 0.0;
                Decimal currentMonthOppInvoiceRevenueSubscr = 0.0;
                for (Product_Revenue_Schedule__c schedule : oppoSchedulesMap.get(oppoId).get(invDate)) {
                    currentMonthOppInvoiceRevenue += schedule.Revenue__c;
                    currentMonthOppInvoiceCost += schedule.Monthly_Revenue_Schedule__r.Costs__c;
                    currentMonthOppInvoiceGrossProfit += schedule.Monthly_Revenue_Schedule__r.Gross__c;
                    currentMonthOppInvoiceRevenueServ += schedule.Revenue_Type__c == ContractInformationCtrl.SERVICES ? schedule.Revenue__c : 0;
                    currentMonthOppInvoiceRevenueSubscr += schedule.Revenue_Type__c == ContractInformationCtrl.SUBSCRIPTION ? schedule.Revenue__c : 0;
                }
                
                Invoice__c invoiceToAdd = new Invoice__c(
                    In_Forecast__c = true,
                    Opportunity__c = oppoId,
                    Invoice_Date__c = invDate.addMonths(1).toStartOfMonth().addDays(-1)
                );
                    
                if (flds.contains('booking_month_' + String.ValueOf(bookingMonthNumber) + '__c')) {
                    Decimal bookingMonthPercent = (Decimal)oppoSetting.get('booking_month_' + String.ValueOf(bookingMonthNumber) + '__c');
                    if(bookingMonthPercent != null) {
                        invoiceToAdd.Invoice_Amount__c = opportunitiesMap.get(oppoId).Amount * bookingMonthPercent / 100;
                    }
                }
                
                if (invoiceMap.containsKey(oppoId) && invoiceMap.get(oppoId).containsKey(invDate)) {
                    // invoiceToAdd.Id = invoiceMap.get(oppoId).get(invDate).Id;
                    
                    if (invoiceMap.get(oppoId).get(invDate).In_Forecast__c && invoiceMap.get(oppoId).get(invDate).Invoice_Amount__c != null) {
                        // currentOppInvoiceDefRevenue += invoiceMap.get(oppoId).get(invDate).Invoice_Amount__c;
                        invoiceToAdd.Milestone_Description__c = invoiceMap.get(oppoId).get(invDate).Milestone_Description__c;
                        invoiceToAdd.Actual_Invoice_Date__c = invoiceMap.get(oppoId).get(invDate).Actual_Invoice_Date__c;
                        invoiceToAdd.Invoice_Num__c = invoiceMap.get(oppoId).get(invDate).Invoice_Num__c;
                        
                        // currentOppCumulativeInvoices += invoiceMap.get(oppoId).get(invDate).Invoice_Amount__c;
                    }
                }
                
                if (invoiceToAdd.Invoice_Amount__c != null) {
                    currentOppInvoiceDefRevenue += invoiceToAdd.Invoice_Amount__c;
                    currentOppCumulativeInvoices += invoiceToAdd.Invoice_Amount__c;
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
                
                /*Net Accounts Receivable*/
                if (!accReceivable.isEmpty()) {
                    invoiceToAdd.Net_Accounts_Receivable__c = invoiceToAdd.Invoice_Amount__c != null ? invoiceToAdd.Invoice_Amount__c : 0;
                    for (Integer i = invoices.size() - Integer.valueOf(accReceivable[0].Months__c) + 1; i >= 0 && i < invoices.size(); i++) {
                        invoiceToAdd.Net_Accounts_Receivable__c += invoices[i].Invoice_Amount__c != null ? invoices[i].Invoice_Amount__c : 0;
                    }
                }
                
                invoices.add(
                    invoiceToAdd
                );
                
                bookingMonthNumber++;
            }
        }
        
        return invoices;
    }

}