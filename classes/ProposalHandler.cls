public class ProposalHandler {
	
    public void onAfterInsert(list<Quote> newList , map<id, Quote> newMap) {
        
        if(!System.isFuture()) {
        	BreakSyncQuotes(newMap.keySet());    
        }
    }
    
    @future
	public static void BreakSyncQuotes(Set<Id> qIds) {
        List<Opportunity> opps = new List<Opportunity>();
        List<Quote> quotes = [SELECT Id, OpportunityId, Status FROM Quote WHERE Id IN: qIds AND Status = 'Approved' AND isSyncing = true];
        
        // Loops through the List of approved Quotes and gets the OpportunityId.
        for (Quote q : quotes) {
            if (string.isNotEmpty(q.OpportunityId)) {
                Opportunity opp = new Opportunity(Id = q.OpportunityId);
                opp.Proposal_Approved__c = true;
                opp.SyncedQuoteId  = null;
                
                opps.add(opp);
            }
        }
        
        if(!opps.isEmpty()) {
            update opps;
        }
    }
}