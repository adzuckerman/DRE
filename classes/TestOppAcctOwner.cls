@isTest
private class TestOppAcctOwner {
    
    @isTest static void TestDiffOppOwner (){
        //Get system admin profiles
        List<Profile> adminProfileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        //Get lead/standard user profiles
        List<Profile> leadProfileList = [SELECT Id FROM Profile WHERE Name = 'Leads'];
        
     
        //Get user list with admin/system admintrator profile
        List<User> adminUserList = [SELECT Id FROM User WHERE ProfileId = :adminProfileList[0].Id AND isActive= true];
        
        //Get user list with lead/standard user profile
        List<User> leadUserList = [SELECT Id FROM User WHERE ProfileId = :leadProfileList[0].Id AND isActive = true];
        
        //Create account and opportunities with different owners
        Account acct = new Account(Name='Test Account',
                                  OwnerId = adminUserList[0].Id);
        insert acct;
        Opportunity opp = new Opportunity(Name='Test Opp',
                                 Amount = 10000,
                                 CloseDate = date.today(),
                                 StageName = 'Qualification/Prospecting',
                                 AccountId = acct.id,
                                 OwnerId = leadUserList[0].Id);
        insert opp;
        List<Opportunity> insertedOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id];
        system.assert(insertedOpp[0].OwnerId == acct.OwnerId);
    }
}