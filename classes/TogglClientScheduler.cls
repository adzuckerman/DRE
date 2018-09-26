/********************************************************************************************************
*    Name:  TogglClientScheduler.cls
*    Author:  
*    Date:  9/5/2018
*    
*    Batch class: TogglClientBatch.cls
*    Test class: TogglClientBatchTest.cls
********************************************************************************************************/

global class TogglClientScheduler implements Schedulable {
   
   global void execute(SchedulableContext sc) {
      
      TogglClientBatch d = new TogglClientBatch(); 
      database.executebatch(d);
   
   }
}