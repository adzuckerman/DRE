/*   Name:          Schedule_Project_Completion_Batch
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          5/18/2018
 *   Description:   Schedulable Class to schedule Project Project_Completion_Batch
 *   Test Class:	Project_Completion_Batch_Test             
 */
global class Schedule_Project_Completion_Batch implements Schedulable {

    global void execute(SchedulableContext sc){
		Project_Completion_Batch batch = new Project_Completion_Batch();
		database.executeBatch(batch);        
    }
    
}