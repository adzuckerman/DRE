/*   Name:          Project_Completion_Batch
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          5/2/2018
 *   Description:   Batch Class to Manage date-based notifications for Projects and Sub-Projects
 *   Test Class:	Project_Completion_Batch_Test             
 */

global class Project_Completion_Batch implements Database.Batchable<TASKRAY__Project__c > {

    private Set<Id> projIdSet = new Set<Id>(); //projectIdList to limit testing to certain projects
    private static final string ARCHIVED_REASON = 'Contract Expired';
    
    global Project_Completion_Batch(){
    }
    
    global Project_Completion_Batch(Set<Id> testProjectIdSet){
        if(testProjectIdSet != NULL)
	        projIdSet = testProjectIdSet;
    }
    
	global List<TASKRAY__Project__c > start(Database.BatchableContext BC) {
        string idSetFilter = (!projIdSet.isEmpty()) ? 'ID IN:projIdSet' : '';
        string days_14_from_now = string.valueof(date.today().adddays(14));
        string query = 'SELECT TASKRAY__trOpportunity__r.Contract_End__c, TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__r.Contract_End__c, Contract_Archive_14_Days__c,Contract_Archive_1_Days__c,TASKRAY__Project_Parent__c,TASKRAY__Status__c,Archived_Date__c,Archived_Reason__c ' +
                'FROM TASKRAY__Project__c WHERE (( (TASKRAY__trOpportunity__c != NULL AND TASKRAY__trOpportunity__r.Contract_End__c = ' + days_14_from_now + ') OR (TASKRAY__Project_Parent__c != NULL AND TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__r.Contract_End__c = ' + days_14_from_now + ')) AND TASKRAY__Status__c = FALSE AND Contract_Archive_14_Days__c = FALSE)' + 
                'OR (( (TASKRAY__trOpportunity__c != NULL AND TASKRAY__trOpportunity__r.Contract_End__c = YESTERDAY) OR (TASKRAY__Project_Parent__c != NULL AND TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__r.Contract_End__c = YESTERDAY)) AND TASKRAY__Status__c = FALSE AND Contract_Archive_1_Days__c = FALSE) ' + idSetFilter;
        system.debug(query);
        return database.query(query);
        /*
		return [SELECT TASKRAY__trOpportunity__r.Contract_End__c, TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__r.Contract_End__c, Contract_Archive_14_Days__c,Contract_Archive_1_Days__c,TASKRAY__Project_Parent__c 
                FROM TASKRAY__Project__c WHERE (( (TASKRAY__trOpportunity__c != NULL AND TASKRAY__trOpportunity__r.Contract_End__c = NEXT_N_DAYS:14) OR (TASKRAY__Project_Parent__c != NULL AND TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__r.Contract_End__c = NEXT_N_DAYS:14)) AND TASKRAY__Status__c = FALSE AND Contract_Archive_14_Days__c = FALSE) 
                OR (( (TASKRAY__trOpportunity__c != NULL AND TASKRAY__trOpportunity__r.Contract_End__c = YESTERDAY) OR (TASKRAY__Project_Parent__c != NULL AND TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__r.Contract_End__c = YESTERDAY)) AND TASKRAY__Status__c = TRUE AND Contract_Archive_1_Days__c = FALSE)];*/
    }

    global void execute(Database.BatchableContext BC, List<TASKRAY__Project__c > projectsList) {
		List<TASKRAY__Project__c> projectsToUpdate = new List<TASKRAY__Project__c>();
        for(TASKRAY__Project__c proj: projectsList){
            //project logic
            if(proj.TASKRAY__Project_Parent__c == NULL){
                //14 days in future logic
                if(proj.TASKRAY__trOpportunity__r.Contract_End__c == date.today().addDays(14) && proj.Contract_Archive_14_Days__c == FALSE){
                    proj.Contract_Archive_14_Days__c = TRUE;
                    projectsToUpdate.add(proj);
                }//1 day ago logic
                else if(proj.TASKRAY__trOpportunity__r.Contract_End__c < date.today() && proj.Contract_Archive_1_Days__c == FALSE){
					proj.Contract_Archive_1_Days__c = TRUE;
                    //archive project logic
                    proj.TASKRAY__Status__c = TRUE;
                    proj.Archived_Date__c = proj.TASKRAY__trOpportunity__r.Contract_End__c;
                    proj.Archived_Reason__c = ARCHIVED_REASON;
                    projectsToUpdate.add(proj);                    
                }                                    
            }//sub-project logic
            else if(proj.TASKRAY__Project_Parent__c != NULL){
                //14 days in future logic
                if(proj.TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__r.Contract_End__c == date.today().addDays(14) && proj.Contract_Archive_14_Days__c == FALSE){
                    proj.Contract_Archive_14_Days__c = TRUE;
                    projectsToUpdate.add(proj);                    
                }//1 day ago logic
                else if(proj.TASKRAY__Project_Parent__r.TASKRAY__trOpportunity__r.Contract_End__c < date.today() && proj.Contract_Archive_1_Days__c == FALSE){
					proj.Contract_Archive_1_Days__c = TRUE;
                    //archive project logic
                    proj.TASKRAY__Status__c = TRUE;
                    proj.Archived_Date__c = proj.TASKRAY__trOpportunity__r.Contract_End__c;
                    proj.Archived_Reason__c = ARCHIVED_REASON;        
                    projectsToUpdate.add(proj);                    
                }            
            }            
        }
        system.debug('projectsListToUpdate---' + projectsToUpdate);
        update projectsToUpdate;
    }

    global void finish(Database.BatchableContext BC) {

    }    
    
}