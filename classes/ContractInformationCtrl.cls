/*   Name:          ContractInformationCtrl
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          8/31/2017
 *   Description:   Controller for ContractInformation page quering Opportunity records and related Invoice records
 */

public with sharing class ContractInformationCtrl {

    public static final String SERVICES = 'Services Revenue';
    public static final String SUBSCRIPTION = 'Subscription Revenue';

    public Date startMonth {get; set;}
    public Date endMonth {get; set;}
    
    public List<OpportunityWrapper> opportunityList {get; private set;}
    public List<InvoicePriorWrapper> invoicePriorList {get; private set;}
    public List<InvoiceMonthWrapper> invoiceMonthList {get; private set;}
    public Integer currentYear {get; private set;}
    public String excelVersionUrl {get; private set;}
    
    private Map<Id, Opportunity> opportunityById;
    private Map<Id, List<Invoice__c>> invoicesByOppId;

    public ContractInformationCtrl() {
        this.currentYear = Date.today().year();
        getInvoicesByMonths();
    }

    public void getInvoicesByMonths() {
        if (ApexPages.currentPage().getParameters().containsKey('start') & ApexPages.currentPage().getParameters().containsKey('end')) {
            List<String> startParams = ApexPages.currentPage().getParameters().get('start').split('-');
            List<String> endParams = ApexPages.currentPage().getParameters().get('end').split('-');
            
            if (startParams.size() == 2 && endParams.size() == 2) {
                this.startMonth = Date.newInstance(Integer.valueOf(startParams.get(1)), Integer.valueOf(startParams.get(0)), 1);
                this.endMonth = Date.newInstance(Integer.valueOf(endParams.get(1)), Integer.valueOf(endParams.get(0)), 1);
            }
        }
    
        if(startMonth == null) {
            startMonth = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        } else {
            startMonth = startMonth.addMonths(1).toStartOfMonth().addDays(-1);
        }

        if(endMonth == null) {
            endMonth = startMonth.addMonths(3).toStartOfMonth().addDays(-1);
        } else {
            endMonth = endMonth.addMonths(1).toStartOfMonth().addDays(-1);            
        }

        if(startMonth > endMonth) {
            endMonth = startMonth.addMonths(3).addDays(-1);
        }
        
        this.excelVersionUrl = Page.ContractInformationExcel.getUrl() 
            + '?start=' + startMonth.month() + '-' + startMonth.year() 
            + '&end=' + endMonth.month() + '-' + endMonth.year();
        
        opportunityById = new Map<Id, Opportunity> ([
            SELECT Contract_ID__c, AccountId, Account.Name, Name, Product_Category__c, Therapeutic_Area__c, Amount, CloseDate, Contract_Start__c, Contract_End__c
            FROM Opportunity
            WHERE Id IN (SELECT Opportunity__c FROM Invoice__c WHERE Enforce_Date__c = true OR (Opportunity__r.Contract_Start__c <= :endMonth AND Opportunity__r.Contract_End__c >= :startMonth) OR (Invoice_Date__c >= :startMonth AND Invoice_Date__c <= :endMonth AND (Accrued_Revenue_Formula__c != 0 OR Deferred_Revenue_Formula__c != 0 OR Monthly_Revenue__c !=0)))
            LIMIT 1000
        ]);

        List<Invoice__c> invoices = [
            SELECT Invoice_Amount__c, Accrued_Revenue_Formula__c, Deferred_Revenue_Formula__c, Invoice_Date__c, Opportunity__c, Enforce_Date__c, Monthly_Revenue__c, Monthly_Revenue_Services__c, Monthly_Revenue_Subscription__c
            FROM Invoice__c
            WHERE Opportunity__c in :opportunityById.keySet()
            ORDER BY Invoice_Date__c
            LIMIT 50000
        ];

        invoicesByOppId = new Map<Id, List<Invoice__c>>();      
        for (Invoice__c invoice : invoices) {
            if (invoicesByOppId.containsKey(invoice.Opportunity__c)) {
                invoicesByOppId.get(invoice.Opportunity__c).add(invoice);
            } else {
                invoicesByOppId.put(invoice.Opportunity__c, new List<Invoice__c> {invoice});
            }
        }

        getOpportunityWrapperList();
        getInvoicePriorWrapperList();
        getInvoiceNextWrapperLists();
    }

    private void getOpportunityWrapperList() {
        opportunityList = new List<OpportunityWrapper>();

        for (Id oppId : opportunityById.keySet()) {
            Decimal totalRevenueToDate;
            Decimal totalRevenueToDateServices;
            Decimal totalRevenueToDateSubscription;

            if (invoicesByOppId.containsKey(oppId)) {
                for (Invoice__c invoice : invoicesByOppId.get(oppId)) {
                    if (invoice.Invoice_Date__c <= Date.today() && invoice.Monthly_Revenue__c != null) {
                        totalRevenueToDate = totalRevenueToDate != null ? 
                            totalRevenueToDate + invoice.Monthly_Revenue__c : invoice.Monthly_Revenue__c;
                            
                        totalRevenueToDateServices = totalRevenueToDateServices != null ? 
                            totalRevenueToDateServices + invoice.Monthly_Revenue_Services__c : invoice.Monthly_Revenue_Services__c;
                        totalRevenueToDateSubscription = totalRevenueToDateSubscription != null ? 
                            totalRevenueToDateSubscription + invoice.Monthly_Revenue_Subscription__c : invoice.Monthly_Revenue_Subscription__c;
                    }
                }
            }

            Opportunity opp = opportunityById.get(oppId);
            OpportunityWrapper opportunityElement = new OpportunityWrapper();
            opportunityElement.contractId = opp.Contract_ID__c;
            opportunityElement.accountName = opp.Account.Name;
            opportunityElement.opportunityName = opp.Name;
            opportunityElement.offering = opp.Product_Category__c;
            opportunityElement.therapeuticArea = opp.Therapeutic_Area__c;
            opportunityElement.contractAmount = opp.Amount;
            opportunityElement.totalContractRev = totalRevenueToDate;
            opportunityElement.totalContractRevServ = totalRevenueToDateServices;
            opportunityElement.totalContractRevSubscr = totalRevenueToDateSubscription;
// -------------------------------------------------------------------- add cost field
            opportunityElement.totalContractCost = null;
            opportunityElement.contractBacklogRevenue = totalRevenueToDate == null ? opp.Amount : opp.Amount - totalRevenueToDate;
            opportunityElement.closeYear = opp.CloseDate.year();
            opportunityElement.accountId = opp.AccountId;
            opportunityElement.opportunityId = opp.Id;

            opportunityList.add(opportunityElement);
        }
    }

    private void getInvoicePriorWrapperList() {
        invoicePriorList = new List<InvoicePriorWrapper>();

        for (Id oppId : opportunityById.keySet()) {
// -------------------------------------------------------------------- add cost fields
            Decimal costPriorCurrentYear;
            Decimal costCurrentYear;
            Decimal revenuePriorCurrentYear;
            Decimal revenueCurrentYear;
            Decimal revenueCurrentYearSubscr;
            Decimal revenueCurrentYearServ;

            if (invoicesByOppId.containsKey(oppId)) {
                for (Invoice__c invoice : invoicesByOppId.get(oppId)) {
                    if (invoice.Monthly_Revenue__c != null) {
                        if (invoice.Invoice_Date__c.year() < currentYear) {
                            if (revenuePriorCurrentYear == null) {
                                revenuePriorCurrentYear = invoice.Monthly_Revenue__c;
                            } else {
                                revenuePriorCurrentYear += invoice.Monthly_Revenue__c;
                            }
                        }
                        else if (invoice.Invoice_Date__c.year() == currentYear) {
                            revenueCurrentYear = revenueCurrentYear != null ? 
                                revenueCurrentYear + invoice.Monthly_Revenue__c : invoice.Monthly_Revenue__c;
                            revenueCurrentYearSubscr = revenueCurrentYearSubscr != null ? 
                                revenueCurrentYearSubscr + invoice.Monthly_Revenue_Subscription__c : invoice.Monthly_Revenue_Subscription__c;
                            revenueCurrentYearServ = revenueCurrentYearServ != null ? 
                                revenueCurrentYearServ + invoice.Monthly_Revenue_Services__c : invoice.Monthly_Revenue_Services__c;
                        }
                    }
                }
            }

            invoicePriorList.add(new InvoicePriorWrapper(costPriorCurrentYear, costCurrentYear, revenuePriorCurrentYear, revenueCurrentYearSubscr, revenueCurrentYearServ, revenueCurrentYear));
        }
    }

    private void getInvoiceNextWrapperLists() {
        List<List<InvoiceWrapper>> invoiceList = new List<List<InvoiceWrapper>>();
        Integer monthsCount = startMonth.monthsBetween(endMonth) + 1;

        for (Integer i = 0; i < monthsCount; i++) {
            invoiceList.add(new List<InvoiceWrapper>());
        }

        for (Id oppId : opportunityById.keySet()) {
            List<Decimal> revenueSubscr = new List<Decimal>();
            List<Decimal> revenueServ = new List<Decimal>();
            List<Decimal> revenue = new List<Decimal>();
            List<Decimal> expense = new List<Decimal>();
            List<Decimal> accruesRev = new List<Decimal>();
            List<Decimal> defRev = new List<Decimal>();
            for (Integer i = 0; i < monthsCount; i++) {
                revenueSubscr.add(null);
                revenueServ.add(null);
                revenue.add(null);
                expense.add(null);
                accruesRev.add(null);
                defRev.add(null);
            }

            if (invoicesByOppId.containsKey(oppId)) {
                for (Invoice__c invoice : invoicesByOppId.get(oppId)) {
                    for (Integer i = 0; i < monthsCount; i++) {
                        if (startMonth.addMonths(i).year() == invoice.Invoice_Date__c.year() && startMonth.addMonths(i).month() == invoice.Invoice_Date__c.month()) {
                            revenueSubscr[i] = invoice.Monthly_Revenue_Subscription__c;
                            revenueServ[i] = invoice.Monthly_Revenue_Services__c;
                            revenue[i] = invoice.Monthly_Revenue__c;
// -------------------------------------------------------------------- add expense field
                            expense[i] = null;
                            accruesRev[i] = invoice.Accrued_Revenue_Formula__c;
                            defRev[i] = invoice.Deferred_Revenue_Formula__c;
                        }
                    }
                }
            }

            for (Integer i = 0; i < monthsCount; i++) {
                invoiceList[i].add(new InvoiceWrapper(revenueSubscr[i], revenueServ[i], revenue[i], expense[i], accruesRev[i], defRev[i]));
            }
        }

        Map<Integer, String> monthNames = new Map<Integer, String> {
            1 => 'January',
            2 => 'February',
            3 => 'March',
            4 => 'April',
            5 => 'May',
            6 => 'June',
            7 => 'July',
            8 => 'August',
            9 => 'September',
            10 => 'October',
            11 => 'November',
            12 => 'December'
        };

        List<String> followingMonthes = new List<String>();
        List<String> followingDates = new List<String>();
        for (Integer i = 0; i < monthsCount; i++) {
            Date nextMonth = startMonth.addMonths(i);
            followingMonthes.add(monthNames.get(nextMonth.month()) + ' - ' + nextMonth.year());
            followingDates.add(nextMonth.month() + '/' + Date.daysInMonth(nextMonth.year(), nextMonth.month()) + '/' + nextMonth.year());
        }

        invoiceMonthList = new List<InvoiceMonthWrapper> ();
        for (Integer i = 0; i < monthsCount; i++) {
            invoiceMonthList.add(new InvoiceMonthWrapper(invoiceList[i], followingMonthes[i], followingDates[i]));   
        }
    }

    private class OpportunityWrapper {
        public String contractId {get; set;}
        public String accountName {get; set;}
        public String opportunityName {get; set;}
        public String offering {get; set;}
        public String therapeuticArea {get; set;}
        public Decimal contractAmount {get; set;}
        public Decimal totalContractRev {get; set;}
        public Decimal totalContractRevServ {get; set;}
        public Decimal totalContractRevSubscr {get; set;}
        public Decimal totalContractCost {get; set;}
        public Decimal contractBacklogRevenue {get; set;}
        public Integer closeYear {get; set;}
        
        public Id accountId {get; set;}
        public Id opportunityId {get; set;}
    }

    private class InvoicePriorWrapper {
        public Decimal costPriorCurrentYear {get; set;}
        public Decimal costCurrentYear {get; set;}
        public Decimal revenuePriorCurrentYear {get; set;}
        public Decimal revenueCurrentYearSubscr {get; set;}
        public Decimal revenueCurrentYearServ {get; set;}
        public Decimal revenueCurrentYear {get; set;}

        public InvoicePriorWrapper(Decimal costPriorCurrentYear, Decimal costCurrentYear, Decimal revenuePriorCurrentYear, Decimal revenueCurrentYearSubscr, Decimal revenueCurrentYearServ, Decimal revenueCurrentYear) {
            this.costPriorCurrentYear = costPriorCurrentYear;
            this.costCurrentYear = costCurrentYear;
            this.revenuePriorCurrentYear = revenuePriorCurrentYear;
            this.revenueCurrentYear = revenueCurrentYear;
            this.revenueCurrentYearSubscr = revenueCurrentYearSubscr;
            this.revenueCurrentYearServ = revenueCurrentYearServ;
        }
    }

    private class InvoiceMonthWrapper {
        public List<InvoiceWrapper> invoice {get; set;}
        public String headerMonth {get; set;}
        public String headerDate {get; set;}

        public InvoiceMonthWrapper(List<InvoiceWrapper> invoice, String headerMonth, String headerDate) {
            this.invoice = invoice;
            this.headerMonth = headerMonth;
            this.headerDate = headerDate;
        }
    }

    private class InvoiceWrapper {
        public Decimal revenueSubscr {get; set;}
        public Decimal revenueServ {get; set;}
        public Decimal revenue {get; set;}
        public Decimal expense {get; set;}
        public Decimal accruesRev {get; set;}
        public Decimal defRev {get; set;}

        public InvoiceWrapper(Decimal revenueSubscr, Decimal revenueServ, Decimal revenue, Decimal expense, Decimal accruesRev, Decimal defRev) {
            this.revenueSubscr = revenueSubscr;
            this.revenueServ = revenueServ;
            this.revenue = revenue;
            this.expense = expense;
            this.accruesRev = accruesRev;
            this.defRev = defRev;
        }
    }
}