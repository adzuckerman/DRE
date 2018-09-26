/********************************************************************************************************
*    Name:  WebSurveyReminderBatch.cls
*    Author:  
*    Date:  8/20/2018
*    
*    Scheduler class: WebSurveyReminderScheduler.cls
*    Test class: WebSurveyReminderBatchTest.cls
********************************************************************************************************/

global class WebSurveyReminderBatch implements Database.Batchable <SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
    
        Date aWeekAgo = (Date.today()).addDays(-7);
        Date twoWeekAgo = (Date.today()).addDays(-14);
        Date threeWeekAgo = (Date.today()).addDays(-21);
        Date fourWeekAgo = (Date.today()).addDays(-28);
        String Query='SELECT Id, Client_Feedback_Requested_Date__c FROM TASKRAY__Project__c WHERE ' 
           + ' Client_Feedback_Requested__c = true AND ((Client_Feedback_Requested_Date__c =: aWeekAgo )  OR ' + 
           + '  (Client_Feedback_Requested_Date__c =: twoWeekAgo ) OR ' + 
           + '  (Client_Feedback_Requested_Date__c =: threeWeekAgo ) OR ' + 
           + '  (Client_Feedback_Requested_Date__c =: fourWeekAgo )) ';
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<TASKRAY__Project__c> scope)
    {
        
        List<Project_Request__c> allProjectsRequests = [SELECT Id, TaskRay_Project__c, Requester_Contact__c, 
                    Requester_Contact__r.AccountId FROM Project_Request__c WHERE TaskRay_Project__c IN: scope];
        List<RME_Value_Framework_Email_Settings__mdt> RMEValueFramework = [SELECT Template_Unique_Name__c FROM RME_Value_Framework_Email_Settings__mdt WHERE Label = 'Web Survey Reminder' LIMIT 1];
        if( RMEValueFramework.size() == 1 )
        {
            String templateUniqueName = RMEValueFramework[0].Template_Unique_Name__c; 
            List<EmailTemplate> emailtemplateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: templateUniqueName ];
            
            for( Project_Request__c pr: allProjectsRequests )
            {
                if(pr.Requester_Contact__c != null && emailtemplateList.size() > 0)
                { 
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
                    mail.setSenderDisplayName('Test Response to Client Request');         
                    mail.setTargetObjectId(pr.Requester_Contact__c);
                    mail.setWhatId(pr.Id);
                    mail.setTemplateId(emailtemplateList[0].Id);
                    if(!Test.isRunningTest())
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                }
            }
        }
        
    }

    global void finish(Database.BatchableContext bc)
    {
        
    }
}