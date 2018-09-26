@IsTest
private class TriggerUtil_ChecklistItemTest {

    @IsTest
    static void testRollupTaskDate() {
        
        //Cloud Mine Consulting---12/21/17
        //Standard User does not have the Taskray Permission Sets and is causing test failures
        //not sure why Standard User is being used
		//Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Ops / Meth / Production Lead'];        

//        Id roleId = [select Id from UserRole where Name='Other (Not on Project Team)'].Id;
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
         
        User u = new User(Alias = uniqueName.substring(18, 23),
                          Email = uniqueName + '@test' + orgId + '.org',
                          EmailEncodingKey='UTF-8',
                          LastName='Testing',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          Username = uniqueName + '@test' + orgId + '.org' /*, UserRoleId=roleId */);

        insert u;
        

        System.runAs(u) {
			Account a = new Account(Name='test account');
    	    insert a;
            Id tpRecId = Schema.SObjectType.TASKRAY__Project__c.getRecordTypeInfosByName().get('Sub-Project').getRecordTypeId();
    
            TASKRAY__Project__c taskP = new TASKRAY__Project__c(TASKRAY__trAccount__c=a.Id, RecordTypeId=tpRecId);
            insert taskp;
            
            TASKRAY__Project_Task__c pt = new TASKRAY__Project_Task__c(TASKRAY__trAccount__c=a.Id, TASKRAY__Project__c=taskP.Id, Assigned_Role__c = 'Other (Not on Project Team)');
            insert pt;
            
			TASKRAY__trChecklistGroup__c taskG = new 	TASKRAY__trChecklistGroup__c(Name='Standard');
			insert taskG;
            
            TASKRAY__trChecklistItem__c tc = new TASKRAY__trChecklistItem__c(Assigned_Date__c = System.today() - 1, TASKRAY__Project_Task__c=pt.id, TASKRAY__trOwner__c=u.Id, Assigned_Role__c='Other (Not on Project Team)', TASKRAY__trChecklistGroup__c=taskG.Id);
            insert tc;          
            
            //simulated a database update with two separate objects as this utility function was commented in the trigger
            //bellow code is the base functionality
            /*tc.Assigned_Date__c = System.today(); 
            tc.Completion_Date__c = System.today()+10;
            update tc;*/
            
            //the code bellow should be deleted for correct testing if the TriggerUtil_ChecklistItem is used in the trigger            
            list<TASKRAY__trChecklistItem__c> tcListOld = new list<TASKRAY__trChecklistItem__c>();
            tcListOld.add(tc);
            
            TASKRAY__trChecklistItem__c tc1 = new TASKRAY__trChecklistItem__c(Assigned_Date__c = System.today(), TASKRAY__Project_Task__c=pt.id, TASKRAY__trOwner__c=u.Id, Assigned_Role__c='Other (Not on Project Team)', TASKRAY__trChecklistGroup__c=taskG.Id);
            insert tc1;
            list<TASKRAY__trChecklistItem__c> tcListNew = new list<TASKRAY__trChecklistItem__c>();
            tcListNew.add(tc1);
            
            TriggerUtil_ChecklistItem.rollupTaskDate(tcListOld, tcListNew);
            //end of code that should be deleted
        }
        

        
    }
    
    
}