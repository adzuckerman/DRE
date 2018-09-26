/********************************************************************************************************
*    Scheduled class: ProcessInstanceStepScheduler.cls
*    Author:  
*    Date:  6/8/2017
*    
*    Batch class: ProcessInstanceStepBatch.cls
*    Test class:  ProcessInstanceStepBatchTest.cls
********************************************************************************************************/

global class ProcessInstanceStepScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      ProcessInstanceStepBatch process = new ProcessInstanceStepBatch();
      Database.executeBatch(process, 10);
   }
}