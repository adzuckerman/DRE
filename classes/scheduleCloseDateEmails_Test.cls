@isTest
private class scheduleCloseDateEmails_Test {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   static String CRON_EXP;

	  @isTest static void test() {
      CRON_EXP = '0 0 0 15 3 ? 2022';
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new scheduleCloseDateEmails());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      string query = 'SELECT Id, Name, CloseDate, Owner.Email, isClosed FROM Opportunity WHERE isClosed = FALSE AND CloseDate <= ' + string.valueOf(date.today().addDays(7));
      List<Opportunity> oppsACD = new List<Opportunity> ([SELECT Id, Name, CloseDate, Owner.Email, isClosed 
                                FROM Opportunity 
                                WHERE isClosed = FALSE 
                                AND CloseDate <= :date.today().addDays(7)]);
      System.assertEquals(oppsACD.size(),0);
      Test.stopTest();
   }
}