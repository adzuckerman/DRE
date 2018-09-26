public class UpdateRoleCheckListHelper {
    public UpdateRoleCheckListHelper(){}
    
    public static void updateRole(List<TASKRAY__trChecklistItem__c> oldValues, List<TASKRAY__trChecklistItem__c> newValues )
    {
        
        List<TASKRAY__trChecklistItem__c> checkListToUpdate = new List<TASKRAY__trChecklistItem__c>();
        
        // The value of the role
            String assignedRole ;
        
        // The name of the role
        	
        	String roleName;
            
        // The value of project field to be querried
            String projectField;
            
        // Holds the id of projects
            List<id> projectIds = new List<id>();
        
        // Get the tasks and the related subproject
        for(TASKRAY__trChecklistItem__c checkList: newValues)
        	{
            	projectIds.add(checkList.TASKRAY__trProjectId__c);
                checkListToUpdate.add(checkList);
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
        		if(newValues[i].Assigned_Role__c == 'Other (Not on Project Team)' || newValues[i].TASKRAY__Completed__c == true || newValues[i].Assigned_Role__c == null)
                {
                    return;
                }
            
                if(oldValues != null && (oldValues[i].Assigned_Role__c == newValues[i].Assigned_Role__c))
                {
                    return;
                }
    
                // If the trigger is update
                if(oldValues != null)
                    {
                        // If the assigned Role is changed, assign its value to assignedRole
                        if(oldValues[i].Assigned_Role__c != newValues[i].Assigned_Role__c)
                            {
                                assignedRole = String.valueOf(newValues[i].Assigned_Role__c);
                            }
                        // The assigned role did not change
                        else
                        {
                            return;
                        }
                    }
                // Trigger is Insert
                else{
                        assignedRole = String.valueOf(newValues[i].Assigned_Role__c);
                    }
                        
                //get the api name for the label using the assigned role string
                Map<String, Schema.SObjectField> projectFields = Schema.SObjectType.TASKRAY__Project__c.fields.getMap();
                
                for(String key: projectFields.KeySet())
                    {
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
                    if(checkListToUpdate[i].TASKRAY__trProjectId__c == pr.Id )
                    {
                        id idtoUpdate2 = (Id)pr.Get(projectField);
                            if(idtoUpdate2 == null)
                            {
                               checkListToUpdate[i].addError('The role \'' + roleName + '\' you have chosen is not assigned to a user on the sub-project. Please assign it in Project Team section of the sub-project.');
                 
                            }
                        checkListToUpdate[i].TASKRAY__trOwner__c = idtoUpdate2;
                    }
                }   
            }   
    }


}