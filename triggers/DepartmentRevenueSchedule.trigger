/*   Name:          Revenue Calculation Test Class
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          11/30/2017
 *   Description:   Trigger for Department Revenue Calculation.
 *                
 */

trigger DepartmentRevenueSchedule on Department_Revenue_Schedule__c (before insert) {

    if (Trigger.isInsert && Trigger.isBefore) {
        Map<Id, Map<String, Id>> mts = new Map<Id, Map<String, Id>>();
        for (Monthly_Revenue_Schedule__c rev : [SELECT Opportunity__c, Date__c FROM Monthly_Revenue_Schedule__c]) {
            if (!mts.containsKey(rev.Opportunity__c)) {
                mts.put(rev.Opportunity__c, new Map<String, Id>());
            }
            mts.get(rev.Opportunity__c).put('' + rev.Date__c.month() + rev.Date__c.year(), rev.Id);
        }
        
        for (Department_Revenue_Schedule__c sch : Trigger.new) {
            if (sch.Import_Date__c == null || !mts.containsKey(sch.Opportunity__c) || !mts.get(sch.Opportunity__c).containsKey('' + sch.Import_Date__c.month() + sch.Import_Date__c.year())) {
                continue;
            }
            sch.Monthly_Revenue_Schedule__c = mts.get(sch.Opportunity__c).get('' + sch.Import_Date__c.month() + sch.Import_Date__c.year());
        }
        
        Map<String, Monthly_Revenue_Schedule__c> mrsToCreate = new Map<String, Monthly_Revenue_Schedule__c>();
        for (Department_Revenue_Schedule__c sch : Trigger.new) {
            if (sch.Import_Date__c != null && sch.Monthly_Revenue_Schedule__c == null) {
                mrsToCreate.put('' + sch.Opportunity__c + sch.Import_Date__c.month() + sch.Import_Date__c.year(), new Monthly_Revenue_Schedule__c(Opportunity__c = sch.Opportunity__c, Date__c = sch.Import_Date__c));
            }
        }
        
        if (mrsToCreate.values().isEmpty()) {
            return;
        }
        
        insert mrsToCreate.values(); 
        
        mts = new Map<Id, Map<String, Id>>();
        for (Monthly_Revenue_Schedule__c rev : [SELECT Opportunity__c, Date__c FROM Monthly_Revenue_Schedule__c]) {
            if (!mts.containsKey(rev.Opportunity__c)) {
                mts.put(rev.Opportunity__c, new Map<String, Id>());
            }
            mts.get(rev.Opportunity__c).put('' + rev.Date__c.month() + rev.Date__c.year(), rev.Id);
        }
        
        for (Department_Revenue_Schedule__c sch : Trigger.new) {
            sch.Monthly_Revenue_Schedule__c = mts.get(sch.Opportunity__c).get('' + sch.Import_Date__c.month() + sch.Import_Date__c.year());
        }
    }

}