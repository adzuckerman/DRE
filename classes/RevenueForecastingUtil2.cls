public with sharing class RevenueForecastingUtil2 {
    
    public static final String PRICEBOOK_NAME = 'Components';

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
            SELECT POC__c, Revenue__c, Date__c, Product__c, Product__r.Name, Monthly_Revenue_Schedule__r.Costs__c, Monthly_Revenue_Schedule__r.Gross__c, Monthly_Revenue_Schedule__r.Opportunity__c, Revenue_Type__c
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
        
        Map<Id, Opportunity> schedulesOpportunities = new Map<Id, Opportunity>([
            SELECT Id, Product_Category__c, (SELECT Product2.Revenue_Period__c FROM OpportunityLineItems)
            FROM Opportunity
            WHERE Id IN :oppos
        ]);
        
        Set<String> productNameList = new Set<String>();
        for (Opportunity oppTmp : schedulesOpportunities.values()) 
        {
            productNameList.add(OpportunityAllHandler.offeringsToProducts.containsKey(oppTmp.Product_Category__c) ? OpportunityAllHandler.offeringsToProducts.get(oppTmp.Product_Category__c) : oppTmp.Product_Category__c);
        }
        Map<String, Product2> productsMap = new Map<String, Product2>();
        for (Product2 prod : [SELECT Id, Name, Revenue_Period__c FROM Product2 WHERE Name IN :productNameList]) {
            productsMap.put(prod.Name, prod);
        }
        
        for (Opportunity opp : oppos) {
        
            if (!result.containsKey(opp.Id)) {
                result.put(opp.Id, new List<Monthly_Revenue_Schedule__c>());
            }
            
            Date startDate = opp.CloseDate;
            Integer noMonths = 0;
            if (schedulesOpportunities.get(opp.Id).OpportunityLineItems != null && schedulesOpportunities.get(opp.Id).OpportunityLineItems.size() > 0) {
	            for (OpportunityLineItem oli : schedulesOpportunities.get(opp.Id).OpportunityLineItems) {
	            	if (oli.Product2.Revenue_Period__c != null)
	            		noMonths = Math.Max(noMonths, (Integer)oli.Product2.Revenue_Period__c);
	            }
            } else {
                Opportunity oppTmp = schedulesOpportunities.get(opp.Id);
                string productName = OpportunityAllHandler.offeringsToProducts.containsKey(oppTmp.Product_Category__c) ? OpportunityAllHandler.offeringsToProducts.get(oppTmp.Product_Category__c) : oppTmp.Product_Category__c;
                if (productsMap.containsKey(productName) && productsMap.get(productName).Revenue_Period__c != null)
            		noMonths = (integer)productsMap.get(productName).Revenue_Period__c;
            }
            Date endDate = opp.CloseDate.addMonths(noMonths);
            Integer duration = startDate != null && endDate != null ? startDate.monthsBetween(endDate) : 0;
        
            for (Integer i = 0; i <= duration; i++) {
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
        System.debug(monthlyOppoDateIdMap);
        
        Set<String> productNameList = new Set<String>();
        for (sObject oppTmpS : schedulesOpportunities.values()) 
        {
            Opportunity oppTmp = (Opportunity)oppTmpS;
            productNameList.add(OpportunityAllHandler.offeringsToProducts.containsKey(oppTmp.Product_Category__c) ? OpportunityAllHandler.offeringsToProducts.get(oppTmp.Product_Category__c) : oppTmp.Product_Category__c);
        }
        Map<String, Product2> productsMap = new Map<String, Product2>();
        for (Product2 prod : [SELECT Id, Name, Revenue_Period__c, Subscription__c, Services__c FROM Product2 WHERE Name IN :productNameList]) {
            productsMap.put(prod.Name, prod);
        }
        
        for (Opportunity opp : [
            SELECT CloseDate, Amount, Product_Category__c,
            		(SELECT Product2.Revenue_Period__c, Product2Id, TotalPrice, Product2.Subscription__c, Product2.Services__c FROM OpportunityLineItems)
            FROM Opportunity 
            WHERE Id IN :oppos]) {
            
            Date startDate = opp.CloseDate;
            Integer noMonths = 0;
            if (opp.OpportunityLineItems != null && opp.OpportunityLineItems.size() > 0) {
	            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
	            	if (oli.Product2.Revenue_Period__c != null)
	            		noMonths = Math.Max(noMonths, (Integer)oli.Product2.Revenue_Period__c);
	            }
            } else {
                string productName = OpportunityAllHandler.offeringsToProducts.containsKey(opp.Product_Category__c) ? OpportunityAllHandler.offeringsToProducts.get(opp.Product_Category__c) : opp.Product_Category__c;
                if (productsMap.containsKey(productName) && productsMap.get(productName).Revenue_Period__c != null)
            		noMonths = (integer)productsMap.get(productName).Revenue_Period__c;
            }
            Date endDate = opp.CloseDate.addMonths(noMonths);
            // -1 because revenues whould start from 2nd month, first one is empty
            Integer duration = startDate != null && endDate != null ? startDate.monthsBetween(endDate) : 0; 
            
            Id subscriptionId = [SELECT Id FROM Product2 WHERE Name = 'Subscription'].Id;
        	Id serviceId = [SELECT Id FROM Product2 WHERE Name = 'Services'].Id;
        
            if (opp.OpportunityLineItems != null && opp.OpportunityLineItems.size() > 0) {
            	// If we have products, we use the new algorithm
	            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                    integer xduration = oli.Product2.Revenue_Period__c != null ? (integer)oli.Product2.Revenue_Period__c : duration;
	            	if (oli.Product2.Subscription__c != null && oli.Product2.Subscription__c > 0) {
			            //first month empty schedule
			            schedulesToUpsert.add(
			                new Product_Revenue_Schedule__c(
			                    In_Forecast__c = true,
			                    Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1).toStartOfMonth().addDays(-1)),
			                    Product__c = oli.Product2Id,
			                    POC__c = 0,
			                    Revenue__c = 0,
			                    Revenue_Category__c = 'Subscription'
			                ) 
			            );
			            for (Integer i = 1; i <= xduration; i++) {
			                if (oli.Product2.Subscription__c != null && oli.Product2.Subscription__c != 0) {
			                    schedulesToUpsert.add(
			                        new Product_Revenue_Schedule__c(
			                            In_Forecast__c = true,
			                            Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)),
			                            Product__c = oli.Product2Id,
			                            POC__c = 100.0 * oli.TotalPrice * (oli.Product2.Subscription__c / 100) / xduration / (oli.TotalPrice * (oli.Product2.Subscription__c / 100)),
			                            Revenue__c = 1.0 * oli.TotalPrice * (oli.Product2.Subscription__c / 100) / xduration,
			                    		Revenue_Category__c = 'Subscription'
			                        )
			                    );
			                }
			            }
	            	}
		            if (oli.Product2.Services__c != null && oli.Product2.Services__c > 0) {
			            //first month empty schedule
				        schedulesToUpsert.add(
			                new Product_Revenue_Schedule__c(
			                    In_Forecast__c = true,
			                    Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1).toStartOfMonth().addDays(-1)),
			                    Product__c = oli.Product2Id,
			                    POC__c = 0,
			                    Revenue__c = 0,
			                    Revenue_Category__c = 'Services'
			                )
			            );
			            for (Integer i = 1; i <= xduration; i++) {
			                if (oli.Product2.Services__c != null && oli.Product2.Services__c != 0) {
			                    schedulesToUpsert.add(
			                        new Product_Revenue_Schedule__c(
			                            In_Forecast__c = true,
			                            Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)),
			                            Product__c = oli.Product2Id,
			                            POC__c = 100.0 * oli.TotalPrice * (oli.Product2.Services__c / 100) / xduration / (oli.TotalPrice * (oli.Product2.Services__c / 100)),
			                            Revenue__c = 1.0 * oli.TotalPrice * (oli.Product2.Services__c / 100) / xduration,
			                    		Revenue_Category__c = 'Services'
			                        )
			                    );
			                }
			            }
		            }
		        }
            } else {
            	// If we don't have products
            	string productName = OpportunityAllHandler.offeringsToProducts.containsKey(opp.Product_Category__c) ? OpportunityAllHandler.offeringsToProducts.get(opp.Product_Category__c) : opp.Product_Category__c;
                Product2 productToUse = null;
                if (productsMap.containsKey(productName))
            		productToUse = productsMap.get(productName);
                
	            schedulesToUpsert.add(
	                new Product_Revenue_Schedule__c(
	                    In_Forecast__c = true,
	                    Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1).toStartOfMonth().addDays(-1)),
	                    Product__c = subscriptionId,
	                    POC__c = 0,
	                    Revenue__c = 0,
			            Revenue_Category__c = 'Subscription'
	                )
	            );
	            schedulesToUpsert.add(
	                new Product_Revenue_Schedule__c(
	                    In_Forecast__c = true,
	                    Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1).toStartOfMonth().addDays(-1)),
	                    Product__c = serviceId,
	                    POC__c = 0,
	                    Revenue__c = 0,
			            Revenue_Category__c = 'Services'
	                )
	            );
	            
	            for (Integer i = 1; i < duration + 1; i++) {
	                if (productToUse.Subscription__c != null && productToUse.Subscription__c != 0) {
	                    schedulesToUpsert.add(
	                        new Product_Revenue_Schedule__c(
	                            In_Forecast__c = true,
	                            Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)),
	                            Product__c = subscriptionId,
	                            POC__c = opp.Amount == 0 ? 0 : (100.0 * opp.Amount * (productToUse.Subscription__c / 100) / duration / (opp.Amount * (productToUse.Subscription__c / 100))),
	                            Revenue__c = opp.Amount == 0 ? 0 : (1.0 * opp.Amount * (productToUse.Subscription__c / 100) / duration),
			            		Revenue_Category__c = 'Subscription'
	                        )
	                    );
	                }
	                if (productToUse.Services__c != null && productToUse.Services__c != 0) {
	                    schedulesToUpsert.add(
	                        new Product_Revenue_Schedule__c(
	                            In_Forecast__c = true,
	                            Monthly_Revenue_Schedule__c = monthlyOppoDateIdMap.get(opp.Id).get(startDate.addMonths(1 + i).toStartOfMonth().addDays(-1)),
	                            Product__c = serviceId,
	                            POC__c = opp.Amount == 0 ? 0 : (100.0 * opp.Amount * (productToUse.Services__c / 100) / duration / (opp.Amount * (productToUse.Services__c / 100))),
	                            Revenue__c = opp.Amount == 0 ? 0 : (1.0 * opp.Amount * (productToUse.Services__c / 100) / duration),
			            		Revenue_Category__c = 'Services'
	                        )
	                    );
	                }
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
        
        List<Net_Accounts_Receivable_Months__mdt> accReceivable = [
            SELECT Months__c
            FROM Net_Accounts_Receivable_Months__mdt
            LIMIT 1
        ];
        
        List<OpportunityLineItem> allOlis = [SELECT OpportunityId, TotalPrice, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppoSchedulesMap.keyset()];
        
        Set<Id> productIds = new Set<Id>();
        for (OpportunityLineItem oli : allOlis) {
        	productIds.add(oli.Product2Id);
        }
        
        // Build a map : ProductId -> Month -> Percent
        Map<Id, Map<Integer, Decimal>> percentMap = new Map<Id, Map<Integer, Decimal>>();
        for (Booking_Months__c bm : [SELECT Month__c, Invoice_Percent__c, Customer_Product__c FROM Booking_Months__c WHERE Customer_Product__c IN : productIds]) {
        	if (!percentMap.containsKey(bm.Customer_Product__c)) {
        		percentMap.put(bm.Customer_Product__c, new Map<Integer, Decimal>());
        	}
        	percentMap.get(bm.Customer_Product__c).put((integer)bm.Month__c, bm.Invoice_Percent__c);
        }
         
        // Build a map : Opportunity Id -> Product Id -> Month -> Amount
        Map<Id, Map<Id, Map<Integer, Decimal>>> pricesMap = new Map<Id, Map<Id, Map<Integer, Decimal>>>();
        for (OpportunityLineItem oli : allOlis) {
        	if (!pricesMap.containsKey(oli.OpportunityId)) {
        		pricesMap.put(oli.OpportunityId, new Map<Id, Map<Integer, Decimal>>());
        	} 
        	if (!pricesMap.get(oli.OpportunityId).containsKey(oli.Product2Id)) {
        		pricesMap.get(oli.OpportunityId).put(oli.Product2Id, new Map<Integer, Decimal>());
        	} 
        	if (percentMap.containsKey(oli.Product2Id)) {
        		for (Integer month : percentMap.get(oli.Product2Id).keyset()) {
        			if (!pricesMap.get(oli.OpportunityId).get(oli.Product2Id).containsKey(month)) {
		        		pricesMap.get(oli.OpportunityId).get(oli.Product2Id).put(month, 0);
		        	}
		        	pricesMap.get(oli.OpportunityId).get(oli.Product2Id).put(
		        			month, 
		        			pricesMap.get(oli.OpportunityId).get(oli.Product2Id).get(month) + oli.TotalPrice * percentMap.get(oli.Product2Id).get(month) / 100);
        		}
        	}
        }
        System.debug(pricesMap);
        
        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Id oppoId : oppoSchedulesMap.keySet()) {
        
            Decimal currentOppCumulativeRevenue = 0.0;
            Decimal currentOppCumulativeCost = 0.0;
            Decimal currentOppCumulativeGrossProfit = 0.0;
            Decimal currentOppCumulativeInvoices = 0.0;
            Decimal currentOppInvoiceDefRevenue = 0.0;
            Decimal currentOppInvoiceAccruedRevenue = 0.0;
            
            Integer bookingMonthNumber = 0;
            
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
                Decimal currentMonthOppInvoiceCost = 0.0;
                Decimal currentMonthOppInvoiceGrossProfit = 0.0;
                Decimal currentMonthOppInvoiceRevenueServ = 0.0;
                Decimal currentMonthOppInvoiceRevenueSubscr = 0.0;
                Decimal totalAmount = 0.0;
                Set<Id> productsSet = new Set<Id>();
                for (Product_Revenue_Schedule__c schedule : oppoSchedulesMap.get(oppoId).get(invDate)) {
                        currentMonthOppInvoiceRevenue += schedule.Revenue__c;
                        currentMonthOppInvoiceCost = schedule.Monthly_Revenue_Schedule__r.Costs__c;
                        currentMonthOppInvoiceGrossProfit = schedule.Monthly_Revenue_Schedule__r.Gross__c;
                        currentMonthOppInvoiceRevenueServ += schedule.Revenue_Type__c == ContractInformationCtrl.SERVICES ? schedule.Revenue__c : 0;
                        currentMonthOppInvoiceRevenueSubscr += schedule.Revenue_Type__c == ContractInformationCtrl.SUBSCRIPTION ? schedule.Revenue__c : 0;
                        
                    if (!productsSet.contains(schedule.Product__c)) {
                        productsSet.add(schedule.Product__c);
                        if (pricesMap.containsKey(oppoId)) {
                            if (pricesMap.get(oppoId).containsKey(schedule.Product__c)) {
                                if (pricesMap.get(oppoId).get(schedule.Product__c).containsKey(bookingMonthNumber)) {
                                    totalAmount += pricesMap.get(oppoId).get(schedule.Product__c).get(bookingMonthNumber);
                                }
                            }
                        }
                    }
                }
                
                Invoice__c invoiceToAdd = new Invoice__c(
                    In_Forecast__c = true,
                    Opportunity__c = oppoId,
                    Invoice_Date__c = invDate.addMonths(1).toStartOfMonth().addDays(-1)
                );
                    
                invoiceToAdd.Invoice_Amount__c = totalAmount;
                
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