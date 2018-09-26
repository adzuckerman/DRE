trigger AddUsersToProjectTeam on TASKRAY__Project__c ( after insert, before update) 
{
 /*   
    TASKRAY__Project__c NewProject = trigger.new[0];
    List<TASKRAY__trContributor__c> teamMembers = [SELECT Id, TASKRAY__Project__c, TASKRAY__User__c FROM TASKRAY__trContributor__c WHERE TASKRAY__Project__c = :NewProject.Id];
	Set<Id> NewteamMembersIds = new Set<Id>();
	List<TASKRAY__trContributor__c> TeamMemberListToUpdate = new List<TASKRAY__trContributor__c>();
	Set<Id> teamMemberIds = new Set<Id>();
    for (TASKRAY__trContributor__c member : teamMembers)
    	{
        	teamMemberIds.add(member.TASKRAY__User__c);
    	}
    
    if(Trigger.isUpdate)
    {   
		TASKRAY__Project__c OldProject = trigger.old[0];
        
		Schema.SObjectType objType = NewProject.getSObjectType(); 

		Map<String, Schema.SObjectField> M = Schema.SObjectType.TASKRAY__Project__c.fields.getMap(); 
	
		for (String str : M.keyset())
	 		{	 
				try 
					{	 
						if(NewProject.get(str) != OldProject.get(str) && NewProject.get(str) !=null )
						  {
							system.debug('******The value has changed!!!! ' + str + ' ' + M.get(str).getDescribe().getLabel() ); 
							TASKRAY__trContributor__c teamMember = new TASKRAY__trContributor__c();
							teamMember.TASKRAY__User__c = (Id)NewProject.get(str); //Value of the Field//
                            System.debug('The user is ' + teamMember.TASKRAY__User__c);
							teamMember.TASKRAY__Project__c = NewProject.Id;
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
        try {
    		insert TeamMemberListToUpdate;
        }
        catch(Exception e){
            System.debug('Error: ' + e);
        }
    }
    
    
    If(Trigger.isInsert)
    {
		//Setup the list of roles
        Set<String> roles = new Set<String>{
           	'Client_services_rep__c', 'ronsulting_services_lead__c', 'consulting_services_rep__c', 
            'associate_dir_library_operations__c', 'librarian_lead__c', 'operations_associate__c', 'gh_qmi__c',
            'meth_rep_1__c', 'meth_rep_2__c', 'meth_rep_3__c', 'extraction_tl__c', 'head_of_analytics__c',
            'vp_client_services__c', 'principal_scientist__c'};
                
        TASKRAY__Project__c projectObject = new TASKRAY__Project__c(); // This takes all available fields from the required object. 	

		Schema.SObjectType objType = projectObject.getSObjectType(); 

		Map<String, Schema.SObjectField> M = Schema.SObjectType.TASKRAY__Project__c.fields.getMap(); 
	
		for (String str : M.keyset())
	 		{	 
				try 
					{
						if( roles.contains(str) && NewProject.get(str) != null )
						  {
							system.debug('Inside If ' + str + ' ' + M.get(str).getDescribe().getLabel() ); 
							// here goes more code
							TASKRAY__trContributor__c teamMember = new TASKRAY__trContributor__c();
                             
							teamMember.TASKRAY__User__c = (Id)NewProject.get(str); //Value of the Field//
                            System.debug('The user is ' + teamMember.TASKRAY__User__c);
							teamMember.TASKRAY__Project__c = NewProject.Id;
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
            try {
    		insert TeamMemberListToUpdate;
        }
        catch(Exception e){
            System.debug('Error: ' + e);
        }
    }
	
    
 */
    
    
    
    if(Trigger.isUpdate)
        {
            AddUsersToProjectTeamHelper.updateProjectTaskTeam(Trigger.Old, Trigger.New);
        }
    if(Trigger.isInsert)
    {
    	AddUsersToProjectTeamHelper.insertProjectCreateTaskTeam(Trigger.New);
    }
	
}