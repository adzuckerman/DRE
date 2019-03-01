/*   Name:          TogglToSalesforceBatch
 *   Developer:     OMNIVO DIGITAL (www.omnivodigital.com)
 *   Date:          4/23/2018
 *   Description:   Batch class to make Toggl callout
 *                
 */

global with sharing class TogglToSalesforceBatch implements Database.Batchable<String>, Database.AllowsCallouts {

    //Get number of days to get Toggl Time Entries from custom metadata.
    //List<ToggleAccount__mdt> dayMdt = [SELECT Days__c FROM ToggleAccount__mdt];
    //global Integer days = Integer.valueOf(dayMdt[0].Days__c);
    global Integer days; 
    global Date untilDate; 
    global Date sinceDate; 
    
    public TogglToSalesforceBatch(Integer noOfDays, Date uDate, Date sDate) {
        days = noOfDays;
        untilDate = uDate;
        sinceDate = sDate;
    }
        
    global List<String> start(Database.BatchableContext BC) {
        TogglToSalesforce api = new TogglToSalesforce();
        System.debug('days====>'+days);
        Integer cnt = api.getTimeEntryCount(days, untilDate, sinceDate);
        List<String> pages = new List<String>();
        for(Integer i = 1; i <= (cnt / 50) + 1; i++) {
            pages.add(String.valueOf(i));
        }
        return pages;
    }

    global void execute(Database.BatchableContext BC, List<String> pages) {
        TogglToSalesforce api = new TogglToSalesforce();
        for(String page : pages) {
            api.getTimeEntriesLastNDays(Integer.valueOf(page), days);
        }
    }

    global void finish(Database.BatchableContext BC) {
        Integer logCount = [SELECT COUNT() FROM Toggl_Custom_Log__c];
        if (logCount > 0) {
            TogglToSalesforceFailedBatch batch = new TogglToSalesforceFailedBatch();
            Database.executeBatch(batch, 2);
        }
    }

}