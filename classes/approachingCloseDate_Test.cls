@isTest
private class approachingCloseDate_Test {

    static testmethod void test() {
        
        Account acct = new Account (Name = 'Test Account');
       	insert acct;
        List <Opportunity> batchOpps = new List<Opportunity>();
        for (Integer i=1; i<=7; i++) {
            Opportunity opp = new Opportunity (
            	Name='Test Opp ' + i,
                CloseDate = date.today() + i,
                AccountId = acct.Id,
                StageName = 'Qualification/Prospecting');
            batchOpps.add(opp);
        }
        insert batchOpps;
        
        test.startTest();
        approachingCloseDate ACD = new approachingCloseDate();
        database.executeBatch(ACD);
        test.stopTest();
    }
}