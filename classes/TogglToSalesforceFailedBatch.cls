global with sharing class TogglToSalesforceFailedBatch  implements Database.Batchable<String>, Database.AllowsCallouts{

    global List<String> start(Database.BatchableContext BC) {
        List<Toggl_Custom_Log__c> customLogs = [SELECT Id, URL__c FROM Toggl_Custom_Log__c];
        List<String> pages = new List<String>();
        for(Toggl_Custom_Log__c customLog : customLogs) {
            pages.add(customLog.URL__c);
        }
        return pages;
    }

    global void execute(Database.BatchableContext BC, List<String> pages) {
        TogglToSalesforce api = new TogglToSalesforce();
        for(String page : pages) {
            api.getFailedTimeEntry(page);
        }
    }

    global void finish(Database.BatchableContext BC) {
        List<ToggleAccount__mdt> dayMdt = [SELECT Delete_Logs_After_Days__c FROM ToggleAccount__mdt];
        List<Toggl_Custom_Log__c> oldCustomLogs = [SELECT Id FROM Toggl_Custom_Log__c WHERE CreatedDate < :Datetime.now().addDays(-Integer.valueOf(dayMdt[0].Delete_Logs_After_Days__c))];
        delete oldCustomLogs;
    }
}