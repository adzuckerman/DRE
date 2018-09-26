/*   Name:          Schedule Close Date Emails
 *   Developer:     Adam Zuckerman - CLOUD MINE CONSULTING
 *   Date:          February 2017
 *   Description:   Schedule batch of email notification for Opportunities approaching close date.									
 * 
 * 	 Updates:               
 */

global class scheduleCloseDateEmails implements Schedulable {
    global void execute (SchedulableContext SC) {
        approachingCloseDate ACD = new approachingCloseDate();
        database.executeBatch(ACD, 200);
    }	
}