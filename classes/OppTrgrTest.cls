@isTest
private class OppTrgrTest {

    public static testmethod void unitTest(){
        //Account Record
        Account acct = new Account(Name = 'Account Test ');
        insert acct;
        
        //Opportunity Record
        Opportunity opp = new Opportunity(
            Name = 'testopp', 
            CloseDate = date.today(), 
            AccountId = acct.Id, 
            StageName = 'Qualification/Prospecting'
        );
        insert opp; 
        
    }
}