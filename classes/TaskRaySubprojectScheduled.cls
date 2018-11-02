/********************************************************************************************************
*    Name:  TaskRaySubprojectScheduled.cls
*    Author:  
*    Date:  6/12/2018
*    
*    Batch class: TaskRaySubprojectBatch.cls
*    Test class: TaskRaySubprojectBatchTest.cls
********************************************************************************************************/

global class TaskRaySubprojectScheduled implements Schedulable {
   
   global void execute(SchedulableContext sc) {
      
      TaskRaySubprojectBatch b = new TaskRaySubprojectBatch(); 
      database.executebatch(b);
   
   }
}