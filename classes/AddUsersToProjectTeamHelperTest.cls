@isTest
public class AddUsersToProjectTeamHelperTest {

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
        
        List<TASKRAY__Project__c> projectList = new List<TASKRAY__Project__c>();
        
        for(integer i = 0 ; i < 200; i++)
        {
            TASKRAY__Project__c project = new TASKRAY__Project__c();
                                                                   project.Name='Project From Apex'+i;
                                                                   //Owner
                                                                   project.OwnerId=u1.Id;
                                                                   project.RecordTypeId= rtype.Id;
                                                                   //user1
                                                                   project.Data_Integrity_TL__c=u2.Id;
        	projectList.add(project);	
        }
        insert projectList;
    }
    
    static testmethod void updateProjectTaskTeamTest()
    {
        //Arrange
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
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
        
        TASKRAY__Project__c returnedProject = [SELECT Id FROM  TASKRAY__Project__c WHERE Name='Project From Apex0' LIMIT 1]; 
        //user1
        returnedProject.Client_Services_Rep__c= u1.Id;
        //user2
        returnedProject.Head_of_Clinical_Operations_and_Data_Int__c=u2.Id;
        
        //Act
        update returnedProject;
        
        //Assert
        List<TASKRAY__trContributor__c> teamMembers = [SELECT Id, TASKRAY__User__c FROM TASKRAY__trContributor__c WHERE TASKRAY__Project__c =:returnedProject.Id];
        Set<Id> uniqueTeamMember = new Set<Id>();
        for(TASKRAY__trContributor__c member : teamMembers)
        {
            uniqueTeamMember.add(member.TASKRAY__User__c );
        }
        System.assert(uniqueTeamMember.contains(returnedProject.Head_of_Clinical_Operations_and_Data_Int__c));
        System.assert(uniqueTeamMember.contains(returnedProject.Client_Services_Rep__c));

    }
    
    static testmethod void InsertProjectTaskTeamTest()
    {
        //Arrange
        
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
        
        
        
        TASKRAY__Project__c newProject = new TASKRAY__Project__c();
                                                               newProject.Name='Project2';
           													   //Owner
           													   newProject.OwnerId=u1.Id;
                                                               newProject.RecordTypeId= rtype.Id;
           													   //user1
       														   newProject.Client_Services_Rep__c= u2.Id;
           													   //user2
       														   newProject.Head_of_Clinical_Operations_and_Data_Int__c=u3.Id;
           													   //user3
       														   newProject.Operations_Associate__c=u4.Id;
        //Act
        insert newProject;
        
        //Assert
        TASKRAY__Project__c createdProject = [SELECT Id, Head_of_Clinical_Operations_and_Data_Int__c, Client_Services_Rep__c, Operations_Associate__c FROM TASKRAY__Project__c WHERE Name='Project2' AND RecordTypeId=:rtype.Id LIMIT 1];     
        List<TASKRAY__trContributor__c> teamMembers = [SELECT Id, TASKRAY__User__c FROM TASKRAY__trContributor__c WHERE TASKRAY__Project__c =:createdProject.Id];
        Set<Id> uniqueTeamMember = new Set<Id>();
        for(TASKRAY__trContributor__c member : teamMembers)
        {
            uniqueTeamMember.add(member.TASKRAY__User__c );
        }
        System.debug('returned ids: ' + uniqueTeamMember);
        System.debug('returned ids: ' + teamMembers);
        System.assert(uniqueTeamMember.contains(createdProject.Head_of_Clinical_Operations_and_Data_Int__c));
        System.debug('Head_of_Clinical_Operations_and_Data_Int__c ok');
        System.assert(uniqueTeamMember.contains(createdProject.Client_Services_Rep__c));
        System.debug('Client_Services_Rep__c ok');
        System.assert(uniqueTeamMember.contains(createdProject.Operations_Associate__c));
        System.debug('Data_Integrity_TL__c ok');
        
    }
    
    
    static testmethod void updateListProjectTaskTeamTest()
    {
        //Arrange
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
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
        
        List<TASKRAY__Project__c> returnedProjects = [SELECT Id FROM  TASKRAY__Project__c WHERE Name LIKE 'Project From Apex']; 
        List<Id> projectIds = new List<Id>();
        
        for(TASKRAY__Project__c prj : returnedProjects)
        {	//user1
            prj.Client_Services_Rep__c= u1.Id;
            //user2
            prj.Head_of_Clinical_Operations_and_Data_Int__c=u2.Id;
            projectIds.add(prj.Id);
        }
        //Act
        update returnedProjects;
        
        //Assert
        List<TASKRAY__trContributor__c> teamMembers = [SELECT Id, TASKRAY__User__c FROM TASKRAY__trContributor__c WHERE TASKRAY__Project__c IN :projectIds];
        Set<Id> uniqueTeamMember = new Set<Id>();
        for(TASKRAY__trContributor__c member : teamMembers)
        {
            uniqueTeamMember.add(member.TASKRAY__User__c );
        }
        for(TASKRAY__Project__c prj : returnedProjects)
        {
            System.assert(uniqueTeamMember.contains(prj.Head_of_Clinical_Operations_and_Data_Int__c));
            System.assert(uniqueTeamMember.contains(prj.Client_Services_Rep__c));
        }            
    }
    
    
    static testmethod void InsertListProjectTaskTeamTest()
    {
        //Arrange
        
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

		randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u6 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        insert u6;
        
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u7 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        insert u7;        

		randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;
        User u8 = new User(Alias = uniqueName.substring(18, 23),Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',Username = uniqueName + '@test' + orgId + '.org');
        insert u8;
        
        List<TASKRAY__Project__c> newProjects = new List<TASKRAY__Project__c>();
        
        for (integer i=0; i<100; i++)
        {
            TASKRAY__Project__c newProject = new TASKRAY__Project__c();
                                                               newProject.Name='Project2'+i;
           													   //Owner
           													   newProject.OwnerId=u1.Id;
                                                               newProject.RecordTypeId= rtype.Id;
           													   //user1
       														   newProject.Client_Services_Rep__c= u2.Id;
           													   //user2
       														   newProject.Head_of_Clinical_Operations_and_Data_Int__c=u3.Id;
           													   //user3
       														   newProject.Operations_Associate__c=u4.Id;
        	newProjects.add(newProject);
        }
        for (integer i=100; i<200; i++)
        {
            TASKRAY__Project__c newProject = new TASKRAY__Project__c();
                                                               newProject.Name='Project2'+i;
           													   //Owner
           													   newProject.OwnerId=u5.Id;
                                                               newProject.RecordTypeId= rtype.Id;
           													   //user1
       														   newProject.Client_Services_Rep__c= u6.Id;
           													   //user2
       														   newProject.Head_of_Clinical_Operations_and_Data_Int__c=u7.Id;
           													   //user3
       														   newProject.Operations_Associate__c=u8.Id;
        	newProjects.add(newProject);
        }
        //Act
        insert newProjects;
        
        //Assert
        List<Id> projectIds = new List<Id>();
        List<TASKRAY__Project__c> createdProjects = [SELECT Id, Head_of_Clinical_Operations_and_Data_Int__c, Client_Services_Rep__c, Operations_Associate__c FROM TASKRAY__Project__c WHERE Name LIKE 'Project2' AND RecordTypeId=:rtype.Id];     
        for(TASKRAY__Project__c prj : createdProjects)
        {
            projectIds.add(prj.Id);
        }
        List<TASKRAY__trContributor__c> teamMembers = [SELECT Id, TASKRAY__User__c FROM TASKRAY__trContributor__c WHERE TASKRAY__Project__c IN :projectIds];
        Set<Id> uniqueTeamMember = new Set<Id>();
        for(TASKRAY__trContributor__c member : teamMembers)
        {
            uniqueTeamMember.add(member.TASKRAY__User__c );
        }
        System.debug('returned ids: ' + uniqueTeamMember);
        System.debug('returned ids: ' + teamMembers);
        for(TASKRAY__Project__c prj : createdProjects)
        {
           	System.assert(uniqueTeamMember.contains(prj.Head_of_Clinical_Operations_and_Data_Int__c));
        	System.debug('Consulting_Services_Rep__c ok');
        	System.assert(uniqueTeamMember.contains(prj.Client_Services_Rep__c));
        	System.debug('Client_Services_Rep__c ok');
        	System.assert(uniqueTeamMember.contains(prj.Operations_Associate__c));
        	System.debug('Data_Integrity_TL__c ok'); 
        }
    }

    
    
    
    
    
    
    
    
    
    
}