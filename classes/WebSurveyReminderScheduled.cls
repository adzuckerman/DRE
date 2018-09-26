/********************************************************************************************************
*    Name:  WebSurveyReminderScheduler.cls
*    Author:  
*    Date:  8/20/2018
*    
*    Batch class: WebSurveyReminderBatch.cls
*    Test class: WebSurveyReminderBatchTest.cls
********************************************************************************************************/

global class WebSurveyReminderScheduled implements Schedulable {
   
   global void execute(SchedulableContext sc) {
      
      WebSurveyReminderBatch b = new WebSurveyReminderBatch(); 
      database.executebatch(b, 1);
   
   }
}