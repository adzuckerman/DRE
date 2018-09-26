trigger OppAcctOwner on Opportunity (before insert) {
    //Define set of accounts in the trigger context.
    Set<Id> acctIDSet = new Set<Id>();
    
    //Loop through opportunities in the trigger context populating acctIDSet
    for (Opportunity opp : Trigger.New) {
        acctIDSet.add(opp.AccountID);
    }
    
    //Define account map based on set of acctIDSet
    Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN : acctIDSet]);
    
    //Loop through opptunities in the trigger context checking mismatched owners. If mismatch, set equal. 
    for (Opportunity opp : Trigger.New) {
        if (opp.OwnerId != acctMap.get(opp.AccountId).OwnerId) {
            opp.OwnerId = acctMap.get(opp.AccountId).OwnerId;
        }
    }
}