public class AddUsersToProjectTeamHelper {
    
	
    public AddUsersToProjectTeamHelper(){}
    
    public static void updateProjectTaskTeam(List<TASKRAY__Project__c> oldProjects, List<TASKRAY__Project__c> newProjects)
    {
        List<Id> projectIds = new List<Id>();
        for(TASKRAY__Project__c pr : newProjects)
        {
           projectIds.add(pr.Id);
        }
        
        List<TASKRAY__trContributor__c> teamMembers = [SELECT Id, TASKRAY__Project__c, TASKRAY__User__c FROM TASKRAY__trContributor__c WHERE TASKRAY__Project__c IN :projectIds];
                
        Set<Id> NewteamMembersIds = new Set<Id>();
		List<TASKRAY__trContributor__c> TeamMemberListToUpdate = new List<TASKRAY__trContributor__c>();
        Set<Id> teamMemberIds = new Set<Id>();
        
    	for (TASKRAY__trContributor__c member : teamMembers)
    		{
        		teamMemberIds.add(member.TASKRAY__User__c);
    		}
        
		//start of the loop
        Schema.SObjectType objType = newProjects.getSObjectType(); 
    
        Map<String, Schema.SObjectField> M = Schema.SObjectType.TASKRAY__Project__c.fields.getMap();
        
        for(integer i =0; i< newProjects.size() ; i++)
        {
             
            for (String str : M.keyset())
                {	 
                    try 
                        {	 
                            if(newProjects[i].get(str) != oldProjects[i].get(str) && newProjects[i].get(str) !=null )
                              {
                                system.debug('******The value has changed!!!! ' + str + ' ' + M.get(str).getDescribe().getLabel() ); 
                                TASKRAY__trContributor__c teamMember = new TASKRAY__trContributor__c();
                                teamMember.TASKRAY__User__c = (Id)newProjects[i].get(str); //Value of the Field//
                                System.debug('The user is ' + teamMember.TASKRAY__User__c);
                                teamMember.TASKRAY__Project__c = newProjects[i].Id;
                                System.debug('The project is is ' + teamMember.TASKRAY__Project__c);
                                 
                                  if(!teamMemberIds.contains(teamMember.TASKRAY__User__c) && !NewteamMembersIds.contains(teamMember.TASKRAY__User__c) )
                                    {
                                        System.debug('The user to be added ' + teamMember.TASKRAY__User__c);
                                        NewteamMembersIds.add(teamMember.TASKRAY__User__c);
                                        TeamMemberListToUpdate.add(teamMember);
                                    } 
                              } 
                        } 
                
                    catch (Exception e) 
                        { 
                            System.debug('Error: ' + e); 
                        }
                }      
             //End Of the loop   
                
			}
        
    	try {
                	System.debug('The list is: ' + TeamMemberListToUpdate);
    				insert TeamMemberListToUpdate;
        	}
        catch(Exception e)
            {
            		System.debug('Error: ' + e);
        	}
    }
    
   public static void insertProjectCreateTaskTeam(List<TASKRAY__Project__c> newProjects)
    {
        TASKRAY__Project__c newProject = newProjects[0];
        Set<Id> NewteamMembersIds = new Set<Id>();
		List<TASKRAY__trContributor__c> TeamMemberListToUpdate = new List<TASKRAY__trContributor__c>();
        
        //Setup the list of roles
        Set<String> roles = new Set<String>{
           	'client_services_rep__c', 'consulting_services_lead__c', 'consulting_services_rep__c', 
            'associate_dir_library_operations__c', 'librarian_lead__c', 'operations_associate__c', 'gh_qmi__c',
            'meth_rep_1__c', 'meth_rep_2__c', 'extraction_tl__c', 'head_of_analytics__c',
            'vp_client_services__c', 'principal_scientist__c','vp_consulting_services__c', 'cmo__c', 'data_integrity_tl__c',
                'ontology_lead__c','ontology_manager__c','head_of_clinical_operations_and_data_int__c'};
                
        TASKRAY__Project__c projectObject = new TASKRAY__Project__c(); // This takes all available fields from the required object. 	

		Schema.SObjectType objType = projectObject.getSObjectType(); 

		Map<String, Schema.SObjectField> M = Schema.SObjectType.TASKRAY__Project__c.fields.getMap(); 
		
        // start loop
        for(TASKRAY__Project__c project : newProjects)
        {
            for (String str : M.keyset())
                {	 
                    try 
                        {
                            if( roles.contains(str) && project.get(str) != null )
                              {
                                system.debug('Inside If ' + str + ' ' + M.get(str).getDescribe().getLabel() ); 
                                // here goes more code
                                TASKRAY__trContributor__c teamMember = new TASKRAY__trContributor__c();
                                 
                                teamMember.TASKRAY__User__c = (Id)project.get(str); //Value of the Field//
                                System.debug('The user is ' + teamMember.TASKRAY__User__c);
                                teamMember.TASKRAY__Project__c = project.Id;
                                System.debug('The project is is ' + teamMember.TASKRAY__Project__c);
                                if(!NewteamMembersIds.contains(teamMember.TASKRAY__User__c))
                                    {
                                        NewteamMembersIds.add(teamMember.TASKRAY__User__c);
                                        TeamMemberListToUpdate.add(teamMember);
                                    } 
                              } 
                        } 
                
                    catch (Exception e) 
                        { 
                            System.debug('Error: ' + e); 
                        } 
                }
        }
        //end of loop
            try {
    		insert TeamMemberListToUpdate;
        }
        catch(Exception e){
            System.debug('Error: ' + e);
        }

    }

}