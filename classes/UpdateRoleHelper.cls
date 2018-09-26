public class UpdateRoleHelper {
    
    public UpdateRoleHelper(){}
    
    public static void updateRole(List<TASKRAY__Project_Task__c> oldValues, List<TASKRAY__Project_Task__c> newValues )
    {
        
        
        List<TASKRAY__Project_Task__c> tasksToUpdate = new List<TASKRAY__Project_Task__c>();
    
            // The value of the role
            String assignedRole ;
        
        	// The name of the role
        	
        	String roleName;
            
            // The value of project field to be querried
            String projectField;
            
            // Holds the id of projects
            List<id> projectIds = new List<id>();
            
            // Get the tasks and the related subproject
            for(TASKRAY__Project_Task__c task: newValues)
                {
                    projectIds.add(task.TASKRAY__Project__c);
                    tasksToUpdate.add(task);
                }
        
        	
			//query related projects
						
        	List<TASKRAY__Project__c> relatedProjectList = [SELECT client_services_rep__c, consulting_services_lead__c,Learning_Development__c, 
                                                            consulting_services_rep__c, associate_dir_library_operations__c, 
                                                            librarian_lead__c, operations_associate__c, gh_qmi__c, 
                                                            meth_rep_1__c, meth_rep_2__c, extraction_tl__c, 
                                                            head_of_analytics__c, vp_client_services__c, principal_scientist__c,
                                                            vp_consulting_services__c, cmo__c, data_integrity_tl__c, ontology_lead__c,
                                                            Ontology_Manager__c, Head_of_Clinical_Operations_and_Data_Int__c
                                                            FROM TASKRAY__Project__c WHERE Id IN :projectIds] ; 
        	//For loop
        	for(Integer i=0 ;i <newValues.size(); i++)
            {       
        	//If The new role is Other or task is Completed or the assigned role is empty:  Don't run the trigger
            if(newValues[i].Assigned_Role__c == 'Other (Not on Project Team)' || newValues[i].TASKRAY__trCompleted__c == true || newValues[i].Assigned_Role__c == null)
            {
                return;
            }  
            
            // If there is no change in the role
            if( oldValues != null && (oldValues[i].Assigned_Role__c == newValues[i].Assigned_Role__c))
            {
                return;
            }
                        
            // If the trigger is update
            if(oldValues != null)
                {
                    System.debug('before true ');
                    System.debug( newValues[i].Assigned_Role__c);
                    System.debug( oldValues[i].Assigned_Role__c);
                    System.debug('after true ');
                    // If the assigned Role is changed, assign its value to assignRole
                    if((oldValues[i].Assigned_Role__c != newValues[i].Assigned_Role__c))
                        {
                            System.debug('This should not be printed if the role is other ' + newValues[i].Assigned_Role__c);
                            assignedRole = String.valueOf(newValues[i].Assigned_Role__c);
                            System.debug('The value of the assigned role: ' + assignedRole);
                        }
                    else
                    {
                    	return;
                    }
                }
        	// Trigger is Insert
        	else{
                	System.debug('inside else ');
            		assignedRole = String.valueOf(newValues[i].Assigned_Role__c);
                	System.debug('assigned role ' + assignedRole);
        		}
                    
            //get the api name for the label using the assigned role string
            Map<String, Schema.SObjectField> projectFields = Schema.SObjectType.TASKRAY__Project__c.fields.getMap();
            
            for(String key: projectFields.KeySet())
                {
                    system.debug('the assigned role: ' + assignedRole );
                    system.debug('the label:  ' + projectFields.get(key).getDescribe().getLabel());
                    System.debug('The Key is : ' + key);
                    if(assignedRole == projectFields.get(key).getDescribe().getLabel())
                    {
                        projectField = key;
                        
                        roleName = projectFields.get(key).getDescribe().getLabel();
                        //Exit loop if we find the api name
                        break; 
                    }
                }
            
            for(TASKRAY__Project__c pr : relatedProjectList)
                {
                    if(tasksToUpdate[i].TASKRAY__Project__c == pr.Id )
                    {
                        id idtoUpdate2 = (Id)pr.Get(projectField);
                            if(idtoUpdate2 == null)
                            {
                               tasksToUpdate[i].addError('The role \'' + roleName + '\' you have chosen is not assigned to a user on the sub-project. Please assign it in Project Team section of the sub-project.');
                 
                            }
                        tasksToUpdate[i].OwnerId = idtoUpdate2;
                    }
                }   
            }
        for(TASKRAY__Project_Task__c tsks : tasksToUpdate)
        {
        	System.debug('the list of tasks' + tsks);
        }	
    }

}