@isTest

public class UpdateRoleHelperTest {
    
    
    //Arrange
    
    @testSetup
    static void testData()
    {
        
        
		String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        RecordType rtype = [Select Name, Id From RecordType 
                  where sObjectType='TASKRAY__Project__c' and isActive=true AND RecordType.Name = 'Sub-Project' LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
		User u2 = new User( Alias = 'newUser', Email='newuser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', Username = uniqueName + '@test' + orgId + '.org');
        insert u2;
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000)); 
        uniqueName = orgId + dateString + randomInt;
        User u1 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        insert u1;
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u3 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        insert u3;        

		randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u4 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        insert u4;
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u5 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        insert u5;
        
       TASKRAY__Project__c project = new TASKRAY__Project__c();
                                                               project.Name='Project From Apex';
           													   //David Avila
                                                               project.OwnerId= u1.Id;
       														   project.RecordTypeId=rtype.Id;
           													   //user1
       														   project.Client_Services_Rep__c= u3.Id;
           													   //user2
       														   project.Learning_Development__c=u4.Id;
           													   //user3
       														   project.Meth_Rep_1__c= u2.Id;
       														          
      insert project; 
      TASKRAY__Project__c projectReturned = [SELECT Id, Learning_Development__c FROM TASKRAY__Project__c WHERE Name = 'Project From Apex' LIMIT 1];
      
     TASKRAY__Project_Task__c task = new TASKRAY__Project_Task__c(   Name = 'Task To update',
            														 TASKRAY__Project__c= projectReturned.Id,
                                                                     Assigned_Role__c = 'Learning & Development',
                                                                 	 OwnerId = u5.Id);  
     insert task;
     
     //List of projects and tasks
     List<TASKRAY__Project__c> projectList = new List<TASKRAY__Project__c>();
     for(Integer i =0; i< 200; i++)
         {
             TASKRAY__Project__c proj = new TASKRAY__Project__c();
                                                                   proj.Name='Project From Apex'+i;
                                                                   //David Avila
                                                                   proj.OwnerId= u1.Id;
                                                                   proj.RecordTypeId=rtype.Id;
                                                                   //user1
                                                                   proj.Client_Services_Rep__c= u3.Id;
                                                                   //user2
                                                                   proj.Ontology_Manager__c=u4.Id;
                                                                   //user3
                                                                   proj.Data_Integrity_TL__c= u2.Id;
            projectList.add(proj); 
         }
    
     insert projectList;
     List<TASKRAY__Project__c> ListProjReturned = [SELECT Id, Client_Services_Rep__c FROM TASKRAY__Project__c WHERE Name LIKE 'Project From Apex'];
	
     List<TASKRAY__Project_Task__c> taskList = new List<TASKRAY__Project_Task__c>();
     for(Integer i =0; i < 200; i++)
     {
         for(TASKRAY__Project__c pr : ListProjReturned)
         {   
             TASKRAY__Project_Task__c tsk = new TASKRAY__Project_Task__c(   Name = 'Task To update'+ i,
                                                                         TASKRAY__Project__c= pr.Id,
                                                                         Assigned_Role__c = 'Associate Account Director',
                                                                         OwnerId = u5.Id);
             taskList.add(tsk);
        }
     }
     insert taskList;
        
    }
	
    
    static testmethod void updateRoleTestWithInsertTrigger()
    { 
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
		User taskOwner = new User( Alias = 'newUser', Email='newuser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', Username = uniqueName + '@test' + orgId + '.org');
        insert taskOwner;
        
		TASKRAY__Project__c project = [SELECT Id, Learning_Development__c FROM TASKRAY__Project__c WHERE RecordType.Name='Sub-Project' AND Name = 'Project From Apex' LIMIT 1]  ;
        
		TASKRAY__Project_Task__c task = new TASKRAY__Project_Task__c(Name = 'Task From Apex',
            														 TASKRAY__Project__c= project.Id,
                                                                   Assigned_Role__c = 'Learning & Development',
                                                                    OwnerId= taskOwner.Id); 
        insert task;
        
    //Assert
    TASKRAY__Project_Task__c insertedTask = [SELECT Id, OwnerId FROM TASKRAY__Project_Task__c WHERE Name='Task From Apex'];
    System.assertEquals(insertedTask.OwnerId, project.Learning_Development__c );
    }
    
    static testMethod void updateRoleTest_WithUpdateTrigger()
    {
		    //Arrange
            TASKRAY__Project__c project = [SELECT Id, Client_Services_Rep__c FROM TASKRAY__Project__c WHERE Name = 'Project From Apex' LIMIT 1];
            TASKRAY__Project_Task__c taskToUpdate = [SELECT Id, OwnerId FROM TASKRAY__Project_Task__c WHERE Name='Task To update' LIMIT 1];
            
            taskToUpdate.Assigned_Role__c='Associate Account Director';
            
            //Act
            update taskToUpdate;
            
            //Assert
            TASKRAY__Project_Task__c createdTask = [SELECT Id, OwnerId FROM TASKRAY__Project_Task__c WHERE Name='Task To update' LIMIT 1];
            System.assertEquals(createdTask.OwnerId, project.Client_Services_Rep__c );
    }
    
    static testMethod void updateRoleTest_WithNullRole_ShouldDisplayErrorMessage(){
     	TASKRAY__Project_Task__c taskToUpdate = [SELECT Id, OwnerId FROM TASKRAY__Project_Task__c WHERE Name='Task To update' LIMIT 1];
		taskToUpdate.Assigned_Role__c = 'Sr. Clinical Data Specialist';
        try
        {
        	update taskToUpdate;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('you have chosen is not assigned to a user on the sub-project. Please assign it in Project Team section of the sub-project.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
    
    static testmethod void updateListRoleTestWithInsertTrigger()
    { 
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
		User taskOwner = new User( Alias = 'newUser', Email='newuser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', Username = uniqueName + '@test' + orgId + '.org');
        insert taskOwner;
        
		List<TASKRAY__Project__c> projects = [SELECT Id, Meth_Rep_1__c FROM TASKRAY__Project__c WHERE RecordType.Name='Sub-Project' AND Name LIKE 'Project From Apex' ORDER BY Id]  ;
        System.debug('the list of projects' + projects);
        List<TASKRAY__Project_Task__c> tasks = new List<TASKRAY__Project_Task__c>();
        
        for(TASKRAY__Project__c pr : projects)
        {
            TASKRAY__Project_Task__c task = new TASKRAY__Project_Task__c(Name = 'Task From Apex',
                                                                         TASKRAY__Project__c= pr.Id,
                                                                         Assigned_Role__c = 'Methodologist',
                                                                         OwnerId= taskOwner.Id); 
            tasks.add(task);
            
        }
        
        insert tasks;
        
    //Assert
    List<TASKRAY__Project_Task__c> insertedTasks = [SELECT Id, OwnerId FROM TASKRAY__Project_Task__c WHERE Name LIKE 'Task From Apex' ORDER BY TASKRAY__Project__c];
        for(TASKRAY__Project_Task__c tsk : insertedTasks)
        {
            for(integer i =0; i<projects.size(); i++)
            System.assertEquals(tsk.OwnerId, projects[i].Meth_Rep_1__c);
        }
    }
    
    static testMethod void updateListRoleTest_WithUpdateTrigger()
    {
		    //Arrange
            
            List<TASKRAY__Project_Task__c> tasksToUpdate = [SELECT Id, OwnerId FROM TASKRAY__Project_Task__c WHERE Name LIKE'Task To update'];
            
        	for(Integer i=0 ; i < tasksToUpdate.size()/3 ; i++)
            {
            	tasksToUpdate[i].Assigned_Role__c='Methodologist';
            }
        	for(Integer i=tasksToUpdate.size()/3 ; i < 2*tasksToUpdate.size()/3 ; i++)
            {
            	tasksToUpdate[i].Assigned_Role__c='Learning & Development';
            }
        	for(Integer i= 2*tasksToUpdate.size()/3 ; i < tasksToUpdate.size() ; i++)
            {
            	tasksToUpdate[i].Assigned_Role__c='Associate Account Director';
            }
            //Act
            update tasksToUpdate;
            
            //Assert
            List<TASKRAY__Project_Task__c> updatedTasks = [SELECT Id,TASKRAY__Project__c, OwnerId FROM TASKRAY__Project_Task__c WHERE Name LIKE 'Task To update'];
            List<Id> relatedProjects = new List<Id>();
        	for(TASKRAY__Project_Task__c tsk : updatedTasks)
                {
                    relatedProjects.add(tsk.TASKRAY__Project__c);
                }
        	
        	List<TASKRAY__Project__c> projectlist = [SELECT Id, Learning_Development__c, Client_Services_Rep__c, Meth_Rep_1__c  FROM TASKRAY__Project__c WHERE Name LIKE 'Project From Apex' AND Id IN :relatedProjects];
                for(TASKRAY__Project_Task__c tsk : updatedTasks)
                {
                    for(TASKRAY__Project__c pr : projectlist)
                    {
                        if (tsk.TASKRAY__Project__c == pr.Id)
                        	{
                                If(tsk.OwnerId ==  pr.Meth_Rep_1__c)
                        			System.assertEquals(tsk.OwnerId, pr.Meth_Rep_1__c );
                                If(tsk.OwnerId ==  pr.Client_Services_Rep__c)
                        			System.assertEquals(tsk.OwnerId, pr.Client_Services_Rep__c ); 
                                If(tsk.OwnerId ==  pr.Learning_Development__c)
                        			System.assertEquals(tsk.OwnerId, pr.Learning_Development__c );
                            }
                    }
                }
    }
}