@isTest
public class UpdateRoleCheckListHelperTest {
    
     static testMethod void updateRoleTest_WithUpdateTrigger()
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

		List<User> usersToInsert = new List<User>();
        User u2 = new User( Alias = 'newUser', Email='newuser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', Username = uniqueName + '@test' + orgId + '.org');
        usersToInsert.add(u2);
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000)); 
        uniqueName = orgId + dateString + randomInt;
        User u1 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        usersToInsert.add(u1);
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u3 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        usersToInsert.add(u3);        

        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u4 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        usersToInsert.add(u4);
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u5 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        usersToInsert.add(u5);
		insert usersToInsert;
        
		TASKRAY__Project__c project = new TASKRAY__Project__c();
		project.Name='ProjectFromApex';
		project.OwnerId= u1.Id;//Owner
		project.RecordTypeId=rtype.Id;
		project.Client_Services_Rep__c= u2.Id;//User1
		project.Learning_Development__c= u3.Id;//User2
		project.Meth_Rep_1__c= u4.Id;//User3                                                 
		insert project; 

		TASKRAY__Project_Task__c ptask = new TASKRAY__Project_Task__c(Name = 'Task To update',
                                                                     TASKRAY__Project__c= project.Id,
                                                                     Assigned_Role__c = 'Learning & Development');  
		insert ptask;
     
		System.Test.startTest();

			TASKRAY__trChecklistItem__c checkListItem = new TASKRAY__trChecklistItem__c( Name = 'CheckMate2',
																						TASKRAY__Project_Task__c = ptask.Id,
																						Assigned_Role__c = 'Methodologist'
																					);
			insert checkListItem;

		System.Test.stopTest();

		checkListItem = [Select Id, TASKRAY__trOwner__c from TASKRAY__trChecklistItem__c Where ID =: checkListItem.Id];
		System.assert(checkListItem.TASKRAY__trOwner__c != null);
	}
    
}