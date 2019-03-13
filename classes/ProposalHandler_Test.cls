@isTest
public class ProposalHandler_Test {
	
    private static testmethod void testProposalHandlerApproval()
    {
        // Data Setup
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';       
        opp.CloseDate = (Date.today()).addDays(6);
		insert opp;
        
        Quote q = new Quote();
        q.Name = 'Test Quote';
        q.Status = 'Draft';
        q.OpportunityId = opp.Id;
        insert q;
        
        opp.SyncedQuoteId = q.Id;
        update opp;
        
        // Run Code
        Test.startTest();
        	
        	q.Status = 'Approved';
        	update q;
        
        Test.stopTest();
        
        //Verify results
        Opportunity o = [SELECT Id, Proposal_Approved__c, SyncedQuoteId FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, o.Proposal_Approved__c);
        System.assertEquals(null, o.SyncedQuoteId);
    }
}