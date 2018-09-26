/*   Name:          OpportunityRevenueCostSectionCtrl
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          11/2/2017
 *   Description:   Controller for OpportunityRevenueCostSectionCtrl page quering related departmnet revenue records
 *
 *   Updates:
 *      01/15/2018 - Serge Kochanovsky - Added locking system for scheduled records.
 */
public with sharing class OpportunityRevenueCostSectionCtrl {

    public Map<String, Map<String, Department_Revenue_Schedule__c>> revenuesMap { get; private set; }
    public List<Monthly_Revenue_Schedule__c> revenues { get; private set; }
    
    public Map<Id, Boolean> lockedSchedules {
        get {
            Map<Id, Boolean> result = new Map<Id, Boolean>();
            List<RevenueCalculationUtil.LockDateWrapper> lockedDates = RevenueCalculationUtil.lockedDates;
            for (Monthly_Revenue_Schedule__c schedule : revenues) {
                for (RevenueCalculationUtil.LockDateWrapper lockedDate : lockedDates) {
                    if (lockedDate.lockType != 'Costs') {
                        result.put(schedule.Id, false);
                        continue;
                    }
                    Boolean inRange = (lockedDate.startDate != null && lockedDate.endDate != null && schedule.Date__c >= lockedDate.startDate && schedule.Date__c <= lockedDate.endDate)
                        || (lockedDate.startDate != null && lockedDate.endDate == null && schedule.Date__c >= lockedDate.startDate)
                        || (lockedDate.startDate == null && lockedDate.endDate != null && schedule.Date__c <= lockedDate.endDate);
                        
                    if (!result.containsKey(schedule.Id) || !result.get(schedule.Id)) {
                        result.put(schedule.Id, inRange);
                    }
                }
            }
            return result;
        }
        private set;
    }
    
    String opportunityId { get; set; }

    public OpportunityRevenueCostSectionCtrl(ApexPages.StandardController controller) {
        opportunityId = controller.getRecord().Id;
        
        this.revenues = [
            SELECT Revenue__c, Costs__c, Gross__c, Date__c,
                (
                    SELECT Department__r.Name, Costs__c, Monthly_Revenue_Schedule__c
                    FROM Department_Revenue_Schedules__r
                    ORDER BY Department__r.Name
                )
            FROM Monthly_Revenue_Schedule__c
            WHERE Opportunity__c = :opportunityId
            ORDER BY Date__c ASC
        ];
        
        for (Monthly_Revenue_Schedule__c revenue : this.revenues) {
            revenue.Date__c = revenue.Date__c.addMonths(1).toStartofMonth().addDays(-1);
        }
        
        Map<String, Id> depMap = new Map<String, Id>();
        for (Department__c dep : [SELECT Name FROM Department__c]) {
            depMap.put(dep.Name, dep.Id);
        }
        
        List<String> depList = new List<String>(depMap.keySet());
        depList.sort();
        
        this.revenuesMap = new Map<String, Map<String, Department_Revenue_Schedule__c>>();
        for (String depName : depList) {
            if (!this.revenuesMap.containsKey(depName)) {
                this.revenuesMap.put(depName, new Map<String, Department_Revenue_Schedule__c>());
            }
            for (Monthly_Revenue_Schedule__c rev : this.revenues) {
                this.revenuesMap.get(depName).put(String.valueOf(rev.Date__c), new Department_Revenue_Schedule__c(Opportunity__c = opportunityId, Monthly_Revenue_Schedule__c = rev.Id, Department__c = depMap.get(depName)));
                for (Department_Revenue_Schedule__c depRev : rev.Department_Revenue_Schedules__r) {
                    if (depRev.Department__r.Name != depName) {
                        continue;
                    }
                    this.revenuesMap.get(depName).put(String.valueOf(rev.Date__c), depRev);
                }
            }
        }
    }
    
    public void updateDepartmentCost() {
        String nameDate = ApexPages.currentPage().getParameters().get('departmentCostId');
        String cost = ApexPages.currentPage().getParameters().get('departmentCostValue');

        if (String.isEmpty(nameDate) || String.isEmpty(cost)) {
            return;
        }

        Department_Revenue_Schedule__c depSchedule = this.revenuesMap.get(nameDate.split('-:-')[0]).get(nameDate.split('-:-')[1]);
        depSchedule.Costs__c = Decimal.valueOf(cost);
        
        try {
            upsert depSchedule;
            revenuesMap.get(nameDate.split('-:-')[0]).put(nameDate.split('-:-')[1], depSchedule);
        } 
        catch (DmlException ex) {
            System.debug(ex);
        }
    }

}