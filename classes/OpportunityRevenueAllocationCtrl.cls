/*   Name:          OpportunityRevenueCostSectionCtrl
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          11/2/2017
 *   Description:   Controller for OpportunityRevenueAllocationCtrl page quering related allocated revenue records
 *
 *   Updates:
 *      01/15/2018 - Serge Kochanovsky - Added locking system for scheduled records.
 */
public with sharing class OpportunityRevenueAllocationCtrl {

    public List<LineWrapper> schedulesList { get; set; }
    public List<String> tableDates { get; private set; }
    public Boolean isForecasted { get; private set; }
    private String opportunityId;
    
    
    
    public Map<Id, Boolean> lockedSchedules {
        get {
            Map<Id, Boolean> result = new Map<Id, Boolean>();
            List<RevenueCalculationUtil.LockDateWrapper> lockedDates = RevenueCalculationUtil.lockedDates;
            system.debug('lockedDates---' + lockedDates);
            for (LineWrapper lw : schedulesList) {
                List<Product_Revenue_Schedule__c> scheduleList = lw.schedules;
                for (Product_Revenue_Schedule__c schedule : scheduleList) {
                    result.put(schedule.Id, false);
                    for (RevenueCalculationUtil.LockDateWrapper lockedDate : lockedDates) {
                        if (lockedDate.lockType == 'Revenue') {
                            Boolean inRange = (lockedDate.startDate != null && lockedDate.endDate != null && schedule.Date__c >= lockedDate.startDate && schedule.Date__c <= lockedDate.endDate)
                                || (lockedDate.startDate != null && lockedDate.endDate == null && schedule.Date__c >= lockedDate.startDate)
                                || (lockedDate.startDate == null && lockedDate.endDate != null && schedule.Date__c <= lockedDate.endDate);
                            
                            if (inRange) {
                                result.put(schedule.Id, true);
                            }
                        }
                    }
                }
            }
            system.debug('result---' + result);
            return result;
        }
        private set;
    }

    public OpportunityRevenueAllocationCtrl(ApexPages.StandardController controller) {
        opportunityId = controller.getRecord().Id;
        
        Opportunity opportunity = [
            SELECT IsClosed, In_Forecast__c
            FROM Opportunity
            WHERE Id = :opportunityId
        ];
        this.isForecasted = opportunity.In_Forecast__c;
        
        loadSchedules();
    }

    private void loadSchedules() {
        
        List<Product_Revenue_Schedule__c> schedules = [
            SELECT Id, POC__c, Revenue__c, Date__c, Product__r.Name, Revenue_Category__c, Product__r.Services__c, Product__r.Subscription__c, Monthly_Revenue_Schedule__r.Opportunity__r.Unlock_Future_Revenue__c
            FROM Product_Revenue_Schedule__c
            WHERE Monthly_Revenue_Schedule__r.Opportunity__c = :opportunityId
            ORDER BY Product__r.Name, Date__c
        ];
        
        Date startDate;
        Date endDate;

        Map<String, Map<Date, Product_Revenue_Schedule__c>> schedulesMap = new Map<String, Map<Date, Product_Revenue_Schedule__c>>();

        for (Product_Revenue_Schedule__c schedule : schedules) {
            if (!schedulesMap.containsKey(schedule.Product__r.Name + '~' + schedule.Revenue_Category__c)) {
                schedulesMap.put(schedule.Product__r.Name + '~' + schedule.Revenue_Category__c, new Map<Date, Product_Revenue_Schedule__c>());
            } 
            schedulesMap.get(schedule.Product__r.Name + '~' + schedule.Revenue_Category__c).put(schedule.Date__c, schedule);
            
            startDate = (startDate == null || startDate > schedule.Date__c) ? schedule.Date__c : startDate;
            endDate = (endDate == null || endDate < schedule.Date__c) ? schedule.Date__c : endDate;
        }
        
        for (String productName : schedulesMap.keySet()) {
            Product_Revenue_Schedule__c clone = schedulesMap.get(productName).values().get(0).clone();
            clone.Id = null;
            clone.POC__c = null;
            clone.Revenue__c = null;
        
            for (Integer i = 1; i <= startDate.monthsBetween(endDate) + 1; i++) {
                Date iterDate = startDate.addMonths(i).toStartOfMonth().addDays(-1);
                // clone.Date__c = iterDate;
            
                if (!schedulesMap.get(productName).containsKey(iterDate)) {
                    schedulesMap.get(productName).put(iterDate, clone);
                }
            }
        }

        schedulesList = new List<LineWrapper>();
        tableDates = new List<String>();

        for (String product : schedulesMap.keySet()) {
            List<Product_Revenue_Schedule__c> schedulesByProduct = new List<Product_Revenue_Schedule__c>();
            Boolean getDates = tableDates.isEmpty();

            List<Date> dates = new List<Date>(schedulesMap.get(product).keySet());
            dates.sort();
            
            for (Date scheduleDate : dates) {
                schedulesByProduct.add(schedulesMap.get(product).get(scheduleDate));

                if (getDates) {
                    tableDates.add(scheduleDate.format());
                }
            }

            schedulesList.add(new LineWrapper(schedulesByProduct));
        }
    }

    public void updateSchedule() {
        String scheduleId = ApexPages.currentPage().getParameters().get('scheduleId');
        String schedulePoc = ApexPages.currentPage().getParameters().get('schedulePoc');
        String scheduleRevenue = ApexPages.currentPage().getParameters().get('scheduleRevenue');

        if (String.isNotEmpty(scheduleId) && String.isNotEmpty(schedulePoc) && String.isNotEmpty(scheduleRevenue)) {

            Product_Revenue_Schedule__c schedule = new Product_Revenue_Schedule__c(
                Id = scheduleId,
                POC__c = Decimal.valueOf(schedulePoc),
                Revenue__c = Decimal.valueOf(scheduleRevenue)
            );
            
            try {
                update schedule;
            } 
            catch (DmlException ex) {
                System.debug(ex);
            }
            system.debug('schedule----' + schedule);

            loadSchedules();
        }
    }
    
    public class LineWrapper {
        public List<Product_Revenue_Schedule__c> schedules { get; set; }
        public String Name {
            get {
                if (schedules == null || schedules.size() == 0)
                    return '';
                string toReturn = schedules[0].Product__r.Name;
                if (schedules[0].Product__r.Services__c > 0 && schedules[0].Product__r.Services__c < 100 && schedules[0].Revenue_Category__c == 'Services')
                    toReturn += ' (svc)';
                if (schedules[0].Product__r.Subscription__c > 0 && schedules[0].Product__r.Subscription__c < 100 && schedules[0].Revenue_Category__c == 'Subscription')
                    toReturn += ' (sub)';
                return toReturn;
            }
        }
        
        public LineWrapper(List<Product_Revenue_Schedule__c> schedules) {
            this.schedules = schedules;
        }
    }
}