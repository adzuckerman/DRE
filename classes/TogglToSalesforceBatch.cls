/*   Name:          TogglToSalesforceBatch
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          4/23/2018
 *   Description:   Batch class to make Toggl callout
 *                
 */

global with sharing class TogglToSalesforceBatch implements Database.Batchable<String>, Database.AllowsCallouts {

    global List<String> start(Database.BatchableContext BC) {
        TogglToSalesforce api = new TogglToSalesforce();
        Integer cnt = api.getTimeEntryCount();
        List<String> pages = new List<String>();
        for(Integer i = 1; i <= (cnt / 50) + 1; i++) {
            pages.add(String.valueOf(i));
        }
        return pages;
    }

    global void execute(Database.BatchableContext BC, List<String> pages) {
        TogglToSalesforce api = new TogglToSalesforce();
        for(String page : pages) {
            api.getTimeEntriesLast45Days(Integer.valueOf(page));
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}